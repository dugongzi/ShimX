import 'package:flutter_test/flutter_test.dart';
import 'package:shim/core/services/local_proxy_service.dart';
import 'package:shim/features/mcp/data/datasources/claude_bridge_binding_datasource.dart';
import 'package:shim/features/mcp/data/datasources/claude_bridge_state_controller.dart';

void main() {
  test(
    'Claude bridge bindings persist and hydrate into proxy runtime',
    () async {
      final memory = <String, String>{};
      final datasource = ClaudeBridgeBindingDatasource(memory: memory);

      final firstProxy = LocalProxyService();
      final firstController = ClaudeBridgeStateController(
        proxy: firstProxy,
        datasource: datasource,
      );
      await firstController.ensureHydrated();
      firstProxy.setClaudeBinding(
        codexThreadId: 'codex-thread-1',
        binding: const ClaudeBridgeBinding(
          sessionId: 'claude-session-1',
          jsonlPath: r'C:\Users\demo\.claude\projects\a.jsonl',
          title: 'Claude task',
        ),
      );
      await firstController.persist();

      final secondProxy = LocalProxyService();
      final secondController = ClaudeBridgeStateController(
        proxy: secondProxy,
        datasource: datasource,
      );
      await secondController.ensureHydrated();

      final restored = secondProxy.claudeBindingFor('codex-thread-1');
      expect(restored?.sessionId, 'claude-session-1');
      expect(restored?.title, 'Claude task');
      expect(secondController.bindingsPayload()['bindings'], hasLength(1));

      secondProxy.clearClaudeBinding(codexThreadId: 'codex-thread-1');
      await secondController.persist();

      final thirdProxy = LocalProxyService();
      final thirdController = ClaudeBridgeStateController(
        proxy: thirdProxy,
        datasource: datasource,
      );
      await thirdController.ensureHydrated();
      expect(thirdProxy.claudeBindingsSnapshot, isEmpty);
    },
  );
}
