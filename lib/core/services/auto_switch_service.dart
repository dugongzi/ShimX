import 'dart:async';

import 'package:shim/core/services/app_log_service.dart';
import 'package:shim/core/services/provider_health_probe_service.dart';
import 'package:shim/core/utils/model_family.dart';
import 'package:shim/features/providers/domain/models/api_provider.dart';
import 'package:shim/features/providers/domain/models/auto_switch_settings.dart';
import 'package:shim/features/providers/domain/models/provider_health.dart';
import 'package:shim/features/providers/domain/repositories/provider_health_repository.dart';

/// 决策器：看 health 快照 + 当前选中 + AutoSwitchSettings 决定要不要切。
/// 切前 force probe 验证候选可用,切后再 force probe 确认新家;
/// 短时间内反复切换 ≥ N 次进入维护模式,停止自动切换。
class AutoSwitchService {
  AutoSwitchService({
    required this.healthRepository,
    required this.probeService,
    required this.onSwitch,
    required this.onMaintenanceMode,
    required this.onAutoSwitched,
    this.onNoEligibleCandidate,
  });

  final ProviderHealthRepository healthRepository;
  final ProviderHealthProbeService probeService;

  /// 决定要切到某家时，由外部执行实际切换（写持久化 + 推 proxy target）
  final Future<void> Function(String targetProviderId) onSwitch;

  /// 全挂止损时通知 presentation 层(用户提示+停 watcher)
  final void Function(String reason) onMaintenanceMode;

  /// 自动切换成功时通知 presentation 层(给用户 toast)
  final void Function(String fromProviderId, String toProviderId) onAutoSwitched;

  /// 评估时发现「没有符合条件的候选」 → 想切但没人可切,提醒用户。
  /// 同一状态用 [_noCandidateNotified] 去抖,避免 health 反复跳动刷屏。
  final void Function(String scope, String? currentModel)? onNoEligibleCandidate;

  /// 已通知过「没有符合条件的候选」的去抖标志;有候选/已切换后重置。
  bool _noCandidateNotified = false;

  /// 最近一次切换时间，用于 cooldown 判定
  DateTime? _lastSwitchAt;

  /// 切换历史(滑动窗口,用于全挂止损)
  final List<DateTime> _switchHistory = [];

  /// 维护模式标志:全挂止损后停止自动切换,等用户手动选一家或停服重启
  bool _inMaintenanceMode = false;

  /// 进行中标志:健康事件可能在切前 probe 写 health 时再次触发本函数,
  /// 用 inflight 锁 + cooldown 共同防 race。
  bool _evaluating = false;

  bool get isInMaintenanceMode => _inMaintenanceMode;

  void exitMaintenanceMode() {
    _inMaintenanceMode = false;
    _switchHistory.clear();
    AppLogService.instance.info('AutoSwitch', '退出维护模式');
  }

  /// 评估是否切换。由 health 变化、请求失败、settings 变更后调用。
  ///
  /// 不切返回 null;切了返回目标 id。
  /// 切前对首选候选 force probe 验证可用,首选挂了顺次试 top3;
  /// 候选全挂或切换太频繁(60s 内 3 次) → 进入维护模式不再切。
  Future<String?> maybeSwitch({
    required AutoSwitchSettings settings,
    required List<ApiProvider> providers,
    required String currentProviderId,
  }) async {
    if (settings.strategy == 'manual') return null;
    if (_inMaintenanceMode) return null;
    if (_evaluating) {
      AppLogService.instance.info('AutoSwitch', '已在评估中，跳过本次触发');
      return null;
    }
    if (_inCooldown(settings)) {
      AppLogService.instance.info('AutoSwitch', '冷却中，跳过');
      return null;
    }
    _evaluating = true;
    try {
      return await _doMaybeSwitch(
        settings: settings,
        providers: providers,
        currentProviderId: currentProviderId,
      );
    } finally {
      _evaluating = false;
    }
  }

