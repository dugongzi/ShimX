import 'package:freezed_annotation/freezed_annotation.dart';

part 'codex_tool.freezed.dart';

@freezed
abstract class CodexTool with _$CodexTool {
  const CodexTool._();

  const factory CodexTool({
    required String id,
    required String kind,
    required String bodyText,
    required bool enabled,
    required bool managedByShim,
    required bool readOnly,
    @Default('') String name,
    @Default('') String description,
  }) = _CodexTool;
}

class CodexToolKind {
  const CodexToolKind._();

  static const mcpServer = 'mcpServer';
  static const skill = 'skill';

  static const values = [mcpServer, skill];

  static String tableName(String kind) {
    return switch (kind) {
      mcpServer => 'mcp_servers',
      skill => 'skills',
      _ => throw ArgumentError('Unsupported Codex tool kind: $kind'),
    };
  }

  static String label(String kind) {
    return switch (kind) {
      mcpServer => 'MCP',
      skill => 'Skill',
      _ => kind,
    };
  }

  static String fromTableName(String tableName) {
    return switch (tableName) {
      'mcp_servers' => mcpServer,
      'skills' => skill,
      _ => throw ArgumentError('Unsupported Codex tool table: $tableName'),
    };
  }
}
