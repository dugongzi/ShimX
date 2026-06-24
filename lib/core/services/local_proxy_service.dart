import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shim/core/services/anthropic_messages_stream_to_responses_transformer.dart';
import 'package:shim/core/services/app_log_service.dart';
import 'package:shim/core/services/chat_stream_to_responses_transformer.dart';
import 'package:shim/core/services/llm_protocol_converter.dart';
import 'package:shim/core/services/llm_protocol_proxy_spec.dart';

final localProxyRunningPortProvider = Provider<ValueNotifier<int?>>((ref) {
  final notifier = ValueNotifier<int?>(null);
  ref.onDispose(notifier.dispose);
  return notifier;
});

final localProxyServiceProvider = Provider<LocalProxyService>((ref) {
  final service = LocalProxyService();
  final runningPort = ref.read(localProxyRunningPortProvider);
  ref.onDispose(() {
    unawaited(service.stop());
    runningPort.value = null;
  });
  return service;
});

/// Hook 给 ProbeService:由 presentation 层启动时调用,把 success/failure 回调
/// 接到 LocalProxyService。这里不直接依赖 ProbeService,避免 core/services 反向依赖 features/。
typedef ProxyRequestFailureHook = void Function(String providerId, String reason);
typedef ProxyRequestSuccessHook = void Function(String providerId);
typedef ProxyRequestTimeoutHook = void Function(String providerId, int waitedMs);

void bindProxyRequestHooks({
  required LocalProxyService proxy,
  required ProxyRequestSuccessHook onSuccess,
  required ProxyRequestFailureHook onFailure,
  ProxyRequestTimeoutHook? onTimeout,
}) {
  proxy.onRequestSuccess = onSuccess;
  proxy.onRequestFailure = onFailure;
  proxy.onRequestTimeout = onTimeout;
}

/// Current forwarding target: real provider base URL, key, model override, and protocol.
/// Protocol JSON fields are deliberately isolated in llm_protocol_converter.dart.
class ProxyTarget {
  const ProxyTarget({
    required this.baseUrl,
    required this.apiKey,
    this.model,
    this.upstreamProtocol = 'responses',
    this.reasoningEffort,
    this.providerId,
  });

  final String baseUrl;
  final String apiKey;
  final String? model;
  final String upstreamProtocol;
  final String? reasoningEffort;

  /// 当前 target 对应的供应商 id。请求成败回调要用它定位是哪家。
  /// 旧的调用方没传 id 时为 null,这种情况下 success/failure 上报跳过。
  final String? providerId;
}

/// Claude 会话接续绑定:用户在 codex 侧栏点了一条 Claude 会话后,
/// proxy 会在每次转发前往 body.input 首部插一条 system message,
/// 指引上游 LLM 调 MCP 工具 read_claude_session 读取这条会话作为接续上下文。
///
/// 单一绑定:整个 LocalProxyService 全局只有一个绑定。
/// 由 JS 注入侧通过 bridge `/claude-bridge/bind` 触发,`/claude-bridge/unbind` 解绑。
class ClaudeBridgeBinding {
  const ClaudeBridgeBinding({
    required this.sessionId,
    required this.jsonlPath,
    this.title,
  });

  final String sessionId;
  final String jsonlPath;
  final String? title;
}

/// Reverse proxy for Codex local requests.
///
/// This class only owns HTTP proxy flow. Request protocol mapping belongs to
/// llm_protocol_converter.dart; upstream route/header decisions belong to
/// llm_protocol_proxy_spec.dart.
class LocalProxyService {
  static const _legacyClaudeBindingKey = '__legacy_claude_binding__';

  HttpServer? _server;
  StreamSubscription<HttpRequest>? _subscription;
  int? _port;

  ProxyTarget? _target;

  /// 每个 codex thread id 各自独立的 Claude 桥绑定。
  /// codex 侧栏每条会话对应一个 thread id(请求 header `session-id`),只对绑定过的
  /// thread 注入接续 prompt,其他 thread 不受影响。
  final Map<String, ClaudeBridgeBinding> _claudeBindings = {};

  ClaudeBridgeBinding? claudeBindingFor(String codexThreadId) =>
      _claudeBindings[codexThreadId] ??
      _claudeBindings[_legacyClaudeBindingKey];

