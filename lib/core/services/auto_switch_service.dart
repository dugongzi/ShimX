import 'dart:async';

import 'package:shim/core/services/app_log_service.dart';
import 'package:shim/core/utils/model_family.dart';
import 'package:shim/features/providers/domain/models/api_provider.dart';
import 'package:shim/features/providers/domain/models/auto_switch_settings.dart';
import 'package:shim/features/providers/domain/models/provider_health.dart';
import 'package:shim/features/providers/domain/repositories/provider_health_repository.dart';

/// 决策器：看 health 快照 + 当前选中 + AutoSwitchSettings 决定要不要切。
/// 不做测速、不做请求。切换由外部回调（presentation 层调 saveSelectedId + 同步 proxy）执行。
class AutoSwitchService {
  AutoSwitchService({required this.healthRepository, required this.onSwitch});

  final ProviderHealthRepository healthRepository;

  /// 决定要切到某家时，由外部执行实际切换（写持久化 + 推 proxy target）
  final Future<void> Function(String targetProviderId) onSwitch;

  /// 最近一次切换时间，用于 cooldown 判定
  DateTime? _lastSwitchAt;

  /// 评估是否切换。由 health 变化、请求失败、settings 变更后调用。
  ///
  /// 不切返回 null；切了返回目标 id。
  Future<String?> maybeSwitch({
    required AutoSwitchSettings settings,
    required List<ApiProvider> providers,
    required String currentProviderId,
  }) async {
    if (settings.strategy == 'manual') return null;
    if (_inCooldown(settings)) {
      AppLogService.instance.info('AutoSwitch', '冷却中，跳过');
      return null;
    }

    final currentProvider = providers.where((p) => p.id == currentProviderId).cast<ApiProvider?>().firstOrNull;
    if (currentProvider == null) return null;
    final currentHealth = healthRepository.read(providerId: currentProviderId);

    final candidates = _candidatesFor(
      current: currentProvider,
      providers: providers,
      scope: settings.scope,
    );
    if (candidates.isEmpty) return null;

    String? target;
    switch (settings.strategy) {
      case 'failover':
        target = _pickFailoverTarget(
          currentHealth: currentHealth,
          candidates: candidates,
          failureThreshold: settings.failureThreshold,
        );
        break;
      case 'fastest':
        target = _pickFastestTarget(
          currentProviderId: currentProviderId,
          currentHealth: currentHealth,
          candidates: candidates,
          marginMs: settings.fastestMarginMs,
        );
        break;
      default:
        return null;
    }

    if (target == null || target == currentProviderId) return null;

    AppLogService.instance.info(
      'AutoSwitch',
      '自动切换',
      details: 'from=$currentProviderId to=$target strategy=${settings.strategy} scope=${settings.scope}',
    );
    _lastSwitchAt = DateTime.now();
    await onSwitch(target);
    return target;
  }

  bool _inCooldown(AutoSwitchSettings settings) {
    final last = _lastSwitchAt;
    if (last == null) return false;
    return DateTime.now().difference(last).inSeconds < settings.cooldownSeconds;
  }

  List<_HealthyCandidate> _candidatesFor({
    required ApiProvider current,
    required List<ApiProvider> providers,
    required String scope,
  }) {
    final currentFamily = modelFamily(current.selectedModel);
    final result = <_HealthyCandidate>[];
    for (final p in providers) {
      if (p.id == current.id) continue;
      final h = healthRepository.read(providerId: p.id);
      if (h == null) continue;
      if (h.status != 'healthy' && h.status != 'slow') continue;
      if (h.latencyMs == null) continue;
      switch (scope) {
        case 'same-type':
          if (modelFamily(p.selectedModel) != currentFamily) continue;
          break;
        case 'same-protocol':
          if (p.upstreamProtocol != current.upstreamProtocol) continue;
          break;
        case 'any':
        default:
          break;
      }
      result.add(_HealthyCandidate(provider: p, health: h));
    }
    result.sort((a, b) => a.health.latencyMs!.compareTo(b.health.latencyMs!));
    return result;
  }

  String? _pickFailoverTarget({
    required ProviderHealth? currentHealth,
    required List<_HealthyCandidate> candidates,
    required int failureThreshold,
  }) {
    if (currentHealth == null) return null;
    final failing = currentHealth.status == 'unreachable' ||
        currentHealth.failureStreak >= failureThreshold;
    if (!failing) return null;
    return candidates.first.provider.id;
  }

  String? _pickFastestTarget({
    required String currentProviderId,
    required ProviderHealth? currentHealth,
    required List<_HealthyCandidate> candidates,
    required int marginMs,
  }) {
    final fastest = candidates.first;
    if (currentHealth == null || currentHealth.latencyMs == null) {
      // 当前没数据 → 直接切到最快
      return fastest.provider.id;
    }
    final improvement = currentHealth.latencyMs! - fastest.health.latencyMs!;
    if (improvement < marginMs) return null;
    return fastest.provider.id;
  }
}

class _HealthyCandidate {
  _HealthyCandidate({required this.provider, required this.health});

  final ApiProvider provider;
  final ProviderHealth health;
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iter = iterator;
    return iter.moveNext() ? iter.current : null;
  }
}
