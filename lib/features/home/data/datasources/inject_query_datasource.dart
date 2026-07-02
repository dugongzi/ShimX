import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class InjectQueryDatasource {
  /// codex_enhance 改造为分层分片后, 注入脚本由多个 .js 文件按层顺序拼接而成。
  /// core → ui → features → runtime, 层内按文件名字母序。
  /// 这里写死的清单就是清晰架构本身的一部分 (不是 manifest 配置), 决定了每层
  /// 哪些底层符号必须先于上层被声明。
  ///
  /// 顺序依赖: core/guard 必须最先 (它装 once guard 和 namespace 根),
  /// core/i18n 必须在所有 features 之前 (S() / state 是底层),
  /// runtime/* 必须最后 (启动调用要等所有 ensureXxx 都挂上 namespace)。
  static const List<String> _injectShards = [
    // core: once guard, 命名空间根, 常量池, RPC, i18n + provider 状态
    'assets/inject/codex_enhance/core/guard.js',
    'assets/inject/codex_enhance/core/constants.js',
    'assets/inject/codex_enhance/core/bridge.js',
    'assets/inject/codex_enhance/core/i18n.js',
    // ui: 跨 feature 复用的纯 UI 工具 (toast / busy / confirm / panel_utils)
    'assets/inject/codex_enhance/ui/busy.js',
    'assets/inject/codex_enhance/ui/confirm.js',
    'assets/inject/codex_enhance/ui/panel_utils.js',
    'assets/inject/codex_enhance/ui/toast.js',
    // features: 各业务模块, 字母序无依赖关系
    'assets/inject/codex_enhance/features/badge.js',
    'assets/inject/codex_enhance/features/claude_bridge.js',
    'assets/inject/codex_enhance/features/control_panel.js',
    'assets/inject/codex_enhance/features/network_blocker.js',
    'assets/inject/codex_enhance/features/project_menu_hook.js',
    'assets/inject/codex_enhance/features/provider_picker.js',
    'assets/inject/codex_enhance/features/shim_menu.js',
    'assets/inject/codex_enhance/features/thread_preview.js',
    'assets/inject/codex_enhance/features/thread_row.js',
    // runtime: 插件兼容层 → scheduler 主循环 → bootstrap 启动序列
    'assets/inject/codex_enhance/runtime/plugins.js',
    'assets/inject/codex_enhance/runtime/scheduler.js',
    'assets/inject/codex_enhance/runtime/bootstrap.js',
    // 面向用户脚本的 SDK,必须排在 codex_enhance 全部装完之后,
    // 用户脚本之前(inject_orchestrator 拼接顺序: [此脚本, ...用户脚本])。
    'assets/inject/shim_api.js',
  ];

  /// debug 模式下直接读项目源码路径下的同名分片, 改完立刻生效 (零重启)。
  static const String _devShardRoot =
      r'F:\Programming_projects\FlutterProject\shim\';

  final Dio _dio;

  InjectQueryDatasource() : _dio = _buildLoopbackDio();

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

  /// 加载注入脚本: 按 _injectShards 顺序读取每个分片, 用空行拼接。
  /// - debug 模式从项目源码目录读 (改完立刻生效, 零重启)
  /// - release 模式从打包进 app 的 asset 读
  /// 分片之间用 '\n\n' 隔开, 每片自带 once-guard, 拼接后整体仍是一个合法 JS 字符串。
  Future<String> loadInjectScript() async {
    final buffer = StringBuffer();
    for (final shard in _injectShards) {
      String? content;
      if (kDebugMode) {
        final devFile = File(_devShardRoot + shard.replaceAll('/', r'\'));
        if (await devFile.exists()) {
          content = await devFile.readAsString();
        }
      }
      content ??= await rootBundle.loadString(shard);
      buffer.writeln(content);
      buffer.writeln();
    }
    return buffer.toString();
  }

  /// 在 page target 上拿到 devtoolsFrontendUrl，用于系统浏览器打开完整 DevTools。
  ///
  /// Chromium 默认返回的 URL 形如
  ///   `https://chrome-devtools-frontend.appspot.com/serve_rev/@<hash>/inspector.html?ws=127.0.0.1:<port>/...`
  /// appspot 在国内被墙,这里把 host 改写成 `127.0.0.1:<port>`,
  /// 用 Codex 自带的 DevTools 前端,完全走本地,不需要 VPN。
  Future<String?> findDevtoolsUrl(int debugPort) async {
    try {
      final response = await _dio.getUri<List<dynamic>>(
        Uri.parse('http://127.0.0.1:$debugPort/json'),
      );
      final targets = response.data ?? const [];
      for (final raw in targets) {
        final target = raw as Map<String, dynamic>;
        if (target['type'] != 'page') continue;
        final wsUrl = target['webSocketDebuggerUrl'] as String?;
        final relative = target['devtoolsFrontendUrl'] as String?;
        if (wsUrl != null && wsUrl.isNotEmpty) {
          final wsPath = Uri.parse(
            wsUrl,
          ).toString().replaceFirst(RegExp(r'^wss?://'), '');
          return 'http://127.0.0.1:$debugPort/devtools/inspector.html?ws=$wsPath';
        }
        if (relative != null && relative.isNotEmpty) {
          if (relative.startsWith('http')) {
            return _rewriteAppspotToLocal(relative, debugPort);
          }
          return 'http://127.0.0.1:$debugPort$relative';
        }
      }
    } catch (_) {}
    return null;
  }

  String _rewriteAppspotToLocal(String url, int debugPort) {
    final appspot = RegExp(
      r'^https?://chrome-devtools-frontend\.appspot\.com/serve_rev/@[^/]+/',
    );
    if (appspot.hasMatch(url)) {
      return url.replaceFirst(appspot, 'http://127.0.0.1:$debugPort/devtools/');
    }
    return url;
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
