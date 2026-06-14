import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shim/core/services/app_storage.dart';
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
}

/// 选中供应商
@riverpod
Future<void> selectProvider(Ref ref, {required String id}) async {
  final repo = ref.read(providerActionRepositoryProvider);
  await repo.saveSelectedId(id);
  ref.invalidate(providerListProvider);
}

/// 设置代理开关
@riverpod
Future<void> setProxyEnabled(Ref ref, {required bool enabled}) async {
  final repo = ref.read(providerActionRepositoryProvider);
  await repo.saveProxyEnabled(enabled);
  ref.invalidate(proxyConfigProvider);
}

/// 设置代理端口
@riverpod
Future<void> setProxyPort(Ref ref, {required int port}) async {
  final repo = ref.read(providerActionRepositoryProvider);
  await repo.saveProxyPort(port.clamp(1, 65535));
  ref.invalidate(proxyConfigProvider);
}
