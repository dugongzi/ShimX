import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:shimx/core/utils/codex_mcp_config_toml_codec.dart';
import 'package:shimx/features/mcp/data/datasources/mcp_server_query_datasource.dart';
import 'package:shimx/features/mcp/data/models/codex_mcp_config_dto.dart';

class CodexMcpConfigQueryDatasource {
  CodexMcpConfigQueryDatasource({File? configFile}) : _configFile = configFile;

  final File? _configFile;

  Future<List<CodexMcpConfigDto>> listConfigs() async {
    final file = _codexConfigFile();
    if (file == null || !await file.exists()) return [];
    final fragments = parseCodexMcpConfigs(
      await file.readAsString(encoding: utf8),
      excludedMcpId: McpServerQueryDatasource.shimxClaudeId,
    );
    return fragments
        .map(
          (fragment) => CodexMcpConfigDto(
            id: fragment.id,
            kind: fragment.kind,
            bodyText: fragment.bodyText,
            enabled: fragment.enabled,
            managedByShimX: fragment.managedByShimX,
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
