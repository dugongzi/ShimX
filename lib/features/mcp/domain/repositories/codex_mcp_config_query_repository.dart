import 'package:shim/features/mcp/domain/models/codex_mcp_config.dart';

abstract class CodexMcpConfigQueryRepository {
  Future<List<CodexMcpConfig>> listConfigs();
}
