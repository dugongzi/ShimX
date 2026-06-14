import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shim/core/services/app_storage.dart';
import 'package:shim/core/services/local_proxy_service.dart';
import 'package:shim/features/providers/data/datasources/provider_action_datasource.dart';
import 'package:shim/features/providers/data/repositories/provider_action_repository_impl.dart';
import 'package:shim/features/providers/domain/models/api_provider.dart';
import 'package:shim/features/providers/domain/repositories/provider_action_repository.dart';
import 'package:shim/features/providers/presentation/providers/provider_query_provider.dart';

part 'provider_action_provider.g.dart';

/// 若代理正在运行，把当前选中的供应商热更新给代理的转发目标（零重启切换）。
/// update/select 后调用，保证改了链接/换了供应商，运行中的代理立刻生效。
Future<void> _syncRunningProxyTarget(Ref ref) async {
  final proxy = ref.read(localProxyServiceProvider);
  if (!proxy.isRunning) return;
  final query = ref.read(providerQueryRepositoryProvider);
  final selectedId = await query.selectedId();
  if (selectedId == null) return;
  final providers = await query.listProviders();
  ApiProvider? selected;
  for (final p in providers) {
    if (p.id == selectedId) {
      selected = p;
      break;
    }
  }
  if (selected == null ||
      selected.baseUrl.isEmpty ||
      selected.apiKey.isEmpty) {
    return;
  }
  proxy.setTarget(
    ProxyTarget(baseUrl: selected.baseUrl, apiKey: selected.apiKey),
  );
}

@riverpod
ProviderActionRepository providerActionRepository(Ref ref) {
  return ProviderActionRepositoryImpl(
    dataSource: ProviderActionDatasource(
      appStorage: ref.read(appStorageProvider),
    ),
  );
}

/// 新增供应商；列表为空时自动选中第一个加入项。
@riverpod
Future<void> addProvider(Ref ref, {required ApiProvider provider}) async {
  final repo = ref.read(providerActionRepositoryProvider);
  final query = ref.read(providerQueryRepositoryProvider);
  final current = await query.listProviders();
  final selectedId = await query.selectedId();
  await repo.saveProviders([...current, provider]);
  if (selectedId == null) {
    await repo.saveSelectedId(provider.id);
  }
  ref.invalidate(providerListProvider);
}

/// 更新供应商
@riverpod
Future<void> updateProvider(Ref ref, {required ApiProvider provider}) async {
  final repo = ref.read(providerActionRepositoryProvider);
  final query = ref.read(providerQueryRepositoryProvider);
  final current = await query.listProviders();
  final next = current.map((p) => p.id == provider.id ? provider : p).toList();
  await repo.saveProviders(next);
  ref.invalidate(providerListProvider);
  // 改的若是当前选中项，热更新运行中的代理目标（链接/key 改了立刻生效）
  await _syncRunningProxyTarget(ref);
}

/// 删除供应商；删的是当前选中项则改选第一个剩余项。
@riverpod
Future<void> removeProvider(Ref ref, {required String id}) async {
  final repo = ref.read(providerActionRepositoryProvider);
  final query = ref.read(providerQueryRepositoryProvider);
  final current = await query.listProviders();
  final selectedId = await query.selectedId();
  final next = current.where((p) => p.id != id).toList();
  await repo.saveProviders(next);
  if (selectedId == id) {
    await repo.saveSelectedId(next.isEmpty ? null : next.first.id);
  }
  ref.invalidate(providerListProvider);
  await _syncRunningProxyTarget(ref);
}

/// 选中供应商
@riverpod
Future<void> selectProvider(Ref ref, {required String id}) async {
  final repo = ref.read(providerActionRepositoryProvider);
  await repo.saveSelectedId(id);
  ref.invalidate(providerListProvider);
  // 切换供应商，热更新运行中的代理目标（零重启）
  await _syncRunningProxyTarget(ref);
}

/// 设置代理开关：写持久化后立即应用（开 → 接管，关 → 释放）。
@riverpod
Future<void> setProxyEnabled(Ref ref, {required bool enabled}) async {
  final repo = ref.read(providerActionRepositoryProvider);
  await repo.saveProxyEnabled(enabled);
  ref.invalidate(proxyConfigProvider);
  if (enabled) {
    await startTakeover(ref);
  } else {
    await stopTakeover(ref);
  }
}

/// 完整接管：起反向代理 + 设转发目标 + 改写 config.toml 的 base_url。
/// 仅当代理开关开着且有可用的选中供应商时执行。可重复调用（幂等）。
Future<void> startTakeover(Ref ref) async {
  final query = ref.read(providerQueryRepositoryProvider);
  final proxyConfig = await query.proxyConfig();
  if (!proxyConfig.enabled) return;

  final selectedId = await query.selectedId();
  if (selectedId == null) return;
  final providers = await query.listProviders();
  ApiProvider? selected;
  for (final p in providers) {
    if (p.id == selectedId) {
      selected = p;
      break;
    }
  }
  if (selected == null ||
      selected.baseUrl.isEmpty ||
      selected.apiKey.isEmpty) {
    return;
  }

  final proxy = ref.read(localProxyServiceProvider);
  final runningPort = ref.read(localProxyRunningPortProvider);
  await proxy.start(
    port: proxyConfig.port,
    target: ProxyTarget(baseUrl: selected.baseUrl, apiKey: selected.apiKey),
  );
  runningPort.value = proxy.port ?? proxyConfig.port;

  final actionRepo = ref.read(providerActionRepositoryProvider);
  await actionRepo.enableTakeover(localProxyUrl: proxyConfig.localProxyUrl);
}

/// 释放接管：还原 config.toml 的 base_url + 停代理。
Future<void> stopTakeover(Ref ref) async {
  final actionRepo = ref.read(providerActionRepositoryProvider);
  await actionRepo.disableTakeover();
  final proxy = ref.read(localProxyServiceProvider);
  await proxy.stop();
  ref.read(localProxyRunningPortProvider).value = null;
}

/// 启动时自动接管：app 起来就 watch 一次，按持久化的开关状态自动起代理。
/// 开关开着且有选中供应商 → 起代理 + 设 target + 改 config.toml。
@Riverpod(keepAlive: true)
Future<void> proxyAutoStart(Ref ref) async {
  await startTakeover(ref);
}

/// 设置代理端口
@riverpod
Future<void> setProxyPort(Ref ref, {required int port}) async {
  final repo = ref.read(providerActionRepositoryProvider);
  await repo.saveProxyPort(port.clamp(1, 65535));
  ref.invalidate(proxyConfigProvider);
}
