import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shim/core/services/app_log_service.dart';
import 'package:shim/core/services/bridge_service.dart';
import 'package:shim/core/services/local_proxy_service.dart';

part 'claude_bridge_provider.g.dart';

/// 注册 Claude 桥控制路由:
///
/// `/claude-bridge/bind`   — 绑定一条 Claude 会话作为接续上下文,
///                          后续每次代理转发都会在 input 首部插一条 system message
/// `/claude-bridge/unbind` — 解绑
/// `/claude-bridge/state`  — 读当前绑定(JS 侧用来初始化 chip)
///
/// 数据存在 [LocalProxyService] 的 [LocalProxyService.claudeBinding],
/// 单例,全局只能绑一条。
@Riverpod(keepAlive: true)
bool claudeBridgeRouteRegistration(Ref ref) {
  final bridge = ref.read(bridgeServiceProvider);
  final proxy = ref.read(localProxyServiceProvider);

  bridge.register('/claude-bridge/bind', (payload) async {
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
      ClaudeBridgeBinding(
        sessionId: sessionId,
        jsonlPath: jsonlPath,
        title: title,
      ),
    );
    return _statePayload(proxy);
  });

  bridge.register('/claude-bridge/unbind', (payload) async {
    proxy.setClaudeBinding(null);
    return _statePayload(proxy);
  });

  bridge.register('/claude-bridge/state', (payload) async {
    return _statePayload(proxy);
  });

  AppLogService.instance.info('ClaudeBridge', '路由已注册');
  return true;
}

Map<String, dynamic> _statePayload(LocalProxyService proxy) {
  final b = proxy.claudeBinding;
  if (b == null) return const {'bound': false};
  return {
    'bound': true,
    'sessionId': b.sessionId,
    'jsonlPath': b.jsonlPath,
    'title': b.title,
  };
}
