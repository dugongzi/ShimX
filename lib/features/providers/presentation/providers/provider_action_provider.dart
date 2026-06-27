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
  if (selected == null || selected.baseUrl.isEmpty || selected.apiKey.isEmpty) {
    return;
  }
  final reasoningEffort = await ref
      .read(appStorageProvider)
      .getString(_reasoningEffortKey);
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
    return _providerListPayload(
      providers,
      selectedId,
      reasoningEffort,
      healthRepo,
      isZh(),
    );
  });

  bridge.register('/provider/select', (payload) async {
    final id = payload['id'];
    if (id is! String || id.isEmpty) {
      throw ArgumentError('provider id is required');
    }
    final prevSelected = await queryRepo.selectedId();
    await actionRepo.saveSelectedId(id);
    if (prevSelected == id) {
      AppLogService.instance.debug(
        'Provider',
        '选中供应商(无变化)',
        details: 'id=$id 调用方=${payload['__caller'] ?? '(unknown)'}',
      );
    } else {
      AppLogService.instance.info(
        'Provider',
        '选中供应商',
        details:
            'id=$id prev=$prevSelected 调用方=${payload['__caller'] ?? '(unknown)'}',
      );
    }
    ref.invalidate(providerListProvider);
    await _syncRunningProxyTarget(ref);

    final providers = await queryRepo.listProviders();
    final selectedId = await queryRepo.selectedId();
    final reasoningEffort = await appStorage.getString(_reasoningEffortKey);
    return _providerListPayload(
      providers,
      selectedId,
      reasoningEffort,
      healthRepo,
      isZh(),
    );
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
    String? prevModel;
    final next = providers.map<ApiProvider>((provider) {
      if (provider.id != id) return provider;
      found = true;
      prevModel = provider.selectedModel;
      return provider.copyWith(selectedModel: model);
    }).toList();
    if (!found) throw ArgumentError('provider not found: $id');

    final prevSelected = await queryRepo.selectedId();
    await actionRepo.saveProviders(next);
    if (prevModel == model) {
      AppLogService.instance.debug(
        'Provider',
        '切换模型(无变化)',
        details:
            'id=$id model=${model ?? "(null)"} 调用方=${payload['__caller'] ?? '(unknown)'}',
      );
    } else {
      AppLogService.instance.info(
        'Provider',
        '切换模型',
        details:
            'id=$id ${prevModel ?? "(null)"} -> ${model ?? "(null)"} 调用方=${payload['__caller'] ?? '(unknown)'}',
      );
    }
    await actionRepo.saveSelectedId(id);
    if (prevSelected != id) {
      AppLogService.instance.info(
        'Provider',
        '选中供应商',
        details: 'id=$id prev=$prevSelected (via select-model)',
      );
    }
    ref.invalidate(providerListProvider);
    await _syncRunningProxyTarget(ref);

    final selectedId = await queryRepo.selectedId();
    final reasoningEffort = await appStorage.getString(_reasoningEffortKey);
    return _providerListPayload(
      next,
      selectedId,
      reasoningEffort,
      healthRepo,
      isZh(),
    );
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
    return _providerListPayload(
      providers,
      selectedId,
      effort,
      healthRepo,
      isZh(),
    );
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
      'claudeBridgeBoundToast': '已绑定为接续上下文',
      'claudeBridgeUnboundToast': '已解除绑定',
      'claudeBridgeBindFailed': '绑定失败',
      'claudeBridgeNoActiveThread': '请先在 codex 中打开或选中一条对话再绑定',
      'claudeBridgeChipPrefix': 'Claude:',
      'claudeBridgeChipUnbindAria': '解除绑定',
      'claudeBridgeSessionsCount': '个会话',
      'shimControlTitle': 'Shim 控制',
      'shimControlSubtitle': 'Codex 运行面板',
      'shimControlClose': '关闭',
      'shimControlRefresh': '刷新',
      'shimControlRefreshAria': '刷新状态',
      'shimControlCopy': '复制',
      'shimControlCopyAria': '复制状态摘要',
      'shimControlCopied': '状态已复制',
      'shimControlCopyEmpty': '暂无可复制的状态',
      'shimControlCopyFailed': '复制失败',
      'shimControlLoading': '状态',
      'shimControlChecking': '检测中…',
      'shimControlCheckingDescription': '正在收集 Bridge、供应商、故障转移和上下文映射状态。',
      'shimControlNoCodexThread': '未选中 Codex 对话',
      'shimControlCurrentThread': '当前对话',
      'shimControlThreadId': 'Thread ID',
      'shimControlThreadWaiting': '打开已保存的 Codex 对话后，可在这里查看上下文映射。',
      'shimControlBoundTo': '映射到',
      'shimControlReadyToBind': '未映射',
      'shimControlNoThreadState': '无对话',
      'shimControlClaudeSession': 'Claude 会话',
      'shimControlBoundVerb': '绑定',
      'shimControlSessionSuffix': '会话',
      'shimControlUnboundClaude': '未绑定 Claude 会话',
      'shimControlClaudeBindingFailed': '绑定状态读取失败',
      'shimControlClaudeBindingEmpty': '暂无 Codex 对话映射 Claude 会话',
      'shimControlClaudeBindingCount': '个对话映射',
      'shimControlLegacyBinding': '旧版全局绑定',
      'shimControlBridge': 'Bridge',
      'shimControlBridgeReady': '已连接',
      'shimControlBridgeFailed': '不可用',
      'shimControlBridgeDescription': '本地 RPC 通道可用，页面可以正常调用 Shim。',
      'shimControlBridgeErrorDescription': '注入页面暂时无法访问本地 Bridge。',
      'shimControlProvider': '供应商',
      'shimControlProviderEmpty': '未接管供应商',
      'shimControlProviderFailed': '供应商不可用',
      'shimControlProviderDescription': 'Codex 请求会通过当前供应商转发。',
      'shimControlProviderEmptyDescription': '未覆盖供应商，Codex 使用当前默认配置。',
      'shimControlAutoSwitch': '自动切换',
      'shimControlAutoSwitchFailed': '自动切换不可用',
      'shimControlAutoSwitchDescription': '供应商健康状态异常时可触发故障转移。',
      'shimControlAutoSwitchManualDescription': '自动故障转移待命，需要时可手动切换。',
      'shimControlClaudeBinding': '上下文映射',
      'shimControlClaudeBindingDescription': '已映射的对话会把 Claude 上下文带入 Codex。',
      'shimControlClaudeBindingEmptyDescription': '从侧栏选择 Claude 会话后，可在这里查看上下文映射。',
      'shimControlBoundMetricSuffix': '条映射',
      'shimControlCopyThreadId': '复制 ID',
      'shimControlThreadIdCopied': 'Thread ID 已复制',
      'shimControlStatusOk': '正常',
      'shimControlStatusWarn': '注意',
      'shimControlStatusError': '异常',
      'shimControlStatusInfo': '信息',
      'shimControlStatusIdle': '待命',
      'shimControlStatus': '状态',
      'shimControlStatusPreviewTab': '状态预览',
      'shimControlRuntimeSection': '运行状态',
      'shimControlCurrentMode': '当前模式',
      'shimControlProviderName': '供应商名称',
      'shimControlProviderModel': '模型',
      'shimControlProviderModelEmpty': '透传',
      'shimControlProviderProtocol': '协议',
      'shimControlProviderWeights': '权重',
      'shimControlBindingsSection': '对话映射',
      'shimControlCodexColumn': 'Codex 对话',
      'shimControlClaudeColumn': 'Claude 会话',
      'shimControlOverviewTab': '数据概览',
      'shimControlNavTitle': '面板',
      'shimControlProviderSection': '供应商详情',
      'shimControlLogsTab': '日志',
      'shimControlLogsHeading': '运行日志',
      'shimControlLogsDescription': '展示 Shim 后端最近的日志条目,用于排查供应商/绑定问题。',
      'shimControlLogsFilterAll': '全部',
      'shimControlLogsFilterInfo': '信息',
      'shimControlLogsFilterWarning': '警告',
      'shimControlLogsFilterError': '错误',
      'shimControlLogsEmpty': '暂无日志',
      'shimControlLogsClear': '清空',
      'shimControlLogsClearAria': '清空日志',
      'shimControlLogsCleared': '已清空日志',
      'shimControlLogsClearFailed': '清空失败',
      'shimControlLogsCopyFailed': '复制失败',
      'shimControlLogsReload': '重新加载',
      'shimControlLogsLoadFailed': '加载日志失败',
      'shimControlLogsCount': '条',
      'shimControlBindingUnbind': '解绑',
      'shimControlBindingUnbindAria': '解除此映射',
      'shimControlBindingUnboundToast': '已解绑',
      'shimControlBindingUnbindFailed': '解绑失败',
      'shimControlActionsLabel': '操作',
      'shimControlExportMarkdown': '导出 Markdown',
      'shimControlExportRaw': '导出原始数据',
      'shimControlDeleteThread': '删除对话',
      'shimControlUnbindCurrent': '解除映射',
      'shimControlBindingMissingThread': '当前对话尚无映射可解除',
      'shimControlExportHtml': '导出 HTML',
      'threadExportHtml': '导出为 HTML',
      'projectMenuExportAs': '导出为',
      'projectMenuExportMarkdownZip': 'Markdown · zip',
      'projectMenuExportRawZip': '原始数据 · zip (支持导入)',
      'projectMenuImportZip': '导入 zip',
      'projectMenuImportZipAria': '把 zip 包内所有对话导入到此项目',
      'projectMenuExportHtmlZip': 'HTML · zip',
      'projectMenuExportEmpty': '该项目没有可导出的对话',
      'projectMenuExportRunning': '正在打包导出…',
      'projectMenuExportDone': '已导出',
      'projectMenuExportFailed': '导出失败',
      'projectMenuExportMissingCwd': '未识别到项目路径',
      'exportBusyMarkdown': '正在导出 Markdown…',
      'exportBusyRaws': '正在导出原始数据…',
      'exportBusyHtml': '正在导出 HTML…',
      'exportBusyBundle': '正在打包导出…',
      'shimControlImport': '导入',
      'shimControlImportAria': '导入会话',
      'shimControlImportJsonl': '导入 .jsonl',
      'shimControlImportZip': '导入 zip',
      'shimControlImportToCurrent': '归到当前项目',
      'shimControlImportToOriginal': '保留原始项目',
      'shimControlImportBusyFile': '正在导入会话…',
      'shimControlImportBusyZip': '正在导入项目…',
      'shimControlImportDone': '导入成功',
      'shimControlImportDoneN': '已导入',
      'shimControlImportFailed': '导入失败',
      'shimControlImportEmpty': '压缩包内未找到 .jsonl 文件',
      'shimControlImportBadFile': '文件无效或为空',
      'shimControlImportHint': '导入后 Codex 需要刷新页面才能在侧栏看到',
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
    'autoSwitchNoEligibleToast':
        'Current provider unhealthy, but no eligible candidate to switch — please check manually',
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
    'claudeBridgeBoundToast': 'Bound as continuation context',
    'claudeBridgeUnboundToast': 'Unbound',
    'claudeBridgeBindFailed': 'Bind failed',
    'claudeBridgeNoActiveThread': 'Open or select a codex conversation first',
    'claudeBridgeChipPrefix': 'Claude:',
    'claudeBridgeChipUnbindAria': 'Unbind',
    'claudeBridgeSessionsCount': 'sessions',
    'shimControlTitle': 'Shim control',
    'shimControlSubtitle': 'Codex runtime panel',
    'shimControlClose': 'Close',
    'shimControlRefresh': 'Refresh',
    'shimControlRefreshAria': 'Refresh status',
    'shimControlCopy': 'Copy',
    'shimControlCopyAria': 'Copy status summary',
    'shimControlCopied': 'Status copied',
    'shimControlCopyEmpty': 'No status to copy yet',
    'shimControlCopyFailed': 'Copy failed',
    'shimControlLoading': 'Status',
    'shimControlChecking': 'Checking…',
    'shimControlCheckingDescription':
        'Collecting bridge, provider, failover, and context mapping status.',
    'shimControlNoCodexThread': 'No active Codex conversation',
    'shimControlCurrentThread': 'Current thread',
    'shimControlThreadId': 'Thread ID',
    'shimControlThreadWaiting':
        'Open a saved Codex conversation to inspect context mappings.',
    'shimControlBoundTo': 'Mapped to',
    'shimControlReadyToBind': 'Not mapped',
    'shimControlNoThreadState': 'No thread',
    'shimControlClaudeSession': 'Claude session',
    'shimControlBoundVerb': 'bound to',
    'shimControlSessionSuffix': 'session',
    'shimControlUnboundClaude': 'has no Claude session bound',
    'shimControlClaudeBindingFailed': 'Binding status unavailable',
    'shimControlClaudeBindingEmpty': 'No Codex conversations are mapped',
    'shimControlClaudeBindingCount': 'conversation mappings',
    'shimControlLegacyBinding': 'Legacy global binding',
    'shimControlBridge': 'Bridge',
    'shimControlBridgeReady': 'Connected',
    'shimControlBridgeFailed': 'Unavailable',
    'shimControlBridgeDescription': 'Local RPC channel is reachable.',
    'shimControlBridgeErrorDescription':
        'The injected page cannot reach the local bridge.',
    'shimControlProvider': 'Provider',
    'shimControlProviderEmpty': 'No active provider',
    'shimControlProviderFailed': 'Provider unavailable',
    'shimControlProviderDescription':
        'Requests are routed through this provider.',
    'shimControlProviderEmptyDescription':
        'Codex is using its current default provider.',
    'shimControlAutoSwitch': 'Auto switch',
    'shimControlAutoSwitchFailed': 'Auto switch unavailable',
    'shimControlAutoSwitchDescription':
        'Provider health can trigger failover.',
    'shimControlAutoSwitchManualDescription':
        'Automatic failover is standing by.',
    'shimControlClaudeBinding': 'Context mapping',
    'shimControlClaudeBindingDescription':
        'Mapped conversations carry Claude context into Codex.',
    'shimControlClaudeBindingEmptyDescription':
        'Select a Claude session from the sidebar to inspect context mappings here.',
    'shimControlBoundMetricSuffix': 'mappings',
    'shimControlCopyThreadId': 'Copy ID',
    'shimControlThreadIdCopied': 'Thread ID copied',
    'shimControlStatusOk': 'OK',
    'shimControlStatusWarn': 'Warn',
    'shimControlStatusError': 'Error',
    'shimControlStatusInfo': 'Info',
    'shimControlStatusIdle': 'Idle',
    'shimControlStatus': 'Status',
    'shimControlStatusPreviewTab': 'Status preview',
    'shimControlRuntimeSection': 'Runtime',
    'shimControlCurrentMode': 'Mode',
    'shimControlProviderName': 'Provider name',
    'shimControlProviderModel': 'Model',
    'shimControlProviderModelEmpty': 'Passthrough',
    'shimControlProviderProtocol': 'Protocol',
    'shimControlProviderWeights': 'Weights',
    'shimControlBindingsSection': 'Conversation mappings',
    'shimControlCodexColumn': 'Codex conversation',
    'shimControlClaudeColumn': 'Claude session',
    'shimControlOverviewTab': 'Data overview',
    'shimControlNavTitle': 'Sections',
    'shimControlProviderSection': 'Provider details',
    'shimControlLogsTab': 'Logs',
    'shimControlLogsHeading': 'Runtime logs',
    'shimControlLogsDescription':
        'Recent log entries from the Shim backend, useful for diagnosing provider and binding issues.',
    'shimControlLogsFilterAll': 'All',
    'shimControlLogsFilterInfo': 'Info',
    'shimControlLogsFilterWarning': 'Warn',
    'shimControlLogsFilterError': 'Error',
    'shimControlLogsEmpty': 'No logs yet',
    'shimControlLogsClear': 'Clear',
    'shimControlLogsClearAria': 'Clear logs',
    'shimControlLogsCleared': 'Logs cleared',
    'shimControlLogsClearFailed': 'Clear failed',
    'shimControlLogsCopyFailed': 'Copy failed',
    'shimControlLogsReload': 'Reload',
    'shimControlLogsLoadFailed': 'Failed to load logs',
    'shimControlLogsCount': 'entries',
    'shimControlBindingUnbind': 'Unbind',
    'shimControlBindingUnbindAria': 'Remove this mapping',
    'shimControlBindingUnboundToast': 'Mapping removed',
    'shimControlBindingUnbindFailed': 'Unbind failed',
    'shimControlActionsLabel': 'Actions',
    'shimControlExportMarkdown': 'Export as Markdown',
    'shimControlExportRaw': 'Export raw data',
    'shimControlDeleteThread': 'Delete thread',
    'shimControlUnbindCurrent': 'Remove mapping',
    'shimControlBindingMissingThread': 'No mapping to remove for this thread',
    'shimControlExportHtml': 'Export HTML',
    'threadExportHtml': 'Export as HTML',
    'projectMenuExportAs': 'Export as',
    'projectMenuExportMarkdownZip': 'Markdown · zip',
    'projectMenuExportRawZip': 'Raw data · zip (importable)',
    'projectMenuImportZip': 'Import zip',
    'projectMenuImportZipAria': 'Import all conversations from a zip into this project',
    'projectMenuExportHtmlZip': 'HTML · zip',
    'projectMenuExportEmpty': 'This project has no conversations to export',
    'projectMenuExportRunning': 'Packing export…',
    'projectMenuExportDone': 'Exported',
    'projectMenuExportFailed': 'Export failed',
    'projectMenuExportMissingCwd': 'Project path not detected',
    'exportBusyMarkdown': 'Exporting Markdown…',
    'exportBusyRaws': 'Exporting raw data…',
    'exportBusyHtml': 'Exporting HTML…',
    'exportBusyBundle': 'Packing export…',
    'shimControlImport': 'Import',
    'shimControlImportAria': 'Import conversations',
    'shimControlImportJsonl': 'Import .jsonl',
    'shimControlImportZip': 'Import zip',
    'shimControlImportToCurrent': 'Assign to current project',
    'shimControlImportToOriginal': 'Keep original project',
    'shimControlImportBusyFile': 'Importing conversation…',
    'shimControlImportBusyZip': 'Importing project bundle…',
    'shimControlImportDone': 'Import succeeded',
    'shimControlImportDoneN': 'Imported',
    'shimControlImportFailed': 'Import failed',
    'shimControlImportEmpty': 'No .jsonl files inside the zip',
    'shimControlImportBadFile': 'File is invalid or empty',
    'shimControlImportHint': 'Reload Codex to see imported threads in the sidebar',
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
    final next = current
        .map((p) => p.id == provider.id ? provider : p)
        .toList();
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
