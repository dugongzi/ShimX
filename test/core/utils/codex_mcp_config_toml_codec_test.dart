import 'package:flutter_test/flutter_test.dart';
import 'package:shimx/core/utils/codex_mcp_config_toml_codec.dart';
import 'package:shimx/features/mcp/domain/models/codex_mcp_config.dart';

void main() {
  group('codex mcp config toml codec', () {
    test(
      'reads managed and non-managed mcp blocks and ignores skill tables',
      () {
        final text =
            '''
model = "gpt-5"

[mcp_servers.external]
command = "npx"

# shimx-managed:start kind=mcp_servers id=managed_mcp
[mcp_servers.managed_mcp]
enabled = false
command = "node"
# shimx-managed:end

${'[skills'}.writer]
description = "Write docs"
''';

        final configs = parseCodexMcpConfigs(text);

        expect(configs, hasLength(2));
        final external = configs.firstWhere(
          (config) => config.id == 'external',
        );
        expect(external.kind, CodexMcpConfigKind.mcpServer);
        expect(external.managedByShimX, isFalse);
        expect(external.readOnly, isFalse);

        final managed = configs.firstWhere(
          (config) => config.id == 'managed_mcp',
        );
        expect(managed.managedByShimX, isTrue);
        expect(managed.readOnly, isFalse);
        expect(managed.enabled, isFalse);
        expect(managed.bodyText, contains('command = "node"'));
      },
    );

    test('appends managed block without rewriting existing config', () {
      const original = '''
model = "gpt-5"

[projects."/tmp/demo"]
trust_level = "trusted"
''';

      final updated = upsertShimXManagedCodexMcpConfigBlock(
        original,
        kind: CodexMcpConfigKind.mcpServer,
        id: 'local_docs',
        bodyText: 'command = "node"\nargs = []',
      );

      expect(updated, contains('model = "gpt-5"'));
      expect(updated, contains('[projects."/tmp/demo"]'));
      expect(
        updated,
        contains('# shimx-managed:start kind=mcp_servers id=local_docs'),
      );
      expect(updated, contains('[mcp_servers.local_docs]'));
      expect(updated, contains('command = "node"'));
      expect(updated.startsWith(original), isTrue);
    });

    test('replaces only the matching managed block', () {
      const original = '''
# shimx-managed:start kind=mcp_servers id=first
[mcp_servers.first]
command = "old"
# shimx-managed:end

[mcp_servers.other]
command = "keep"
''';

      final updated = upsertShimXManagedCodexMcpConfigBlock(
        original,
        kind: CodexMcpConfigKind.mcpServer,
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
# shimx-managed:start kind=mcp_servers id=first
[mcp_servers.first]
command = "old"
# shimx-managed:end
''';
      const after = '''

[projects."/tmp/demo"]
trust_level = "trusted"
''';

      final updated = upsertShimXManagedCodexMcpConfigBlock(
        '$before$block$after',
        kind: CodexMcpConfigKind.mcpServer,
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

# shimx-managed:start kind=mcp_servers id=writer
[mcp_servers.writer]
command = "draft"
# shimx-managed:end

[mcp_servers.external]
command = "keep"
''';

      final updated = deleteShimXManagedCodexMcpConfigBlock(
        original,
        kind: CodexMcpConfigKind.mcpServer,
        id: 'writer',
      );

      expect(updated, contains('model = "gpt-5"'));
      expect(updated, contains('[mcp_servers.external]'));
      expect(updated, isNot(contains('[mcp_servers.writer]')));
    });

    test('toggles enabled only inside the matching managed block', () {
      const original = '''
[mcp_servers.external]
enabled = false
command = "keep"

# shimx-managed:start kind=mcp_servers id=managed
[mcp_servers.managed]
command = "node"
# shimx-managed:end
''';

      final updated = setShimXManagedCodexMcpConfigEnabled(
        original,
        kind: CodexMcpConfigKind.mcpServer,
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

      final updated = upsertShimXManagedCodexMcpConfigBlock(
        original,
        kind: CodexMcpConfigKind.mcpServer,
        id: 'external',
        bodyText: 'command = "node"',
      );

      expect(updated, contains('[mcp_servers.external]\ncommand = "node"'));
      expect(updated, isNot(contains('shimx-managed:start')));
      expect(updated, contains('[projects."/tmp/demo"]'));

      final deleted = deleteShimXManagedCodexMcpConfigBlock(
        updated,
        kind: CodexMcpConfigKind.mcpServer,
        id: 'external',
      );
      expect(deleted, isNot(contains('[mcp_servers.external]')));
      expect(deleted, contains('[projects."/tmp/demo"]'));
    });

    test('skips shimx_claude from advanced list', () {
      const text = '''
[mcp_servers.shimx_claude]
url = "http://127.0.0.1:18787/mcp"

[mcp_servers.external]
command = "npx"
''';

      final configs = parseCodexMcpConfigs(text, excludedMcpId: 'shimx_claude');

      expect(configs.map((config) => config.id), ['external']);
    });
  });
}
