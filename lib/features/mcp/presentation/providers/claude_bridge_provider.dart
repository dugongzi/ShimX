import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shim/core/services/app_log_service.dart';
import 'package:shim/core/services/bridge_service.dart';
import 'package:shim/core/services/local_proxy_service.dart';

part 'claude_bridge_provider.g.dart';

/// 注册 Claude 桥控制路由。
///
/// 绑定按 codex thread id 隔离 —— codex 侧栏每条对话各自有一个 Claude 桥状态。
///
/// `/claude-bridge/bind`   — 绑定一条 Claude 会话作为当前 codex thread 的接续上下文
/// `/claude-bridge/unbind` — 解除当前 codex thread 的绑定
/// `/claude-bridge/state`  — 读某个 codex thread 的绑定状态(JS chip 初始化用)
///
/// 数据存在 [LocalProxyService] 的 `_claudeBindings`(`Map<threadId, binding>`),
/// 仅内存态,shim 重启清空。
@Riverpod(keepAlive: true)
bool claudeBridgeRouteRegistration(Ref ref) {
  registerClaudeBridgeRoutes(
    bridge: ref.read(bridgeServiceProvider),
    proxy: ref.read(localProxyServiceProvider),
  );
  return true;
}

void registerClaudeBridgeRoutes({
  required BridgeService bridge,
  required LocalProxyService proxy,
}) {
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
    proxy.setClaudeBinding(
      codexThreadId: codexThreadId,
      binding: ClaudeBridgeBinding(
        sessionId: sessionId,
        jsonlPath: jsonlPath,
        title: title,
      ),
    );
    return _statePayload(proxy, codexThreadId);
  });

  bridge.register('/claude-bridge/unbind', (payload) async {
    final codexThreadId = payload['codexThreadId'];
    if (codexThreadId is! String || codexThreadId.isEmpty) {
      throw ArgumentError('codexThreadId is required');
    }
    proxy.clearClaudeBinding(codexThreadId: codexThreadId);
    return _statePayload(proxy, codexThreadId);
  });

  bridge.register('/claude-bridge/state', (payload) async {
    final codexThreadId = payload['codexThreadId'];
    // /state 允许 codexThreadId 为空 — 此时返回 bound:false,让 JS 知道当前没活跃 thread
    final id = codexThreadId is String ? codexThreadId : '';
    return _statePayload(proxy, id);
  });

  AppLogService.instance.info('ClaudeBridge', '路由已注册');
}

Map<String, dynamic> _statePayload(LocalProxyService proxy, String codexThreadId) {
  if (codexThreadId.isEmpty) return const {'bound': false};
  final b = proxy.claudeBindingFor(codexThreadId);
  if (b == null) {
    return {'bound': false, 'codexThreadId': codexThreadId};
  }
  return {
    'bound': true,
    'codexThreadId': codexThreadId,
    'sessionId': b.sessionId,
    'jsonlPath': b.jsonlPath,
    'title': b.title,
  };
}
