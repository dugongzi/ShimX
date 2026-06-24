import 'package:shim/features/mcp/data/datasources/mcp_server_query_datasource.dart';
import 'package:shim/features/mcp/domain/models/mcp_server_info.dart';
import 'package:shim/features/mcp/domain/repositories/mcp_server_query_repository.dart';

class McpServerQueryRepositoryImpl implements McpServerQueryRepository {
  final McpServerQueryDatasource dataSource;

  McpServerQueryRepositoryImpl({required this.dataSource});

  @override
  Future<List<McpServerInfo>> listServers() async {
    final dtos = await dataSource.listServers();
    return dtos.map((d) => d.toEntity()).toList();
  }

  @override
  Future<bool?> enabled() => dataSource.enabled();

  @override
  Future<bool> isRegisteredInCodex({required String id}) =>
      dataSource.isRegisteredInCodex(id);
}