  Map<String, ClaudeBridgeBinding> get claudeBindingsSnapshot =>
      Map.unmodifiable(_claudeBindings);

  void setClaudeBinding({
    required String codexThreadId,
    required ClaudeBridgeBinding binding,
  }) {
    _claudeBindings[codexThreadId] = binding;
    AppLogService.instance.info(
      'ClaudeBridge',
      '已绑定',
      details:
          'codexThread=$codexThreadId claudeSession=${binding.sessionId} jsonlPath=${binding.jsonlPath}',
    );
  }

  void clearClaudeBinding({required String codexThreadId}) {
    final removed = _claudeBindings.remove(codexThreadId) ??
        _claudeBindings.remove(_legacyClaudeBindingKey);
    if (removed != null) {
      AppLogService.instance.info(
        'ClaudeBridge',
        '已解绑',
        details: 'codexThread=$codexThreadId',
      );
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #setClaudeBinding &&
        invocation.positionalArguments.length == 1 &&
        invocation.positionalArguments.first is ClaudeBridgeBinding) {
      final binding = invocation.positionalArguments.first as ClaudeBridgeBinding;
      _claudeBindings[_legacyClaudeBindingKey] = binding;
      AppLogService.instance.warning(
        'ClaudeBridge',
        '兼容旧版绑定调用',
        details:
            '旧 handler 调用了 setClaudeBinding(binding),请刷新/重启 shim 以恢复按 codex thread 隔离。claudeSession=${binding.sessionId}',
      );
      return null;
    }
    return super.noSuchMethod(invocation);
  }

  /// 由 ProbeService 注入。每条上游请求结束时通知它结果。
  /// providerId 为空则跳过(老调用方未带 id)。
  void Function(String providerId)? onRequestSuccess;
  void Function(String providerId, String reason)? onRequestFailure;

  /// 慢响应专用回调。区别于 onRequestFailure:
  /// 慢响应一次就该考虑直接切换,不要按 streak 累计的常规流程走。
  void Function(String providerId, int waitedMs)? onRequestTimeout;

  /// 单条上游请求等待响应头的最大秒数。0 = 不启用慢响应检测,等无限久。
  Duration _slowTimeout = Duration.zero;

  void setSlowTimeout(Duration duration) {
    _slowTimeout = duration < Duration.zero ? Duration.zero : duration;
    AppLogService.instance.info(
      'Proxy',
      '慢响应阈值已设置',
      details: '${_slowTimeout.inSeconds}s (0=不启用)',
    );
  }

  bool get isRunning => _server != null;
  int? get port => _port;
  ProxyTarget? get target => _target;

  void setTarget(ProxyTarget target) {
    final prev = _target;
    _target = target;
    final unchanged = prev != null &&
        prev.baseUrl == target.baseUrl &&
        prev.model == target.model &&
        prev.upstreamProtocol == target.upstreamProtocol &&
        prev.providerId == target.providerId &&
        prev.reasoningEffort == target.reasoningEffort;
    if (unchanged) {
      AppLogService.instance.debug(
        'Proxy',
        '代理目标无变化',
        details:
            'baseUrl=${target.baseUrl}\nmodel=${target.model ?? "(passthrough)"}\nprotocol=${target.upstreamProtocol}\nprovider=${target.providerId ?? "(none)"}',
      );
      return;
    }
    AppLogService.instance.info(
      'Proxy',
      '已切换代理目标',
      details:
          'baseUrl=${target.baseUrl}\nmodel=${target.model ?? "(passthrough)"}\nprotocol=${target.upstreamProtocol}\nprovider=${target.providerId ?? "(none)"}\nprev=${prev?.baseUrl ?? "(none)"} prevModel=${prev?.model ?? "(none)"} prevProvider=${prev?.providerId ?? "(none)"}',
    );
  }

  /// 把上游响应状态码归类:
  ///   ok       — 200,清 streak
  ///   failure  — 5xx / 408 / 429 / 401 / 403 / timeout / refused / reset
  ///              算上游不可用,累计 streak 触发自动切换
  ///   ignore   — 400 / 422 等业务错误,跟上游可用性无关
  static String _classifyStatus(int statusCode) {
    if (statusCode == 200) return 'ok';
    if (statusCode >= 500) return 'failure';
    if (statusCode == 408 || statusCode == 429) return 'failure';
    if (statusCode == 401 || statusCode == 403) return 'failure';
    return 'ignore';
  }

