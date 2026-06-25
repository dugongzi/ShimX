import 'package:shim/features/mcp/domain/models/codex_tool.dart';

abstract class CodexToolActionRepository {
  Future<void> saveTool(CodexTool tool);

  Future<void> deleteTool({required String kind, required String id});

  Future<void> setEnabled({
    required String kind,
    required String id,
    required bool enabled,
  });
}
