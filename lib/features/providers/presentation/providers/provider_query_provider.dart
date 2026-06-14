import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shim/core/services/app_storage.dart';
import 'package:shim/features/providers/data/datasources/provider_query_datasource.dart';
import 'package:shim/features/providers/data/repositories/provider_query_repository_impl.dart';
import 'package:shim/features/providers/domain/models/provider_list_state.dart';
import 'package:shim/features/providers/domain/models/proxy_config.dart';
import 'package:shim/features/providers/domain/repositories/provider_query_repository.dart';

part 'provider_query_provider.g.dart';

@riverpod
ProviderQueryRepository providerQueryRepository(Ref ref) {
  return ProviderQueryRepositoryImpl(
    dataSource: ProviderQueryDatasource(
      appStorage: ref.read(appStorageProvider),
    ),
  );
}

/// 供应商列表 + 当前选中项。action 写入后 invalidate 本 provider 刷新。
@riverpod
Future<ProviderListState> providerList(Ref ref) async {
  final repo = ref.read(providerQueryRepositoryProvider);
  final providers = await repo.listProviders();
  final selectedId = await repo.selectedId();
  return ProviderListState(providers: providers, selectedId: selectedId);
}

/// 本地代理配置（开关 + 端口）。action 写入后 invalidate 本 provider 刷新。
@riverpod
Future<ProxyConfig> proxyConfig(Ref ref) {
  return ref.read(providerQueryRepositoryProvider).proxyConfig();
}
