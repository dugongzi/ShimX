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

  /// `Page.addScriptToEvaluateOnNewDocument` 是**累积式**注册:每调一次,
  /// reload 时该脚本就多执行一次。同一份脚本反复 inject(用户点"刷新 codex"
  /// 多次)就会叠加,导致 DOM listener / fetch hook / MutationObserver
  /// 被多次注册,表现为"用户点一次按钮 codex 发 N 次请求"。
  ///
  /// 这里按脚本 hash 记 identifier。下次同 hash 再来 inject,先 remove
  /// 旧的再 add,真正幂等。
  final Map<String, String> _injectedScriptIdentifiers = {};

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
    // 连接断开后,目标页里之前 add 的脚本注册都失效了;identifier 不再有效。
    // 不清 map 的话下次 reconnect inject 时会拿旧 identifier 去 remove,
    // 报 "ScriptToEvaluateOnLoad: not found",虽然不致命,但日志噪声。
    _injectedScriptIdentifiers.clear();
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
  ///
  /// 幂等:同一份脚本反复 inject,只有第一份生效;后续 inject 先 remove 上次
  /// 的脚本注册再 add,避免 reload 时同一脚本被执行多次。
  /// 脚本本身也应该有 once guard 兜底,但底层这里也做去重,降低风险。
  Future<void> injectScript(String script) async {
    final key = _scriptHash(script);
    final prevId = _injectedScriptIdentifiers[key];
    if (prevId != null) {
      try {
        await sendCommand('Page.removeScriptToEvaluateOnNewDocument', {
          'identifier': prevId,
        });
      } catch (_) {
        // 目标页可能已 reload / 关闭,identifier 失效。忽略即可,
        // 下面 addScriptToEvaluateOnNewDocument 会重建。
      }
      _injectedScriptIdentifiers.remove(key);
    }
    final addResp = await sendCommand(
      'Page.addScriptToEvaluateOnNewDocument',
      {'source': script},
    );
    final newId = (addResp['result'] as Map?)?['identifier'] as String?;
    if (newId != null) _injectedScriptIdentifiers[key] = newId;

    await sendCommand('Runtime.evaluate', {
      'expression': script,
      'allowUnsafeEvalBlockedByCSP': true,
    });
  }

  /// 简单 djb2 hash:脚本同样的字符串得到同样的 key。不需要密码学强度,
  /// 只是用来区分"这次注入的是同一份还是新脚本"。
  String _scriptHash(String s) {
    var hash = 5381;
    for (var i = 0; i < s.length; i++) {
      hash = ((hash << 5) + hash + s.codeUnitAt(i)) & 0x7fffffff;
    }
    return 'h$hash:len${s.length}';
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
