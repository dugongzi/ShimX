import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shim/core/services/chat_to_responses_transformer.dart';

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

/// 当前转发目标：真实供应商的 base_url + key。
/// 切换供应商 = 改这个对象，零重启。
class ProxyTarget {
  const ProxyTarget({
    required this.baseUrl,
    required this.apiKey,
    this.model,
    this.wireApi = 'responses',
  });

  /// 例：https://api.muxueai.pro/v1
  final String baseUrl;

  /// 真实供应商的 bearer token
  final String apiKey;

  /// 覆盖请求 body 的 model（null = 不改，用 Codex 自己选的）
  final String? model;

  /// 上游协议：'responses'（默认）| 'chat'
  final String wireApi;
}

/// 反向代理：Codex 用 HTTP 发到本地，代理按当前 target 改写后用 HTTPS 转发到真实供应商。
///
/// Codex 侧 base_url 配置成 `http://127.0.0.1:<port>/v1`，
/// 收到 /v1/responses 这类请求后，拼到 target.baseUrl 上转发，
/// Authorization 换成 target.apiKey。
class LocalProxyService {
  HttpServer? _server;
  StreamSubscription<HttpRequest>? _subscription;
  int? _port;

  /// 当前转发目标，可热切换
  ProxyTarget? _target;

  bool get isRunning => _server != null;
  int? get port => _port;
  ProxyTarget? get target => _target;

  /// 热切换转发目标（零重启）
  void setTarget(ProxyTarget target) {
    _target = target;
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
    // ignore: avoid_print
    print('[Proxy] 监听启动 127.0.0.1:$port');
    _subscription = server.listen(
      _handleRequest,
      onError: (Object error, StackTrace stackTrace) {
        // ignore: avoid_print
        print('[Proxy] ❌ server 层错误（请求未进 handler）: $error');
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
  }

  Future<void> _handleRequest(HttpRequest request) async {
    final target = _target;
    // ignore: avoid_print
    print('[Proxy] 收到请求 ${request.method} ${request.uri} '
        'target=${target?.baseUrl}');
    if (target == null) {
      // ignore: avoid_print
      print('[Proxy] ❌ target 为 null，返回 503');
      await _closeWithStatus(request.response, HttpStatus.serviceUnavailable);
      return;
    }

    final upstreamUri = _resolveUpstreamUri(
      target.baseUrl,
      request.uri,
      target.wireApi,
    );
    if (upstreamUri == null) {
      // ignore: avoid_print
      print('[Proxy] ❌ 解析 upstream 失败, baseUrl=${target.baseUrl}');
      await _closeWithStatus(request.response, HttpStatus.badGateway);
      return;
    }

    final isChat = target.wireApi == 'chat';
    // ignore: avoid_print
    print('[Proxy] 转发 → $upstreamUri model=${target.model ?? "(透传)"} '
        'wire=${target.wireApi}');
    final client = HttpClient();
    client.findProxy = (_) => 'DIRECT';
    var responseStarted = false;
    try {
      final upstreamRequest = await client.openUrl(request.method, upstreamUri);
      _copyRequestHeaders(request, upstreamRequest, upstreamUri.host);
      upstreamRequest.headers.set('authorization', 'Bearer ${target.apiKey}');

      // chat 协议：请求体 Responses→Chat 转换；否则仅按需改写 model。
      final bodyBytes = await _collectBody(request);
      final outBytes = isChat
          ? convertResponsesBodyToChat(bodyBytes, target.model)
          : _rewriteModelIfNeeded(bodyBytes, target.model);
      upstreamRequest.headers.contentLength = outBytes.length;
      upstreamRequest.add(outBytes);
      final upstreamResponse = await upstreamRequest.close();

      // ignore: avoid_print
      print('[Proxy] 上游响应 ${upstreamResponse.statusCode} '
          'content-type=${upstreamResponse.headers.contentType} ← $upstreamUri');

      if (isChat && upstreamResponse.statusCode == 200) {
        // chat 协议：把 Chat SSE 流转成 Responses SSE 流回传
        request.response.statusCode = 200;
        responseStarted = true;
        await ChatToResponsesTransformer()
            .transform(upstreamResponse, request.response);
      } else {
        request.response.statusCode = upstreamResponse.statusCode;
        request.response.reasonPhrase = upstreamResponse.reasonPhrase;
        _copyResponseHeaders(upstreamResponse, request.response);
        responseStarted = true;
        await upstreamResponse.cast<List<int>>().pipe(request.response);
      }
    } catch (error) {
      // ignore: avoid_print
      print('[Proxy] ❌ 转发异常: $error');
      if (!responseStarted) {
        await _closeWithStatus(request.response, HttpStatus.badGateway);
      }
    } finally {
      client.close(force: true);
    }
  }

  /// 真实 base_url 的 scheme/host/port + 请求 path/query。
  /// wireApi == 'chat' 时把 path 改为 base_url path 前缀 + /chat/completions，
  /// 让只支持 chat 端点的供应商也能用。
  Uri? _resolveUpstreamUri(String baseUrl, Uri requestUri, String wireApi) {
    final base = Uri.tryParse(baseUrl);
    if (base == null || base.host.isEmpty) return null;
    final String path;
    if (wireApi == 'chat') {
      final prefix = base.path.replaceAll(RegExp(r'/+$'), '');
      path = '$prefix/chat/completions';
    } else {
      path = requestUri.path;
    }
    return Uri(
      scheme: base.scheme,
      host: base.host,
      port: base.hasPort ? base.port : null,
      path: path,
      query: requestUri.query.isEmpty ? null : requestUri.query,
    );
  }

  Future<List<int>> _collectBody(HttpRequest request) {
    return request.fold<List<int>>(<int>[], (acc, chunk) => acc..addAll(chunk));
  }

  /// model 非空则改写 body 的 model 字段；解析失败或无需改写时原样返回。
  List<int> _rewriteModelIfNeeded(List<int> bodyBytes, String? model) {
    if (model == null || model.isEmpty || bodyBytes.isEmpty) return bodyBytes;
    try {
      final decoded = jsonDecode(utf8.decode(bodyBytes));
      if (decoded is! Map<String, dynamic>) return bodyBytes;
      decoded['model'] = model;
      return utf8.encode(jsonEncode(decoded));
    } catch (_) {
      return bodyBytes;
    }
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
      if (name.toLowerCase() == 'host') return; // 用真实 host
      if (name.toLowerCase() == 'authorization') return; // 稍后单独设
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
