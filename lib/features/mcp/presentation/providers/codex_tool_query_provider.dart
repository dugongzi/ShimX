import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shim/features/mcp/data/datasources/codex_tool_query_datasource.dart';
import 'package:shim/features/mcp/data/repositories/codex_tool_query_repository_impl.dart';
import 'package:shim/features/mcp/domain/models/codex_tool.dart';
import 'package:shim/features/mcp/domain/repositories/codex_tool_query_repository.dart';

part 'codex_tool_query_provider.g.dart';

@riverpod
CodexToolQueryRepository codexToolQueryRepository(Ref ref) {
  return CodexToolQueryRepositoryImpl(dataSource: CodexToolQueryDatasource());
}

@riverpod
Future<List<CodexTool>> codexTools(Ref ref) {
  return ref.read(codexToolQueryRepositoryProvider).listTools();
}
