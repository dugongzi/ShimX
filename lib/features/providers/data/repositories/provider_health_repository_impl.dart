import 'package:shim/features/providers/data/datasources/provider_health_datasource.dart';
import 'package:shim/features/providers/domain/models/provider_health.dart';
import 'package:shim/features/providers/domain/repositories/provider_health_repository.dart';

class ProviderHealthRepositoryImpl implements ProviderHealthRepository {
  final ProviderHealthDatasource dataSource;

  ProviderHealthRepositoryImpl({required this.dataSource});

  @override
  Map<String, ProviderHealth> snapshot() => dataSource.snapshot();

  @override
  ProviderHealth? read({required String providerId}) =>
      dataSource.read(providerId);

  @override
  void write({required ProviderHealth health}) {
    dataSource.write(health);
  }

  @override
  void remove({required String providerId}) {
    dataSource.remove(providerId);
  }

  @override
  Stream<Map<String, ProviderHealth>> watch() => dataSource.watch();
}
