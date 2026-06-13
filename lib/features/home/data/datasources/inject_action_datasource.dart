import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:web_socket_channel/io.dart';

class InjectActionDatasource {
  static const String _injectAssetPath = 'assets/inject/codex_enhance.js';

  /// debug 模式下直接读这个源码文件，改完立刻生效（零重启）
  static const String _devSourcePath =
      r'F:\Programming_projects\FlutterProject\shim\assets\inject\codex_enhance.js';

  final Dio _dio;

  InjectActionDatasource() : _dio = _buildLoopbackDio();

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

  /// 端口已有 CDP 服务在监听则返回 true
  Future<bool> isDebugPortAlive(int debugPort) async {
    try {
      await _dio.getUri<List<dynamic>>(
        Uri.parse('http://127.0.0.1:$debugPort/json'),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// 通过监听端口反查可执行文件路径，三平台分别实现
  Future<String?> findExecutableByPort(int debugPort) async {
    if (Platform.isWindows) {
      return _findExecutableWindows(debugPort);
    }
    if (Platform.isMacOS) {
      return _findExecutableMacOS(debugPort);
    }
    if (Platform.isLinux) {
      return _findExecutableLinux(debugPort);
    }
    return null;
  }

  Future<String?> _findExecutableWindows(int debugPort) async {
    final result = await Process.run(
      'powershell',
      [
        '-NoProfile',
        '-Command',
        "(Get-Process -Id (Get-NetTCPConnection -LocalPort $debugPort -State Listen -ErrorAction Stop).OwningProcess).Path",
      ],
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    );
    if (result.exitCode != 0) return null;
    final path = (result.stdout as String).trim();
    return path.isEmpty ? null : path;
  }

  Future<int?> _pidByLsof(int debugPort) async {
    final result = await Process.run(
      'lsof',
      ['-nP', '-iTCP:$debugPort', '-sTCP:LISTEN', '-F', 'p'],
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    );
    if (result.exitCode != 0) return null;
    for (final line in (result.stdout as String).split('\n')) {
      if (line.startsWith('p')) {
        return int.tryParse(line.substring(1).trim());
      }
    }
    return null;
  }

  Future<String?> _findExecutableMacOS(int debugPort) async {
    final pid = await _pidByLsof(debugPort);
    if (pid == null) return null;
    final result = await Process.run(
      'ps',
      ['-p', '$pid', '-o', 'comm='],
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    );
    if (result.exitCode != 0) return null;
    final path = (result.stdout as String).trim();
    return path.isEmpty ? null : path;
  }

  Future<String?> _findExecutableLinux(int debugPort) async {
    final pid = await _pidByLsof(debugPort);
    if (pid == null) return null;
    final link = Link('/proc/$pid/exe');
    try {
      return await link.target();
    } catch (_) {
      return null;
    }
  }

  /// 启动目标程序并附加 --remote-debugging-port 参数
  Future<void> launchExecutable({
    required String executablePath,
    required int debugPort,
  }) async {
    await Process.start(
      executablePath,
      ['--remote-debugging-port=$debugPort'],
      mode: ProcessStartMode.detached,
    );
  }

  /// 轮询直到出现可注入的 page target 或超时
  Future<void> waitForDebugPort({
    required int debugPort,
    Duration timeout = const Duration(seconds: 30),
    Duration interval = const Duration(milliseconds: 500),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      try {
        await _findPageWebSocketUrl(debugPort);
        return;
      } catch (_) {
        await Future.delayed(interval);
      }
    }
    throw TimeoutException('No page target on port $debugPort');
  }

  /// 加载注入脚本：
  /// - debug 模式直接读项目源码下的 codex_enhance.js（改完立刻生效）
  /// - release 模式读打包进 app 的 asset
  Future<String> loadInjectScript() async {
    if (kDebugMode) {
      final source = File(_devSourcePath);
      if (await source.exists()) {
        return source.readAsString();
      }
    }
    return rootBundle.loadString(_injectAssetPath);
  }

  Future<void> injectScript({
    required int debugPort,
    required String script,
  }) async {
    final wsUrl = await _findPageWebSocketUrl(debugPort);
    final channel = IOWebSocketChannel.connect(Uri.parse(wsUrl));
    final broadcast = channel.stream.asBroadcastStream();
    try {
      await _sendCommand(
        channel,
        broadcast,
        id: 1,
        method: 'Page.addScriptToEvaluateOnNewDocument',
        params: {'source': script},
      );
      await _sendCommand(
        channel,
        broadcast,
        id: 2,
        method: 'Runtime.evaluate',
        params: {
          'expression': script,
          'allowUnsafeEvalBlockedByCSP': true,
        },
      );
    } finally {
      await channel.sink.close();
    }
  }

  Future<String> _findPageWebSocketUrl(int debugPort) async {
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

  Future<Map<String, dynamic>> _sendCommand(
    IOWebSocketChannel channel,
    Stream<dynamic> broadcast, {
    required int id,
    required String method,
    Map<String, dynamic>? params,
  }) async {
    final completer = Completer<Map<String, dynamic>>();
    final subscription = broadcast.listen((raw) {
      final msg = jsonDecode(raw as String) as Map<String, dynamic>;
      if (msg['id'] == id && !completer.isCompleted) {
        completer.complete(msg);
      }
    });
    channel.sink.add(jsonEncode({
      'id': id,
      'method': method,
      if (params != null) 'params': params,
    }));
    try {
      return await completer.future.timeout(const Duration(seconds: 5));
    } finally {
      await subscription.cancel();
    }
  }
}
