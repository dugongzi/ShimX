import 'package:shim/features/providers/data/datasources/provider_action_datasource.dart';
import 'package:shim/features/providers/data/models/api_provider_dto.dart';
import 'package:shim/features/providers/domain/models/api_provider.dart';
import 'package:shim/features/providers/domain/repositories/provider_action_repository.dart';

class ProviderActionRepositoryImpl implements ProviderActionRepository {
  final ProviderActionDatasource dataSource;

  ProviderActionRepositoryImpl({required this.dataSource});

  @override
  Future<void> saveProviders(List<ApiProvider> providers) {
    final dtos = providers.map(ApiProviderDto.fromEntity).toList();
    return dataSource.saveProviders(dtos);
  }

  @override
  Future<void> saveSelectedId(String? id) {
    return dataSource.saveSelectedId(id);
  }

  @override
  Future<void> saveProxyEnabled(bool enabled) {
    return dataSource.saveProxyEnabled(enabled);
  }

  @override
  Future<void> saveProxyPort(int port) {
    return dataSource.saveProxyPort(port);
  }

  @override
  Future<bool> enableTakeover({required String localProxyUrl}) {
    return dataSource.enableTakeover(localProxyUrl: localProxyUrl);
  }

  @override
  Future<bool> disableTakeover() {
    return dataSource.disableTakeover();
  }
}
