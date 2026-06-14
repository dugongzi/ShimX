import 'package:shim/common/widgets/app_bootstrap.dart';
import 'package:shim/common/widgets/window_tray_bootstrap.dart';
import 'package:shim/core/providers/launch_args_provider.dart';
import 'package:shim/core/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main(List<String> args) async {
  // ignore: avoid_print
  print('[shim] main args = $args');
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await windowManager.setPreventClose(true);
  runApp(
    ProviderScope(
      overrides: [launchArgsProvider.overrideWithValue(args)],
      child: const MainApp(),
    ),
  );
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return AppBootstrap(
      builder: (context, locale, lightTheme, darkTheme, themeMode) {
        return MaterialApp.router(
          title: 'Shim',
          locale: locale,
          localizationsDelegates: AppBootstrap.localizationsDelegates,
          supportedLocales: AppBootstrap.supportedLocales,
          localeResolutionCallback: (_, __) => locale,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeMode,
          debugShowCheckedModeBanner: false,
          routerConfig: router,
          builder: (context, child) {
            final smartDialogBuilder = FlutterSmartDialog.init();
            return WindowTrayBootstrap(
              child: smartDialogBuilder(context, child),
            );
          },
        );
      },
    );
  }
}
