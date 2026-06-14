import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shim/core/services/bridge_service.dart';
import 'package:shim/core/services/cdp_service.dart';
import 'package:shim/core/services/codex_launcher_service.dart';
import 'package:shim/core/services/local_proxy_service.dart';
import 'package:shim/features/codex_session/presentation/providers/codex_session_action_provider.dart';
import 'package:shim/features/codex_session/presentation/providers/codex_session_query_provider.dart';
import 'package:shim/features/home/data/datasources/inject_action_datasource.dart';
import 'package:shim/features/home/data/repositories/inject_action_repository_impl.dart';
import 'package:shim/features/home/domain/repositories/inject_action_repository.dart';
import 'package:shim/features/providers/presentation/providers/provider_action_provider.dart';
import 'package:shim/features/providers/presentation/providers/provider_query_provider.dart';
import 'package:url_launcher/url_launcher.dart';

part 'inject_action_provider.g.dart';

@riverpod
InjectActionDatasource injectActionDatasource(Ref ref) {
  return InjectActionDatasource();
}

@riverpod
InjectActionRepository injectActionRepository(Ref ref) {
  final dataSource = ref.watch(injectActionDatasourceProvider);
  return InjectActionRepositoryImpl(dataSource: dataSource);
}

@riverpod
Future<bool> isDebugPortAlive(Ref ref, {required int debugPort}) async {
  return ref
      .read(injectActionRepositoryProvider)
      .isDebugPortAlive(debugPort: debugPort);
}

@riverpod
Future<void> openInspector(Ref ref, {required int debugPort}) async {
  final repo = ref.read(injectActionRepositoryProvider);
  final url = await repo.findDevtoolsUrl(debugPort: debugPort);
  if (url == null) {
    throw Exception('未检测到 Codex 正在运行');
  }
  await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
}

@riverpod
Future<void> waitForDebugPort(Ref ref, {required int debugPort}) async {
  await ref
      .read(injectActionRepositoryProvider)
      .waitForDebugPort(debugPort: debugPort);
}

@riverpod
Future<String> loadInjectScript(Ref ref) async {
  return ref.read(injectActionRepositoryProvider).loadInjectScript();
}

/// 直接注入到端口（要求端口上已经有 page），建立 CDP 长连接并安装 bridge + 脚本
@riverpod
Future<void> injectToRunningPort(Ref ref, {required int debugPort}) async {
  final repo = ref.read(injectActionRepositoryProvider);
  final cdp = ref.read(cdpServiceProvider);
  final bridge = ref.read(bridgeServiceProvider);
  ref.read(codexSessionRouteRegistrationProvider);
  ref.read(codexSessionActionRouteRegistrationProvider);
  final script = await repo.loadInjectScript();
  await cdp.connect(debugPort);
  await bridge.install(documentScripts: [script]);
}

/// 完整流程：
/// - 端口活 → 直接连上现有 Codex 并注入
/// - 端口不活 → 自动发现 + 启动 Codex（Windows: COM 激活 UWP；macOS: open .app）→ 等就绪 → 注入
///
/// Codex 未安装时抛 CodexNotInstalledException
@Riverpod(keepAlive: true)
Future<void> launchAndInject(Ref ref, {required int debugPort}) async {
  // 所有 ref 依赖在第一个 await 前读出（避免 autoDispose provider 在 async gap 后用 ref）
  final repo = ref.read(injectActionRepositoryProvider);
  final cdp = ref.read(cdpServiceProvider);
  final bridge = ref.read(bridgeServiceProvider);
  final launcher = ref.read(codexLauncherServiceProvider);
  final proxy = ref.read(localProxyServiceProvider);
  final runningProxyPort = ref.read(localProxyRunningPortProvider);
  final takeoverRepo = ref.read(providerActionRepositoryProvider);
  ref.read(codexSessionRouteRegistrationProvider);
  ref.read(codexSessionActionRouteRegistrationProvider);
  final proxyConfigFuture = ref.read(proxyConfigProvider.future);
  final providerListFuture = ref.read(providerListProvider.future);

  final proxyConfig = await proxyConfigFuture;
  if (!ref.mounted) return;
  final providerList = await providerListFuture;
  if (!ref.mounted) return;
  final selected = providerList.selected;

  // 接管开启：先起反向代理 + 设转发目标 + 改写 config.toml 的 base_url。
  // base_url 指向本地代理后，Codex 的 app-server 就会把模型请求发到代理，
  // 代理再按选中供应商转发到真实地址（零重启切换）。
  if (proxyConfig.enabled &&
      selected != null &&
      selected.baseUrl.isNotEmpty &&
      selected.apiKey.isNotEmpty) {
    await proxy.start(
      port: proxyConfig.port,
      target: ProxyTarget(
        baseUrl: selected.baseUrl,
        apiKey: selected.apiKey,
      ),
    );
    runningProxyPort.value = proxy.port ?? proxyConfig.port;
    await takeoverRepo.enableTakeover(localProxyUrl: proxyConfig.localProxyUrl);
  } else {
    // 接管关闭或无选中供应商：还原 base_url，停代理。
    await takeoverRepo.disableTakeover();
    await proxy.stop();
    runningProxyPort.value = null;
  }
  if (!ref.mounted) return;

  final alive = await repo.isDebugPortAlive(debugPort: debugPort);
  if (!ref.mounted) return;
  if (!alive) {
    await launcher.launchCodex(debugPort: debugPort);
    await repo.waitForDebugPort(debugPort: debugPort);
  }

  final script = await repo.loadInjectScript();
  if (!ref.mounted) return;
  await cdp.connect(debugPort);
  await bridge.install(documentScripts: [script]);
}
