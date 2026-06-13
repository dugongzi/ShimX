// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'Codex Z';

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
  String get homeTitle => 'Codex Z';

  @override
  String get welcome => 'Codex Z';

  @override
  String get inject => '注入';

  @override
  String get injectPanelTitle => '界面注入';

  @override
  String get injectPanelDescription => '将 Codex Z 的控制界面注入到目标环境，用于后续连接、调试和操作。';

  @override
  String get injectReadyStatus => '等待注入';

  @override
  String get readyStatus => '就绪';

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
  String get settingsPersistedDescription =>
      '这些设置会通过 SharedPreferencesAsync 持久化保存。';
}
