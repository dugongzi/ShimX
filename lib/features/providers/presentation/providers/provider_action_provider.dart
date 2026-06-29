import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shim/core/services/app_storage.dart';
import 'package:shim/core/services/takeover_service.dart';
import 'package:shim/features/providers/data/datasources/provider_action_datasource.dart';
import 'package:shim/features/providers/data/repositories/provider_action_repository_impl.dart';
import 'package:shim/features/providers/domain/models/api_provider.dart';
import 'package:shim/features/providers/domain/repositories/provider_action_repository.dart';
import 'package:shim/features/providers/presentation/providers/provider_query_provider.dart';

part 'provider_action_provider.g.dart';

@riverpod
ProviderActionRepository providerActionRepository(Ref ref) {
  return ProviderActionRepositoryImpl(
    dataSource: ProviderActionDatasource(
      appStorage: ref.read(appStorageProvider),
    ),
  );
}

/// 供应商相关写操作的命令面板。
///
/// 用 Notifier 而不是一堆 family-Future provider:
/// - family-Future provider 按参数缓存(`addProviderProvider(provider: X)` 算一个 key),
///   同 key 第二次 `ref.read(...future)` 拿到的是上次的 completed Future,根本不重跑。
/// - 没人 watch 时 family 会被 auto-dispose,正在跑的 await 后续用 ref 直接抛
///   "Cannot use the Ref ... after it has been disposed"。
/// - Notifier 是单例 + keepAlive,方法每次调用都重新执行,没有缓存复用问题,
///   ref 也不会在异步 gap 后被销毁。
@Riverpod(keepAlive: true)
class ProviderActions extends _$ProviderActions {
  @override
  void build() {}

  /// 新增供应商;列表为空时自动选中第一个加入项。
  Future<void> add(ApiProvider provider) async {
    final repo = ref.read(providerActionRepositoryProvider);
    final query = ref.read(providerQueryRepositoryProvider);
    final current = await query.listProviders();
    final selectedId = await query.selectedId();
    await repo.saveProviders([...current, provider]);
    if (selectedId == null) {
      await repo.saveSelectedId(provider.id);
    }
    ref.invalidate(providerListProvider);
    syncProbeTargets(ref);
  }

  /// 更新供应商。
  Future<void> update(ApiProvider provider) async {
    final repo = ref.read(providerActionRepositoryProvider);
    final query = ref.read(providerQueryRepositoryProvider);
    final current = await query.listProviders();
    final next =
        current.map((p) => p.id == provider.id ? provider : p).toList();
    await repo.saveProviders(next);
    ref.invalidate(providerListProvider);
    // 改的若是当前选中项,热更新运行中的代理目标(链接/key 改了立刻生效)
    await syncRunningProxyTarget(ref);
    syncProbeTargets(ref);
  }

  /// 删除供应商;删的是当前选中项则改选第一个剩余项。
  Future<void> remove(String id) async {
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
    await syncRunningProxyTarget(ref);
    syncProbeTargets(ref);
  }

  /// 选中供应商。
  Future<void> select(String id) async {
    final repo = ref.read(providerActionRepositoryProvider);
    await repo.saveSelectedId(id);
    ref.invalidate(providerListProvider);
    // 切换供应商,热更新运行中的代理目标(零重启)
    await syncRunningProxyTarget(ref);
  }

  /// 设置代理开关:写持久化后立即应用(开 → 接管,关 → 释放)。
  Future<void> setProxyEnabled(bool enabled) async {
    final repo = ref.read(providerActionRepositoryProvider);
    await repo.saveProxyEnabled(enabled);
    // 先执行接管/释放,再 invalidate proxyConfigProvider。
    // 否则 invalidate 时 startTakeover 里 read 出来的 proxyConfig 还是旧值。
    if (enabled) {
      await startTakeover(ref, enabledOverride: true);
    } else {
      await stopTakeover(ref);
    }
    ref.invalidate(proxyConfigProvider);
  }

  /// 设置代理端口。
  Future<void> setProxyPort(int port) async {
    final repo = ref.read(providerActionRepositoryProvider);
    await repo.saveProxyPort(port.clamp(1, 65535));
    ref.invalidate(proxyConfigProvider);
  }
}
