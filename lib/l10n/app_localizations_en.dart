// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Shim';

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
  String get homeTitle => 'Shim';

  @override
  String get welcome => 'Shim';

  @override
  String get inject => 'Inject';

  @override
  String get injectPanelTitle => 'UI Injection';

  @override
  String get injectPanelDescription =>
      'Inject the Shim control surface into the target environment for connection, debugging, and operation.';

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
  String get trayQuit => 'Quit Shim';

  @override
  String get trayTooltip => 'Shim';

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
  String get cancel => 'Cancel';

  @override
  String get settingsPersistedDescription =>
      'These settings are persisted with SharedPreferencesAsync.';

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
  String get providerSave => 'Save';

  @override
  String get providerSavedToast => 'Saved';

  @override
  String get providerFillFirstToast => 'Fill Base URL and API Key first';

  @override
  String get providerFillAllToast => 'Please fill all fields';

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
  String get shimDeleteThreadHeading => 'Delete thread';

  @override
  String get shimDeleteThreadDelete => 'Delete';

  @override
  String get shimDeleteThreadAria => 'Delete thread';

  @override
  String get shimDeleteThreadDefaultTitle => 'this thread';

  @override
  String get shimDeleteSessionIdMissing => 'Session id not found';

  @override
  String get shimDeleteFailed => 'Delete failed';

  @override
  String get shimDeleteSuccess => 'Deleted';

  @override
  String get shimUnknownError => 'Unknown error';

  @override
  String get shimProviderFallbackName => 'Provider';

  @override
  String get shimClearModel => 'Clear model';

  @override
  String get shimEffortLow => 'Low';

  @override
  String get shimEffortMedium => 'Med';

  @override
  String get shimEffortHigh => 'High';

  @override
  String get shimEffortXHigh => 'XHigh';

  @override
  String get shimHealthTimeout => 'timeout';

  @override
  String get shimNoProviders => 'No providers configured yet';

  @override
  String get shimUnnamedProvider => 'Unnamed provider';

  @override
  String get shimProviderNoModels => 'No models for this provider';

  @override
  String get shimReasoningEffort => 'Reasoning';

  @override
  String get shimSaveFailed => 'Save failed';

  @override
  String get shimSwitchProviderFailed => 'Switch provider failed';

  @override
  String get shimSwitchModelFailed => 'Switch model failed';

  @override
  String get shimSwitchEffortFailed => 'Switch reasoning failed';
}
