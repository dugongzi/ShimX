import 'package:shimx/features/mcp/data/datasources/codex_mcp_config_action_datasource.dart';
import 'package:shimx/features/mcp/data/models/codex_mcp_config_dto.dart';
import 'package:shimx/features/mcp/domain/models/codex_mcp_config.dart';
import 'package:shimx/features/mcp/domain/repositories/codex_mcp_config_action_repository.dart';

class CodexMcpConfigActionRepositoryImpl
    implements CodexMcpConfigActionRepository {
  CodexMcpConfigActionRepositoryImpl({required this.dataSource});

  final CodexMcpConfigActionDatasource dataSource;

  @override
  Future<void> saveConfig(CodexMcpConfig config) {
    return dataSource.saveConfig(CodexMcpConfigDto.fromEntity(config));
  }

  @override
  Future<void> deleteConfig({required String kind, required String id}) {
    return dataSource.deleteConfig(kind: kind, id: id);
  }

  @override
  Future<void> setEnabled({
    required String kind,
    required String id,
    required bool enabled,
  }) {
    return dataSource.setEnabled(kind: kind, id: id, enabled: enabled);
  }
}
