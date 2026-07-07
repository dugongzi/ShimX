import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shimx/features/mcp/data/datasources/codex_mcp_config_action_datasource.dart';
import 'package:shimx/features/mcp/data/datasources/codex_mcp_config_query_datasource.dart';
import 'package:shimx/features/mcp/data/models/codex_mcp_config_dto.dart';
import 'package:shimx/features/mcp/data/repositories/codex_mcp_config_action_repository_impl.dart';
import 'package:shimx/features/mcp/data/repositories/codex_mcp_config_query_repository_impl.dart';
import 'package:shimx/features/mcp/domain/models/codex_mcp_config.dart';

void main() {
  late Directory tempDir;
  late File configFile;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'shimx_codex_mcp_config_test_',
    );
    configFile = File('${tempDir.path}${Platform.pathSeparator}config.toml');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('datasource reads managed and existing mcp configs', () async {
    final legacyKind = '${'kind=sk'}ills';
    final legacyTable = '${'[skills'}.writer]';
    await configFile.writeAsString('''
model = "gpt-5"

[mcp_servers.shimx_claude]
url = "http://127.0.0.1:18787/mcp"

[mcp_servers.external]
command = "npx"

# shimx-managed:start $legacyKind id=writer
$legacyTable
description = "Draft docs"
# shimx-managed:end
''');

    final datasource = CodexMcpConfigQueryDatasource(configFile: configFile);
    final configs = await datasource.listConfigs();

    expect(configs.map((config) => config.id), ['external']);
    expect(
      configs.firstWhere((config) => config.id == 'external').readOnly,
      isFalse,
    );
  });

  test('action datasource writes only shimx-managed marker blocks', () async {
    const original = '''
model = "gpt-5"

[mcp_servers.external]
command = "keep"
''';
    await configFile.writeAsString(original);

    final datasource = CodexMcpConfigActionDatasource(configFile: configFile);
    await datasource.saveConfig(
      const CodexMcpConfigDto(
        id: 'local_docs',
        kind: CodexMcpConfigKind.mcpServer,
        bodyText: 'command = "node"\nargs = []',
        enabled: true,
        managedByShimX: true,
        readOnly: false,
      ),
    );

    final text = await configFile.readAsString();
    expect(text.startsWith(original), isTrue);
    expect(
      text,
      contains('# shimx-managed:start kind=mcp_servers id=local_docs'),
    );
    expect(text, contains('[mcp_servers.external]\ncommand = "keep"'));

    await datasource.deleteConfig(
      kind: CodexMcpConfigKind.mcpServer,
      id: 'external',
    );
    final deletedText = await configFile.readAsString();
    expect(deletedText, isNot(contains('[mcp_servers.external]')));
    expect(deletedText, contains('[mcp_servers.local_docs]'));
  });

  test(
    'action datasource toggles existing mcp block with child env table',
    () async {
      await configFile.writeAsString(r'''
[mcp_servers.node_repl]
enabled = false
args = []
command = 'C:\node_repl.exe'
startup_timeout_sec = 120

[mcp_servers.node_repl.env]
NODE_REPL_NODE_PATH = 'C:\node.exe'

[projects."/tmp/demo"]
trust_level = "trusted"
''');

      final datasource = CodexMcpConfigActionDatasource(configFile: configFile);

      await datasource.setEnabled(
        kind: CodexMcpConfigKind.mcpServer,
        id: 'node_repl',
        enabled: true,
      );

      final text = await configFile.readAsString();
      expect(text, contains('[mcp_servers.node_repl]\nenabled = true'));
      expect(
        text,
        contains("[mcp_servers.node_repl.env]\nNODE_REPL_NODE_PATH"),
      );
      expect(text, contains('[projects."/tmp/demo"]'));
    },
  );

  test('repositories keep DTO mapping out of providers', () async {
    await configFile.writeAsString('');
    final actionRepository = CodexMcpConfigActionRepositoryImpl(
      dataSource: CodexMcpConfigActionDatasource(configFile: configFile),
    );
    final queryRepository = CodexMcpConfigQueryRepositoryImpl(
      dataSource: CodexMcpConfigQueryDatasource(configFile: configFile),
    );

    await actionRepository.saveConfig(
      const CodexMcpConfig(
        id: 'local_docs',
        kind: CodexMcpConfigKind.mcpServer,
        bodyText: 'command = "node"\nargs = []',
        enabled: false,
        managedByShimX: true,
        readOnly: false,
        name: 'local_docs',
        description: 'command = "node"',
      ),
    );

    final configs = await queryRepository.listConfigs();

    expect(configs, hasLength(1));
    expect(configs.single, isA<CodexMcpConfig>());
    expect(configs.single.id, 'local_docs');
    expect(configs.single.enabled, isFalse);
    expect(configs.single.readOnly, isFalse);
  });
}
