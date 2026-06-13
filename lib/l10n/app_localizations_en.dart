// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Codex Z';

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
  String get homeTitle => 'Codex Z';

  @override
  String get welcome => 'Codex Z';

  @override
  String get inject => 'Inject';

  @override
  String get injectPanelTitle => 'UI Injection';

  @override
  String get injectPanelDescription =>
      'Inject the Codex Z control surface into the target environment for connection, debugging, and operation.';

  @override
  String get injectReadyStatus => 'Ready to inject';

  @override
  String get readyStatus => 'Ready';

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
  String get settingsPersistedDescription =>
      'These settings are persisted with SharedPreferencesAsync.';
}
