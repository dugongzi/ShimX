import 'package:shimx/core/providers/locale_provider.dart';
import 'package:shimx/core/providers/theme_provider.dart';
import 'package:shimx/core/themes/app_theme.dart';
import 'package:shimx/features/mcp/presentation/providers/mcp_server_action_provider.dart';
import 'package:shimx/core/services/takeover_service.dart';
import 'package:flutter/material.dart';
import 'package:shimx/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

typedef AppBootstrapBuilder =
    Widget Function(
      BuildContext context,
      Locale locale,
      ThemeData lightTheme,
      ThemeData darkTheme,
      ThemeMode themeMode,
    );

class AppBootstrap extends ConsumerWidget {
  const AppBootstrap({super.key, required this.builder});

  final AppBootstrapBuilder builder;

  static const Iterable<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ];

  static const Iterable<Locale> supportedLocales = <Locale>[
    Locale('zh', 'CN'),
    Locale('en', 'US'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final themeColor = ref.watch(themeColorProvider);
    // 启动时按持久化的代理开关自动接管（keepAlive，只触发一次）
    ref.watch(proxyAutoStartProvider);
    // 启动时按持久化的 MCP 开关自动起本地 MCP server
    ref.watch(mcpServerAutoStartProvider);

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return builder(
          context,
          locale,
          AppTheme.lightTheme(themeColor),
          AppTheme.darkTheme(themeColor),
          themeMode,
        );
      },
    );
  }
}
