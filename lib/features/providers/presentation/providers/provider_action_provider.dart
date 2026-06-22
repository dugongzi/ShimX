import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shim/core/providers/locale_provider.dart';
import 'package:shim/core/services/app_log_service.dart';
import 'package:shim/core/services/app_storage.dart';
import 'package:shim/core/services/bridge_service.dart';
import 'package:shim/core/services/local_proxy_service.dart';
import 'package:shim/features/providers/data/datasources/provider_action_datasource.dart';
import 'package:shim/features/providers/data/repositories/provider_action_repository_impl.dart';
import 'package:shim/features/providers/domain/models/api_provider.dart';
import 'package:shim/features/providers/domain/models/provider_health.dart';
import 'package:shim/features/providers/domain/repositories/provider_action_repository.dart';
import 'package:shim/features/providers/domain/repositories/provider_health_repository.dart';
import 'package:shim/features/providers/presentation/providers/auto_switch_provider.dart';
import 'package:shim/features/providers/presentation/providers/provider_health_provider.dart';
import 'package:shim/features/providers/presentation/providers/provider_query_provider.dart';

part 'provider_action_provider.g.dart';

const _reasoningEffortKey = 'shim_reasoning_effort';

/// 若代理正在运行，把当前选中的供应商热更新给代理的转发目标（零重启切换）。
/// update/select 后调用，保证改了链接/换了供应商，运行中的代理立刻生效。
/// 顺便把后台测速的周期范围更新到新选中的家。
Future<void> _syncRunningProxyTarget(Ref ref) async {
  final proxy = ref.read(localProxyServiceProvider);
  if (!proxy.isRunning) return;
  final query = ref.read(providerQueryRepositoryProvider);
  final selectedId = await query.selectedId();
  if (selectedId == null) return;
  final providers = await query.listProviders();
  ApiProvider? selected;
  for (final p in providers) {
    if (p.id == selectedId) {
      selected = p;
      break;
    }
  }
  if (selected == null ||
      selected.baseUrl.isEmpty ||
      selected.apiKey.isEmpty) {
    return;
  }
  final reasoningEffort =
      await ref.read(appStorageProvider).getString(_reasoningEffortKey);
  proxy.setTarget(
    ProxyTarget(
      baseUrl: selected.baseUrl,
      apiKey: selected.apiKey,
      model: selected.selectedModel,
      upstreamProtocol: selected.upstreamProtocol,
      reasoningEffort: reasoningEffort,
      providerId: selected.id,
    ),
  );
  // 切换供应商时,周期 scope 也要带新的候选(top2 同 scope)
  final autoSettings = await ref.read(autoSwitchRepositoryProvider).read();
  ref.read(providerHealthProbeServiceProvider).refreshPeriodicScopeFor(
    currentProviderId: selected.id,
    providers: providers,
    scope: autoSettings.scope,
  );
}

@riverpod
ProviderActionRepository providerActionRepository(Ref ref) {
  return ProviderActionRepositoryImpl(
    dataSource: ProviderActionDatasource(
      appStorage: ref.read(appStorageProvider),
    ),
  );
}

/// 注册 JS 侧供应商/模型选择路由。
///
/// 通过 @Riverpod(keepAlive: true) 包一层 provider,任何持有 Ref 或 WidgetRef
/// 的地方都可以 `ref.read(providerActionRouteRegistrationProvider)` 触发注册。
@Riverpod(keepAlive: true)
bool providerActionRouteRegistration(Ref ref) {
  registerProviderActionBridgeRoutes(ref);
  return true;
}

