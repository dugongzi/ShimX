import 'dart:async';
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

/// Reverse proxy for Codex local requests.
///
/// This class only owns HTTP proxy flow. Request protocol mapping belongs to
/// llm_protocol_converter.dart; upstream route/header decisions belong to
/// llm_protocol_proxy_spec.dart.
class LocalProxyService {
  HttpServer? _server;
  StreamSubscription<HttpRequest>? _subscription;
  int? _port;

  ProxyTarget? _target;

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
    _target = target;
    AppLogService.instance.info(
      'Proxy',
      '已切换代理目标',
      details:
          'baseUrl=${target.baseUrl}\nmodel=${target.model ?? "(passthrough)"}\nprotocol=${target.upstreamProtocol}\nprovider=${target.providerId ?? "(none)"}',
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
    AppLogService.instance.info(
      'Proxy',
      '收到请求 ${request.method} ${request.uri}',
      details: 'target=${target?.baseUrl}',
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
      final outBytes = convertLlmProtocolBody(
        bodyBytes,
        from: LlmProtocol.responses,
        to: spec.protocol,
        options: LlmRequestConvertOptions(
          overrideModel: target.model,
          reasoningEffort: target.reasoningEffort,
        ),
      );
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
}
