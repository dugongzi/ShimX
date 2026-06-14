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
}