void registerProviderActionBridgeRoutes(Ref ref) {
  final bridge = ref.read(bridgeServiceProvider);
  final actionRepo = ref.read(providerActionRepositoryProvider);
  final queryRepo = ref.read(providerQueryRepositoryProvider);
  final appStorage = ref.read(appStorageProvider);

  final healthRepo = ref.read(providerHealthRepositoryProvider);

  bool isZh() => ref.read(localeProvider).languageCode == 'zh';

  bridge.register('/provider/list', (payload) async {
    final providers = await queryRepo.listProviders();
    final selectedId = await queryRepo.selectedId();
    final reasoningEffort = await appStorage.getString(_reasoningEffortKey);
    return _providerListPayload(providers, selectedId, reasoningEffort, healthRepo, isZh());
  });

  bridge.register('/provider/select', (payload) async {
    final id = payload['id'];
    if (id is! String || id.isEmpty) {
      throw ArgumentError('provider id is required');
    }
    await actionRepo.saveSelectedId(id);
    AppLogService.instance.info('Provider', '选中供应商', details: id);
    ref.invalidate(providerListProvider);
    await _syncRunningProxyTarget(ref);

    final providers = await queryRepo.listProviders();
    final selectedId = await queryRepo.selectedId();
    final reasoningEffort = await appStorage.getString(_reasoningEffortKey);
    return _providerListPayload(providers, selectedId, reasoningEffort, healthRepo, isZh());
  });

  bridge.register('/provider/select-model', (payload) async {
    final id = payload['id'];
    if (id is! String || id.isEmpty) {
      throw ArgumentError('provider id is required');
    }
    final rawModel = payload['model'];
    final model = rawModel is String && rawModel.isNotEmpty ? rawModel : null;
    final providers = await queryRepo.listProviders();
    var found = false;
    final next = providers.map<ApiProvider>((provider) {
      if (provider.id != id) return provider;
      found = true;
      return provider.copyWith(selectedModel: model);
    }).toList();
    if (!found) throw ArgumentError('provider not found: $id');

    await actionRepo.saveProviders(next);
    AppLogService.instance.info('Provider', '切换模型', details: ' -> ');
    await actionRepo.saveSelectedId(id);
    AppLogService.instance.info('Provider', '选中供应商', details: id);
    ref.invalidate(providerListProvider);
    await _syncRunningProxyTarget(ref);

    final selectedId = await queryRepo.selectedId();
    final reasoningEffort = await appStorage.getString(_reasoningEffortKey);
    return _providerListPayload(next, selectedId, reasoningEffort, healthRepo, isZh());
  });

  bridge.register('/provider/set-reasoning-effort', (payload) async {
    final rawEffort = payload['effort'];
    final effort = rawEffort is String ? rawEffort : '';
    if (!_isSupportedReasoningEffort(effort)) {
      throw ArgumentError('unsupported reasoning effort: $effort');
    }
    await appStorage.setString(_reasoningEffortKey, effort);
    AppLogService.instance.info('Provider', '切换思考深度', details: effort);
    await _syncRunningProxyTarget(ref);

    final providers = await queryRepo.listProviders();
    final selectedId = await queryRepo.selectedId();
    return _providerListPayload(providers, selectedId, effort, healthRepo, isZh());
  });
}

Map<String, dynamic> _providerListPayload(
  List<ApiProvider> providers,
  String? selectedId,
  String? reasoningEffort,
  ProviderHealthRepository healthRepo,
  bool isZh,
) {
  return {
    'selectedId': selectedId,
    'reasoningEffort': _isSupportedReasoningEffort(reasoningEffort)
        ? reasoningEffort
        : 'high',
    'providers': providers
        .map(
          (provider) => {
            'id': provider.id,
            'name': provider.name,
            'models': provider.models,
            'selectedModel': provider.selectedModel,
            'protocol': provider.upstreamProtocol,
            'providerWeight': provider.providerWeight,
            'modelWeight': provider.modelWeight,
            'health': _healthJson(healthRepo.read(providerId: provider.id)),
          },
        )
        .toList(),
    'labels': _shimLabels(isZh),
  };
}

