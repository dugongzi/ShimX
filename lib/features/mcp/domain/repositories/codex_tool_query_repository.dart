import 'package:shim/features/mcp/domain/models/codex_tool.dart';

abstract class CodexToolQueryRepository {
  Future<List<CodexTool>> listTools();
}
