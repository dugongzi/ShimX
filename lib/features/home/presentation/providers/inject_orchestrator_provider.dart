import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shim/core/providers/tool_filter_keywords_provider.dart';
import 'package:shim/core/services/bridge_service.dart';
import 'package:shim/core/services/cdp_service.dart';
import 'package:shim/core/services/codex_launcher_service.dart';
import 'package:shim/features/claude_session/presentation/providers/claude_session_bridge_provider.dart';
import 'package:shim/features/codex_session/presentation/providers/codex_session_bridge_provider.dart';
import 'package:shim/features/home/presentation/providers/inject_query_provider.dart';
import 'package:shim/features/logs/presentation/providers/logs_bridge_provider.dart';
import 'package:shim/features/mcp/presentation/providers/claude_bridge_bridge_provider.dart';
import 'package:shim/features/mcp/presentation/providers/claude_bridge_query_provider.dart';
import 'package:shim/features/plugins/presentation/providers/plugin_bridge_provider.dart';
import 'package:shim/features/polish/presentation/providers/polish_bridge_provider.dart';
import 'package:shim/features/providers/presentation/providers/auto_switch_provider.dart';
import 'package:shim/core/services/takeover_service.dart';
import 'package:shim/features/providers/presentation/providers/provider_action_bridge_provider.dart';
import 'package:shim/features/providers/presentation/providers/provider_health_provider.dart';
import 'package:shim/features/providers/presentation/providers/provider_query_provider.dart';
import 'package:shim/features/scripts/domain/repositories/script_query_repository.dart';
import 'package:shim/features/scripts/presentation/providers/script_query_provider.dart';

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
/// 单纯 `ref.read(...Provider)` 触发 keepAlive provider 的 build,代价≈零;
/// 重复读不会重新注册(provider 自己幂等)。
void _registerAllBridgeRoutes(Ref ref) {
  ref.read(codexSessionRouteRegistrationProvider);
  ref.read(claudeSessionRouteRegistrationProvider);
  ref.read(providerRouteRegistrationProvider);
  ref.read(providerHealthRouteRegistrationProvider);
  ref.read(autoSwitchRouteRegistrationProvider);
  ref.read(providerActionRouteRegistrationProvider);
  ref.read(logsBridgeRouteRegistrationProvider);
  ref.read(claudeBridgeRouteRegistrationProvider);
  ref.read(pluginBridgeRouteRegistrationProvider);
  ref.read(polishBridgeRouteRegistrationProvider);
  ref.read(toolFilterRouteRegistrationProvider);
}

/// 直接注入到端口(要求端口上已经有 page),建立 CDP 长连接并安装 bridge + 脚本。
@riverpod
Future<void> injectToRunningPort(Ref ref, {required int debugPort}) async {
  final repo = ref.read(injectQueryRepositoryProvider);
  final scriptsRepo = ref.read(scriptQueryRepositoryProvider);
  final cdp = ref.read(cdpServiceProvider);
  final bridge = ref.read(bridgeServiceProvider);
  _registerAllBridgeRoutes(ref);
  await ref.read(claudeBridgeQueryRepositoryProvider).ensureHydrated();
  final script = await repo.loadInjectScript();
  final userScripts = await _loadEnabledUserScripts(scriptsRepo);
  await cdp.connect(debugPort);
  await bridge.install(documentScripts: [script, ...userScripts]);
}

/// 完整流程:
/// - 端口活 → 直接连上现有 Codex 并注入
/// - 端口不活 → 自动发现 + 启动 Codex(Windows: COM 激活 UWP;macOS: open .app)→ 等就绪 → 注入
///
/// Codex 未安装时抛 [CodexNotInstalledException]。
@Riverpod(keepAlive: true)
Future<void> launchAndInject(Ref ref, {required int debugPort}) async {
  // 所有 ref 依赖在第一个 await 前读出(避免 autoDispose provider 在 async gap 后用 ref)
  final repo = ref.read(injectQueryRepositoryProvider);
  final scriptsRepo = ref.read(scriptQueryRepositoryProvider);
  final cdp = ref.read(cdpServiceProvider);
  final bridge = ref.read(bridgeServiceProvider);
  final launcher = ref.read(codexLauncherServiceProvider);
  _registerAllBridgeRoutes(ref);
  await ref.read(claudeBridgeQueryRepositoryProvider).ensureHydrated();
  if (!ref.mounted) return;

  // 接管开关开着 → 完整接管(起代理 + 改 config);否则释放。
  await startTakeover(ref);
  if (!ref.mounted) return;

  final alive = await repo.isDebugPortAlive(debugPort: debugPort);
  if (!ref.mounted) return;
  if (!alive) {
    await launcher.launchCodex(debugPort: debugPort);
    await repo.waitForDebugPort(debugPort: debugPort);
  }

  final script = await repo.loadInjectScript();
  final userScripts = await _loadEnabledUserScripts(scriptsRepo);
  if (!ref.mounted) return;
  await cdp.connect(debugPort);
  await bridge.install(documentScripts: [script, ...userScripts]);
}

/// 已注入状态下手动刷新 Codex 页面 + 重新装 bridge + 重跑脚本。
/// 与 [injectToRunningPort] 区别:这里会先调用 `cdp.reloadPage()`,清掉旧 page 上的脚本副作用。
@riverpod
Future<void> reloadCodexAndReinject(Ref ref, {required int debugPort}) async {
  final repo = ref.read(injectQueryRepositoryProvider);
  final scriptsRepo = ref.read(scriptQueryRepositoryProvider);
  final cdp = ref.read(cdpServiceProvider);
  final bridge = ref.read(bridgeServiceProvider);
  _registerAllBridgeRoutes(ref);
  await ref.read(claudeBridgeQueryRepositoryProvider).ensureHydrated();

  await cdp.connect(debugPort);
  await cdp.reloadPage();
  await Future<void>.delayed(const Duration(milliseconds: 800));
  final script = await repo.loadInjectScript();
  final userScripts = await _loadEnabledUserScripts(scriptsRepo);
  await bridge.install(documentScripts: [script, ...userScripts]);
}