  void _reportSuccess(ProxyTarget target) {
    final id = target.providerId;
    if (id == null || id.isEmpty) {
      AppLogService.instance.warning(
        'Proxy',
        '上报成功被跳过:target.providerId 为空',
        details: 'baseUrl=${target.baseUrl}',
      );
      return;
    }
    if (onRequestSuccess == null) {
      AppLogService.instance.warning(
        'Proxy',
        '上报成功被跳过:onRequestSuccess 回调未绑定',
      );
      return;
    }
    onRequestSuccess!.call(id);
  }

  void _reportFailure(ProxyTarget target, String reason) {
    final id = target.providerId;
    if (id == null || id.isEmpty) {
      AppLogService.instance.warning(
        'Proxy',
        '上报失败被跳过:target.providerId 为空',
        details: 'reason=$reason baseUrl=${target.baseUrl}',
      );
      return;
    }
    if (onRequestFailure == null) {
      AppLogService.instance.warning(
        'Proxy',
        '上报失败被跳过:onRequestFailure 回调未绑定',
        details: 'reason=$reason',
      );
      return;
    }
    onRequestFailure!.call(id, reason);
  }

  void _reportTimeout(ProxyTarget target, int waitedMs) {
    final id = target.providerId;
    if (id == null || id.isEmpty) {
      AppLogService.instance.warning(
        'Proxy',
        '上报超时被跳过:target.providerId 为空',
      );
      return;
    }
    if (onRequestTimeout == null) {
      AppLogService.instance.warning(
        'Proxy',
        '上报超时被跳过:onRequestTimeout 回调未绑定',
      );
      return;
    }
    onRequestTimeout!.call(id, waitedMs);
  }

  Future<void> start({required int port, ProxyTarget? target}) async {
    if (target != null) _target = target;
    if (_server != null && _port == port) return;
    await stop();

    final server = await HttpServer.bind(
      InternetAddress.loopbackIPv4,
      port,
      shared: true,
    );
    _server = server;
    _port = server.port;
    AppLogService.instance.info('Proxy', '监听启动 127.0.0.1:$port');
    _subscription = server.listen(
      _handleRequest,
      onError: (Object error, StackTrace stackTrace) {
        AppLogService.instance.error(
          'Proxy',
          'server 层错误（请求未进 handler）',
          details: '$error',
        );
      },
    );
  }

  Future<void> stop() async {
    final subscription = _subscription;
    final server = _server;
    _subscription = null;
    _server = null;
    _port = null;
    await subscription?.cancel();
    await server?.close(force: true);
    if (server != null) {
      AppLogService.instance.info('Proxy', '监听已停止');
    }
  }

