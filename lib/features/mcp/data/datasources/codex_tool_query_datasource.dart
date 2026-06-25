import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:shim/core/utils/codex_tool_toml_codec.dart';
import 'package:shim/features/mcp/data/datasources/mcp_server_query_datasource.dart';
import 'package:shim/features/mcp/data/models/codex_tool_dto.dart';

class CodexToolQueryDatasource {
  CodexToolQueryDatasource({File? configFile}) : _configFile = configFile;

  final File? _configFile;

  Future<List<CodexToolDto>> listTools() async {
    final file = _codexConfigFile();
    if (file == null || !await file.exists()) return [];
    final fragments = parseCodexTools(
      await file.readAsString(encoding: utf8),
      excludedMcpId: McpServerQueryDatasource.shimClaudeId,
    );
    return fragments
        .map(
          (fragment) => CodexToolDto(
            id: fragment.id,
            kind: fragment.kind,
            bodyText: fragment.bodyText,
            enabled: fragment.enabled,
            managedByShim: fragment.managedByShim,
            readOnly: fragment.readOnly,
            name: fragment.name,
            description: fragment.description,
          ),
        )
        .toList();
  }

  File? _codexConfigFile() {
    if (_configFile != null) return _configFile;
    final home = Platform.isWindows
        ? Platform.environment['USERPROFILE']
        : Platform.environment['HOME'];
    if (home == null || home.isEmpty) return null;
    return File(p.join(home, '.codex', 'config.toml'));
  }
}
