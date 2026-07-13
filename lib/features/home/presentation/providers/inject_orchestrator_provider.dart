import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shimx/core/providers/codex_launch_target_provider.dart';
import 'package:shimx/core/providers/tool_filter_keywords_provider.dart';
import 'package:shimx/core/services/app_log_service.dart';
import 'package:shimx/core/services/bridge_service.dart';
import 'package:shimx/core/services/cdp_service.dart';
import 'package:shimx/core/services/codex_launcher_service.dart';
import 'package:shimx/features/claude_session/presentation/providers/claude_session_bridge_provider.dart';
import 'package:shimx/features/codex_session/presentation/providers/codex_session_bridge_provider.dart';
import 'package:shimx/features/home/presentation/providers/inject_query_provider.dart';
import 'package:shimx/features/logs/presentation/providers/logs_bridge_provider.dart';
import 'package:shimx/features/mcp/presentation/providers/claude_bridge_bridge_provider.dart';
import 'package:shimx/features/mcp/presentation/providers/claude_bridge_query_provider.dart';
import 'package:shimx/features/plugins/presentation/providers/plugin_bridge_provider.dart';
import 'package:shimx/features/polish/presentation/providers/polish_bridge_provider.dart';
import 'package:shimx/features/providers/presentation/providers/auto_switch_provider.dart';
import 'package:shimx/core/services/takeover_service.dart';
import 'package:shimx/features/providers/presentation/providers/provider_action_bridge_provider.dart';
import 'package:shimx/features/providers/presentation/providers/provider_health_provider.dart';
import 'package:shimx/features/providers/presentation/providers/provider_query_provider.dart';
import 'package:shimx/features/scripts/domain/repositories/script_query_repository.dart';
import 'package:shimx/features/scripts/presentation/providers/script_query_provider.dart';

part 'inject_orchestrator_provider.g.dart';

/// 读所有 enabled 用户脚本文件,按脚本顺序返回代码列表。
/// enabled 判定走 [ScriptQueryRepository.isScriptEnabled] (SharedPreferences)。
///
/// **调用方约定**:必须传入已经在 async gap 之前从 ref 读出的 repo,
/// 否则 autoDispose provider(如 [injectToRunningPort])在 `await` 后
/// 已 disposed,再用 `ref.read(...)` 会抛 "Ref after disposed"。
/// 任何 IO / 读盘失败静默跳过——用户脚本不应阻断内置 codex_enhance 注入。
Future<List<String>> _loadEnabledUserScripts(
  ScriptQueryRepository repo,
) async {
  try {
    final scripts = await repo.listScripts();
    final result = <String>[];
    for (final s in scripts) {
      final enabled = await repo.isScriptEnabled(id: s.id);
      if (enabled) result.add(s.code);
    }
    return result;
  } catch (_) {
    return const [];
  }
}

/// 触发全部跨 feature 的 bridge 路由注册。注入前必须先跑一次,确保 codex_enhance.js
/// 调用 `/session/list` `/provider/list` 等路由时 dart 侧已挂上 handler。
///
/// 单纯 `container.read(...Provider)` 触发 keepAlive provider 的 build,代价≈零;
/// 重复读不会重新注册(provider 自己幂等)。走 [ProviderContainer] 是为了不绑
/// 死在 autoDispose provider 生命周期上——UI action 长流程里 ref 可能中途 dispose。
void _registerAllBridgeRoutes(ProviderContainer container) {
  container.read(codexSessionRouteRegistrationProvider);
  container.read(claudeSessionRouteRegistrationProvider);
  container.read(providerRouteRegistrationProvider);
  container.read(providerHealthRouteRegistrationProvider);
  container.read(autoSwitchRouteRegistrationProvider);
  container.read(providerActionRouteRegistrationProvider);
  container.read(logsBridgeRouteRegistrationProvider);
  container.read(claudeBridgeRouteRegistrationProvider);
  container.read(pluginBridgeRouteRegistrationProvider);
  container.read(polishBridgeRouteRegistrationProvider);
  container.read(toolFilterRouteRegistrationProvider);
}

/// 直接注入到端口(要求端口上已经有 page),建立 CDP 长连接并安装 bridge + 脚本。
@riverpod
Future<void> injectToRunningPort(Ref ref, {required int debugPort}) =>
    runInjectToRunningPort(ref.container, debugPort: debugPort);

Future<void> runInjectToRunningPort(
  ProviderContainer container, {
  required int debugPort,
}) async {
  final repo = container.read(injectQueryRepositoryProvider);
  final scriptsRepo = container.read(scriptQueryRepositoryProvider);
  final cdp = container.read(cdpServiceProvider);
  final bridge = container.read(bridgeServiceProvider);
  _registerAllBridgeRoutes(container);
  await container.read(claudeBridgeQueryRepositoryProvider).ensureHydrated();
  final script = await repo.loadInjectScript();
  final userScripts = await _loadEnabledUserScripts(scriptsRepo);
  await cdp.connect(debugPort);
  await bridge.install(documentScripts: [script, ...userScripts]);
}

