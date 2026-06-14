import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

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

  /// 在 page target 上拿到 devtoolsFrontendUrl，用于系统浏览器打开完整 DevTools
  Future<String?> findDevtoolsUrl(int debugPort) async {
    try {
      final response = await _dio.getUri<List<dynamic>>(
        Uri.parse('http://127.0.0.1:$debugPort/json'),
      );
      final targets = response.data ?? const [];
      for (final raw in targets) {
        final target = raw as Map<String, dynamic>;
        if (target['type'] == 'page' &&
            target['devtoolsFrontendUrl'] is String) {
          final relative = target['devtoolsFrontendUrl'] as String;
          if (relative.startsWith('http')) return relative;
          return 'http://127.0.0.1:$debugPort$relative';
        }
      }
    } catch (_) {}
    return null;
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
}
