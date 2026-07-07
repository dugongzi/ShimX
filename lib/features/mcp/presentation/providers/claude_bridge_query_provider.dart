import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shimx/core/services/app_storage.dart';
import 'package:shimx/core/services/local_proxy_service.dart';
import 'package:shimx/features/mcp/data/datasources/claude_bridge_binding_datasource.dart';
import 'package:shimx/features/mcp/data/datasources/claude_bridge_state_controller.dart';
import 'package:shimx/features/mcp/data/repositories/claude_bridge_query_repository_impl.dart';
import 'package:shimx/features/mcp/domain/repositories/claude_bridge_query_repository.dart';

part 'claude_bridge_query_provider.g.dart';

/// query 与 action 共享同一个 controller —— 内存状态(hydrated / proxy snapshot)
/// 必须单一源,所以 keepAlive。
@Riverpod(keepAlive: true)
ClaudeBridgeStateController claudeBridgeStateController(Ref ref) {
  return ClaudeBridgeStateController(
    proxy: ref.read(localProxyServiceProvider),
    datasource: ClaudeBridgeBindingDatasource(
      storage: ref.read(appStorageProvider),
    ),
  );
}

@Riverpod(keepAlive: true)
ClaudeBridgeQueryRepository claudeBridgeQueryRepository(Ref ref) {
  return ClaudeBridgeQueryRepositoryImpl(
    controller: ref.read(claudeBridgeStateControllerProvider),
  );
}