/// Codex 注入侧需要展示给用户看的所有文案。JS 不持有 i18n,这边一并拼好,
/// 任意 /provider/list /select /select-model /set-reasoning-effort 返回时都带。
Map<String, String> _shimLabels(bool isZh) {
  if (isZh) {
    return {
      'deleteHeading': '删除对话',
      'deleteOk': '删除',
      'deleteAria': '删除对话',
      'deleteDefaultTitle': '此对话',
      'deleteSessionIdMissing': '未找到会话 id',
      'deleteFailed': '删除失败',
      'deleteSuccess': '已删除',
      'deleteConfirmPrefix': '确定删除「',
      'deleteConfirmSuffix': '」？此操作不可逆。',
      'cancel': '取消',
      'unknownError': '未知错误',
      'providerFallback': '供应商',
      'clearModel': '清除模型',
      'effortLow': '低',
      'effortMedium': '中',
      'effortHigh': '高',
      'effortXHigh': '超高',
      'healthTimeout': '超时',
      'noProviders': '还没有导入供应商',
      'unnamedProvider': '未命名供应商',
      'providerNoModels': '该供应商没有模型',
      'reasoningEffort': '思考深度',
      'saveFailed': '保存失败',
      'switchProviderFailed': '切换供应商失败',
      'switchModelFailed': '切换模型失败',
      'switchEffortFailed': '切换思考深度失败',
      'autoSwitchedToast': '已自动切换供应商',
      'autoSwitchMaintenanceToast': '自动切换已暂停',
      'autoSwitchNoEligibleToast': '当前供应商不健康,但没有符合条件的候选可切换,请手动检查',
      'probeNow': '测速',
      'threadMenu': '更多',
      'threadExport': '导出对话',
      'threadExportMarkdown': '导出为 Markdown',
      'threadExportRaw': '导出原始数据',
      'threadExportedToast': '已导出',
      'threadExportFailed': '导出失败',
      'claudeBridgeNavLabel': 'Claude 桥',
      'claudeBridgeLoading': '加载中…',
      'claudeBridgeEmpty': '未发现 Claude Code 会话',
      'claudeBridgeErrorPrefix': '加载失败:',
      'claudeBridgeContinueToast': '接续功能待开发',
      'claudeBridgeSessionsCount': '个会话',
    };
  }
  return {
    'deleteHeading': 'Delete thread',
    'deleteOk': 'Delete',
    'deleteAria': 'Delete thread',
    'deleteDefaultTitle': 'this thread',
    'deleteSessionIdMissing': 'Session id not found',
    'deleteFailed': 'Delete failed',
    'deleteSuccess': 'Deleted',
    'deleteConfirmPrefix': 'Delete "',
    'deleteConfirmSuffix': '"? This cannot be undone.',
    'cancel': 'Cancel',
    'unknownError': 'Unknown error',
    'providerFallback': 'Provider',
    'clearModel': 'Clear model',
    'effortLow': 'Low',
    'effortMedium': 'Med',
    'effortHigh': 'High',
    'effortXHigh': 'XHigh',
    'healthTimeout': 'timeout',
    'noProviders': 'No providers configured yet',
    'unnamedProvider': 'Unnamed provider',
    'providerNoModels': 'No models for this provider',
    'reasoningEffort': 'Reasoning',
    'saveFailed': 'Save failed',
    'switchProviderFailed': 'Switch provider failed',
    'switchModelFailed': 'Switch model failed',
    'switchEffortFailed': 'Switch reasoning failed',
    'autoSwitchedToast': 'Provider auto-switched',
    'autoSwitchMaintenanceToast': 'Auto-switch paused',
    'autoSwitchNoEligibleToast': 'Current provider unhealthy, but no eligible candidate to switch — please check manually',
    'probeNow': 'Measure latency',
    'threadMenu': 'More',
    'threadExport': 'Export',
    'threadExportMarkdown': 'Export as Markdown',
    'threadExportRaw': 'Export raws data',
    'threadExportedToast': 'Exported',
    'threadExportFailed': 'Export failed',
    'claudeBridgeNavLabel': 'Claude bridge',
    'claudeBridgeLoading': 'Loading…',
    'claudeBridgeEmpty': 'No Claude Code sessions found',
    'claudeBridgeErrorPrefix': 'Load failed: ',
    'claudeBridgeContinueToast': 'Continue is not implemented yet',
    'claudeBridgeSessionsCount': 'sessions',
  };
}

Map<String, dynamic>? _healthJson(ProviderHealth? h) {
  if (h == null) return null;
  return {
    'status': h.status,
    'latencyMs': h.latencyMs,
    'measuredAt': h.measuredAt,
    'failureStreak': h.failureStreak,
  };
}

bool _isSupportedReasoningEffort(String? effort) {
  return effort == 'low' ||
      effort == 'medium' ||
      effort == 'high' ||
      effort == 'xhigh';
}

