import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shim/features/mcp/data/datasources/codex_tool_action_datasource.dart';
import 'package:shim/features/mcp/data/datasources/codex_tool_query_datasource.dart';
import 'package:shim/features/mcp/data/models/codex_tool_dto.dart';
import 'package:shim/features/mcp/data/repositories/codex_tool_action_repository_impl.dart';
import 'package:shim/features/mcp/data/repositories/codex_tool_query_repository_impl.dart';
import 'package:shim/features/mcp/domain/models/codex_tool.dart';

void main() {
  late Directory tempDir;
  late File configFile;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('shim_codex_tool_test_');
    configFile = File('${tempDir.path}${Platform.pathSeparator}config.toml');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('datasource reads managed and existing config fragments', () async {
    await configFile.writeAsString('''
model = "gpt-5"

[mcp_servers.shim_claude]
url = "http://127.0.0.1:18787/mcp"

[mcp_servers.external]
command = "npx"

# shim-managed:start kind=skills id=writer
[skills.writer]
description = "Draft docs"
# shim-managed:end
''');

    final datasource = CodexToolQueryDatasource(configFile: configFile);
    final tools = await datasource.listTools();

    expect(tools.map((tool) => tool.id), ['external', 'writer']);
    expect(tools.firstWhere((tool) => tool.id == 'external').readOnly, isFalse);
    expect(
      tools.firstWhere((tool) => tool.id == 'writer').managedByShim,
      isTrue,
    );
  });

  test('action datasource writes only shim-managed marker blocks', () async {
    const original = '''
model = "gpt-5"

[mcp_servers.external]
command = "keep"
''';
    await configFile.writeAsString(original);

    final datasource = CodexToolActionDatasource(configFile: configFile);
    await datasource.saveTool(
      const CodexToolDto(
        id: 'local_docs',
        kind: CodexToolKind.mcpServer,
        bodyText: 'command = "node"\nargs = []',
        enabled: true,
        managedByShim: true,
        readOnly: false,
      ),
    );

    final text = await configFile.readAsString();
    expect(text.startsWith(original), isTrue);
    expect(
      text,
      contains('# shim-managed:start kind=mcp_servers id=local_docs'),
    );
    expect(text, contains('[mcp_servers.external]\ncommand = "keep"'));

    await datasource.deleteTool(kind: CodexToolKind.mcpServer, id: 'external');
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

      final datasource = CodexToolActionDatasource(configFile: configFile);

      await datasource.setEnabled(
        kind: CodexToolKind.mcpServer,
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
    final actionRepository = CodexToolActionRepositoryImpl(
      dataSource: CodexToolActionDatasource(configFile: configFile),
    );
    final queryRepository = CodexToolQueryRepositoryImpl(
      dataSource: CodexToolQueryDatasource(configFile: configFile),
    );

    await actionRepository.saveTool(
      const CodexTool(
        id: 'writer',
        kind: CodexToolKind.skill,
        bodyText: 'description = "Draft docs"',
        enabled: false,
        managedByShim: true,
        readOnly: false,
        name: 'writer',
        description: 'Draft docs',
      ),
    );

    final tools = await queryRepository.listTools();

    expect(tools, hasLength(1));
    expect(tools.single, isA<CodexTool>());
    expect(tools.single.id, 'writer');
    expect(tools.single.enabled, isFalse);
    expect(tools.single.readOnly, isFalse);
  });
}
