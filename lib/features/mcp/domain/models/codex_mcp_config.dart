import 'package:freezed_annotation/freezed_annotation.dart';

part 'codex_mcp_config.freezed.dart';

@freezed
abstract class CodexMcpConfig with _$CodexMcpConfig {
  const CodexMcpConfig._();

  const factory CodexMcpConfig({
    required String id,
    required String kind,
    required String bodyText,
    required bool enabled,
    required bool managedByShim,
    required bool readOnly,
    @Default('') String name,
    @Default('') String description,
  }) = _CodexMcpConfig;
}

class CodexMcpConfigKind {
  const CodexMcpConfigKind._();

  static const mcpServer = 'mcpServer';

  static const values = [mcpServer];

  static String tableName(String kind) {
    return switch (kind) {
      mcpServer => 'mcp_servers',
      _ => throw ArgumentError('Unsupported Codex MCP config kind: $kind'),
    };
  }

  static String label(String kind) {
    return switch (kind) {
      mcpServer => 'MCP',
      _ => kind,
    };
  }

  static String fromTableName(String tableName) {
    return switch (tableName) {
      'mcp_servers' => mcpServer,
      _ => throw ArgumentError(
        'Unsupported Codex MCP config table: $tableName',
      ),
    };
  }
}
