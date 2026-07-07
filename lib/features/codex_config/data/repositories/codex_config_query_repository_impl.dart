import 'package:shimx/features/codex_config/data/datasources/codex_config_query_datasource.dart';
import 'package:shimx/features/codex_config/domain/repositories/codex_config_query_repository.dart';

class CodexConfigQueryRepositoryImpl implements CodexConfigQueryRepository {
  CodexConfigQueryRepositoryImpl({required this.dataSource});

  final CodexConfigQueryDatasource dataSource;

  @override
  Future<String?> readModelProvider() => dataSource.readModelProvider();
}
