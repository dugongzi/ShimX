import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:shimx/core/services/app_log_service.dart';
import 'package:shimx/core/services/bridge_service.dart';
import 'package:shimx/features/plugins/data/datasources/plugin_action_datasource.dart';
import 'package:shimx/features/plugins/domain/models/plugin_marketplace_status.dart';
import 'package:shimx/features/plugins/domain/repositories/plugin_action_repository.dart';
import 'package:shimx/features/plugins/domain/repositories/plugin_query_repository.dart';
import 'package:shimx/features/plugins/presentation/providers/plugin_action_provider.dart';
import 'package:shimx/features/plugins/presentation/providers/plugin_query_provider.dart';

part 'plugin_bridge_provider.g.dart';

/// 注册 codex 页面「插件解锁」浮层用到的 bridge 路由。
///
/// - `/plugin/status`              → 读磁盘 + config,返回 marketplace 状态
/// - `/plugin/install-from-github` → 拉 openai/plugins zip,落盘 + 写 config
/// - `/plugin/install-from-local`  → 用户传 `zipPath` 或 `dirPath`,落盘 + 写 config
///
/// GitHub 下载期间通过 [BridgeService.dispatchEvent] 主动推
/// `/plugin/download-progress` 事件,JS 侧用 `window.__shimxOn` 订阅。
@Riverpod(keepAlive: true)
bool pluginBridgeRouteRegistration(Ref ref) {
  final bridge = ref.read(bridgeServiceProvider);
  final query = ref.read(pluginQueryRepositoryProvider);
  final action = ref.read(pluginActionRepositoryProvider);
  _registerPluginBridgeRoutes(
    bridge: bridge,
    queryRepository: query,
    actionRepository: action,
  );
  return true;
}

/// 200ms 节流的进度推送。避免 dio 每 8KB 一次回调直接 flood JS。
class _ProgressThrottle {
  _ProgressThrottle(this._bridge);

  final BridgeService _bridge;
  static const _minInterval = Duration(milliseconds: 200);
  DateTime _lastSent = DateTime.fromMillisecondsSinceEpoch(0);

  void push(int received, int total) {
    final now = DateTime.now();
    final done = total > 0 && received >= total;
    if (!done && now.difference(_lastSent) < _minInterval) return;
    _lastSent = now;
    final percent = total > 0 ? (received * 100 ~/ total) : 0;
    _bridge.dispatchEvent('/plugin/download-progress', {
      'received': received,
      'total': total,
      'percent': percent,
      'done': done,
    });
  }
}

void _registerPluginBridgeRoutes({
  required BridgeService bridge,
  required PluginQueryRepository queryRepository,
  required PluginActionRepository actionRepository,
}) {
  bridge.register('/plugin/status', (_) async {
    final status = await queryRepository.readMarketplaceStatus();
    return _statusJson(status);
  });

  bridge.register('/plugin/install-from-remote', (payload) async {
    final source = payload['source'];
    final url = _resolveMirrorUrl(source);
    if (url == null) {
      throw StateError('unknown mirror source: $source');
    }
    final throttle = _ProgressThrottle(bridge);
    final status = await actionRepository.installFromRemoteZip(
      url: url,
      onProgress: throttle.push,
    );
    return _statusJson(status);
  });

  bridge.register('/plugin/pick-local-zip', (_) async {
    final path = await actionRepository.pickLocalZipPath();
    return {'zipPath': path};
  });

  bridge.register('/plugin/install-from-local', (payload) async {
    final zipPath = payload['zipPath'];
    final dirPath = payload['dirPath'];
    if (zipPath is String && zipPath.isNotEmpty) {
      final status = await actionRepository.installFromLocalZip(zipPath: zipPath);
      return _statusJson(status);
    }
    if (dirPath is String && dirPath.isNotEmpty) {
      final status = await actionRepository.installFromLocalDir(dirPath: dirPath);
      return _statusJson(status);
    }
    throw StateError('payload must include zipPath or dirPath');
  });

  AppLogService.instance.info('Plugin', '路由已注册');
}

/// 镜像枚举字符串 → 具体 URL。URL 定在 data 层常量,前端只传 short name。
String? _resolveMirrorUrl(dynamic source) {
  final s = source is String ? source : '';
  switch (s) {
    case 'jihulab':
      return PluginActionDatasource.kJihulabZipUrl;
    case 'github':
      return PluginActionDatasource.kGithubZipUrl;
    default:
      return null;
  }
}

Map<String, dynamic> _statusJson(PluginMarketplaceStatus status) => {
      'installed': status.installed,
      'configured': status.configured,
      'pluginCount': status.pluginCount,
      'codexHome': status.codexHome,
    };
