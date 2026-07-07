import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shimx/core/services/app_storage.dart';
import 'package:shimx/features/mcp/data/datasources/mcp_server_query_datasource.dart';
import 'package:shimx/features/mcp/data/repositories/mcp_server_query_repository_impl.dart';
import 'package:shimx/features/mcp/domain/models/mcp_server_info.dart';
import 'package:shimx/features/mcp/domain/repositories/mcp_server_query_repository.dart';

part 'mcp_server_query_provider.g.dart';

@riverpod
McpServerQueryRepository mcpServerQueryRepository(Ref ref) {
  return McpServerQueryRepositoryImpl(
    dataSource: McpServerQueryDatasource(
      appStorage: ref.read(appStorageProvider),
    ),
  );
}

/// shimx 暴露的 MCP server 列表(配置 + codex 注册状态)。
/// runtime running 状态由 UI 层结合 [mcpServerRunningPortProvider] 自行覆盖。
@riverpod
Future<List<McpServerInfo>> mcpServerList(Ref ref) {
  return ref.read(mcpServerQueryRepositoryProvider).listServers();
}

/// shimx 内置 MCP server 是否开启;未设置过时返回默认 true。
@riverpod
Future<bool> mcpServerEnabled(Ref ref) async {
  final stored = await ref.read(mcpServerQueryRepositoryProvider).enabled();
  return stored ?? true;
}