  Future<String?> _doMaybeSwitch({
    required AutoSwitchSettings settings,
    required List<ApiProvider> providers,
    required String currentProviderId,
  }) async {

    final currentProvider = providers.where((p) => p.id == currentProviderId).cast<ApiProvider?>().firstOrNull;
    if (currentProvider == null) return null;
    final currentHealth = healthRepository.read(providerId: currentProviderId);

    final candidates = _candidatesFor(
      current: currentProvider,
      providers: providers,
      settings: settings,
    );
    if (candidates.isEmpty) {
      AppLogService.instance.warning(
        'AutoSwitch',
        '没有符合条件的候选,不切',
        details: 'scope=${settings.scope} '
            'currentFamily=${modelFamily(currentProvider.selectedModel)} '
            'currentModel=${currentProvider.selectedModel} '
            'allProviders=${providers.map((p) => "${p.id}:${p.selectedModel}").join(",")}',
      );
      if (!_noCandidateNotified) {
        _noCandidateNotified = true;
        onNoEligibleCandidate?.call(settings.scope, currentProvider.selectedModel);
      }
      return null;
    }
    _noCandidateNotified = false;

    String? preferredTarget;
    switch (settings.strategy) {
      case 'failover':
        preferredTarget = _pickFailoverTarget(
          currentHealth: currentHealth,
          candidates: candidates,
          failureThreshold: settings.failureThreshold,
        );
        break;
      case 'fastest':
        preferredTarget = _pickFastestTarget(
          currentProviderId: currentProviderId,
          currentHealth: currentHealth,
          candidates: candidates,
          marginMs: settings.fastestMarginMs,
        );
        break;
      default:
        return null;
    }

    if (preferredTarget == null || preferredTarget == currentProviderId) return null;

    // 切前 force probe 验证 — 排序后顺次试 top3,首个 probe 通过的就切
    final reorderedCandidates = [
      ...candidates.where((c) => c.provider.id == preferredTarget),
      ...candidates.where((c) => c.provider.id != preferredTarget),
    ];
    String? confirmedTarget;
    for (final c in reorderedCandidates.take(3)) {
      try {
        await probeService.probeOne(c.provider, force: true);
      } catch (_) {}
      final fresh = healthRepository.read(providerId: c.provider.id);
      if (fresh != null && (fresh.status == 'healthy' || fresh.status == 'slow')) {
        confirmedTarget = c.provider.id;
        break;
      }
      AppLogService.instance.warning(
        'AutoSwitch',
        '候选切前 probe 不通过,试下一个',
        details: 'candidate=${c.provider.id} status=${fresh?.status}',
      );
    }

    if (confirmedTarget == null) {
      // 候选全挂 → 累计止损计数,可能进维护模式
      _recordFailedSwitchAttempt();
      AppLogService.instance.error(
        'AutoSwitch',
        '所有候选 probe 均不通过,本轮不切',
      );
      return null;
    }

    AppLogService.instance.info(
      'AutoSwitch',
      '自动切换',
      details: 'from=$currentProviderId to=$confirmedTarget strategy=${settings.strategy} scope=${settings.scope}',
    );
    _lastSwitchAt = DateTime.now();
    _switchHistory.add(DateTime.now());
    _trimSwitchHistory();
    if (_switchHistory.length >= 3) {
      _enterMaintenanceMode('60s 内自动切换 ${_switchHistory.length} 次,可能全部供应商不稳定');
      // 进入维护模式后仍然完成本次切换,从下次开始才停
    }

    await onSwitch(confirmedTarget);
    onAutoSwitched(currentProviderId, confirmedTarget);

    // 切后再 force probe 一次新家,确认真切到能用的(避免 /models 通但实际 Responses 挂)
    unawaited(() async {
      final target = providers.where((p) => p.id == confirmedTarget).cast<ApiProvider?>().firstOrNull;
      if (target == null) return;
      try {
        await probeService.probeOne(target, force: true);
      } catch (_) {}
    }());

    return confirmedTarget;
  }

  void _recordFailedSwitchAttempt() {
    _switchHistory.add(DateTime.now());
    _trimSwitchHistory();
    if (_switchHistory.length >= 3) {
      _enterMaintenanceMode('候选连续不通过');
    }
  }

  void _trimSwitchHistory() {
    final now = DateTime.now();
    _switchHistory.removeWhere((t) => now.difference(t).inSeconds > 60);
  }

  void _enterMaintenanceMode(String reason) {
    if (_inMaintenanceMode) return;
    _inMaintenanceMode = true;
    AppLogService.instance.error(
      'AutoSwitch',
      '进入维护模式',
      details: reason,
    );
    onMaintenanceMode(reason);
  }

  bool _inCooldown(AutoSwitchSettings settings) {
    final last = _lastSwitchAt;
    if (last == null) return false;
    return DateTime.now().difference(last).inSeconds < settings.cooldownSeconds;
  }

  List<_HealthyCandidate> _candidatesFor({
    required ApiProvider current,
    required List<ApiProvider> providers,
    required AutoSwitchSettings settings,
  }) {
    final currentFamily = modelFamily(current.selectedModel);
    final result = <_HealthyCandidate>[];
    for (final p in providers) {
      if (p.id == current.id) continue;
      // 同一家供应商(baseUrl + apiKey 相同)默认不互切,
      // 用户在 settings 里打开 allowSameProviderSibling 才允许。
      if (!settings.allowSameProviderSibling &&
          p.baseUrl == current.baseUrl &&
          p.apiKey == current.apiKey) {
        continue;
      }
      // scope 过滤
      switch (settings.scope) {
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
      // health 检查:已知 unreachable 才跳过;null/healthy/slow 都进候选池(切前 force probe 再过滤一次)
      final h = healthRepository.read(providerId: p.id);
      if (h != null && h.status == 'unreachable') continue;
      // 用合成的 candidate;有 health 就用真实,没 health 用占位(后续 probe 会刷新)
      final effectiveHealth = h ?? ProviderHealth(
        providerId: p.id,
        status: 'unknown',
        latencyMs: null,
        measuredAt: null,
        failureStreak: 0,
      );
      result.add(_HealthyCandidate(provider: p, health: effectiveHealth));
    }
    // 加权排序:score = providerWeight * modelWeight * (1000 / latencyMs)
    // 无 latency 的家排最后(score = 0),让切前 force probe 决定。
    double scoreOf(_HealthyCandidate c) {
      final ms = c.health.latencyMs;
      if (ms == null || ms <= 0) return 0;
      return c.provider.providerWeight * c.provider.modelWeight * (1000 / ms);
    }
    result.sort((a, b) => scoreOf(b).compareTo(scoreOf(a)));
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
