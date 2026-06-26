import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shim/features/mcp/data/datasources/codex_mcp_config_query_datasource.dart';
import 'package:shim/features/mcp/data/repositories/codex_mcp_config_query_repository_impl.dart';
import 'package:shim/features/mcp/domain/models/codex_mcp_config.dart';
import 'package:shim/features/mcp/domain/repositories/codex_mcp_config_query_repository.dart';

part 'codex_mcp_config_query_provider.g.dart';

@riverpod
CodexMcpConfigQueryRepository codexMcpConfigQueryRepository(Ref ref) {
  return CodexMcpConfigQueryRepositoryImpl(
    dataSource: CodexMcpConfigQueryDatasource(),
  );
}

@riverpod
Future<List<CodexMcpConfig>> codexMcpConfigs(Ref ref) {
  return ref.read(codexMcpConfigQueryRepositoryProvider).listConfigs();
}
