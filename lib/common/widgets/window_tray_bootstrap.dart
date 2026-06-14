import 'dart:io';

import 'package:shim/common/pages/shortcut_launch_loading_page.dart';
import 'package:shim/core/extensions/context_extensions.dart';
import 'package:shim/core/providers/launch_args_provider.dart';
import 'package:shim/core/services/bridge_service.dart';
import 'package:shim/core/services/shortcut_service.dart';
import 'package:shim/core/services/tray_service.dart';
import 'package:shim/features/home/presentation/providers/inject_action_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:window_manager/window_manager.dart';

/// 把窗口关闭拦截 + 系统托盘装配挂在 widget 树根部。
/// 关闭按钮 → 缩到托盘，不真退出。退出由托盘菜单完成。
class WindowTrayBootstrap extends HookConsumerWidget {
  const WindowTrayBootstrap({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final tray = ref.watch(trayServiceProvider);
    final args = ref.watch(launchArgsProvider);
    final isShortcutLaunch = ShortcutService.shouldAutoLaunchCodex(args);
    final showShortcutLoading = useState(isShortcutLaunch);
    final shortcutLaunchStarted = useRef(false);

    useEffect(() {
      Future<void> launchCodex() async {
        try {
          await windowManager.show();
          await windowManager.focus();
          await ref.read(launchAndInjectProvider(debugPort: 9229).future);
          SmartDialog.showToast(l10n.injectSuccess);
        } catch (e) {
          SmartDialog.showToast(l10n.launchFailed(e.toString()));
        }
      }

      void quit() => exit(0);

      tray
        ..onShowWindow = () {
          windowManager.show();
          windowManager.focus();
        }
        ..onLaunchCodex = launchCodex
        ..onQuit = quit;

      tray.install(
        tooltip: l10n.trayTooltip,
        showWindowLabel: l10n.trayShowWindow,
        launchCodexLabel: l10n.trayLaunchCodex,
        quitLabel: l10n.trayQuit,
      );

      final listener = _CloseToTrayListener();
      windowManager.addListener(listener);

      // 由快捷方式拉起：自动注入 Codex 后缩到托盘
      // ignore: avoid_print
      print('[shim] bootstrap launchArgs = $args');
      if (isShortcutLaunch && !shortcutLaunchStarted.value) {
        shortcutLaunchStarted.value = true;
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          try {
            await ref.read(launchAndInjectProvider(debugPort: 9229).future);
            SmartDialog.showToast(l10n.injectSuccess);
            await Future.delayed(const Duration(milliseconds: 1500));
            await windowManager.hide();
            showShortcutLoading.value = false;
          } catch (e) {
            showShortcutLoading.value = false;
            SmartDialog.showToast(l10n.launchFailed(e.toString()));
          }
        });
      }

      return () => windowManager.removeListener(listener);
    }, [l10n, args, isShortcutLaunch]);

    // 让 bridge service 跟着 keepAlive，main 启动后立刻 ready
    ref.watch(bridgeServiceProvider);

    return showShortcutLoading.value
        ? const ShortcutLaunchLoadingPage()
        : child;
  }
}

class _CloseToTrayListener with WindowListener {
  @override
  void onWindowClose() async {
    final preventClose = await windowManager.isPreventClose();
    if (preventClose) {
      await windowManager.hide();
    }
  }
}
