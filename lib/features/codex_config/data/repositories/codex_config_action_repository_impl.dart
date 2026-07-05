import 'package:shim/features/codex_config/data/datasources/codex_config_action_datasource.dart';
import 'package:shim/features/codex_config/domain/repositories/codex_config_action_repository.dart';

class CodexConfigActionRepositoryImpl implements CodexConfigActionRepository {
  CodexConfigActionRepositoryImpl({required this.dataSource});

  final CodexConfigActionDatasource dataSource;

  @override
  Future<void> writeModelProvider(String value) =>
      dataSource.writeModelProvider(value);

  @override
  Future<void> writeModelProviderWithSection({
    required String value,
    required String baseUrl,
  }) =>
      dataSource.writeModelProvider(value, ensureBaseUrl: baseUrl);
}
