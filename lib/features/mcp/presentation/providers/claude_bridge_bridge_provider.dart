import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shimx/core/services/app_log_service.dart';
import 'package:shimx/core/services/bridge_service.dart';
import 'package:shimx/features/mcp/domain/repositories/claude_bridge_query_repository.dart';
import 'package:shimx/features/mcp/presentation/providers/claude_bridge_action_provider.dart';
import 'package:shimx/features/mcp/presentation/providers/claude_bridge_query_provider.dart';

part 'claude_bridge_bridge_provider.g.dart';

/// 注册 Claude 桥控制路由。
///
/// 绑定按 codex thread id 隔离 —— codex 侧栏每条对话各自有一个 Claude 桥状态。
///
/// `/claude-bridge/bind`   — 绑定一条 Claude 会话作为当前 codex thread 的接续上下文
/// `/claude-bridge/unbind` — 解除当前 codex thread 的绑定
/// `/claude-bridge/state`  — 读某个 codex thread 的绑定状态(JS chip 初始化用)
/// `/claude-bridge/list`   — 读全部 codex thread → Claude 会话绑定状态
@Riverpod(keepAlive: true)
bool claudeBridgeRouteRegistration(Ref ref) {
  final bridge = ref.read(bridgeServiceProvider);
  final queryRepo = ref.read(claudeBridgeQueryRepositoryProvider);
  final actionRepo = ref.read(claudeBridgeActionRepositoryProvider);

  // hydrate 不必等 —— 路由 handler 内部每次都先 ensureHydrated。
  unawaitedHydrate(queryRepo);

  bridge.register('/claude-bridge/bind', (payload) async {
    final codexThreadId = payload['codexThreadId'];
    if (codexThreadId is! String || codexThreadId.isEmpty) {
      throw ArgumentError('codexThreadId is required');
    }
    final sessionId = payload['sessionId'];
    final jsonlPath = payload['jsonlPath'];
    if (sessionId is! String || sessionId.isEmpty) {
      throw ArgumentError('sessionId is required');
    }
    if (jsonlPath is! String || jsonlPath.isEmpty) {
      throw ArgumentError('jsonlPath is required');
    }
    final rawTitle = payload['title'];
    final title = rawTitle is String && rawTitle.isNotEmpty ? rawTitle : null;
    return actionRepo.bind(
      codexThreadId: codexThreadId,
      sessionId: sessionId,
      jsonlPath: jsonlPath,
      title: title,
    );
  });

  bridge.register('/claude-bridge/unbind', (payload) async {
    final codexThreadId = payload['codexThreadId'];
    if (codexThreadId is! String || codexThreadId.isEmpty) {
      throw ArgumentError('codexThreadId is required');
    }
    return actionRepo.unbind(codexThreadId: codexThreadId);
  });

  bridge.register('/claude-bridge/state', (payload) async {
    await queryRepo.ensureHydrated();
    final codexThreadId = payload['codexThreadId'];
    // /state 允许 codexThreadId 为空 — 此时返回 bound:false,让 JS 知道当前没活跃 thread
    final id = codexThreadId is String ? codexThreadId : '';
    return queryRepo.statePayload(id);
  });

  bridge.register('/claude-bridge/list', (payload) async {
    await queryRepo.ensureHydrated();
    return queryRepo.bindingsPayload();
  });

  AppLogService.instance.info('ClaudeBridge', '路由已注册');
  return true;
}

/// 注册 provider 时同时 fire-and-forget 一次 hydrate,避免首条 /state 调用时多等一次磁盘 IO。
void unawaitedHydrate(ClaudeBridgeQueryRepository repo) {
  repo.ensureHydrated();
}
