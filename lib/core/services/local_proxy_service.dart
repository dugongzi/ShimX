import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:riverpod/riverpod.dart';

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
  const ProxyTarget({required this.baseUrl, required this.apiKey});

  /// 例：https://api.muxueai.pro/v1
  final String baseUrl;

  /// 真实供应商的 bearer token
  final String apiKey;
}

/// 反向代理：Codex 用 HTTP 发到本地，代理按当前 target 改写后用 HTTPS 转发到真实供应商。
///
/// Codex 侧 base_url 配置成 http://127.0.0.1:<port>/v1，
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
    _subscription = server.listen(
      _handleRequest,
      onError: (Object error, StackTrace stackTrace) {},
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
    if (target == null) {
      await _closeWithStatus(request.response, HttpStatus.serviceUnavailable);
      return;
    }

    // 拿到 Codex 请求里 /v1 之后的路径，拼到真实 base_url 上。
    // base_url 本身可能带 /v1，Codex 发来的也是 /v1/responses，
    // 所以用 base_url 的 origin + 请求的完整 path。
    final upstreamUri = _resolveUpstreamUri(target.baseUrl, request.uri);
    if (upstreamUri == null) {
      await _closeWithStatus(request.response, HttpStatus.badGateway);
      return;
    }

    final client = HttpClient();
    client.findProxy = (_) => 'DIRECT';
    var responseStarted = false;
    try {
      final upstreamRequest = await client.openUrl(request.method, upstreamUri);
      _copyRequestHeaders(request, upstreamRequest, upstreamUri.host);
      // 用真实供应商的 key 覆盖 Authorization
      upstreamRequest.headers.set('authorization', 'Bearer ${target.apiKey}');
      await upstreamRequest.addStream(request.cast<List<int>>());
      final upstreamResponse = await upstreamRequest.close();

      request.response.statusCode = upstreamResponse.statusCode;
      request.response.reasonPhrase = upstreamResponse.reasonPhrase;
      _copyResponseHeaders(upstreamResponse, request.response);
      responseStarted = true;
      await upstreamResponse.cast<List<int>>().pipe(request.response);
    } catch (error) {
      if (!responseStarted) {
        await _closeWithStatus(request.response, HttpStatus.badGateway);
      }
    } finally {
      client.close(force: true);
    }
  }

  /// 把真实 base_url 的 scheme/host/port 跟请求的 path/query 拼起来。
  ///
  /// base_url = https://api.muxueai.pro/v1
  /// 请求 path = /v1/responses
  /// → https://api.muxueai.pro/v1/responses
  ///
  /// 为避免 /v1 重复，base_url 的 path 前缀以请求 path 为准：
  /// 直接用 base origin + 请求完整 path。
  Uri? _resolveUpstreamUri(String baseUrl, Uri requestUri) {
    final base = Uri.tryParse(baseUrl);
    if (base == null || base.host.isEmpty) return null;
    return Uri(
      scheme: base.scheme,
      host: base.host,
      port: base.hasPort ? base.port : null,
      path: requestUri.path,
      query: requestUri.query.isEmpty ? null : requestUri.query,
    );
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
