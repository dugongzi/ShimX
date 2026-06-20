import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shim/core/services/app_log_service.dart';
import 'package:shim/core/services/auto_switch_service.dart';
import 'package:shim/core/services/bridge_service.dart';
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
    onSwitch: (targetId) async {
      // 复用现有 selectProvider 逻辑(写持久化 + 同步 proxy + invalidate)
      await ref.read(selectProviderProvider(id: targetId).future);
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
    return _settingsPayload(settings);
  });

  bridge.register('/auto-switch/set', (payload) async {
    final next = AutoSwitchSettings(
      strategy: _readString(payload, 'strategy', 'manual'),
      scope: _readString(payload, 'scope', 'same-type'),
      failureThreshold: _readInt(payload, 'failureThreshold', 3),
      fastestMarginMs: _readInt(payload, 'fastestMarginMs', 200),
      cooldownSeconds: _readInt(payload, 'cooldownSeconds', 10),
      probeIntervalSeconds: _readInt(payload, 'probeIntervalSeconds', 300),
    );
    await repo.save(settings: next);
    AppLogService.instance.info(
      'AutoSwitch',
      '设置已更新',
      details: 'strategy=${next.strategy} scope=${next.scope}',
    );
    ref.invalidate(autoSwitchSettingsProvider);
    return _settingsPayload(next);
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

  final sub = healthRepo.watch().listen((snapshot) async {
    final settings = await autoRepo.read();
    if (settings.strategy == 'manual') return;
    final selectedId = await queryRepo.selectedId();
    if (selectedId == null) return;
    final providers = await queryRepo.listProviders();
    await service.maybeSwitch(
      settings: settings,
      providers: providers,
      currentProviderId: selectedId,
    );
  });
  ref.onDispose(sub.cancel);
}

Map<String, dynamic> _settingsPayload(AutoSwitchSettings settings) {
  return {
    'strategy': settings.strategy,
    'scope': settings.scope,
    'failureThreshold': settings.failureThreshold,
    'fastestMarginMs': settings.fastestMarginMs,
    'cooldownSeconds': settings.cooldownSeconds,
    'probeIntervalSeconds': settings.probeIntervalSeconds,
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
