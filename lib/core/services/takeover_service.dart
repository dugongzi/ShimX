import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shimx/core/constants/storage_keys.dart';
import 'package:shimx/core/services/app_log_service.dart';
import 'package:shimx/core/services/app_storage.dart';
import 'package:shimx/core/services/local_proxy_service.dart';
import 'package:shimx/features/providers/domain/models/api_provider.dart';
import 'package:shimx/features/providers/presentation/providers/auto_switch_provider.dart';
import 'package:shimx/features/providers/presentation/providers/provider_action_provider.dart';
import 'package:shimx/features/providers/presentation/providers/provider_health_provider.dart';
import 'package:shimx/features/providers/presentation/providers/provider_query_provider.dart';

part 'takeover_service.g.dart';

/// 完整接管:起反向代理 + 设转发目标 + 改写 config.toml 的 base_url。
/// 仅当代理开关开着且有可用的选中供应商时执行。可重复调用(幂等)。
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
  if (selected == null || selected.baseUrl.isEmpty || selected.apiKey.isEmpty) {
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
      reasoningEffort:
          await ref.read(appStorageProvider).getString(reasoningEffortKey),
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
  proxy.setSlowTimeout(
    Duration(seconds: autoSettings.slowRequestTimeoutSeconds),
  );

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

/// 释放接管:还原 config.toml 的 base_url + 停代理 + 停测速。
Future<void> stopTakeover(Ref ref) async {
  final actionRepo = ref.read(providerActionRepositoryProvider);
  await actionRepo.disableTakeover();
  ref.read(providerHealthProbeServiceProvider).stop();
  final proxy = ref.read(localProxyServiceProvider);
  await proxy.stop();
  ref.read(localProxyRunningPortProvider).value = null;
}

/// 若代理正在运行,把当前选中的供应商热更新给代理的转发目标(零重启切换)。
/// update/select 后调用,保证改了链接/换了供应商,运行中的代理立刻生效。
/// 顺便把后台测速的周期范围更新到新选中的家。
Future<void> syncRunningProxyTarget(Ref ref) async {
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
  if (selected == null || selected.baseUrl.isEmpty || selected.apiKey.isEmpty) {
    return;
  }
  final reasoningEffort =
      await ref.read(appStorageProvider).getString(reasoningEffortKey);
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
  ref
      .read(providerHealthProbeServiceProvider)
      .refreshPeriodicScopeFor(
        currentProviderId: selected.id,
        providers: providers,
        scope: autoSettings.scope,
      );
}

/// 把测速目标列表推给运行中的 probe。仅 probe 已运行时生效;未运行时无副作用。
void syncProbeTargets(Ref ref) {
  final probe = ref.read(providerHealthProbeServiceProvider);
  if (!probe.isRunning) return;
  () async {
    final query = ref.read(providerQueryRepositoryProvider);
    final providers = await query.listProviders();
    probe.updateTargets(providers: providers);
  }();
}

/// 启动时自动接管:app 起来就 watch 一次,按持久化的开关状态自动起代理。
/// 开关开着且有选中供应商 → 起代理 + 设 target + 改 config.toml。
@Riverpod(keepAlive: true)
Future<void> proxyAutoStart(Ref ref) async {
  await startTakeover(ref);
}
