import 'package:codex_z/common/widgets/app_bootstrap.dart';
import 'package:codex_z/core/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return AppBootstrap(
      builder: (context, locale, lightTheme, darkTheme, themeMode) {
        return GlassBackdropScope(
          child: MaterialApp.router(
            title: 'Codex Z',
            locale: locale,
            localizationsDelegates: AppBootstrap.localizationsDelegates,
            supportedLocales: AppBootstrap.supportedLocales,
            localeResolutionCallback: (_, __) => locale,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeMode,
            debugShowCheckedModeBanner: false,
            routerConfig: router,
            builder: FlutterSmartDialog.init(),
          ),
        );
      },
    );
  }
}
