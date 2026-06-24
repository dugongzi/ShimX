import 'package:shim/features/mcp/data/datasources/mcp_server_action_datasource.dart';
import 'package:shim/features/mcp/domain/repositories/mcp_server_action_repository.dart';

class McpServerActionRepositoryImpl implements McpServerActionRepository {
  final McpServerActionDatasource dataSource;

  McpServerActionRepositoryImpl({required this.dataSource});

  @override
  Future<void> saveEnabled(bool enabled) => dataSource.saveEnabled(enabled);

  @override
  Future<bool> registerInCodex({required String id, required String url}) =>
      dataSource.registerInCodex(id: id, url: url);

  @override
  Future<bool> unregisterFromCodex({required String id}) =>
      dataSource.unregisterFromCodex(id: id);
}
