import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shim/core/services/bridge_service.dart';
import 'package:shim/core/services/provider_health_probe_service.dart';
import 'package:shim/features/providers/data/datasources/provider_health_datasource.dart';
import 'package:shim/features/providers/data/repositories/provider_health_repository_impl.dart';
import 'package:shim/features/providers/domain/models/provider_health.dart';
import 'package:shim/features/providers/domain/repositories/provider_health_repository.dart';
import 'package:shim/features/providers/presentation/providers/provider_query_provider.dart';

part 'provider_health_provider.g.dart';

@Riverpod(keepAlive: true)
ProviderHealthRepository providerHealthRepository(Ref ref) {
  final dataSource = ProviderHealthDatasource();
  ref.onDispose(dataSource.dispose);
  return ProviderHealthRepositoryImpl(dataSource: dataSource);
}

@Riverpod(keepAlive: true)
ProviderHealthProbeService providerHealthProbeService(Ref ref) {
  final repository = ref.read(providerHealthRepositoryProvider);
  final service = ProviderHealthProbeService(repository: repository);
  ref.onDispose(service.stop);
  return service;
}

/// 订阅式快照，给 UI 用。
@Riverpod(keepAlive: true)
Stream<Map<String, ProviderHealth>> providerHealthStream(Ref ref) {
  return ref.read(providerHealthRepositoryProvider).watch();
}

/// 把测速相关路由注册到 bridge。注入时 watch 一次让它生效。
///
/// /provider/health/refresh — 触发一次按需测速。
///   payload.id    指定测哪家;不传 = 测当前选中那家(默认行为,最省请求)
///   payload.scope 'selected' (默认) | 'all' (用户主动点"刷新全部"才传)
///   payload.force 跳过 60s cooldown(用户手动刷新才传)
@Riverpod(keepAlive: true)
bool providerHealthRouteRegistration(Ref ref) {
  final bridge = ref.read(bridgeServiceProvider);
  final probe = ref.read(providerHealthProbeServiceProvider);
  final queryRepo = ref.read(providerQueryRepositoryProvider);

  bridge.register('/provider/health/refresh', (payload) async {
    final id = (payload['id'] as String?)?.trim();
    final scope = (payload['scope'] as String?)?.trim();
    final force = payload['force'] == true;
    final providers = await queryRepo.listProviders();
    probe.updateTargets(providers: providers);

    if (id != null && id.isNotEmpty) {
      final target = providers.where((p) => p.id == id).cast().firstOrNull;
      if (target == null) {
        throw ArgumentError('provider not found: $id');
      }
      await probe.probeOne(target, force: force);
      return {'ok': true, 'probed': 1, 'scope': 'one'};
    }

    if (scope == 'all') {
      await probe.probeAll(force: force);
      return {'ok': true, 'probed': providers.length, 'scope': 'all'};
    }

    // 默认:只测当前选中的一家
    final selectedId = await queryRepo.selectedId();
    if (selectedId == null) return {'ok': true, 'probed': 0, 'scope': 'none'};
    await probe.probeAll(onlyIds: {selectedId}, force: force);
    return {'ok': true, 'probed': 1, 'scope': 'selected'};
  });

  return true;
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iter = iterator;
    return iter.moveNext() ? iter.current : null;
  }
}
