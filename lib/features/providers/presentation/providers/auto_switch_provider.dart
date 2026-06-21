import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shim/core/providers/locale_provider.dart';
import 'package:shim/core/services/app_log_service.dart';
import 'package:shim/core/services/auto_switch_service.dart';
import 'package:shim/core/services/bridge_service.dart';
import 'package:shim/core/services/local_proxy_service.dart';
import 'package:shim/features/providers/data/datasources/auto_switch_datasource.dart';
import 'package:shim/features/providers/data/repositories/auto_switch_repository_impl.dart';
import 'package:shim/features/providers/domain/models/auto_switch_settings.dart';
import 'package:shim/features/providers/domain/repositories/auto_switch_repository.dart';
import 'package:shim/core/services/app_storage.dart';
import 'package:shim/features/providers/presentation/providers/provider_action_provider.dart';
import 'package:shim/features/providers/presentation/providers/provider_health_provider.dart';
import 'package:shim/features/providers/presentation/providers/provider_query_provider.dart';

part 'auto_switch_provider.g.dart';

@Riverpod(keepAlive: true)
AutoSwitchRepository autoSwitchRepository(Ref ref) {
  return AutoSwitchRepositoryImpl(
    dataSource: AutoSwitchDatasource(
      appStorage: ref.read(appStorageProvider),
    ),
  );
}

@riverpod
Future<AutoSwitchSettings> autoSwitchSettings(Ref ref) {
  return ref.read(autoSwitchRepositoryProvider).read();
}

@Riverpod(keepAlive: true)
AutoSwitchService autoSwitchService(Ref ref) {
  return AutoSwitchService(
    healthRepository: ref.read(providerHealthRepositoryProvider),
    probeService: ref.read(providerHealthProbeServiceProvider),
    onSwitch: (targetId) async {
      // 复用现有 select 逻辑(写持久化 + 同步 proxy + invalidate)
      await ref.read(providerActionsProvider.notifier).select(targetId);
    },
    onMaintenanceMode: (reason) {
      AppLogService.instance.error(
        'AutoSwitch',
        '维护模式已激活',
        details: reason,
      );
      // 通知 bridge 推一条提示到 Codex
      final bridge = ref.read(bridgeServiceProvider);
      bridge.dispatchEvent('/provider/auto-switched', {
        'event': 'maintenance',
        'reason': reason,
      });
    },
    onAutoSwitched: (fromId, toId) {
      final bridge = ref.read(bridgeServiceProvider);
      bridge.dispatchEvent('/provider/auto-switched', {
        'event': 'switched',
        'from': fromId,
        'to': toId,
      });
    },
  );
}

/// 把自动切换路由注册到 bridge。
///
/// /auto-switch/get — 读当前设置
/// /auto-switch/set — 写设置(整份覆盖)
@Riverpod(keepAlive: true)
bool autoSwitchRouteRegistration(Ref ref) {
  final bridge = ref.read(bridgeServiceProvider);
  final repo = ref.read(autoSwitchRepositoryProvider);

  bridge.register('/auto-switch/get', (payload) async {
    final settings = await repo.read();
    final isZh = ref.read(localeProvider).languageCode == 'zh';
    return _settingsPayload(settings, isZh);
  });

  bridge.register('/auto-switch/set', (payload) async {
    final next = AutoSwitchSettings(
      strategy: _readString(payload, 'strategy', 'manual'),
      scope: _readString(payload, 'scope', 'same-type'),
      failureThreshold: _readInt(payload, 'failureThreshold', 3),
      fastestMarginMs: _readInt(payload, 'fastestMarginMs', 200),
      cooldownSeconds: _readInt(payload, 'cooldownSeconds', 10),
      probeIntervalSeconds: _readInt(payload, 'probeIntervalSeconds', 300),
      slowRequestTimeoutSeconds: _readInt(payload, 'slowRequestTimeoutSeconds', 20),
      slowRequestSwitchThreshold: _readInt(payload, 'slowRequestSwitchThreshold', 1),
      allowSameProviderSibling: _readBool(payload, 'allowSameProviderSibling', false),
    );
    await repo.save(settings: next);
    AppLogService.instance.info(
      'AutoSwitch',
      '设置已更新',
      details: 'strategy=${next.strategy} scope=${next.scope} slowTimeout=${next.slowRequestTimeoutSeconds}s slowThreshold=${next.slowRequestSwitchThreshold}',
    );
    ref.invalidate(autoSwitchSettingsProvider);

    // 慢响应阈值热推给运行中的 proxy(否则得等 startTakeover 重新跑才生效)
    final proxy = ref.read(localProxyServiceProvider);
    if (proxy.isRunning) {
      proxy.setSlowTimeout(Duration(seconds: next.slowRequestTimeoutSeconds));
    }

    final isZh = ref.read(localeProvider).languageCode == 'zh';
    return _settingsPayload(next, isZh);
  });

  return true;
}

