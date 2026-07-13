// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'ShimX';

  @override
  String get searchHint => 'Search';

  @override
  String get searchNoResults => 'No results';

  @override
  String get save => 'Save';

  @override
  String get close => 'Close';

  @override
  String get back => 'Back';

  @override
  String get cancel => 'Cancel';

  @override
  String get create => 'Create';

  @override
  String get run => 'Run';

  @override
  String get newScript => 'New Script';

  @override
  String get editScript => 'Edit Script';

  @override
  String get viewCode => 'View Code';

  @override
  String get editorLine => 'Ln';

  @override
  String get editorColumn => 'Col';

  @override
  String get editorSavedLabel => 'Saved';

  @override
  String get editorUnsavedLabel => 'Unsaved';

  @override
  String get editorSavingLabel => 'Saving...';

  @override
  String get editorReloadOnRun => 'Reload on Run';

  @override
  String get editorReloadOnRunTooltip =>
      'On: Run reloads the Codex page and reinstalls scripts. Off: reinject only, no page reload.';

  @override
  String get editorManual => 'Manual';

  @override
  String editorManualLoadFailed(String error) {
    return 'Failed to load manual: $error';
  }

  @override
  String get editorHotRun => 'Hot Run';

  @override
  String get editorHotRunTooltip =>
      'On: manual save (Ctrl/Cmd+S) auto-runs the current script (does not apply to the 1s auto-save).';

  @override
  String get editorExternalChangeTitle => 'File changed on disk';

  @override
  String editorExternalChangeMessage(String id) {
    return '\"$id\" was changed on disk, but you have unsaved edits. Discard your changes and load the disk version?';
  }

  @override
  String get editorExternalChangeReload => 'Load disk version';

  @override
  String get editorExternalChangeKeep => 'Keep my edits';

  @override
  String editorExternalDeletedToast(String id) {
    return '\"$id\" was deleted';
  }

  @override
  String get noScriptSelected => 'No script selected';

  @override
  String get noScriptSelectedHint =>
      'Pick a script on the left, or click + to create one';

  @override
  String get selectScriptFirst => 'Select a script first';

  @override
  String get scriptNameHint => 'Filename (auto .js suffix)';

  @override
  String get scriptNameRequired => 'Filename required';

  @override
  String get scriptNameExists => 'A script with this name already exists';

  @override
  String get scriptNameInvalid => 'Filename cannot contain \\ / : * ? \" < > |';

  @override
  String get scriptCreateSuccess => 'Created — takes effect on next inject';

  @override
  String get scriptSaveSuccess => 'Saved — takes effect on next inject';

  @override
  String get scriptSaveFailed => 'Save failed, file not found';

  @override
  String get scriptRunSuccess => 'Reinjected';

  @override
  String scriptNotFound(String id) {
    return 'Script $id not found';
  }

  @override
  String get home => 'Home';

  @override
  String get settings => 'Settings';

  @override
  String get pageNotFound => 'Page not found';

  @override
  String get unknownRouteError => 'Unknown route error';

  @override
  String get backToHome => 'Back to home';

  @override
  String get homeTitle => 'ShimX';

  @override
  String get welcome => 'ShimX';

  @override
  String get inject => 'Inject';

  @override
  String get injectPanelTitle => 'UI Injection';

  @override
  String get injectPanelDescription =>
      'Inject the ShimX control surface into the target environment for connection, debugging, and operation.';

  @override
  String get injectReadyStatus => 'Ready to inject';

  @override
  String injectedAtStatus(String time) {
    return 'Injected · $time';
  }

  @override
  String get readyStatus => 'Ready';

  @override
  String get codexConnected => 'Codex connected';

  @override
  String get codexDisconnected => 'Disconnected';

  @override
  String get checkingStatus => 'Checking...';

  @override
  String get refresh => 'Refresh';

  @override
  String get proxy => 'Proxy';

  @override
  String proxyEnabledDescription(int port) {
    return 'Active on :$port';
  }

  @override
  String get proxyDisabledDescription => 'Disabled';

  @override
  String get proxyPort => 'Port';

  @override
  String get desktopShortcut => 'Desktop shortcut';

  @override
  String get desktopShortcutDescription =>
      'Launch Codex and inject in one click';

  @override
  String get createShortcut => 'Create shortcut';

  @override
  String get openSourceRepository => 'Open-source repository';

  @override
  String get openRepository => 'Open repo';

  @override
  String openSourceRepositoryFailed(String message) {
    return 'Failed to open repository: $message';
  }

  @override
  String get shortcutCreated => 'Shortcut created on desktop';

  @override
  String shortcutFailed(String message) {
    return 'Failed to create: $message';
  }

  @override
  String get launchingCodex => 'Launching Codex & injecting...';

  @override
  String get trayShowWindow => 'Show window';

  @override
  String get trayLaunchCodex => 'Launch Codex & inject';

  @override
  String get trayQuit => 'Quit ShimX';

  @override
  String get trayTooltip => 'ShimX';

  @override
  String get systemLanguage => 'System language';

  @override
  String get chineseLanguage => 'Simplified Chinese';

  @override
  String get englishLanguage => 'English';

  @override
  String get themeMode => 'Theme mode';

  @override
  String get systemTheme => 'System';

  @override
  String get lightTheme => 'Light mode';

  @override
  String get darkTheme => 'Dark mode';

  @override
  String get primaryColor => 'Primary color';

  @override
  String get reset => 'Reset';

  @override
  String get codexNotInstalled => 'Codex is not installed';

  @override
  String launchFailed(String message) {
    return 'Launch failed: $message';
  }

  @override
  String get injectSuccess => 'Injection successful';

  @override
  String get scripts => 'Scripts';

  @override
  String get localScripts => 'Local';

  @override
  String get remoteScripts => 'Remote';

  @override
  String get installScript => 'Install';

  @override
  String get updateScript => 'Update';

  @override
  String get restoreScript => 'Restore';

  @override
  String get scriptInstalled => 'Installed';

  @override
  String get remoteScriptsEmpty => 'No remote scripts';

  @override
  String get remoteScriptInstallSuccess => 'Remote script installed';

  @override
  String remoteScriptInstallFailed(String message) {
    return 'Install failed: $message';
  }

  @override
  String get noScripts => 'No scripts';

  @override
  String get importScript => 'Import script';

  @override
  String get selectAll => 'Select all';

  @override
  String get invertSelection => 'Invert';

  @override
  String get deleteSelected => 'Delete';

  @override
  String get enableSelected => 'Enable';

  @override
  String get disableSelected => 'Disable';

  @override
  String get notImplementedYet => 'Not implemented yet';

  @override
  String get openInspector => 'Open inspector';

  @override
  String openInspectorFailed(String message) {
    return 'Failed to open inspector: $message';
  }

  @override
  String get confirm => 'Confirm';

  @override
  String get settingsPersistedDescription =>
      'These settings are persisted with SharedPreferencesAsync.';

  @override
  String get updateDownload => 'Download update';

  @override
  String updateDownloadFailed(String message) {
    return 'Failed to open download: $message';
  }

  @override
  String get updateAvailableTitle => 'New version available';

  @override
  String updateAvailableVersion(String version) {
    return 'New version: $version';
  }

  @override
  String get updateForceBadge => 'Required';

  @override
  String get updateLog => 'Update log';

  @override
  String get updateLogDescription => 'View the published version timeline';

  @override
  String get updateLogOpen => 'View';

  @override
  String get updateLogEmpty => 'No update log yet';

  @override
  String updateLogLoadFailed(String message) {
    return 'Failed to load update log: $message';
  }

  @override
  String get updateLogCurrentSystem => 'Current OS';

  @override
  String get updateLogAllSystems => 'All OS';

  @override
  String get updateCardNoChangelog => 'No changelog provided';

  @override
  String get providers => 'Providers';

  @override
  String get addProvider => 'Add';

  @override
  String get noProvidersHint => 'No providers yet. Tap Add at the top right.';

  @override
  String get deletedToast => 'Deleted';

  @override
  String get editProvider => 'Edit';

  @override
  String get deleteProvider => 'Delete';

  @override
  String get providerEditTitleNew => 'Add provider';

  @override
  String get providerEditTitleEdit => 'Edit provider';

  @override
  String get providerName => 'Name';

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
  String get providerProtocol => 'Provider protocol';

  @override
  String get providerProtocolResponses => 'Responses';

  @override
  String get providerProtocolChat => 'Chat';

  @override
  String get providerProtocolMessages => 'Messages';

  @override
  String get providerModels => 'Models';

  @override
  String get providerModelsFetch => 'Fetch';

  @override
  String get providerModelInputHint => 'gpt-5.5 / claude-sonnet-4-6 ...';

  @override
  String get providerUseDefault => 'Use Codex default (no override)';

  @override
  String get providerWeight => 'Provider weight';

  @override
  String get providerWeightHelp =>
      'Used for auto-switch ranking. Entries sharing the same baseUrl+apiKey should normally share the same value. 1-10, default 5.';

  @override
  String get modelWeight => 'Model weight';

  @override
  String get modelWeightHelp =>
      'Used for auto-switch ranking. Score = weight × 1/latency, higher first. 1-10, default 5.';

  @override
  String get providerSave => 'Save';

  @override
  String get providerSavedToast => 'Saved';

  @override
  String get providerFillFirstToast => 'Fill Base URL and API Key first';

  @override
  String get providerFillAllToast => 'Please fill all fields';

  @override
  String get providerSelectModelRequiredToast => 'Please pick a model below';

  @override
  String providerFetchedToast(int count) {
    return 'Fetched $count models';
  }

  @override
  String providerFetchFailedToast(String message) {
    return 'Fetch failed: $message';
  }

  @override
  String get autoSwitch => 'Auto switch';

  @override
  String get autoSwitchStrategy => 'Strategy';

  @override
  String get autoSwitchStrategyHelp =>
      'Manual: only show latency, no auto switch;\nFailover: switch to fastest candidate when current fails N times in a row;\nFastest: switch when a candidate is at least margin ms faster than the current one';

  @override
  String get autoSwitchStrategyManual => 'Manual';

  @override
  String get autoSwitchStrategyFailover => 'Failover';

  @override
  String get autoSwitchStrategyFastest => 'Fastest';

  @override
  String get autoSwitchScope => 'Scope';

  @override
  String get autoSwitchScopeHelp =>
      'Same type: candidates must share the same model family (openai/claude/gemini);\nSame protocol: candidates must share the same upstream protocol;\nAny: no restriction';

  @override
  String get autoSwitchScopeSameType => 'Same type';

  @override
  String get autoSwitchScopeSameProtocol => 'Same protocol';

  @override
  String get autoSwitchScopeAny => 'Any';

  @override
  String get autoSwitchFailureThreshold => 'Failure threshold';

  @override
  String get autoSwitchFailureThresholdHelp =>
      'In failover strategy, number of consecutive failures before switching';

  @override
  String get autoSwitchFailureThresholdUnit => 'x';

  @override
  String get autoSwitchFastestMargin => 'Fastest margin';

  @override
  String get autoSwitchFastestMarginHelp =>
      'In fastest strategy, how much faster (ms) a candidate must be than the current one to trigger a switch';

  @override
  String get autoSwitchFastestMarginUnit => 'ms';

  @override
  String get autoSwitchCooldown => 'Cooldown';

  @override
  String get autoSwitchCooldownHelp =>
      'Seconds after a switch during which another switch is suppressed';

  @override
  String get autoSwitchCooldownUnit => 's';

  @override
  String get autoSwitchProbeInterval => 'Probe interval';

  @override
  String get autoSwitchProbeIntervalHelp =>
      'Background probe period in seconds. Disabled when strategy is Manual.';

  @override
  String get autoSwitchProbeIntervalUnit => 's';

  @override
  String get autoSwitchSlowTimeout => 'Slow threshold';

  @override
  String get autoSwitchSlowTimeoutHelp =>
      'A single request waiting longer than this for response headers is treated as stalled. 0 = disabled.';

  @override
  String get autoSwitchSlowTimeoutUnit => 's';

  @override
  String get autoSwitchSlowThreshold => 'Slow streak';

  @override
  String get autoSwitchSlowThresholdHelp =>
      'N consecutive slow responses trigger auto-switch directly (bypasses failure threshold). 1 = switch on first slow response.';

  @override
  String get autoSwitchSlowThresholdUnit => 'x';

  @override
  String get autoSwitchAllowSibling => 'Same-provider fallback';

  @override
  String get autoSwitchAllowSiblingHelp =>
      'When on, allows switching to another model entry with the same baseUrl + apiKey. Off by default: switching within the same upstream defeats the purpose.';

  @override
  String get navLogs => 'Logs';

  @override
  String proxyRunningOnPort(int port) {
    return 'Proxy running :$port';
  }

  @override
  String proxyEnabledOnPort(int port) {
    return 'Proxy enabled :$port';
  }

  @override
  String get proxyDisabled => 'Proxy disabled';

  @override
  String get refreshCodex => 'Refresh Codex';

  @override
  String get codexRefreshedToast => 'Codex refreshed and re-injected';

  @override
  String codexRefreshFailedToast(String message) {
    return 'Refresh failed: $message';
  }

  @override
  String get codexNotRunningError => 'Codex is not running';

  @override
  String get logs => 'Logs';

  @override
  String get logsFilterAll => 'All';

  @override
  String get logsFilterInfo => 'Info';

  @override
  String get logsFilterWarning => 'Warn';

  @override
  String get logsFilterError => 'Error';

  @override
  String get logsCopy => 'Copy';

  @override
  String get logsClear => 'Clear';

  @override
  String get logsEmpty => 'No logs';

  @override
  String get logsCopiedToast => 'Logs copied';

  @override
  String get shimxDeleteThreadHeading => 'Delete thread';

  @override
  String get shimxDeleteThreadDelete => 'Delete';

  @override
  String get shimxDeleteThreadAria => 'Delete thread';

  @override
  String get shimxDeleteThreadDefaultTitle => 'this thread';

  @override
  String get shimxDeleteSessionIdMissing => 'Session id not found';

  @override
  String get shimxDeleteFailed => 'Delete failed';

  @override
  String get shimxDeleteSuccess => 'Deleted';

  @override
  String get shimxUnknownError => 'Unknown error';

  @override
  String get shimxProviderFallbackName => 'Provider';

  @override
  String get shimxClearModel => 'Clear model';

  @override
  String get shimxEffortLow => 'Low';

  @override
  String get shimxEffortMedium => 'Med';

  @override
  String get shimxEffortHigh => 'High';

  @override
  String get shimxEffortXHigh => 'XHigh';

  @override
  String get shimxHealthTimeout => 'timeout';

  @override
  String get shimxNoProviders => 'No providers configured yet';

  @override
  String get shimxUnnamedProvider => 'Unnamed provider';

  @override
  String get shimxProviderNoModels => 'No models for this provider';

  @override
  String get shimxReasoningEffort => 'Reasoning';

  @override
  String get shimxSaveFailed => 'Save failed';

  @override
  String get shimxSwitchProviderFailed => 'Switch provider failed';

  @override
  String get shimxSwitchModelFailed => 'Switch model failed';

  @override
  String get shimxSwitchEffortFailed => 'Switch reasoning failed';

  @override
  String get sessionManagement => 'Sessions';

  @override
  String get sessionTabClaude => 'Claude';

  @override
  String get sessionTabCodex => 'Codex';

  @override
  String get sessionTabHome => 'Home';

  @override
  String get sessionTabBackup => 'Backup';

  @override
  String get sessionCurrentBucket => 'Current codex bucket';

  @override
  String get sessionSwitchBucket => 'Switch bucket';

  @override
  String get sessionSwitchToShimX => 'Switch to shimx';

  @override
  String get sessionRefresh => 'Refresh';

  @override
  String get sessionBucketLabel => 'Bucket';

  @override
  String get sessionSelectAll => 'Select all';

  @override
  String sessionSelectedCount(int n) {
    return '$n selected';
  }

  @override
  String get sessionMoveTo => 'Move to';

  @override
  String get sessionExecute => 'Run';

  @override
  String get sessionBackupSelected => 'Back up selected';

  @override
  String get sessionMergeAllToShimX => 'Unify threads';

  @override
  String get sessionMergeAllToShimXTooltip =>
      'codex groups threads by model_provider (bucket). When you switch provider, the sidebar only shows the current bucket — history in other buckets is hidden.\nThis moves every thread outside the shimx bucket into it and points codex\'s default bucket to shimx. Afterwards the sidebar shows all history regardless of which provider you use.';

  @override
  String get sessionSwitchBucketTooltip =>
      'Pick which bucket codex\'s sidebar currently shows. A bucket name is the model_provider field on each thread — threads created under different providers fall into different buckets. Switching only changes sidebar filtering, thread content is not touched.';

  @override
  String get sessionBackupSelectedTooltip =>
      'Zip the selected threads into shimx\'s backup directory along with the original bucket for each. Later you can restore them individually or all at once from the Backup tab.';

  @override
  String sessionMoveSuccess(int n, String bucket) {
    return 'Moved $n thread(s) to \"$bucket\"';
  }

  @override
  String sessionMoveFailed(String error) {
    return 'Move failed: $error';
  }

  @override
  String sessionBackupSuccess(int n) {
    return 'Backed up $n thread(s)';
  }

  @override
  String sessionBackupFailed(String error) {
    return 'Backup failed: $error';
  }

  @override
  String get sessionEmptyBucket => '(empty)';

  @override
  String get sessionLoadMore => 'Load more';

  @override
  String get sessionNoSelection => 'No threads selected';

  @override
  String sessionSwitchBucketSuccess(String bucket) {
    return 'Switched to \"$bucket\" bucket';
  }

  @override
  String sessionSwitchBucketFailed(String error) {
    return 'Switch failed: $error';
  }

  @override
  String get sessionMergeConfirmTitle => 'Merge?';

  @override
  String get sessionMergeConfirmBody =>
      'This moves every thread outside the shimx bucket into it. It does not create a backup automatically.';

  @override
  String get sessionMergeConfirmOk => 'Merge';

  @override
  String get sessionMergeProgressTitle => 'Merging into shimx bucket';

  @override
  String sessionMergeProgressBody(int done, int total) {
    return '$done / $total';
  }

  @override
  String get sessionBackupLibrary => 'Backup library';

  @override
  String sessionBackupCountLabel(int n) {
    return '$n backup(s)';
  }

  @override
  String sessionBackupFromBucket(String bucket) {
    return 'From \"$bucket\"';
  }

  @override
  String sessionBackupThreadCount(int n) {
    return '$n thread(s)';
  }

  @override
  String get sessionRestoreOne => 'Restore';

  @override
  String get sessionRestoreAll => 'Restore all';

  @override
  String get sessionDeleteBackup => 'Delete backup';

  @override
  String get sessionRestoreConfirmTitle => 'Restore?';

  @override
  String get sessionRestoreConfirmBody =>
      'The backup content will overwrite the current thread state.';

  @override
  String get sessionRestoreConfirmOk => 'Restore';

  @override
  String get sessionDeleteBackupConfirmTitle => 'Delete backup?';

  @override
  String get sessionDeleteBackupConfirmBody => 'This cannot be undone.';

  @override
  String get sessionDeleteBackupConfirmOk => 'Delete';

  @override
  String sessionRestoreSuccess(int n) {
    return 'Restored $n thread(s)';
  }

  @override
  String sessionRestoreFailed(String error) {
    return 'Restore failed: $error';
  }

  @override
  String get sessionDeleteBackupSuccess => 'Backup deleted';

  @override
  String get sessionBackupEmpty => 'No backups yet';

  @override
  String get sessionsTitle => 'Sessions';

  @override
  String get sessionsEmpty => 'No sessions';

  @override
  String get threadSelectHint => 'Pick a session to view';

  @override
  String get threadEmpty => 'Session has no messages';

  @override
  String get threadMessageUser => 'User';

  @override
  String get threadMessageAssistant => 'Assistant';

  @override
  String get threadMessageToolCall => 'Tool call';

  @override
  String get threadMessageToolResult => 'Tool result';

  @override
  String get threadMessageGeneric => 'Message';

  @override
  String get expand => 'Expand';

  @override
  String get collapse => 'Collapse';

  @override
  String get sessionExport => 'Export';

  @override
  String get sessionExportMarkdown => 'Export as Markdown';

  @override
  String get sessionExportRaw => 'Export raw JSONL';

  @override
  String get sessionExportSuccess => 'Exported';

  @override
  String sessionExportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String get claudeProjects => 'Projects';

  @override
  String get claudeProjectsEmpty =>
      'No Claude Code sessions found (~/.claude/projects/)';

  @override
  String get claudeProjectsSelectHint => 'Pick a project on the left';

  @override
  String claudeProjectSubtitle(int count, String time) {
    return '$count sessions · $time';
  }

  @override
  String get justNow => 'just now';

  @override
  String minutesAgo(int n) {
    return '$n min ago';
  }

  @override
  String hoursAgo(int n) {
    return '$n h ago';
  }

  @override
  String daysAgo(int n) {
    return '$n d ago';
  }

  @override
  String get copy => 'Copy';

  @override
  String get copied => 'Copied';

  @override
  String get mcp => 'MCP';

  @override
  String get mcpServersTitle => 'MCP servers from shimx';

  @override
  String get mcpServersHint =>
      'These MCP servers are hosted inside the shimx process and can be wired into codex via streamable_http so the LLM can query local data on demand.';

  @override
  String get mcpServersEmpty => 'No MCP servers enabled';

  @override
  String get mcpShimXClaudeName => 'Claude session search';

  @override
  String get mcpShimXClaudeDescription =>
      'Expose local Claude Code sessions to the Codex LLM as MCP tools.';

  @override
  String get mcpServerUrlLabel => 'URL';

  @override
  String get mcpServerIdLabel => 'ID';

  @override
  String get mcpServerToolCountLabel => 'Tools';

  @override
  String get mcpServerRegisteredLabel => 'Registered in codex';

  @override
  String get mcpServerRegisteredYes => 'Yes';

  @override
  String get mcpServerRegisteredNo => 'No';

  @override
  String get mcpServerStatusDetailLabel => 'Error';

  @override
  String get mcpStatusRunning => 'running';

  @override
  String get mcpStatusStopped => 'stopped';

  @override
  String get mcpStatusError => 'error';

  @override
  String get mcpConfigTitle => 'Codex MCP config (Advanced)';

  @override
  String get mcpConfigHint =>
      'Shows [mcp_servers.*] from config.toml. Toggles and saves write config.toml and take effect in new Codex sessions.';

  @override
  String get mcpConfigEmpty => 'No Codex MCP config yet';

  @override
  String get mcpConfigAdd => 'Add';

  @override
  String get mcpConfigBodyLabel => 'Config';

  @override
  String get mcpConfigIdLabel => 'ID';

  @override
  String get mcpConfigFillRequiredToast => 'Fill ID and config';

  @override
  String get mcpConfigDialogTitleNew => 'Add MCP config';

  @override
  String get mcpConfigDialogTitleEdit => 'Edit MCP config';

  @override
  String get mcpConfigIdHint => 'e.g. my_server';

  @override
  String get mcpConfigBodyContentLabel => 'Config content';

  @override
  String get mcpConfigBodyHelper =>
      'Enter only this entry\'s fields. The table header is written from the ID.';

  @override
  String get mcpConfigEnabledLabel => 'Write to config.toml';

  @override
  String get mcpConfigInstalling => 'Installing MCP...';

  @override
  String get skills => 'Skills';

  @override
  String get skillsTitle => 'Codex Skills';

  @override
  String get skillsHint =>
      'Manage local Codex skills under ~/.codex/skills. ShimX only deletes or overwrites skills imported into its registry.';

  @override
  String get skillsInstallFolder => 'Install folder';

  @override
  String get skillsInstallZip => 'Install ZIP';

  @override
  String get skillsManagedGroup => 'Managed by shimx';

  @override
  String get skillsExternalGroup => 'External Codex Skills';

  @override
  String get skillsEmpty => 'No Codex Skills found';

  @override
  String get skillsManagedBadge => 'managed';

  @override
  String get skillsExternalBadge => 'external';

  @override
  String get skillsImportManaged => 'Import';

  @override
  String get skillsCopyPath => 'Copy path';

  @override
  String get skillsDelete => 'Delete';

  @override
  String get skillsPathLabel => 'Path';

  @override
  String get skillsIdLabel => 'ID';

  @override
  String get skillsHashLabel => 'Content hash';

  @override
  String get skillsInstallSuccess => 'Skill installed';

  @override
  String get skillsImportSuccess => 'Imported';

  @override
  String get skillsDeleteSuccess => 'Skill deleted';

  @override
  String skillsActionFailed(String message) {
    return 'Action failed: $message';
  }

  @override
  String get skillsOverwriteTitle => 'Overwrite Skill';

  @override
  String get skillsOverwriteMessage =>
      'A shimx-managed Skill with the same name already exists. Overwrite its directory?';

  @override
  String get skillsDeleteTitle => 'Delete Skill';

  @override
  String get skillsDeleteMessage =>
      'Delete this shimx-managed Skill directory?';

  @override
  String get skillsZipChooseTitle => 'Choose Skill from ZIP';

  @override
  String get skillsNoFolderSelected => 'No folder selected';

  @override
  String get skillsNoZipSelected => 'No ZIP selected';

  @override
  String get skillsNoDescription => 'No description';

  @override
  String get skillsRefreshing => 'Refreshing Skills...';

  @override
  String get skillsInstalling => 'Installing Skills...';

  @override
  String get skillsImporting => 'Importing Skill...';

  @override
  String get skillsDeleting => 'Deleting Skill...';

  @override
  String get toolFilterKeywordsTitle => 'Tool filter keywords';

  @override
  String get toolFilterKeywordsDescription => 'Strip request tools by keyword';

  @override
  String get toolFilterKeywordsManage => 'Manage';

  @override
  String get toolFilterKeywordsEmpty =>
      'No keywords (empty list = no filtering)';

  @override
  String get toolFilterKeywordAdd => 'Add';

  @override
  String get toolFilterKeywordHint => 'e.g. image_generation';

  @override
  String get toolFilterKeywordEmpty => 'Keyword cannot be empty';

  @override
  String get toolFilterKeywordDuplicate => 'Keyword already in the list';

  @override
  String get requiresOpenaiAuthTitle => 'Use official login';

  @override
  String get requiresOpenaiAuthDescription => 'Restart Codex to apply';

  @override
  String get codexLaunchTargetTitle => 'Codex launch target';

  @override
  String get codexLaunchTargetDescription =>
      'Leave empty to use built-in defaults (Windows matches OpenAI.ChatGPT*/OpenAI.Codex*, macOS probes /Applications/ChatGPT.app or Codex.app)';

  @override
  String get codexLaunchTargetHintMac =>
      'Custom .app absolute path, e.g. /Applications/ChatGPT.app';

  @override
  String get codexLaunchTargetHintWindows =>
      'Custom AppxPackage -Name pattern, e.g. OpenAI.ChatGPT*';

  @override
  String get codexLaunchTargetHintDefault => 'Custom codex launch target';

  @override
  String get codexLaunchTargetReset => 'Reset to default';

  @override
  String get codexRunningWithoutDebugTitle =>
      'Codex is running without a debug port';

  @override
  String get codexRunningWithoutDebugBody =>
      'Please fully quit Codex, then click inject again so shim can relaunch it with the debug flag.';
}
