import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
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

  final Dio _dio;
  IOWebSocketChannel? _channel;
  Stream<dynamic>? _broadcast;
  StreamSubscription<dynamic>? _subscription;
  int _commandId = 1000;
  final Map<int, Completer<Map<String, dynamic>>> _pendingCommands = {};

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
    await sendCommand('Page.enable');
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
  }

  void _handleMessage(dynamic raw) {
    final message = jsonDecode(raw as String) as Map<String, dynamic>;
    final id = message['id'];
    if (id is int) {
      _pendingCommands.remove(id)?.complete(message);
      return;
    }
    final method = message['method'] as String?;
    if (method == 'Runtime.consoleAPICalled') {
      onEvent?.call(message);
      return;
    }
    onEvent?.call(message);
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

  Future<void> reloadPage() async {
    await sendCommand('Page.reload', {'ignoreCache': true});
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