void _syncProbeTargets(Ref ref) {
  final probe = ref.read(providerHealthProbeServiceProvider);
  if (!probe.isRunning) return;
  // 异步从 repo 取最新列表后推给 probe；不阻塞调用方
  () async {
    final query = ref.read(providerQueryRepositoryProvider);
    final providers = await query.listProviders();
    probe.updateTargets(providers: providers);
  }();
}

/// 供应商相关写操作的命令面板。
///
/// 用 Notifier 而不是一堆 family-Future provider:
/// - family-Future provider 按参数缓存(`addProviderProvider(provider: X)` 算一个 key),
///   同 key 第二次 `ref.read(...future)` 拿到的是上次的 completed Future,根本不重跑。
/// - 没人 watch 时 family 会被 auto-dispose,正在跑的 await 后续用 ref 直接抛
///   "Cannot use the Ref ... after it has been disposed"。
/// - Notifier 是单例 + keepAlive,方法每次调用都重新执行,没有缓存复用问题,
///   ref 也不会在异步 gap 后被销毁。
@Riverpod(keepAlive: true)
class ProviderActions extends _$ProviderActions {
  @override
  void build() {}

  /// 新增供应商；列表为空时自动选中第一个加入项。
  Future<void> add(ApiProvider provider) async {
    final repo = ref.read(providerActionRepositoryProvider);
    final query = ref.read(providerQueryRepositoryProvider);
    final current = await query.listProviders();
    final selectedId = await query.selectedId();
    await repo.saveProviders([...current, provider]);
    if (selectedId == null) {
      await repo.saveSelectedId(provider.id);
    }
    ref.invalidate(providerListProvider);
    _syncProbeTargets(ref);
  }

  /// 更新供应商。
  Future<void> update(ApiProvider provider) async {
    final repo = ref.read(providerActionRepositoryProvider);
    final query = ref.read(providerQueryRepositoryProvider);
    final current = await query.listProviders();
    final next =
        current.map((p) => p.id == provider.id ? provider : p).toList();
    await repo.saveProviders(next);
    ref.invalidate(providerListProvider);
    // 改的若是当前选中项,热更新运行中的代理目标(链接/key 改了立刻生效)
    await _syncRunningProxyTarget(ref);
    _syncProbeTargets(ref);
  }

  /// 删除供应商；删的是当前选中项则改选第一个剩余项。
  Future<void> remove(String id) async {
    final repo = ref.read(providerActionRepositoryProvider);
    final query = ref.read(providerQueryRepositoryProvider);
    final current = await query.listProviders();
    final selectedId = await query.selectedId();
    final next = current.where((p) => p.id != id).toList();
    await repo.saveProviders(next);
    if (selectedId == id) {
      await repo.saveSelectedId(next.isEmpty ? null : next.first.id);
    }
    ref.invalidate(providerListProvider);
    await _syncRunningProxyTarget(ref);
    _syncProbeTargets(ref);
  }

  /// 选中供应商。
  Future<void> select(String id) async {
    final repo = ref.read(providerActionRepositoryProvider);
    await repo.saveSelectedId(id);
    ref.invalidate(providerListProvider);
    // 切换供应商,热更新运行中的代理目标(零重启)
    await _syncRunningProxyTarget(ref);
  }

  /// 设置代理开关:写持久化后立即应用(开 → 接管,关 → 释放)。
  Future<void> setProxyEnabled(bool enabled) async {
    final repo = ref.read(providerActionRepositoryProvider);
    await repo.saveProxyEnabled(enabled);
    // 先执行接管/释放,再 invalidate proxyConfigProvider。
    // 否则 invalidate 时 startTakeover 里 read 出来的 proxyConfig 还是旧值。
    if (enabled) {
      await startTakeover(ref, enabledOverride: true);
    } else {
      await stopTakeover(ref);
    }
    ref.invalidate(proxyConfigProvider);
  }

  /// 设置代理端口。
  Future<void> setProxyPort(int port) async {
    final repo = ref.read(providerActionRepositoryProvider);
    await repo.saveProxyPort(port.clamp(1, 65535));
    ref.invalidate(proxyConfigProvider);
  }
}

