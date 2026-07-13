// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'ShimX';

  @override
  String get searchHint => '搜索';

  @override
  String get searchNoResults => '没有匹配的结果';

  @override
  String get save => '保存';

  @override
  String get close => '关闭';

  @override
  String get back => '返回';

  @override
  String get cancel => '取消';

  @override
  String get create => '创建';

  @override
  String get run => '运行';

  @override
  String get newScript => '新建脚本';

  @override
  String get editScript => '编辑脚本';

  @override
  String get viewCode => '查看代码';

  @override
  String get editorLine => '行';

  @override
  String get editorColumn => '列';

  @override
  String get editorSavedLabel => '已保存';

  @override
  String get editorUnsavedLabel => '未保存';

  @override
  String get editorSavingLabel => '保存中...';

  @override
  String get editorReloadOnRun => '运行时刷新';

  @override
  String get editorReloadOnRunTooltip =>
      '开启:运行按钮会重新加载 Codex 页面并重装脚本;关闭:仅重新注入,不刷新页面';

  @override
  String get editorManual => '手册';

  @override
  String editorManualLoadFailed(String error) {
    return '手册加载失败:$error';
  }

  @override
  String get editorHotRun => '热运行';

  @override
  String get editorHotRunTooltip => '开启:手动保存(Ctrl/Cmd+S)后自动运行当前脚本(不含 1 秒自动保存)';

  @override
  String get editorExternalChangeTitle => '文件已被外部修改';

  @override
  String editorExternalChangeMessage(String id) {
    return '「$id」在磁盘上有新内容,但你有未保存的改动。要放弃当前修改并加载磁盘版本吗?';
  }

  @override
  String get editorExternalChangeReload => '加载磁盘版本';

  @override
  String get editorExternalChangeKeep => '保留我的修改';

  @override
  String editorExternalDeletedToast(String id) {
    return '「$id」已被删除';
  }

  @override
  String get noScriptSelected => '未选中脚本';

  @override
  String get noScriptSelectedHint => '在左侧选一个脚本,或点 + 新建';

  @override
  String get selectScriptFirst => '请先选中一个脚本';

  @override
  String get scriptNameHint => '文件名(自动补 .js)';

  @override
  String get scriptNameRequired => '请填写文件名';

  @override
  String get scriptNameExists => '同名脚本已存在';

  @override
  String get scriptNameInvalid => '文件名不能包含 \\ / : * ? \" < > |';

  @override
  String get scriptCreateSuccess => '已创建,下次注入生效';

  @override
  String get scriptSaveSuccess => '已保存,下次注入生效';

  @override
  String get scriptSaveFailed => '保存失败,文件不存在';

  @override
  String get scriptRunSuccess => '已重新注入';

  @override
  String scriptNotFound(String id) {
    return '找不到脚本 $id';
  }

  @override
  String get home => '首页';

  @override
  String get settings => '设置';

  @override
  String get pageNotFound => '页面不存在';

  @override
  String get unknownRouteError => '未知路由错误';

  @override
  String get backToHome => '返回首页';

  @override
  String get homeTitle => 'ShimX';

  @override
  String get welcome => 'ShimX';

  @override
  String get inject => '注入';

  @override
  String get injectPanelTitle => '界面注入';

  @override
  String get injectPanelDescription => '将 ShimX 的控制界面注入到目标环境，用于后续连接、调试和操作。';

  @override
  String get injectReadyStatus => '等待注入';

  @override
  String injectedAtStatus(String time) {
    return '已注入 · $time';
  }

  @override
  String get readyStatus => '就绪';

  @override
  String get codexConnected => '已连接 Codex';

  @override
  String get codexDisconnected => '未连接';

  @override
  String get checkingStatus => '检测中...';

  @override
  String get refresh => '刷新';

  @override
  String get proxy => '代理';

  @override
  String proxyEnabledDescription(int port) {
    return '已接管 :$port';
  }

  @override
  String get proxyDisabledDescription => '未启用';

  @override
  String get proxyPort => '端口';

  @override
  String get desktopShortcut => '桌面快捷方式';

  @override
  String get desktopShortcutDescription => '一键启动 Codex 并自动注入';

  @override
  String get createShortcut => '创建快捷方式';

  @override
  String get openSourceRepository => '开源地址';

  @override
  String get openRepository => '打开仓库';

  @override
  String openSourceRepositoryFailed(String message) {
    return '打开仓库失败：$message';
  }

  @override
  String get shortcutCreated => '快捷方式已创建到桌面';

  @override
  String shortcutFailed(String message) {
    return '创建失败：$message';
  }

  @override
  String get launchingCodex => '正在启动 Codex 并注入...';

  @override
  String get trayShowWindow => '显示窗口';

  @override
  String get trayLaunchCodex => '启动 Codex 并注入';

  @override
  String get trayQuit => '退出 ShimX';

  @override
  String get trayTooltip => 'ShimX';

  @override
  String get systemLanguage => '系统语言';

  @override
  String get chineseLanguage => '简体中文';

  @override
  String get englishLanguage => '英语';

  @override
  String get themeMode => '主题模式';

  @override
  String get systemTheme => '跟随系统';

  @override
  String get lightTheme => '浅色模式';

  @override
  String get darkTheme => '深色模式';

  @override
  String get primaryColor => '主题色';

  @override
  String get reset => '重置';

  @override
  String get codexNotInstalled => '未检测到已安装的 Codex';

  @override
  String launchFailed(String message) {
    return '启动失败：$message';
  }

  @override
  String get injectSuccess => '注入成功';

  @override
  String get scripts => '脚本';

  @override
  String get localScripts => '本地';

  @override
  String get remoteScripts => '远程';

  @override
  String get installScript => '安装';

  @override
  String get updateScript => '更新';

  @override
  String get restoreScript => '恢复';

  @override
  String get scriptInstalled => '已安装';

  @override
  String get remoteScriptsEmpty => '暂无远程脚本';

  @override
  String get remoteScriptsGithubHint =>
      '远程脚本目录托管在 GitHub,需要能正常访问 raw.githubusercontent.com 的网络环境';

  @override
  String get remoteScriptInstallSuccess => '远程脚本已安装';

  @override
  String remoteScriptInstallFailed(String message) {
    return '安装失败：$message';
  }

  @override
  String get noScripts => '暂无脚本';

  @override
  String get importScript => '导入脚本';

  @override
  String get selectAll => '全选';

  @override
  String get invertSelection => '反选';

  @override
  String get deleteSelected => '删除';

  @override
  String get enableSelected => '启用';

  @override
  String get disableSelected => '禁用';

  @override
  String get notImplementedYet => '暂未实现';

  @override
  String get openInspector => '打开控制台';

  @override
  String openInspectorFailed(String message) {
    return '打开控制台失败：$message';
  }

  @override
  String get confirm => '确认';

  @override
  String get settingsPersistedDescription =>
      '这些设置会通过 SharedPreferencesAsync 持久化保存。';

  @override
  String get updateDownload => '下载更新';

  @override
  String updateDownloadFailed(String message) {
    return '打开下载失败：$message';
  }

  @override
  String get updateAvailableTitle => '发现新版本';

  @override
  String updateAvailableVersion(String version) {
    return '有新版本：$version';
  }

  @override
  String get updateForceBadge => '强制';

  @override
  String get updateLog => '更新日志';

  @override
  String get updateLogDescription => '查看已发布版本时间线';

  @override
  String get updateLogOpen => '查看';

  @override
  String get updateLogEmpty => '暂无更新日志';

  @override
  String updateLogLoadFailed(String message) {
    return '更新日志加载失败：$message';
  }

  @override
  String get updateLogCurrentSystem => '当前系统';

  @override
  String get updateLogAllSystems => '全部系统';

  @override
  String get updateCardNoChangelog => '暂无更新说明';

  @override
  String get providers => '供应商';

  @override
  String get addProvider => '新增';

  @override
  String get noProvidersHint => '还没有供应商，点右上角新增';

  @override
  String get deletedToast => '已删除';

  @override
  String get editProvider => '编辑';

  @override
  String get deleteProvider => '删除';

  @override
  String get providerEditTitleNew => '新增供应商';

  @override
  String get providerEditTitleEdit => '编辑供应商';

  @override
  String get providerName => '名称';

  @override
  String get providerNameHint => 'MuxueAI';

  @override
  String get providerBaseUrl => 'Base URL';

  @override
  String get providerBaseUrlHint => 'https://api.example.com/v1';

  @override
  String get providerApiKey => 'API Key';

  @override
  String get providerApiKeyHint => 'sk-...';

  @override
  String get providerProtocol => '供应商格式';

  @override
  String get providerProtocolResponses => 'Responses';

  @override
  String get providerProtocolChat => 'Chat';

  @override
  String get providerProtocolMessages => 'Messages';

  @override
  String get providerModels => '模型';

  @override
  String get providerModelsFetch => '获取';

  @override
  String get providerModelInputHint => 'gpt-5.5 / claude-sonnet-4-6 ...';

  @override
  String get providerUseDefault => '用 Codex 默认（不覆盖）';

  @override
  String get providerWeight => '供应商权重';

  @override
  String get providerWeightHelp =>
      '自动切换排序用。同 baseUrl+apiKey 的多个条目建议设相同值。1-10,默认 5';

  @override
  String get modelWeight => '模型权重';

  @override
  String get modelWeightHelp => '自动切换排序用。优先级:权重 × 1/延迟 越大越优先。1-10,默认 5';

  @override
  String get providerSave => '保存';

  @override
  String get providerSavedToast => '已保存';

  @override
  String get providerFillFirstToast => '先填 Base URL 和 API Key';

  @override
  String get providerFillAllToast => '请填完整';

  @override
  String get providerSelectModelRequiredToast => '请在下方点选一个模型';

  @override
  String providerFetchedToast(int count) {
    return '获取到 $count 个模型';
  }

  @override
  String providerFetchFailedToast(String message) {
    return '获取失败：$message';
  }

  @override
  String get autoSwitch => '自动切换';

  @override
  String get autoSwitchStrategy => '策略';

  @override
  String get autoSwitchStrategyHelp =>
      '手动：只显示延迟，不自动切；\n故障转移：当前家连续失败 N 次后切到最快候选；\n最快优先：候选比当前快 ≥ 增益就切';

  @override
  String get autoSwitchStrategyManual => '手动';

  @override
  String get autoSwitchStrategyFailover => '故障转移';

  @override
  String get autoSwitchStrategyFastest => '最快优先';

  @override
  String get autoSwitchScope => '切换范围';

  @override
  String get autoSwitchScopeHelp =>
      '同类型：候选必须跟当前同模型家族（openai/claude/gemini）；\n同协议：候选必须跟当前同上游协议；\n任意：不限';

  @override
  String get autoSwitchScopeSameType => '同类型';

  @override
  String get autoSwitchScopeSameProtocol => '同协议';

  @override
  String get autoSwitchScopeAny => '任意';

  @override
  String get autoSwitchFailureThreshold => '失败阈值';

  @override
  String get autoSwitchFailureThresholdHelp => '故障转移策略下，当前家连续失败几次后切换';

  @override
  String get autoSwitchFailureThresholdUnit => '次';

  @override
  String get autoSwitchFastestMargin => '最快优先增益';

  @override
  String get autoSwitchFastestMarginHelp => '最快优先策略下，候选要比当前快多少 ms 才切';

  @override
  String get autoSwitchFastestMarginUnit => 'ms';

  @override
  String get autoSwitchCooldown => '冷却时间';

  @override
  String get autoSwitchCooldownHelp => '切换后多少秒内不再二次切换，防反复横跳';

  @override
  String get autoSwitchCooldownUnit => '秒';

  @override
  String get autoSwitchProbeInterval => '后台测速周期';

  @override
  String get autoSwitchProbeIntervalHelp => '后台多少秒测一次速。手动策略下完全不跑后台周期';

  @override
  String get autoSwitchProbeIntervalUnit => '秒';

  @override
  String get autoSwitchSlowTimeout => '慢响应阈值';

  @override
  String get autoSwitchSlowTimeoutHelp => '单条请求等待响应头超过此秒数视为挂起。0 表示不启用';

  @override
  String get autoSwitchSlowTimeoutUnit => '秒';

  @override
  String get autoSwitchSlowThreshold => '慢响应次数';

  @override
  String get autoSwitchSlowThresholdHelp =>
      '连续 N 次慢响应直接触发自动切换(绕过失败阈值)。1 = 1 次就切';

  @override
  String get autoSwitchSlowThresholdUnit => '次';

  @override
  String get autoSwitchAllowSibling => '允许同家其他模型';

  @override
  String get autoSwitchAllowSiblingHelp =>
      '打开后,当前家挂时也可切到同 baseUrl + apiKey 的另一个模型条目。默认关:同一家挂了切自己等于没切';

  @override
  String get navLogs => '日志';

  @override
  String proxyRunningOnPort(int port) {
    return '代理运行中 :$port';
  }

  @override
  String proxyEnabledOnPort(int port) {
    return '代理已启用 :$port';
  }

  @override
  String get proxyDisabled => '代理未启用';

  @override
  String get refreshCodex => '刷新 Codex';

  @override
  String get codexRefreshedToast => 'Codex 已刷新并重新注入';

  @override
  String codexRefreshFailedToast(String message) {
    return '刷新失败：$message';
  }

  @override
  String get codexNotRunningError => '未检测到 Codex 正在运行';

  @override
  String get logs => '日志';

  @override
  String get logsFilterAll => '全部';

  @override
  String get logsFilterInfo => '信息';

  @override
  String get logsFilterWarning => '警告';

  @override
  String get logsFilterError => '错误';

  @override
  String get logsCopy => '复制';

  @override
  String get logsClear => '清空';

  @override
  String get logsEmpty => '暂无日志';

  @override
  String get logsCopiedToast => '日志已复制';

  @override
  String get shimxDeleteThreadHeading => '删除对话';

  @override
  String get shimxDeleteThreadDelete => '删除';

  @override
  String get shimxDeleteThreadAria => '删除对话';

  @override
  String get shimxDeleteThreadDefaultTitle => '此对话';

  @override
  String get shimxDeleteSessionIdMissing => '未找到会话 id';

  @override
  String get shimxDeleteFailed => '删除失败';

  @override
  String get shimxDeleteSuccess => '已删除';

  @override
  String get shimxUnknownError => '未知错误';

  @override
  String get shimxProviderFallbackName => '供应商';

  @override
  String get shimxClearModel => '清除模型';

  @override
  String get shimxEffortLow => '低';

  @override
  String get shimxEffortMedium => '中';

  @override
  String get shimxEffortHigh => '高';

  @override
  String get shimxEffortXHigh => '超高';

  @override
  String get shimxHealthTimeout => '超时';

  @override
  String get shimxNoProviders => '还没有导入供应商';

  @override
  String get shimxUnnamedProvider => '未命名供应商';

  @override
  String get shimxProviderNoModels => '该供应商没有模型';

  @override
  String get shimxReasoningEffort => '思考深度';

  @override
  String get shimxSaveFailed => '保存失败';

  @override
  String get shimxSwitchProviderFailed => '切换供应商失败';

  @override
  String get shimxSwitchModelFailed => '切换模型失败';

  @override
  String get shimxSwitchEffortFailed => '切换思考深度失败';

  @override
  String get sessionManagement => '会话管理';

  @override
  String get sessionTabClaude => 'Claude';

  @override
  String get sessionTabCodex => 'Codex';

  @override
  String get sessionTabHome => '首页';

  @override
  String get sessionTabBackup => '备份';

  @override
  String get sessionCurrentBucket => '当前 codex 桶';

  @override
  String get sessionSwitchBucket => '切换桶';

  @override
  String get sessionSwitchToShimX => '切到 shimx';

  @override
  String get sessionRefresh => '刷新';

  @override
  String get sessionBucketLabel => '桶';

  @override
  String get sessionSelectAll => '全选';

  @override
  String sessionSelectedCount(int n) {
    return '已选 $n 条';
  }

  @override
  String get sessionMoveTo => '移动到';

  @override
  String get sessionExecute => '执行';

  @override
  String get sessionBackupSelected => '备份选中';

  @override
  String get sessionMergeAllToShimX => '统一对话';

  @override
  String get sessionMergeAllToShimXTooltip =>
      'codex 的会话按 model_provider(桶)分组显示。切换供应商时侧栏只显示当前桶,其它桶里的历史看不到。\n此操作把所有非 shimx 桶里的会话都改成 shimx 桶,并把 codex 的默认桶切到 shimx。之后不管你用哪个供应商,侧栏都能看到全部历史。';

  @override
  String get sessionSwitchBucketTooltip =>
      '选择 codex 侧栏当前显示哪个桶的会话。桶名就是每条会话记录里的 model_provider 字段,不同供应商生成的会话会落到不同桶。切桶只影响侧栏筛选,不会改动会话内容。';

  @override
  String get sessionBackupSelectedTooltip =>
      '把选中的会话打包保存到 shimx 备份目录,同时记录每条会话原本所属的桶。之后可在「备份」tab 里逐条或整批恢复到原桶。';

  @override
  String sessionMoveSuccess(int n, String bucket) {
    return '已移动 $n 条到「$bucket」';
  }

  @override
  String sessionMoveFailed(String error) {
    return '移动失败: $error';
  }

  @override
  String sessionBackupSuccess(int n) {
    return '已备份 $n 条';
  }

  @override
  String sessionBackupFailed(String error) {
    return '备份失败: $error';
  }

  @override
  String get sessionEmptyBucket => '(空)';

  @override
  String get sessionLoadMore => '加载更多';

  @override
  String get sessionNoSelection => '未选择会话';

  @override
  String sessionSwitchBucketSuccess(String bucket) {
    return '已切换到「$bucket」桶';
  }

  @override
  String sessionSwitchBucketFailed(String error) {
    return '切换失败: $error';
  }

  @override
  String get sessionMergeConfirmTitle => '确认合并?';

  @override
  String get sessionMergeConfirmBody =>
      '将把除 shimx 桶外所有会话全部移动到 shimx 桶,该操作不会自动备份。';

  @override
  String get sessionMergeConfirmOk => '合并';

  @override
  String get sessionMergeProgressTitle => '正在合并到 shimx 桶';

  @override
  String sessionMergeProgressBody(int done, int total) {
    return '$done / $total 条';
  }

  @override
  String get sessionBackupLibrary => '备份库';

  @override
  String sessionBackupCountLabel(int n) {
    return '$n 条备份';
  }

  @override
  String sessionBackupFromBucket(String bucket) {
    return '来自「$bucket」';
  }

  @override
  String sessionBackupThreadCount(int n) {
    return '$n 条会话';
  }

  @override
  String get sessionRestoreOne => '恢复';

  @override
  String get sessionRestoreAll => '一键恢复全部';

  @override
  String get sessionDeleteBackup => '删除此备份';

  @override
  String get sessionRestoreConfirmTitle => '确认恢复?';

  @override
  String get sessionRestoreConfirmBody => '会用备份中的内容覆盖当前会话状态。';

  @override
  String get sessionRestoreConfirmOk => '恢复';

  @override
  String get sessionDeleteBackupConfirmTitle => '删除备份?';

  @override
  String get sessionDeleteBackupConfirmBody => '此操作不可撤销。';

  @override
  String get sessionDeleteBackupConfirmOk => '删除';

  @override
  String sessionRestoreSuccess(int n) {
    return '已恢复 $n 条';
  }

  @override
  String sessionRestoreFailed(String error) {
    return '恢复失败: $error';
  }

  @override
  String get sessionDeleteBackupSuccess => '已删除备份';

  @override
  String get sessionBackupEmpty => '还没有备份';

  @override
  String get sessionsTitle => '会话';

  @override
  String get sessionsEmpty => '暂无会话';

  @override
  String get threadSelectHint => '选择一个会话查看详情';

  @override
  String get threadEmpty => '会话内容为空';

  @override
  String get threadMessageUser => '用户';

  @override
  String get threadMessageAssistant => '助手';

  @override
  String get threadMessageToolCall => '工具调用';

  @override
  String get threadMessageToolResult => '工具结果';

  @override
  String get threadMessageGeneric => '消息';

  @override
  String get expand => '展开';

  @override
  String get collapse => '收起';

  @override
  String get sessionExport => '导出';

  @override
  String get sessionExportMarkdown => '导出为 Markdown';

  @override
  String get sessionExportRaw => '导出原始 JSONL';

  @override
  String get sessionExportSuccess => '已导出';

  @override
  String sessionExportFailed(String error) {
    return '导出失败:$error';
  }

  @override
  String get claudeProjects => '项目';

  @override
  String get claudeProjectsEmpty => '未发现 Claude Code 会话(~/.claude/projects/)';

  @override
  String get claudeProjectsSelectHint => '在左侧选择一个项目';

  @override
  String claudeProjectSubtitle(int count, String time) {
    return '$count 个会话 · $time';
  }

  @override
  String get justNow => '刚刚';

  @override
  String minutesAgo(int n) {
    return '$n 分钟前';
  }

  @override
  String hoursAgo(int n) {
    return '$n 小时前';
  }

  @override
  String daysAgo(int n) {
    return '$n 天前';
  }

  @override
  String get copy => '复制';

  @override
  String get copied => '已复制';

  @override
  String get mcp => 'MCP';

  @override
  String get mcpServersTitle => 'shimx 提供的 MCP server';

  @override
  String get mcpServersHint =>
      '这些 MCP server 由 shimx 进程内置提供,可以被 codex 通过 streamable_http 接入,让 LLM 按需查询本地数据。';

  @override
  String get mcpServersEmpty => '尚未启用任何 MCP server';

  @override
  String get mcpShimXClaudeName => 'Claude 会话查询';

  @override
  String get mcpShimXClaudeDescription =>
      '把本地 Claude Code 会话作为 MCP 工具暴露给 Codex 的 LLM。';

  @override
  String get mcpServerUrlLabel => 'URL';

  @override
  String get mcpServerIdLabel => 'ID';

  @override
  String get mcpServerToolCountLabel => '工具数';

  @override
  String get mcpServerRegisteredLabel => '已写入 codex 配置';

  @override
  String get mcpServerRegisteredYes => '是';

  @override
  String get mcpServerRegisteredNo => '否';

  @override
  String get mcpServerStatusDetailLabel => '错误信息';

  @override
  String get mcpStatusRunning => '运行中';

  @override
  String get mcpStatusStopped => '未启动';

  @override
  String get mcpStatusError => '错误';

  @override
  String get mcpConfigTitle => 'Codex MCP 配置（高级）';

  @override
  String get mcpConfigHint =>
      '展示 config.toml 中的 [mcp_servers.*]；开关和保存会写入 config.toml，并在新的 Codex 会话中生效。';

  @override
  String get mcpConfigEmpty => '还没有 Codex MCP 配置';

  @override
  String get mcpConfigAdd => '新增';

  @override
  String get mcpConfigBodyLabel => '配置';

  @override
  String get mcpConfigIdLabel => 'ID';

  @override
  String get mcpConfigFillRequiredToast => '请填写 ID 和配置';

  @override
  String get mcpConfigDialogTitleNew => '新增 MCP 配置';

  @override
  String get mcpConfigDialogTitleEdit => '编辑 MCP 配置';

  @override
  String get mcpConfigIdHint => '例如 my_server';

  @override
  String get mcpConfigBodyContentLabel => '配置内容';

  @override
  String get mcpConfigBodyHelper => '只填写当前条目的字段内容；表头由 ID 自动写入';

  @override
  String get mcpConfigEnabledLabel => '写入 config.toml';

  @override
  String get mcpConfigInstalling => '正在安装 MCP...';

  @override
  String get skills => 'Skills';

  @override
  String get skillsTitle => 'Codex Skills';

  @override
  String get skillsHint =>
      '管理 ~/.codex/skills 下的本地 Codex Skill。shimx 只会删除或覆盖已导入 registry 的 Skill。';

  @override
  String get skillsInstallFolder => '安装文件夹';

  @override
  String get skillsInstallZip => '安装 ZIP';

  @override
  String get skillsManagedGroup => 'shimx 管理';

  @override
  String get skillsExternalGroup => '外部 Codex Skills';

  @override
  String get skillsEmpty => '还没有发现 Codex Skill';

  @override
  String get skillsManagedBadge => 'shimx 管理';

  @override
  String get skillsExternalBadge => '外部';

  @override
  String get skillsImportManaged => '导入管理';

  @override
  String get skillsCopyPath => '复制路径';

  @override
  String get skillsDelete => '删除';

  @override
  String get skillsPathLabel => '路径';

  @override
  String get skillsIdLabel => 'ID';

  @override
  String get skillsHashLabel => '内容 Hash';

  @override
  String get skillsInstallSuccess => 'Skill 已安装';

  @override
  String get skillsImportSuccess => '已导入管理';

  @override
  String get skillsDeleteSuccess => 'Skill 已删除';

  @override
  String skillsActionFailed(String message) {
    return '操作失败：$message';
  }

  @override
  String get skillsOverwriteTitle => '覆盖 Skill';

  @override
  String get skillsOverwriteMessage => '同名 shimx 管理 Skill 已存在，确认覆盖当前目录？';

  @override
  String get skillsDeleteTitle => '删除 Skill';

  @override
  String get skillsDeleteMessage => '确认删除这个 shimx 管理的 Skill 目录？';

  @override
  String get skillsZipChooseTitle => '选择 ZIP 中的 Skill';

  @override
  String get skillsNoFolderSelected => '未选择文件夹';

  @override
  String get skillsNoZipSelected => '未选择 ZIP';

  @override
  String get skillsNoDescription => '无描述';

  @override
  String get skillsRefreshing => '正在刷新 Skills...';

  @override
  String get skillsInstalling => '正在安装 Skills...';

  @override
  String get skillsImporting => '正在导入 Skill...';

  @override
  String get skillsDeleting => '正在删除 Skill...';

  @override
  String get toolFilterKeywordsTitle => '工具过滤关键词';

  @override
  String get toolFilterKeywordsDescription => '按关键词剔除请求里的工具项';

  @override
  String get toolFilterKeywordsManage => '管理';

  @override
  String get toolFilterKeywordsEmpty => '暂无关键词(空列表 = 不过滤任何工具)';

  @override
  String get toolFilterKeywordAdd => '添加';

  @override
  String get toolFilterKeywordHint => '如 image_generation';

  @override
  String get toolFilterKeywordEmpty => '关键词不能为空';

  @override
  String get toolFilterKeywordDuplicate => '该关键词已在列表中';

  @override
  String get requiresOpenaiAuthTitle => '开启官方登录';

  @override
  String get requiresOpenaiAuthDescription => '改动需重启 Codex';

  @override
  String get codexLaunchTargetTitle => 'Codex 启动目标';

  @override
  String get codexLaunchTargetDescription =>
      '留空 = 走内置默认(Windows 匹配 OpenAI.ChatGPT*/OpenAI.Codex*,macOS 探测 /Applications/ChatGPT.app 或 Codex.app)';

  @override
  String get codexLaunchTargetHintMac =>
      '自定义 .app 完整路径,例如 /Applications/ChatGPT.app';

  @override
  String get codexLaunchTargetHintWindows =>
      '自定义 AppxPackage -Name 通配符,例如 OpenAI.ChatGPT*';

  @override
  String get codexLaunchTargetHintDefault => '自定义 codex 启动目标';

  @override
  String get codexLaunchTargetReset => '重置为默认';

  @override
  String get codexRunningWithoutDebugTitle => 'Codex 已运行但未启用调试端口';

  @override
  String get codexRunningWithoutDebugBody =>
      '请先完全退出 Codex,然后再点击注入让 shim 用调试参数重启它。';

  @override
  String get threadContextMenuDelete => '删除会话';

  @override
  String get threadDeleteConfirmTitle => '删除会话';

  @override
  String threadDeleteConfirmBody(String title) {
    return '确定要删除\"$title\"吗?原始文件会先备份到应用数据目录,可以在文件夹里找回。';
  }

  @override
  String get threadDeleteSuccess => '已删除';

  @override
  String threadDeleteFailed(String message) {
    return '删除失败:$message';
  }
}
