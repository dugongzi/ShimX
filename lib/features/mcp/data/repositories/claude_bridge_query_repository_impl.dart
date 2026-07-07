import 'package:shimx/features/mcp/data/datasources/claude_bridge_state_controller.dart';
import 'package:shimx/features/mcp/domain/repositories/claude_bridge_query_repository.dart';

class ClaudeBridgeQueryRepositoryImpl implements ClaudeBridgeQueryRepository {
  ClaudeBridgeQueryRepositoryImpl({required this.controller});

  final ClaudeBridgeStateController controller;

  @override
  Future<void> ensureHydrated() => controller.ensureHydrated();

  @override
  Map<String, dynamic> statePayload(String codexThreadId) =>
      controller.statePayload(codexThreadId);

  @override
  Map<String, dynamic> bindingsPayload() => controller.bindingsPayload();
}
