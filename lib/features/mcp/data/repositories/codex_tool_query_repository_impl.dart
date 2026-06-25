import 'package:shim/features/mcp/data/datasources/codex_tool_query_datasource.dart';
import 'package:shim/features/mcp/domain/models/codex_tool.dart';
import 'package:shim/features/mcp/domain/repositories/codex_tool_query_repository.dart';

class CodexToolQueryRepositoryImpl implements CodexToolQueryRepository {
  CodexToolQueryRepositoryImpl({required this.dataSource});

  final CodexToolQueryDatasource dataSource;

  @override
  Future<List<CodexTool>> listTools() async {
    final dtos = await dataSource.listTools();
    return dtos.map((dto) => dto.toEntity()).toList();
  }
}