  Future<void> _handleRequest(HttpRequest request) async {
    final target = _target;
    // 调试用:把请求来源 + headers 关键字段记下,便于定位"谁在发请求"
    final hdrSummary = _summarizeRequestHeaders(request);
    AppLogService.instance.info(
      'Proxy',
      '收到请求 ${request.method} ${request.uri}',
      details:
          'target=${target?.baseUrl}\n  origin=${request.connectionInfo?.remoteAddress.address}:${request.connectionInfo?.remotePort}\n  $hdrSummary',
    );
    if (target == null) {
      await _closeWithStatus(request.response, HttpStatus.serviceUnavailable);
      return;
    }

    late final LlmProtocolSpec spec;
    try {
      spec = resolveLlmProtocolSpec(
        baseUrl: target.baseUrl,
        requestUri: request.uri,
        apiKey: target.apiKey,
        upstreamProtocol: target.upstreamProtocol,
      );
    } catch (error) {
      AppLogService.instance.error('Proxy', '上游目标解析失败', details: '$error');
      await _closeWithStatus(request.response, HttpStatus.badGateway);
      return;
    }

    AppLogService.instance.info(
      'Proxy',
      '转发到 ${spec.uri}',
      details: 'model=${target.model ?? "(passthrough)"} protocol=${target.upstreamProtocol}',
    );

    final client = HttpClient();
    client.findProxy = HttpClient.findProxyFromEnvironment;
    var responseStarted = false;
    try {
      final upstreamRequest = await client.openUrl(request.method, spec.uri);
      _copyRequestHeaders(request, upstreamRequest, spec.uri.host);
      _applyProtocolHeaders(upstreamRequest, spec.headers);

      final bodyBytes = await _collectBody(request);
      // 调试用:把原始请求 body 前 800 字节 dump 出来定位发起方
      AppLogService.instance.info(
        'Proxy',
        '请求 body',
        details: _summarizeBody(bodyBytes),
      );
      // 按 codex 请求头 session-id 查这个 thread 自己的 Claude 桥绑定。
      // 没绑就不注入,跟"全局兜底"明确切开。
      final codexThreadId = request.headers.value('session-id') ?? '';
      final binding = codexThreadId.isEmpty
          ? null
          : _claudeBindings[codexThreadId];
      final injectedSystem = binding == null
          ? null
          : _buildClaudeBridgeSystemMessage(binding);
      if (injectedSystem != null) {
        AppLogService.instance.info(
          'ClaudeBridge',
          '注入 system message',
          details:
              'codexThread=$codexThreadId claudeSession=${binding!.sessionId} promptBytes=${utf8.encode(injectedSystem).length}',
        );
        _dumpInputItemComparison(bodyBytes, injectedSystem);
      }
      final outBytes = convertLlmProtocolBody(
        bodyBytes,
        from: LlmProtocol.responses,
        to: spec.protocol,
        options: LlmRequestConvertOptions(
          overrideModel: target.model,
          reasoningEffort: target.reasoningEffort,
          prependSystemMessage: injectedSystem,
        ),
      );
      if (injectedSystem != null) {
        AppLogService.instance.info(
          'ClaudeBridge',
          '注入后 body 大小',
          details: 'inBytes=${bodyBytes.length} outBytes=${outBytes.length}',
        );
        // 输出注入后整个 input/messages 数组(去掉 instructions 那段固定 prompt 后)
        _dumpInjectedBody(outBytes);
      }
      upstreamRequest.headers.contentLength = outBytes.length;
      upstreamRequest.add(outBytes);

      // 慢响应保护:_slowTimeout 秒内拿不到响应头就当挂掉,触发 onRequestTimeout。
      final stopwatch = Stopwatch()..start();
      final HttpClientResponse upstreamResponse;
      if (_slowTimeout > Duration.zero) {
        try {
          upstreamResponse = await upstreamRequest.close().timeout(_slowTimeout);
        } on TimeoutException {
          stopwatch.stop();
          AppLogService.instance.warning(
            'Proxy',
            '上游慢响应超时',
            details: 'waited=${stopwatch.elapsedMilliseconds}ms threshold=${_slowTimeout.inSeconds}s',
          );
          _reportTimeout(target, stopwatch.elapsedMilliseconds);
          if (!responseStarted) {
            await _closeWithStatus(request.response, HttpStatus.gatewayTimeout);
          }
          return;
        }
      } else {
        upstreamResponse = await upstreamRequest.close();
      }
      stopwatch.stop();
      AppLogService.instance.info(
        'Proxy',
        '上游响应 ${upstreamResponse.statusCode}',
        details: '${upstreamResponse.headers.contentType} elapsed=${stopwatch.elapsedMilliseconds}ms',
      );

      // 上报给 health/auto-switch
      final classification = _classifyStatus(upstreamResponse.statusCode);
      if (classification == 'ok') {
        _reportSuccess(target);
      } else if (classification == 'failure') {
        _reportFailure(target, 'http ${upstreamResponse.statusCode}');
      }

      if (upstreamResponse.statusCode == HttpStatus.ok) {
        final transformed = await _tryTransformStream(
          spec.responseStreamKind,
          upstreamResponse,
          request.response,
        );
        if (transformed) {
          responseStarted = true;
          return;
        }
      }

      request.response.statusCode = upstreamResponse.statusCode;
      request.response.reasonPhrase = upstreamResponse.reasonPhrase;
      _copyResponseHeaders(upstreamResponse, request.response);
      responseStarted = true;
      await upstreamResponse.cast<List<int>>().pipe(request.response);
    } catch (error) {
      AppLogService.instance.error('Proxy', '转发异常', details: '$error');
      _reportFailure(target, 'exception: $error');
      if (!responseStarted) {
        await _closeWithStatus(request.response, HttpStatus.badGateway);
      }
    } finally {
      client.close(force: true);
    }
  }

