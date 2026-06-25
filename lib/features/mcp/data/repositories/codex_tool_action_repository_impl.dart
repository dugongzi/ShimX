import 'package:shim/features/mcp/data/datasources/codex_tool_action_datasource.dart';
import 'package:shim/features/mcp/data/models/codex_tool_dto.dart';
import 'package:shim/features/mcp/domain/models/codex_tool.dart';
import 'package:shim/features/mcp/domain/repositories/codex_tool_action_repository.dart';

class CodexToolActionRepositoryImpl implements CodexToolActionRepository {
  CodexToolActionRepositoryImpl({required this.dataSource});

  final CodexToolActionDatasource dataSource;

  @override
  Future<void> saveTool(CodexTool tool) {
    return dataSource.saveTool(CodexToolDto.fromEntity(tool));
  }

  @override
  Future<void> deleteTool({required String kind, required String id}) {
    return dataSource.deleteTool(kind: kind, id: id);
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
