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

  /// No description provided for @proxy.
  ///
  /// In zh, this message translates to:
  /// **'代理'**
  String get proxy;

  /// No description provided for @proxyEnabledDescription.
  ///
  /// In zh, this message translates to:
  /// **'已接管 :{port}'**
  String proxyEnabledDescription(int port);

  /// No description provided for @proxyDisabledDescription.
  ///
  /// In zh, this message translates to:
  /// **'未启用'**
  String get proxyDisabledDescription;

  /// No description provided for @proxyPort.
  ///
  /// In zh, this message translates to:
  /// **'端口'**
  String get proxyPort;

  /// No description provided for @desktopShortcut.
  ///
  /// In zh, this message translates to:
  /// **'桌面快捷方式'**
  String get desktopShortcut;

  /// No description provided for @desktopShortcutDescription.
  ///
  /// In zh, this message translates to:
  /// **'一键启动 Codex 并自动注入'**
  String get desktopShortcutDescription;

  /// No description provided for @createShortcut.
  ///
  /// In zh, this message translates to:
  /// **'创建快捷方式'**
  String get createShortcut;

  /// No description provided for @shortcutCreated.
  ///
  /// In zh, this message translates to:
  /// **'快捷方式已创建到桌面'**
  String get shortcutCreated;

  /// No description provided for @shortcutFailed.
  ///
  /// In zh, this message translates to:
  /// **'创建失败：{message}'**
  String shortcutFailed(String message);

  /// No description provided for @launchingCodex.
  ///
  /// In zh, this message translates to:
  /// **'正在启动 Codex 并注入...'**
  String get launchingCodex;

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

  /// No description provided for @providers.
  ///
  /// In zh, this message translates to:
  /// **'供应商'**
  String get providers;

  /// No description provided for @addProvider.
  ///
  /// In zh, this message translates to:
  /// **'新增'**
  String get addProvider;

  /// No description provided for @noProvidersHint.
  ///
  /// In zh, this message translates to:
  /// **'还没有供应商，点右上角新增'**
  String get noProvidersHint;

  /// No description provided for @deletedToast.
  ///
  /// In zh, this message translates to:
  /// **'已删除'**
  String get deletedToast;

  /// No description provided for @editProvider.
  ///
  /// In zh, this message translates to:
  /// **'编辑'**
  String get editProvider;

  /// No description provided for @deleteProvider.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get deleteProvider;

  /// No description provided for @providerEditTitleNew.
  ///
  /// In zh, this message translates to:
  /// **'新增供应商'**
  String get providerEditTitleNew;

  /// No description provided for @providerEditTitleEdit.
  ///
  /// In zh, this message translates to:
  /// **'编辑供应商'**
  String get providerEditTitleEdit;

  /// No description provided for @providerName.
  ///
  /// In zh, this message translates to:
  /// **'名称'**
  String get providerName;

  /// No description provided for @providerNameHint.
  ///
  /// In zh, this message translates to:
  /// **'MuxueAI'**
  String get providerNameHint;

  /// No description provided for @providerBaseUrl.
  ///
  /// In zh, this message translates to:
  /// **'Base URL'**
  String get providerBaseUrl;

  /// No description provided for @providerBaseUrlHint.
  ///
  /// In zh, this message translates to:
  /// **'https://api.example.com/v1'**
  String get providerBaseUrlHint;

  /// No description provided for @providerApiKey.
  ///
  /// In zh, this message translates to:
  /// **'API Key'**
  String get providerApiKey;

  /// No description provided for @providerApiKeyHint.
  ///
  /// In zh, this message translates to:
  /// **'sk-...'**
  String get providerApiKeyHint;

  /// No description provided for @providerProtocol.
  ///
  /// In zh, this message translates to:
  /// **'供应商格式'**
  String get providerProtocol;

  /// No description provided for @providerProtocolResponses.
  ///
  /// In zh, this message translates to:
  /// **'Responses'**
  String get providerProtocolResponses;

  /// No description provided for @providerProtocolChat.
  ///
  /// In zh, this message translates to:
  /// **'Chat'**
  String get providerProtocolChat;

  /// No description provided for @providerProtocolMessages.
  ///
  /// In zh, this message translates to:
  /// **'Messages'**
  String get providerProtocolMessages;

  /// No description provided for @providerModels.
  ///
  /// In zh, this message translates to:
  /// **'模型'**
  String get providerModels;

  /// No description provided for @providerModelsFetch.
  ///
  /// In zh, this message translates to:
  /// **'获取'**
  String get providerModelsFetch;

  /// No description provided for @providerModelInputHint.
  ///
  /// In zh, this message translates to:
  /// **'gpt-5.5 / claude-sonnet-4-6 ...'**
  String get providerModelInputHint;

  /// No description provided for @providerUseDefault.
  ///
  /// In zh, this message translates to:
  /// **'用 Codex 默认（不覆盖）'**
  String get providerUseDefault;

  /// No description provided for @providerWeight.
  ///
  /// In zh, this message translates to:
  /// **'供应商权重'**
  String get providerWeight;

  /// No description provided for @providerWeightHelp.
  ///
  /// In zh, this message translates to:
  /// **'自动切换排序用。同 baseUrl+apiKey 的多个条目建议设相同值。1-10,默认 5'**
  String get providerWeightHelp;

  /// No description provided for @modelWeight.
  ///
  /// In zh, this message translates to:
  /// **'模型权重'**
  String get modelWeight;

  /// No description provided for @modelWeightHelp.
  ///
  /// In zh, this message translates to:
  /// **'自动切换排序用。优先级:权重 × 1/延迟 越大越优先。1-10,默认 5'**
  String get modelWeightHelp;

  /// No description provided for @providerSave.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get providerSave;

  /// No description provided for @providerSavedToast.
  ///
  /// In zh, this message translates to:
  /// **'已保存'**
  String get providerSavedToast;

  /// No description provided for @providerFillFirstToast.
  ///
  /// In zh, this message translates to:
  /// **'先填 Base URL 和 API Key'**
  String get providerFillFirstToast;

  /// No description provided for @providerFillAllToast.
  ///
  /// In zh, this message translates to:
  /// **'请填完整'**
  String get providerFillAllToast;

  /// No description provided for @providerSelectModelRequiredToast.
  ///
  /// In zh, this message translates to:
  /// **'请在下方点选一个模型'**
  String get providerSelectModelRequiredToast;

  /// No description provided for @providerFetchedToast.
  ///
  /// In zh, this message translates to:
  /// **'获取到 {count} 个模型'**
  String providerFetchedToast(int count);

  /// No description provided for @providerFetchFailedToast.
  ///
  /// In zh, this message translates to:
  /// **'获取失败：{message}'**
  String providerFetchFailedToast(String message);

  /// No description provided for @autoSwitch.
  ///
  /// In zh, this message translates to:
  /// **'自动切换'**
  String get autoSwitch;

  /// No description provided for @autoSwitchStrategy.
  ///
  /// In zh, this message translates to:
  /// **'策略'**
  String get autoSwitchStrategy;

  /// No description provided for @autoSwitchStrategyHelp.
  ///
  /// In zh, this message translates to:
  /// **'手动：只显示延迟，不自动切；\n故障转移：当前家连续失败 N 次后切到最快候选；\n最快优先：候选比当前快 ≥ 增益就切'**
  String get autoSwitchStrategyHelp;

  /// No description provided for @autoSwitchStrategyManual.
  ///
  /// In zh, this message translates to:
  /// **'手动'**
  String get autoSwitchStrategyManual;

  /// No description provided for @autoSwitchStrategyFailover.
  ///
  /// In zh, this message translates to:
  /// **'故障转移'**
  String get autoSwitchStrategyFailover;

  /// No description provided for @autoSwitchStrategyFastest.
  ///
  /// In zh, this message translates to:
  /// **'最快优先'**
  String get autoSwitchStrategyFastest;

  /// No description provided for @autoSwitchScope.
  ///
  /// In zh, this message translates to:
  /// **'切换范围'**
  String get autoSwitchScope;

  /// No description provided for @autoSwitchScopeHelp.
  ///
  /// In zh, this message translates to:
  /// **'同类型：候选必须跟当前同模型家族（openai/claude/gemini）；\n同协议：候选必须跟当前同上游协议；\n任意：不限'**
  String get autoSwitchScopeHelp;

  /// No description provided for @autoSwitchScopeSameType.
  ///
  /// In zh, this message translates to:
  /// **'同类型'**
  String get autoSwitchScopeSameType;

  /// No description provided for @autoSwitchScopeSameProtocol.
  ///
  /// In zh, this message translates to:
  /// **'同协议'**
  String get autoSwitchScopeSameProtocol;

  /// No description provided for @autoSwitchScopeAny.
  ///
  /// In zh, this message translates to:
  /// **'任意'**
  String get autoSwitchScopeAny;

  /// No description provided for @autoSwitchFailureThreshold.
  ///
  /// In zh, this message translates to:
  /// **'失败阈值'**
  String get autoSwitchFailureThreshold;

  /// No description provided for @autoSwitchFailureThresholdHelp.
  ///
  /// In zh, this message translates to:
  /// **'故障转移策略下，当前家连续失败几次后切换'**
  String get autoSwitchFailureThresholdHelp;

  /// No description provided for @autoSwitchFailureThresholdUnit.
  ///
  /// In zh, this message translates to:
  /// **'次'**
  String get autoSwitchFailureThresholdUnit;

  /// No description provided for @autoSwitchFastestMargin.
  ///
  /// In zh, this message translates to:
  /// **'最快优先增益'**
  String get autoSwitchFastestMargin;

  /// No description provided for @autoSwitchFastestMarginHelp.
  ///
  /// In zh, this message translates to:
  /// **'最快优先策略下，候选要比当前快多少 ms 才切'**
  String get autoSwitchFastestMarginHelp;

  /// No description provided for @autoSwitchFastestMarginUnit.
  ///
  /// In zh, this message translates to:
  /// **'ms'**
  String get autoSwitchFastestMarginUnit;

  /// No description provided for @autoSwitchCooldown.
  ///
  /// In zh, this message translates to:
  /// **'冷却时间'**
  String get autoSwitchCooldown;

  /// No description provided for @autoSwitchCooldownHelp.
  ///
  /// In zh, this message translates to:
  /// **'切换后多少秒内不再二次切换，防反复横跳'**
  String get autoSwitchCooldownHelp;

  /// No description provided for @autoSwitchCooldownUnit.
  ///
  /// In zh, this message translates to:
  /// **'秒'**
  String get autoSwitchCooldownUnit;

  /// No description provided for @autoSwitchProbeInterval.
  ///
  /// In zh, this message translates to:
  /// **'后台测速周期'**
  String get autoSwitchProbeInterval;

  /// No description provided for @autoSwitchProbeIntervalHelp.
  ///
  /// In zh, this message translates to:
  /// **'后台多少秒测一次速。手动策略下完全不跑后台周期'**
  String get autoSwitchProbeIntervalHelp;

  /// No description provided for @autoSwitchProbeIntervalUnit.
  ///
  /// In zh, this message translates to:
  /// **'秒'**
  String get autoSwitchProbeIntervalUnit;

  /// No description provided for @autoSwitchSlowTimeout.
  ///
  /// In zh, this message translates to:
  /// **'慢响应阈值'**
  String get autoSwitchSlowTimeout;

  /// No description provided for @autoSwitchSlowTimeoutHelp.
  ///
  /// In zh, this message translates to:
  /// **'单条请求等待响应头超过此秒数视为挂起。0 表示不启用'**
  String get autoSwitchSlowTimeoutHelp;

  /// No description provided for @autoSwitchSlowTimeoutUnit.
  ///
  /// In zh, this message translates to:
  /// **'秒'**
  String get autoSwitchSlowTimeoutUnit;

  /// No description provided for @autoSwitchSlowThreshold.
  ///
  /// In zh, this message translates to:
  /// **'慢响应次数'**
  String get autoSwitchSlowThreshold;

  /// No description provided for @autoSwitchSlowThresholdHelp.
  ///
  /// In zh, this message translates to:
  /// **'连续 N 次慢响应直接触发自动切换(绕过失败阈值)。1 = 1 次就切'**
  String get autoSwitchSlowThresholdHelp;

  /// No description provided for @autoSwitchSlowThresholdUnit.
  ///
  /// In zh, this message translates to:
  /// **'次'**
  String get autoSwitchSlowThresholdUnit;

  /// No description provided for @autoSwitchAllowSibling.
  ///
  /// In zh, this message translates to:
  /// **'允许同家其他模型'**
  String get autoSwitchAllowSibling;

  /// No description provided for @autoSwitchAllowSiblingHelp.
  ///
  /// In zh, this message translates to:
  /// **'打开后,当前家挂时也可切到同 baseUrl + apiKey 的另一个模型条目。默认关:同一家挂了切自己等于没切'**
  String get autoSwitchAllowSiblingHelp;

  /// No description provided for @navLogs.
  ///
  /// In zh, this message translates to:
  /// **'日志'**
  String get navLogs;

  /// No description provided for @proxyRunningOnPort.
  ///
  /// In zh, this message translates to:
  /// **'代理运行中 :{port}'**
  String proxyRunningOnPort(int port);

  /// No description provided for @proxyEnabledOnPort.
  ///
  /// In zh, this message translates to:
  /// **'代理已启用 :{port}'**
  String proxyEnabledOnPort(int port);

  /// No description provided for @proxyDisabled.
  ///
  /// In zh, this message translates to:
  /// **'代理未启用'**
  String get proxyDisabled;

  /// No description provided for @refreshCodex.
  ///
  /// In zh, this message translates to:
  /// **'刷新 Codex'**
  String get refreshCodex;

  /// No description provided for @codexRefreshedToast.
  ///
  /// In zh, this message translates to:
  /// **'Codex 已刷新并重新注入'**
  String get codexRefreshedToast;

  /// No description provided for @codexRefreshFailedToast.
  ///
  /// In zh, this message translates to:
  /// **'刷新失败：{message}'**
  String codexRefreshFailedToast(String message);

  /// No description provided for @codexNotRunningError.
  ///
  /// In zh, this message translates to:
  /// **'未检测到 Codex 正在运行'**
  String get codexNotRunningError;

  /// No description provided for @logs.
  ///
  /// In zh, this message translates to:
  /// **'日志'**
  String get logs;

  /// No description provided for @logsFilterAll.
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get logsFilterAll;

  /// No description provided for @logsFilterInfo.
  ///
  /// In zh, this message translates to:
  /// **'信息'**
  String get logsFilterInfo;

  /// No description provided for @logsFilterWarning.
  ///
  /// In zh, this message translates to:
  /// **'警告'**
  String get logsFilterWarning;

  /// No description provided for @logsFilterError.
  ///
  /// In zh, this message translates to:
  /// **'错误'**
  String get logsFilterError;

  /// No description provided for @logsCopy.
  ///
  /// In zh, this message translates to:
  /// **'复制'**
  String get logsCopy;

  /// No description provided for @logsClear.
  ///
  /// In zh, this message translates to:
  /// **'清空'**
  String get logsClear;

  /// No description provided for @logsEmpty.
  ///
  /// In zh, this message translates to:
  /// **'暂无日志'**
  String get logsEmpty;

  /// No description provided for @logsCopiedToast.
  ///
  /// In zh, this message translates to:
  /// **'日志已复制'**
  String get logsCopiedToast;

  /// No description provided for @shimDeleteThreadHeading.
  ///
  /// In zh, this message translates to:
  /// **'删除对话'**
  String get shimDeleteThreadHeading;

  /// No description provided for @shimDeleteThreadDelete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get shimDeleteThreadDelete;

  /// No description provided for @shimDeleteThreadAria.
  ///
  /// In zh, this message translates to:
  /// **'删除对话'**
  String get shimDeleteThreadAria;

  /// No description provided for @shimDeleteThreadDefaultTitle.
  ///
  /// In zh, this message translates to:
  /// **'此对话'**
  String get shimDeleteThreadDefaultTitle;

  /// No description provided for @shimDeleteSessionIdMissing.
  ///
  /// In zh, this message translates to:
  /// **'未找到会话 id'**
  String get shimDeleteSessionIdMissing;

  /// No description provided for @shimDeleteFailed.
  ///
  /// In zh, this message translates to:
  /// **'删除失败'**
  String get shimDeleteFailed;

  /// No description provided for @shimDeleteSuccess.
  ///
  /// In zh, this message translates to:
  /// **'已删除'**
  String get shimDeleteSuccess;

  /// No description provided for @shimUnknownError.
  ///
  /// In zh, this message translates to:
  /// **'未知错误'**
  String get shimUnknownError;

  /// No description provided for @shimProviderFallbackName.
  ///
  /// In zh, this message translates to:
  /// **'供应商'**
  String get shimProviderFallbackName;

  /// No description provided for @shimClearModel.
  ///
  /// In zh, this message translates to:
  /// **'清除模型'**
  String get shimClearModel;

  /// No description provided for @shimEffortLow.
  ///
  /// In zh, this message translates to:
  /// **'低'**
  String get shimEffortLow;

  /// No description provided for @shimEffortMedium.
  ///
  /// In zh, this message translates to:
  /// **'中'**
  String get shimEffortMedium;

  /// No description provided for @shimEffortHigh.
  ///
  /// In zh, this message translates to:
  /// **'高'**
  String get shimEffortHigh;

  /// No description provided for @shimEffortXHigh.
  ///
  /// In zh, this message translates to:
  /// **'超高'**
  String get shimEffortXHigh;

  /// No description provided for @shimHealthTimeout.
  ///
  /// In zh, this message translates to:
  /// **'超时'**
  String get shimHealthTimeout;

  /// No description provided for @shimNoProviders.
  ///
  /// In zh, this message translates to:
  /// **'还没有导入供应商'**
  String get shimNoProviders;

  /// No description provided for @shimUnnamedProvider.
  ///
  /// In zh, this message translates to:
  /// **'未命名供应商'**
  String get shimUnnamedProvider;

  /// No description provided for @shimProviderNoModels.
  ///
  /// In zh, this message translates to:
  /// **'该供应商没有模型'**
  String get shimProviderNoModels;

  /// No description provided for @shimReasoningEffort.
  ///
  /// In zh, this message translates to:
  /// **'思考深度'**
  String get shimReasoningEffort;

  /// No description provided for @shimSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'保存失败'**
  String get shimSaveFailed;

  /// No description provided for @shimSwitchProviderFailed.
  ///
  /// In zh, this message translates to:
  /// **'切换供应商失败'**
  String get shimSwitchProviderFailed;

  /// No description provided for @shimSwitchModelFailed.
  ///
  /// In zh, this message translates to:
  /// **'切换模型失败'**
  String get shimSwitchModelFailed;

  /// No description provided for @shimSwitchEffortFailed.
  ///
  /// In zh, this message translates to:
  /// **'切换思考深度失败'**
  String get shimSwitchEffortFailed;

  /// No description provided for @sessionManagement.
  ///
  /// In zh, this message translates to:
  /// **'会话管理'**
  String get sessionManagement;

  /// No description provided for @sessionTabClaude.
  ///
  /// In zh, this message translates to:
  /// **'Claude'**
  String get sessionTabClaude;

  /// No description provided for @sessionTabCodex.
  ///
  /// In zh, this message translates to:
  /// **'Codex'**
  String get sessionTabCodex;

  /// No description provided for @sessionsTitle.
  ///
  /// In zh, this message translates to:
  /// **'会话'**
  String get sessionsTitle;

  /// No description provided for @sessionsEmpty.
  ///
  /// In zh, this message translates to:
  /// **'暂无会话'**
  String get sessionsEmpty;

  /// No description provided for @threadSelectHint.
  ///
  /// In zh, this message translates to:
  /// **'选择一个会话查看详情'**
  String get threadSelectHint;

  /// No description provided for @threadEmpty.
  ///
  /// In zh, this message translates to:
  /// **'会话内容为空'**
  String get threadEmpty;

  /// No description provided for @sessionExport.
  ///
  /// In zh, this message translates to:
  /// **'导出'**
  String get sessionExport;

  /// No description provided for @sessionExportMarkdown.
  ///
  /// In zh, this message translates to:
  /// **'导出为 Markdown'**
  String get sessionExportMarkdown;

  /// No description provided for @sessionExportRaw.
  ///
  /// In zh, this message translates to:
  /// **'导出原始 JSONL'**
  String get sessionExportRaw;

  /// No description provided for @sessionExportSuccess.
  ///
  /// In zh, this message translates to:
  /// **'已导出'**
  String get sessionExportSuccess;

  /// No description provided for @sessionExportFailed.
  ///
  /// In zh, this message translates to:
  /// **'导出失败:{error}'**
  String sessionExportFailed(String error);

  /// No description provided for @claudeProjects.
  ///
  /// In zh, this message translates to:
  /// **'项目'**
  String get claudeProjects;

  /// No description provided for @claudeProjectsEmpty.
  ///
  /// In zh, this message translates to:
  /// **'未发现 Claude Code 会话(~/.claude/projects/)'**
  String get claudeProjectsEmpty;

  /// No description provided for @claudeProjectsSelectHint.
  ///
  /// In zh, this message translates to:
  /// **'在左侧选择一个项目'**
  String get claudeProjectsSelectHint;

  /// No description provided for @claudeProjectSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个会话 · {time}'**
  String claudeProjectSubtitle(int count, String time);

  /// No description provided for @justNow.
  ///
  /// In zh, this message translates to:
  /// **'刚刚'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In zh, this message translates to:
  /// **'{n} 分钟前'**
  String minutesAgo(int n);

  /// No description provided for @hoursAgo.
  ///
  /// In zh, this message translates to:
  /// **'{n} 小时前'**
  String hoursAgo(int n);

  /// No description provided for @daysAgo.
  ///
  /// In zh, this message translates to:
  /// **'{n} 天前'**
  String daysAgo(int n);
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