/// 完整接管：起反向代理 + 设转发目标 + 改写 config.toml 的 base_url。
/// 仅当代理开关开着且有可用的选中供应商时执行。可重复调用（幂等）。
Future<void> startTakeover(Ref ref, {bool? enabledOverride}) async {
  final query = ref.read(providerQueryRepositoryProvider);
  final proxyConfig = await query.proxyConfig();
  final effectiveEnabled = enabledOverride ?? proxyConfig.enabled;
  if (!effectiveEnabled) return;

  final selectedId = await query.selectedId();
  if (selectedId == null) return;
  final providers = await query.listProviders();
  ApiProvider? selected;
  for (final p in providers) {
    if (p.id == selectedId) {
      selected = p;
      break;
    }
  }
  if (selected == null ||
      selected.baseUrl.isEmpty ||
      selected.apiKey.isEmpty) {
    return;
  }

  final proxy = ref.read(localProxyServiceProvider);
  final runningPort = ref.read(localProxyRunningPortProvider);
  await proxy.start(
    port: proxyConfig.port,
    target: ProxyTarget(
      baseUrl: selected.baseUrl,
      apiKey: selected.apiKey,
      model: selected.selectedModel,
      upstreamProtocol: selected.upstreamProtocol,
      reasoningEffort: await ref
          .read(appStorageProvider)
          .getString(_reasoningEffortKey),
      providerId: selected.id,
    ),
  );
  runningPort.value = proxy.port ?? proxyConfig.port;

  final actionRepo = ref.read(providerActionRepositoryProvider);
  await actionRepo.enableTakeover(localProxyUrl: proxyConfig.localProxyUrl);

  // 测速调度只在非 manual 才起。manual 模式下用户开 picker 时点对点测,
  // 不在后台轮询,完全避免给上游中转造成压力。
  final allProviders = await query.listProviders();
  final autoSettings = await ref.read(autoSwitchRepositoryProvider).read();
  final probe = ref.read(providerHealthProbeServiceProvider);
  probe.updateTargets(providers: allProviders);

  // 把请求 success/failure/timeout 回调接到 probe 上(请求实时感知)
  bindProxyRequestHooks(
    proxy: proxy,
    onSuccess: (id) => probe.reportRequestSuccess(providerId: id),
    onFailure: (id, reason) {
      probe.reportRequestFailure(providerId: id);
      AppLogService.instance.warning(
        'Proxy',
        '上游请求失败,已上报 health',
        details: 'provider=$id reason=$reason',
      );
    },
    onTimeout: (id, waitedMs) {
      probe.reportSlowTimeout(
        providerId: id,
        waitedMs: waitedMs,
        threshold: autoSettings.slowRequestSwitchThreshold,
      );
    },
  );
  // 把慢响应阈值推给 proxy(0 表示不启用)
  proxy.setSlowTimeout(Duration(seconds: autoSettings.slowRequestTimeoutSeconds));

  if (autoSettings.strategy != 'manual') {
    probe.refreshPeriodicScopeFor(
      currentProviderId: selected.id,
      providers: allProviders,
      scope: autoSettings.scope,
    );
    probe.start(
      providers: allProviders,
      interval: Duration(seconds: autoSettings.probeIntervalSeconds),
    );
    // 必须用 .future 触发 Future provider 执行,只 read 不会跑里面的代码
    unawaited(ref.read(autoSwitchWatcherProvider.future));
  }
}

/// 释放接管：还原 config.toml 的 base_url + 停代理 + 停测速。
Future<void> stopTakeover(Ref ref) async {
  final actionRepo = ref.read(providerActionRepositoryProvider);
  await actionRepo.disableTakeover();
  ref.read(providerHealthProbeServiceProvider).stop();
  final proxy = ref.read(localProxyServiceProvider);
  await proxy.stop();
  ref.read(localProxyRunningPortProvider).value = null;
}

/// 启动时自动接管：app 起来就 watch 一次，按持久化的开关状态自动起代理。
/// 开关开着且有选中供应商 → 起代理 + 设 target + 改 config.toml。
@Riverpod(keepAlive: true)
Future<void> proxyAutoStart(Ref ref) async {
  await startTakeover(ref);
}

