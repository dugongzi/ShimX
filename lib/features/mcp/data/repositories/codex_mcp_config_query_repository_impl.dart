import 'package:shimx/features/mcp/data/datasources/codex_mcp_config_query_datasource.dart';
import 'package:shimx/features/mcp/domain/models/codex_mcp_config.dart';
import 'package:shimx/features/mcp/domain/repositories/codex_mcp_config_query_repository.dart';

class CodexMcpConfigQueryRepositoryImpl
    implements CodexMcpConfigQueryRepository {
  CodexMcpConfigQueryRepositoryImpl({required this.dataSource});

  final CodexMcpConfigQueryDatasource dataSource;

  @override
  Future<List<CodexMcpConfig>> listConfigs() async {
    final dtos = await dataSource.listConfigs();
    return dtos.map((dto) => dto.toEntity()).toList();
  }
}
