import 'package:flutter_test/flutter_test.dart';
import 'package:shim/core/utils/codex_tool_toml_codec.dart';
import 'package:shim/features/mcp/domain/models/codex_tool.dart';

void main() {
  group('codex tool toml codec', () {
    test('reads managed and non-managed mcp and skill blocks', () {
      const text = '''
model = "gpt-5"

[mcp_servers.external]
command = "npx"

# shim-managed:start kind=mcp_servers id=managed_mcp
[mcp_servers.managed_mcp]
enabled = false
command = "node"
# shim-managed:end

[skills.writer]
description = "Write docs"
''';

      final tools = parseCodexTools(text);

      expect(tools, hasLength(3));
      final external = tools.firstWhere((tool) => tool.id == 'external');
      expect(external.kind, CodexToolKind.mcpServer);
      expect(external.managedByShim, isFalse);
      expect(external.readOnly, isFalse);

      final managed = tools.firstWhere((tool) => tool.id == 'managed_mcp');
      expect(managed.managedByShim, isTrue);
      expect(managed.readOnly, isFalse);
      expect(managed.enabled, isFalse);
      expect(managed.bodyText, contains('command = "node"'));

      final skill = tools.firstWhere((tool) => tool.id == 'writer');
      expect(skill.kind, CodexToolKind.skill);
      expect(skill.description, 'Write docs');
    });

    test('appends managed block without rewriting existing config', () {
      const original = '''
model = "gpt-5"

[projects."/tmp/demo"]
trust_level = "trusted"
''';

      final updated = upsertShimManagedCodexToolBlock(
        original,
        kind: CodexToolKind.mcpServer,
        id: 'local_docs',
        bodyText: 'command = "node"\nargs = []',
      );

      expect(updated, contains('model = "gpt-5"'));
      expect(updated, contains('[projects."/tmp/demo"]'));
      expect(
        updated,
        contains('# shim-managed:start kind=mcp_servers id=local_docs'),
      );
      expect(updated, contains('[mcp_servers.local_docs]'));
      expect(updated, contains('command = "node"'));
      expect(updated.startsWith(original), isTrue);
    });

    test('replaces only the matching managed block', () {
      const original = '''
# shim-managed:start kind=mcp_servers id=first
[mcp_servers.first]
command = "old"
# shim-managed:end

[mcp_servers.other]
command = "keep"
''';

      final updated = upsertShimManagedCodexToolBlock(
        original,
        kind: CodexToolKind.mcpServer,
        id: 'first',
        bodyText: 'command = "new"',
      );

      expect(updated, contains('command = "new"'));
      expect(updated, isNot(contains('command = "old"')));
      expect(updated, contains('[mcp_servers.other]'));
      expect(updated, contains('command = "keep"'));
    });

    test('replace preserves text outside the marker block byte-for-byte', () {
      const before = '''
model = "gpt-5"
# keep this comment

''';
      const block = '''
# shim-managed:start kind=mcp_servers id=first
[mcp_servers.first]
command = "old"
# shim-managed:end
''';
      const after = '''

[projects."/tmp/demo"]
trust_level = "trusted"
''';

      final updated = upsertShimManagedCodexToolBlock(
        '$before$block$after',
        kind: CodexToolKind.mcpServer,
        id: 'first',
        bodyText: 'command = "new"',
      );

      expect(updated.startsWith(before), isTrue);
      expect(updated.endsWith(after), isTrue);
      expect(updated, contains('command = "new"'));
      expect(updated, isNot(contains('command = "old"')));
    });

    test('deletes only managed block', () {
      const original = '''
model = "gpt-5"

# shim-managed:start kind=skills id=writer
[skills.writer]
description = "draft"
# shim-managed:end

[mcp_servers.external]
command = "keep"
''';

      final updated = deleteShimManagedCodexToolBlock(
        original,
        kind: CodexToolKind.skill,
        id: 'writer',
      );

      expect(updated, contains('model = "gpt-5"'));
      expect(updated, contains('[mcp_servers.external]'));
      expect(updated, isNot(contains('[skills.writer]')));
    });

    test('toggles enabled only inside the matching managed block', () {
      const original = '''
[mcp_servers.external]
enabled = false
command = "keep"

# shim-managed:start kind=mcp_servers id=managed
[mcp_servers.managed]
command = "node"
# shim-managed:end
''';

      final updated = setShimManagedCodexToolEnabled(
        original,
        kind: CodexToolKind.mcpServer,
        id: 'managed',
        enabled: false,
      );

      expect(updated, contains('[mcp_servers.external]\nenabled = false'));
      expect(updated, contains('[mcp_servers.managed]\nenabled = false'));
      expect(updated, contains('command = "keep"'));
    });

    test('updates and deletes non-managed entries in place', () {
      const original = '''
[mcp_servers.external]
command = "npx"

[projects."/tmp/demo"]
trust_level = "trusted"
''';

      final updated = upsertShimManagedCodexToolBlock(
        original,
        kind: CodexToolKind.mcpServer,
        id: 'external',
        bodyText: 'command = "node"',
      );

      expect(updated, contains('[mcp_servers.external]\ncommand = "node"'));
      expect(updated, isNot(contains('shim-managed:start')));
      expect(updated, contains('[projects."/tmp/demo"]'));

      final deleted = deleteShimManagedCodexToolBlock(
        updated,
        kind: CodexToolKind.mcpServer,
        id: 'external',
      );
      expect(deleted, isNot(contains('[mcp_servers.external]')));
      expect(deleted, contains('[projects."/tmp/demo"]'));
    });

    test('skips shim_claude from advanced list', () {
      const text = '''
[mcp_servers.shim_claude]
url = "http://127.0.0.1:18787/mcp"

[mcp_servers.external]
command = "npx"
''';

      final tools = parseCodexTools(text, excludedMcpId: 'shim_claude');

      expect(tools.map((tool) => tool.id), ['external']);
    });
  });
}