  Future<bool> _tryTransformStream(
    LlmResponseStreamKind streamKind,
    HttpClientResponse upstream,
    HttpResponse downstream,
  ) async {
    switch (streamKind) {
      case LlmResponseStreamKind.passthrough:
        return false;
      case LlmResponseStreamKind.chatToResponses:
        downstream.statusCode = HttpStatus.ok;
        await ChatStreamToResponsesTransformer().transform(upstream, downstream);
        return true;
      case LlmResponseStreamKind.messagesToResponses:
        downstream.statusCode = HttpStatus.ok;
        await AnthropicMessagesStreamToResponsesTransformer()
            .transform(upstream, downstream);
        return true;
    }
  }

  void _applyProtocolHeaders(
    HttpClientRequest request,
    Map<String, String> headers,
  ) {
    for (final entry in headers.entries) {
      request.headers.set(entry.key, entry.value);
    }
  }

  Future<List<int>> _collectBody(HttpRequest request) {
    return request.fold<List<int>>(<int>[], (acc, chunk) => acc..addAll(chunk));
  }

  Future<void> _closeWithStatus(HttpResponse response, int statusCode) async {
    try {
      response.statusCode = statusCode;
      await response.close();
    } catch (_) {
      // The response may already be detached or closed by the socket layer.
    }
  }

  void _copyRequestHeaders(
    HttpRequest source,
    HttpClientRequest destination,
    String upstreamHost,
  ) {
    source.headers.forEach((name, values) {
      if (_isHopByHopHeader(name)) return;
      final lowerName = name.toLowerCase();
      if (lowerName == 'host') return;
      if (lowerName == 'authorization') return;
      for (final value in values) {
        destination.headers.add(name, value);
      }
    });
    destination.headers.set('host', upstreamHost);
  }

  void _copyResponseHeaders(
    HttpClientResponse source,
    HttpResponse destination,
  ) {
    source.headers.forEach((name, values) {
      if (_isHopByHopHeader(name)) return;
      for (final value in values) {
        destination.headers.add(name, value);
      }
    });
  }

  bool _isHopByHopHeader(String name) {
    switch (name.toLowerCase()) {
      case 'connection':
      case 'keep-alive':
      case 'proxy-authenticate':
      case 'proxy-authorization':
      case 'te':
      case 'trailer':
      case 'transfer-encoding':
      case 'upgrade':
        return true;
      default:
        return false;
    }
  }

  /// 把入站请求的关键 headers 拼成一行,便于在日志里识别"谁在发请求"。
  /// 取 User-Agent / Origin / Referer / 各种 x-* 客户端标识。
  String _summarizeRequestHeaders(HttpRequest request) {
    final wanted = <String>[
      'user-agent',
      'origin',
      'referer',
      'host',
      'x-forwarded-for',
      'x-originator',
      'x-client',
      'x-session-id',
      'x-request-id',
      'session-id',
      'mcp-session-id',
    ];
    final parts = <String>[];
    for (final name in wanted) {
      final value = request.headers.value(name);
      if (value != null && value.isNotEmpty) {
        parts.add('$name=${_clip(value, 120)}');
      }
    }
    return parts.isEmpty ? '(no notable headers)' : parts.join(' | ');
  }

