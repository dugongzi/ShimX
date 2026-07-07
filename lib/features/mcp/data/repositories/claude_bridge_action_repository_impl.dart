import 'package:shimx/features/mcp/data/datasources/claude_bridge_state_controller.dart';
import 'package:shimx/features/mcp/domain/repositories/claude_bridge_action_repository.dart';

class ClaudeBridgeActionRepositoryImpl implements ClaudeBridgeActionRepository {
  ClaudeBridgeActionRepositoryImpl({required this.controller});

  final ClaudeBridgeStateController controller;

  @override
  Future<Map<String, dynamic>> bind({
    required String codexThreadId,
    required String sessionId,
    required String jsonlPath,
    String? title,
  }) async {
    await controller.ensureHydrated();
    controller.setBinding(
      codexThreadId: codexThreadId,
      sessionId: sessionId,
      jsonlPath: jsonlPath,
      title: title,
    );
    await controller.persist();
    return controller.statePayload(codexThreadId);
  }

  @override
  Future<Map<String, dynamic>> unbind({required String codexThreadId}) async {
    await controller.ensureHydrated();
    controller.clearBinding(codexThreadId: codexThreadId);
    await controller.persist();
    return controller.statePayload(codexThreadId);
  }
}