/// 监听 health 变化 + 设置变化,自动评估切换。
@Riverpod(keepAlive: true)
Future<void> autoSwitchWatcher(Ref ref) async {
  final service = ref.read(autoSwitchServiceProvider);
  final queryRepo = ref.read(providerQueryRepositoryProvider);
  final autoRepo = ref.read(autoSwitchRepositoryProvider);
  final healthRepo = ref.read(providerHealthRepositoryProvider);

  AppLogService.instance.info('AutoSwitch', 'watcher 已订阅 health 变化');

  final sub = healthRepo.watch().listen((snapshot) async {
    final settings = await autoRepo.read();
    AppLogService.instance.info(
      'AutoSwitch',
      '收到 health 变化事件',
      details: 'count=${snapshot.length} strategy=${settings.strategy} scope=${settings.scope}',
    );
    if (settings.strategy == 'manual') {
      AppLogService.instance.info('AutoSwitch', '策略=manual,不评估');
      return;
    }
    final selectedId = await queryRepo.selectedId();
    if (selectedId == null) {
      AppLogService.instance.warning('AutoSwitch', '当前无选中供应商,不评估');
      return;
    }
    final providers = await queryRepo.listProviders();
    await service.maybeSwitch(
      settings: settings,
      providers: providers,
      currentProviderId: selectedId,
    );
  });
  ref.onDispose(sub.cancel);
}

Map<String, dynamic> _settingsPayload(AutoSwitchSettings settings, bool isZh) {
  return {
    'strategy': settings.strategy,
    'scope': settings.scope,
    'failureThreshold': settings.failureThreshold,
    'fastestMarginMs': settings.fastestMarginMs,
    'cooldownSeconds': settings.cooldownSeconds,
    'probeIntervalSeconds': settings.probeIntervalSeconds,
    'slowRequestTimeoutSeconds': settings.slowRequestTimeoutSeconds,
    'slowRequestSwitchThreshold': settings.slowRequestSwitchThreshold,
    'allowSameProviderSibling': settings.allowSameProviderSibling,
    'labels': _labels(isZh),
  };
}

Map<String, dynamic> _labels(bool isZh) {
  if (isZh) {
    return {
      'title': '自动切换',
      'strategy': '策略',
      'scope': '范围',
      'failureThreshold': '失败阈值',
      'fastestMarginMs': '增益',
      'cooldownSeconds': '冷却',
      'probeIntervalSeconds': '周期',
      'slowRequestTimeoutSeconds': '慢响应阈值',
      'slowRequestSwitchThreshold': '慢响应次数',
      'allowSameProviderSibling': '允许同家其他模型',
      'allowSameProviderSiblingOn': '开',
      'allowSameProviderSiblingOff': '关',
      'unitTimes': '次',
      'unitMs': 'ms',
      'unitSeconds': '秒',
      'strategyManual': '手动',
      'strategyFailover': '故障转移',
      'strategyFastest': '最快优先',
      'scopeSameType': '同类型',
      'scopeSameProtocol': '同协议',
      'scopeAny': '任意',
    };
  }
  return {
    'title': 'Auto switch',
    'strategy': 'Strategy',
    'scope': 'Scope',
    'failureThreshold': 'Threshold',
    'fastestMarginMs': 'Margin',
    'cooldownSeconds': 'Cooldown',
    'probeIntervalSeconds': 'Interval',
    'slowRequestTimeoutSeconds': 'Slow th.',
    'slowRequestSwitchThreshold': 'Slow streak',
    'allowSameProviderSibling': 'Sibling fallback',
    'allowSameProviderSiblingOn': 'On',
    'allowSameProviderSiblingOff': 'Off',
    'unitTimes': 'x',
    'unitMs': 'ms',
    'unitSeconds': 's',
    'strategyManual': 'Manual',
    'strategyFailover': 'Failover',
    'strategyFastest': 'Fastest',
    'scopeSameType': 'Same type',
    'scopeSameProtocol': 'Same proto',
    'scopeAny': 'Any',
  };
}

String _readString(Map<String, dynamic> payload, String key, String fallback) {
  final v = payload[key];
  return v is String && v.isNotEmpty ? v : fallback;
}

int _readInt(Map<String, dynamic> payload, String key, int fallback) {
  final v = payload[key];
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? fallback;
  return fallback;
}

bool _readBool(Map<String, dynamic> payload, String key, bool fallback) {
  final v = payload[key];
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) return v == 'true' || v == '1';
  return fallback;
}