  /// 诊断:对比 codex 自己的 input[0] (developer message 模板) 和我注入的那一条。
  /// 如果两者的 JSON 结构不同 → 我塞的格式不被上游接受,大概率是 503 根因。
  void _dumpInputItemComparison(List<int> bodyBytes, String injected) {
    try {
      final decoded = jsonDecode(utf8.decode(bodyBytes));
      if (decoded is! Map) return;
      final input = decoded['input'];
      if (input is! List || input.isEmpty) return;
      final firstItem = input.first;
      // codex 自己的 developer message:只看结构 + content[0] 的 type,
      // 文本太长截掉前 80 字符就够看格式了
      String firstSummary;
      try {
        firstSummary = _shortenJsonValues(firstItem);
      } catch (_) {
        firstSummary = '<dump-failed>';
      }
      // 我注入的那一条 — 模拟 _applyRequestOptionsToResponses 里的构造
      final myInjection = {
        'type': 'message',
        'role': 'developer',
        'content': [
          {'type': 'input_text', 'text': injected},
        ],
      };
      AppLogService.instance.info(
        'ClaudeBridge',
        '对比:codex 原生 input[0] vs 我注入的',
        details:
            'codex_input[0]=$firstSummary\n  my_inject=${_shortenJsonValues(myInjection)}',
      );
    } catch (e) {
      AppLogService.instance.warning(
        'ClaudeBridge',
        '对比失败',
        details: '$e',
      );
    }
  }

  /// 注入后,把整个 input/messages 数组(每项摘要)dump 出来。
  /// 这样能看到我塞的那条到底落在哪个位置、跟前后是什么关系。
  void _dumpInjectedBody(List<int> outBytes) {
    try {
      final decoded = jsonDecode(utf8.decode(outBytes));
      if (decoded is! Map) return;
      final buf = StringBuffer();
      // responses 协议:dump input 数组
      final input = decoded['input'];
      if (input is List) {
        buf.write('input.count=${input.length}');
        for (var i = 0; i < input.length; i++) {
          buf.write('\n  [$i]=${_shortenJsonValues(input[i])}');
        }
      }
      // messages 协议:dump messages 数组 + 顶层 system
      final messages = decoded['messages'];
      if (messages is List) {
        final sys = decoded['system'];
        if (sys != null) {
          buf.write('system=${_clip(sys.toString().replaceAll('\n', '\\n'), 400)}');
        }
        buf.write('\n  messages.count=${messages.length}');
        for (var i = 0; i < messages.length; i++) {
          buf.write('\n  [$i]=${_shortenJsonValues(messages[i])}');
        }
      }
      AppLogService.instance.info(
        'ClaudeBridge',
        '注入后完整 input/messages dump',
        details: buf.toString(),
      );
    } catch (e) {
      AppLogService.instance.warning(
        'ClaudeBridge',
        'dump 失败',
        details: '$e',
      );
    }
  }

  /// 递归把 JSON 里的长字符串截断,保留结构。用 JSON encode 输出。
  String _shortenJsonValues(Object? value) {
    final shortened = _shortenValue(value, 80);
    return jsonEncode(shortened);
  }

  Object? _shortenValue(Object? value, int maxStr) {
    if (value is String) {
      if (value.length <= maxStr) return value;
      return '${value.substring(0, maxStr)}…(+${value.length - maxStr})';
    }
    if (value is List) {
      return value.map((v) => _shortenValue(v, maxStr)).toList();
    }
    if (value is Map) {
      return value.map((k, v) => MapEntry(k, _shortenValue(v, maxStr)));
    }
    return value;
  }

  /// 把当前的 Claude 桥绑定渲染成一条 system message 内容。
  /// 让上游 LLM 知道这次对话需要先调 MCP 工具读取这条 Claude 会话作为接续上下文。
  String _buildClaudeBridgeSystemMessage(ClaudeBridgeBinding binding) {
    final titlePart =
        (binding.title != null && binding.title!.isNotEmpty) ? '\n- 标题: ${binding.title}' : '';
    return '本次对话需要接续一条已存在的 Claude Code 会话作为上下文。\n'
        '请在响应用户之前,通过 MCP 工具 `read_claude_session` 读取下列会话的消息流,\n'
        '理解其历史后再回答用户的新请求。可分页读取(每次 limit≤200),必要时多次调用直到 hasMore=false。\n\n'
        '- jsonl_path: ${binding.jsonlPath}\n'
        '- sessionId: ${binding.sessionId}$titlePart\n\n'
        '注意:这条 system 指引每轮都会出现,直到用户在客户端解除绑定。如果你已经在前面的轮次读取过该会话,可以直接复用记忆,不需要重复调用工具。';
  }

