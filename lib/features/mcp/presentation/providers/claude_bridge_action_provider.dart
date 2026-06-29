import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shim/features/mcp/data/repositories/claude_bridge_action_repository_impl.dart';
import 'package:shim/features/mcp/domain/repositories/claude_bridge_action_repository.dart';
import 'package:shim/features/mcp/presentation/providers/claude_bridge_query_provider.dart';

part 'claude_bridge_action_provider.g.dart';

@Riverpod(keepAlive: true)
ClaudeBridgeActionRepository claudeBridgeActionRepository(Ref ref) {
  return ClaudeBridgeActionRepositoryImpl(
    controller: ref.read(claudeBridgeStateControllerProvider),
  );
}
