import 'package:shim/features/mcp/domain/models/codex_mcp_config.dart';

abstract class CodexMcpConfigActionRepository {
  Future<void> saveConfig(CodexMcpConfig config);

  Future<void> deleteConfig({required String kind, required String id});

  Future<void> setEnabled({
    required String kind,
    required String id,
    required bool enabled,
  });
}
