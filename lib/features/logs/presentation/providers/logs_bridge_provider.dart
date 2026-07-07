import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shimx/core/services/app_log_service.dart';
import 'package:shimx/core/services/bridge_service.dart';

part 'logs_bridge_provider.g.dart';

/// 注册控制面板"日志"tab 用到的路由。
///
/// `/logs/list`  — 拉当前内存里的全部日志条目, payload 可选 `{limit: number}`
/// `/logs/clear` — 清空 AppLogService 内存缓冲
@Riverpod(keepAlive: true)
bool logsBridgeRouteRegistration(Ref ref) {
  final bridge = ref.read(bridgeServiceProvider);
  registerLogsBridgeRoutes(bridge: bridge);
  return true;
}

void registerLogsBridgeRoutes({required BridgeService bridge}) {
  bridge.register('/logs/list', (payload) async {
    final entries = AppLogService.instance.value;
    final rawLimit = payload['limit'];
    final limit = rawLimit is int && rawLimit > 0 ? rawLimit : entries.length;
    final slice = entries.take(limit).toList();
    return {
      'entries': slice.map(_entryJson).toList(),
      'total': entries.length,
    };
  });

  bridge.register('/logs/clear', (payload) async {
    AppLogService.instance.clear();
    return {'ok': true};
  });

  AppLogService.instance.info('Logs', '路由已注册');
}

Map<String, dynamic> _entryJson(AppLogEntry entry) {
  return {
    'id': entry.id,
    'timestamp': entry.timestamp.toIso8601String(),
    'level': _levelKey(entry.level),
    'source': entry.source,
    'message': entry.message,
    if (entry.details != null && entry.details!.isNotEmpty)
      'details': entry.details,
  };
}

String _levelKey(AppLogLevel level) {
  switch (level) {
    case AppLogLevel.debug:
      return 'debug';
    case AppLogLevel.info:
      return 'info';
    case AppLogLevel.warning:
      return 'warning';
    case AppLogLevel.error:
      return 'error';
  }
}
