import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:web_socket_channel/io.dart';

part 'cdp_service.g.dart';

@Riverpod(keepAlive: true)
CdpService cdpService(Ref ref) {
  final service = CdpService();
  ref.onDispose(service.disconnect);
  return service;
}

/// Chrome DevTools Protocol 传输层：管理到 page 的长连接，收发命令、注入脚本。
/// 不涉及业务，纯技术通道。
class CdpService {
  CdpService() : _dio = _buildLoopbackDio();

  static final _apiUrlPatterns = [
    RegExp(r'/v1/'),
    RegExp(r'openai\.com'),
    RegExp(r'chatgpt\.com'),
  ];

  final Dio _dio;
  IOWebSocketChannel? _channel;
  Stream<dynamic>? _broadcast;
  StreamSubscription<dynamic>? _subscription;
  int _commandId = 1000;
  final Map<int, Completer<Map<String, dynamic>>> _pendingCommands = {};
  final Map<String, _NetworkRequest> _pendingNetworkRequests = {};

  /// 事件监听器（如 Runtime.bindingCalled），由 BridgeService 注册。
  void Function(Map<String, dynamic> event)? onEvent;

  static Dio _buildLoopbackDio() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 3),
        receiveTimeout: const Duration(seconds: 3),
      ),
    );
    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.findProxy = (uri) => 'DIRECT';
      return client;
    };
    return dio;
  }

  bool get isConnected => _channel != null;

  Future<void> connect(int debugPort) async {
    await disconnect();
    final wsUrl = await findPageWebSocketUrl(debugPort);
    final channel = IOWebSocketChannel.connect(Uri.parse(wsUrl));
    _channel = channel;
    _broadcast = channel.stream.asBroadcastStream();
    _subscription = _broadcast!.listen(
      _handleMessage,
      onDone: _cleanup,
      onError: (_) => _cleanup(),
    );
    await sendCommand('Network.enable');
  }

  Future<void> disconnect() async {
    await _subscription?.cancel();
    _subscription = null;
    await _channel?.sink.close();
    _cleanup();
  }

  void _cleanup() {
    _channel = null;
    _broadcast = null;
    for (final completer in _pendingCommands.values) {
      if (!completer.isCompleted) {
        completer.completeError(StateError('cdp connection closed'));
      }
    }
    _pendingCommands.clear();
    _pendingNetworkRequests.clear();
  }

  void _handleMessage(dynamic raw) {
    final message = jsonDecode(raw as String) as Map<String, dynamic>;
    final id = message['id'];
    if (id is int) {
      _pendingCommands.remove(id)?.complete(message);
      return;
    }
    final method = message['method'] as String?;
    if (method != null && method.startsWith('Network.')) {
      _handleNetworkEvent(method, message['params'] as Map<String, dynamic>?);
      return;
    }
    onEvent?.call(message);
  }

  void _handleNetworkEvent(String method, Map<String, dynamic>? params) {
    if (params == null) return;
    switch (method) {
      case 'Network.requestWillBeSent':
        final requestId = params['requestId'] as String?;
        final request = (params['request'] as Map?)?.cast<String, dynamic>();
        if (requestId == null || request == null) return;
        final url = request['url'] as String? ?? '';
        if (!_shouldLogApi(url)) return;
        _pendingNetworkRequests[requestId] = _NetworkRequest(
          method: request['method'] as String? ?? '',
          url: url,
        );
        debugPrint(
          '[shim:api] → ${request['method']} $url\n'
          '  headers: ${request['headers']}\n'
          '  postData: ${request['postData']}',
        );
        break;
      case 'Network.responseReceived':
        final requestId = params['requestId'] as String?;
        if (requestId == null) return;
        final pending = _pendingNetworkRequests[requestId];
        if (pending == null) return;
        final response = (params['response'] as Map?)?.cast<String, dynamic>();
        if (response == null) return;
        final status = response['status'];
        final contentType =
            (response['headers'] as Map?)?['content-type'] ??
                (response['headers'] as Map?)?['Content-Type'] ??
                '';
        debugPrint(
          '[shim:api] ← $status ${pending.url}\n'
          '  contentType: $contentType',
        );
        break;
      case 'Network.loadingFinished':
        final requestId = params['requestId'] as String?;
        if (requestId == null) return;
        final pending = _pendingNetworkRequests.remove(requestId);
        if (pending == null) return;
        _fetchAndLogResponseBody(requestId, pending);
        break;
      case 'Network.loadingFailed':
        final requestId = params['requestId'] as String?;
        if (requestId == null) return;
        final pending = _pendingNetworkRequests.remove(requestId);
        if (pending == null) return;
        debugPrint(
          '[shim:api] ✗ ${pending.url}\n'
          '  errorText: ${params['errorText']}',
        );
        break;
    }
  }

  Future<void> _fetchAndLogResponseBody(
    String requestId,
    _NetworkRequest request,
  ) async {
    try {
      final result = await sendCommand(
        'Network.getResponseBody',
        {'requestId': requestId},
      );
      final body = (result['result'] as Map?)?['body'];
      final base64Encoded =
          (result['result'] as Map?)?['base64Encoded'] == true;
      debugPrint(
        '[shim:api] ✓ ${request.url}\n'
        '  body${base64Encoded ? '(base64)' : ''}: $body',
      );
    } catch (e) {
      debugPrint('[shim:api] body fetch failed ${request.url}: $e');
    }
  }

  bool _shouldLogApi(String url) {
    return _apiUrlPatterns.any((re) => re.hasMatch(url));
  }

  Future<Map<String, dynamic>> sendCommand(
    String method, [
    Map<String, dynamic>? params,
  ]) async {
    final channel = _channel;
    if (channel == null) {
      throw StateError('cdp not connected');
    }
    final id = _commandId++;
    final completer = Completer<Map<String, dynamic>>();
    _pendingCommands[id] = completer;
    channel.sink.add(jsonEncode({
      'id': id,
      'method': method,
      if (params != null) 'params': params,
    }));
    return completer.future.timeout(const Duration(seconds: 5));
  }

  /// 注入脚本：注册到新文档（刷新保留）并立即执行一次。
  Future<void> injectScript(String script) async {
    await sendCommand(
      'Page.addScriptToEvaluateOnNewDocument',
      {'source': script},
    );
    await sendCommand('Runtime.evaluate', {
      'expression': script,
      'allowUnsafeEvalBlockedByCSP': true,
    });
  }

  Future<void> evaluate(String expression) async {
    await sendCommand('Runtime.evaluate', {'expression': expression});
  }

  Future<String> findPageWebSocketUrl(int debugPort) async {
    final response = await _dio.getUri<List<dynamic>>(
      Uri.parse('http://127.0.0.1:$debugPort/json'),
    );
    final targets = response.data ?? const [];
    for (final raw in targets) {
      final target = raw as Map<String, dynamic>;
      if (target['type'] == 'page' &&
          target['webSocketDebuggerUrl'] is String) {
        return target['webSocketDebuggerUrl'] as String;
      }
    }
    throw StateError('No injectable page target on port $debugPort');
  }
}

class _NetworkRequest {
  _NetworkRequest({required this.method, required this.url});

  final String method;
  final String url;
}