/// codex 已经在跑但没开 `--remote-debugging-port` 时抛这个。UI 层捕获后可以
/// 给用户一句人话:请退出 codex 后再点注入,让 shim 用调试参数把它拉起来。
class CodexRunningWithoutDebugException implements Exception {
  const CodexRunningWithoutDebugException();
  @override
  String toString() =>
      'codex 已在运行但未启用 CDP 调试端口。请先完全退出 codex,再点击注入让 shim 用调试参数重启它。';
}

/// 完整流程:
/// - 端口活 → 直接连上现有 Codex 并注入
/// - 端口不活 → 自动发现 + 启动 Codex(Windows: COM 激活 UWP;macOS: open .app)→ 等就绪 → 注入
///
/// Codex 未安装时抛 [CodexNotInstalledException]。
/// codex 已运行但没开 CDP 时抛 [CodexRunningWithoutDebugException]。
///
/// provider 版本供 tray/shortcut 场景("成功/失败任意都行,只关心结束"),
/// UI 精细异常处理请直接调 [runLaunchAndInject]。
@riverpod
Future<void> launchAndInject(Ref ref, {required int debugPort}) =>
    runLaunchAndInject(ref.container, debugPort: debugPort);

/// [launchAndInject] 的 [ProviderContainer] 版本。UI 拿 `WidgetRef.container`
/// 直接调这个,长流程里 `.read()` 全走容器,不受 autoDispose provider 生命周期
/// 影响,异常按 Dart 语义原样冒到调用方。
Future<void> runLaunchAndInject(
  ProviderContainer container, {
  required int debugPort,
}) async {
  final repo = container.read(injectQueryRepositoryProvider);
  final scriptsRepo = container.read(scriptQueryRepositoryProvider);
  final cdp = container.read(cdpServiceProvider);
  final bridge = container.read(bridgeServiceProvider);
  final launcher = container.read(codexLauncherServiceProvider);
  final userTarget = container.read(codexLaunchTargetProvider);
  final log = AppLogService.instance;

  log.info('Inject', '开始:launchAndInject port=$debugPort');
  _registerAllBridgeRoutes(container);
  log.debug('Inject', '路由注册完成');
  await container.read(claudeBridgeQueryRepositoryProvider).ensureHydrated();
  log.debug('Inject', 'claude bridge 数据已加载');

  // 接管开关开着 → 完整接管(起代理 + 改 config);否则释放。
  log.debug('Inject', '进入 startTakeover');
  await startTakeoverContainer(container);
  log.debug('Inject', 'startTakeover 结束');

  log.debug('Inject', '检查 debug 端口存活');
  final alive = await repo.isDebugPortAlive(debugPort: debugPort);
  log.info('Inject', 'debug 端口 alive=$alive');
  if (!alive) {
    // 端口没活,先看 codex 进程是不是已经在跑。已在跑就是"用户手动开了 codex
    // 而没走 shim",这种情况下再 launchCodex 也没用(codex 单实例,不会开
    // 第二份带调试端口的),要求用户先退出。
    log.debug('Inject', '端口未活,检查 codex 进程');
    final running = await launcher.isCodexRunning(userTarget: userTarget);
    log.info('Inject', 'codex 进程 running=$running');
    if (running) {
      log.warning('Inject', '即将抛出 CodexRunningWithoutDebugException');
      throw const CodexRunningWithoutDebugException();
    }
    log.info('Inject', '启动 codex(带 --remote-debugging-port=$debugPort)');
    await launcher.launchCodex(debugPort: debugPort, userTarget: userTarget);
    log.info('Inject', 'launchCodex 返回,开始等 debug 端口就绪');
    await repo.waitForDebugPort(debugPort: debugPort);
    log.info('Inject', 'debug 端口已就绪');
  }

  log.debug('Inject', '读取注入脚本');
  final script = await repo.loadInjectScript();
  final userScripts = await _loadEnabledUserScripts(scriptsRepo);
  log.debug('Inject', '脚本已就绪,连接 CDP');
  await cdp.connect(debugPort);
  log.debug('Inject', 'CDP 已连接,安装 bridge + 脚本');
  await bridge.install(documentScripts: [script, ...userScripts]);
  log.info('Inject', '完成');
}

/// 已注入状态下手动刷新 Codex 页面 + 重新装 bridge + 重跑脚本。
/// 与 [injectToRunningPort] 区别:这里会先调用 `cdp.reloadPage()`,清掉旧 page 上的脚本副作用。
@riverpod
Future<void> reloadCodexAndReinject(Ref ref, {required int debugPort}) =>
    runReloadCodexAndReinject(ref.container, debugPort: debugPort);

Future<void> runReloadCodexAndReinject(
  ProviderContainer container, {
  required int debugPort,
}) async {
  final repo = container.read(injectQueryRepositoryProvider);
  final scriptsRepo = container.read(scriptQueryRepositoryProvider);
  final cdp = container.read(cdpServiceProvider);
  final bridge = container.read(bridgeServiceProvider);
  _registerAllBridgeRoutes(container);
  await container.read(claudeBridgeQueryRepositoryProvider).ensureHydrated();

  await cdp.connect(debugPort);
  await cdp.reloadPage();
  await Future<void>.delayed(const Duration(milliseconds: 800));
  final script = await repo.loadInjectScript();
  final userScripts = await _loadEnabledUserScripts(scriptsRepo);
  await bridge.install(documentScripts: [script, ...userScripts]);
}