  /// body 摘要:解析 JSON 后只打印 model + input/messages 摘要,跳过固定的 instructions。
  /// 让日志直接体现"这次请求究竟跟上次哪里不一样",好判断是不是 codex 重发同一个请求。
  String _summarizeBody(List<int> bytes) {
    if (bytes.isEmpty) return '(empty body)';
    String text;
    try {
      text = utf8.decode(bytes, allowMalformed: true);
    } catch (_) {
      return 'bytes=${bytes.length} <binary>';
    }
    dynamic decoded;
    try {
      decoded = jsonDecode(text);
    } catch (_) {
      // 非 JSON,退回原来的截断方案
      return 'bytes=${bytes.length}\n  ${_clip(text, 800).replaceAll('\n', '\\n')}';
    }
    if (decoded is! Map) {
      return 'bytes=${bytes.length} (non-object json)';
    }
    final buf = StringBuffer('bytes=${bytes.length}');
    final model = decoded['model'];
    if (model != null) buf.write('\n  model=$model');

    // tools 摘要:codex 发来的工具列表 — 名字 + 总数。Claude 桥用户最关心
    // 「我注册的 MCP 工具 read_claude_session 有没有进上游」
    final tools = decoded['tools'];
    if (tools is List) {
      final names = <String>[];
      for (final t in tools) {
        if (t is Map) {
          final n = t['name'] ?? (t['function'] is Map ? (t['function'] as Map)['name'] : null);
          if (n is String) names.add(n);
        }
      }
      buf.write('\n  tools.count=${tools.length} names=[${names.join(", ")}]');
    } else {
      buf.write('\n  tools=(none)');
    }

    // responses 协议:input 是 list of turns
    final input = decoded['input'];
    if (input is List) {
      buf.write('\n  input.count=${input.length}');
      // 只打最后 3 条(尾端才是新的)
      final tail = input.length <= 3 ? input : input.sublist(input.length - 3);
      for (var i = 0; i < tail.length; i++) {
        final idx = input.length - tail.length + i;
        buf.write('\n  input[$idx]=${_clip(_summarizeTurn(tail[i]), 400)}');
      }
    }

    // messages 协议:messages 是 list of {role, content}
    final messages = decoded['messages'];
    if (messages is List) {
      buf.write('\n  messages.count=${messages.length}');
      final tail = messages.length <= 3
          ? messages
          : messages.sublist(messages.length - 3);
      for (var i = 0; i < tail.length; i++) {
        final idx = messages.length - tail.length + i;
        buf.write('\n  messages[$idx]=${_clip(_summarizeTurn(tail[i]), 400)}');
      }
    }

    // chat 协议同样走 messages 路径

    return buf.toString();
  }

  /// 把单个 turn(input 元素或 message)压成一行摘要。
  /// 关注 role / type / 文本内容 / function_call name + args 长度。
  String _summarizeTurn(dynamic turn) {
    if (turn is! Map) return jsonEncode(turn);
    final role = turn['role'];
    final type = turn['type'];
    final parts = <String>[];
    if (role != null) parts.add('role=$role');
    if (type != null && type != role) parts.add('type=$type');

    // function_call 类型:打 name + arguments 长度
    if (type == 'function_call' || turn['name'] != null) {
      final name = turn['name'];
      final args = turn['arguments'];
      if (name != null) parts.add('name=$name');
      if (args is String) {
        parts.add('args.len=${args.length}');
      } else if (args != null) {
        parts.add('args=${_clip(jsonEncode(args), 120)}');
      }
    }
    if (type == 'function_call_output') {
      final output = turn['output'];
      if (output is String) {
        parts.add('output.len=${output.length}');
      }
    }

    // content 可能是 string 或 list of {type, text}
    final content = turn['content'];
    if (content is String) {
      parts.add('content=${_clip(content.replaceAll('\n', '\\n'), 200)}');
    } else if (content is List) {
      final texts = <String>[];
      for (final item in content) {
        if (item is Map) {
          final t = item['text'] ?? item['content'];
          if (t is String) texts.add(t);
        } else if (item is String) {
          texts.add(item);
        }
      }
      if (texts.isNotEmpty) {
        parts.add('content=${_clip(texts.join(" | ").replaceAll('\n', '\\n'), 200)}');
      }
    }

    return parts.join(' ');
  }

  String _clip(String s, int max) {
    if (s.length <= max) return s;
    return '${s.substring(0, max)}…(+${s.length - max})';
  }
}
