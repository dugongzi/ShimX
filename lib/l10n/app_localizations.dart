import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appName.
  ///
  /// In zh, this message translates to:
  /// **'Shim'**
  String get appName;

  /// No description provided for @home.
  ///
  /// In zh, this message translates to:
  /// **'首页'**
  String get home;

  /// No description provided for @settings.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settings;

  /// No description provided for @pageNotFound.
  ///
  /// In zh, this message translates to:
  /// **'页面不存在'**
  String get pageNotFound;

  /// No description provided for @unknownRouteError.
  ///
  /// In zh, this message translates to:
  /// **'未知路由错误'**
  String get unknownRouteError;

  /// No description provided for @backToHome.
  ///
  /// In zh, this message translates to:
  /// **'返回首页'**
  String get backToHome;

  /// No description provided for @homeTitle.
  ///
  /// In zh, this message translates to:
  /// **'Shim'**
  String get homeTitle;

  /// No description provided for @welcome.
  ///
  /// In zh, this message translates to:
  /// **'Shim'**
  String get welcome;

  /// No description provided for @inject.
  ///
  /// In zh, this message translates to:
  /// **'注入'**
  String get inject;

  /// No description provided for @injectPanelTitle.
  ///
  /// In zh, this message translates to:
  /// **'界面注入'**
  String get injectPanelTitle;

  /// No description provided for @injectPanelDescription.
  ///
  /// In zh, this message translates to:
  /// **'将 Shim 的控制界面注入到目标环境，用于后续连接、调试和操作。'**
  String get injectPanelDescription;

  /// No description provided for @injectReadyStatus.
  ///
  /// In zh, this message translates to:
  /// **'等待注入'**
  String get injectReadyStatus;

  /// No description provided for @injectedAtStatus.
  ///
  /// In zh, this message translates to:
  /// **'已注入 · {time}'**
  String injectedAtStatus(String time);

  /// No description provided for @readyStatus.
  ///
  /// In zh, this message translates to:
  /// **'就绪'**
  String get readyStatus;

  /// No description provided for @codexConnected.
  ///
  /// In zh, this message translates to:
  /// **'已连接 Codex'**
  String get codexConnected;

  /// No description provided for @codexDisconnected.
  ///
  /// In zh, this message translates to:
  /// **'未连接'**
  String get codexDisconnected;

  /// No description provided for @checkingStatus.
  ///
  /// In zh, this message translates to:
  /// **'检测中...'**
  String get checkingStatus;

  /// No description provided for @refresh.
  ///
  /// In zh, this message translates to:
  /// **'刷新'**
  String get refresh;

  /// No description provided for @trayShowWindow.
  ///
  /// In zh, this message translates to:
  /// **'显示窗口'**
  String get trayShowWindow;

  /// No description provided for @trayLaunchCodex.
  ///
  /// In zh, this message translates to:
  /// **'启动 Codex 并注入'**
  String get trayLaunchCodex;

  /// No description provided for @trayQuit.
  ///
  /// In zh, this message translates to:
  /// **'退出 Shim'**
  String get trayQuit;

  /// No description provided for @trayTooltip.
  ///
  /// In zh, this message translates to:
  /// **'Shim'**
  String get trayTooltip;

  /// No description provided for @systemLanguage.
  ///
  /// In zh, this message translates to:
  /// **'系统语言'**
  String get systemLanguage;

  /// No description provided for @chineseLanguage.
  ///
  /// In zh, this message translates to:
  /// **'简体中文'**
  String get chineseLanguage;

  /// No description provided for @englishLanguage.
  ///
  /// In zh, this message translates to:
  /// **'英语'**
  String get englishLanguage;

  /// No description provided for @themeMode.
  ///
  /// In zh, this message translates to:
  /// **'主题模式'**
  String get themeMode;

  /// No description provided for @systemTheme.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get systemTheme;

  /// No description provided for @lightTheme.
  ///
  /// In zh, this message translates to:
  /// **'浅色模式'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In zh, this message translates to:
  /// **'深色模式'**
  String get darkTheme;

  /// No description provided for @primaryColor.
  ///
  /// In zh, this message translates to:
  /// **'主题色'**
  String get primaryColor;

  /// No description provided for @reset.
  ///
  /// In zh, this message translates to:
  /// **'重置'**
  String get reset;

  /// No description provided for @codexNotInstalled.
  ///
  /// In zh, this message translates to:
  /// **'未检测到已安装的 Codex'**
  String get codexNotInstalled;

  /// No description provided for @launchFailed.
  ///
  /// In zh, this message translates to:
  /// **'启动失败：{message}'**
  String launchFailed(String message);

  /// No description provided for @injectSuccess.
  ///
  /// In zh, this message translates to:
  /// **'注入成功'**
  String get injectSuccess;

  /// No description provided for @scripts.
  ///
  /// In zh, this message translates to:
  /// **'脚本'**
  String get scripts;

  /// No description provided for @noScripts.
  ///
  /// In zh, this message translates to:
  /// **'暂无脚本'**
  String get noScripts;

  /// No description provided for @importScript.
  ///
  /// In zh, this message translates to:
  /// **'导入脚本'**
  String get importScript;

  /// No description provided for @selectAll.
  ///
  /// In zh, this message translates to:
  /// **'全选'**
  String get selectAll;

  /// No description provided for @invertSelection.
  ///
  /// In zh, this message translates to:
  /// **'反选'**
  String get invertSelection;

  /// No description provided for @deleteSelected.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get deleteSelected;

  /// No description provided for @enableSelected.
  ///
  /// In zh, this message translates to:
  /// **'启用'**
  String get enableSelected;

  /// No description provided for @disableSelected.
  ///
  /// In zh, this message translates to:
  /// **'禁用'**
  String get disableSelected;

  /// No description provided for @notImplementedYet.
  ///
  /// In zh, this message translates to:
  /// **'暂未实现'**
  String get notImplementedYet;

  /// No description provided for @openInspector.
  ///
  /// In zh, this message translates to:
  /// **'打开控制台'**
  String get openInspector;

  /// No description provided for @openInspectorFailed.
  ///
  /// In zh, this message translates to:
  /// **'打开控制台失败：{message}'**
  String openInspectorFailed(String message);

  /// No description provided for @confirm.
  ///
  /// In zh, this message translates to:
  /// **'确认'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel;

  /// No description provided for @settingsPersistedDescription.
  ///
  /// In zh, this message translates to:
  /// **'这些设置会通过 SharedPreferencesAsync 持久化保存。'**
  String get settingsPersistedDescription;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
