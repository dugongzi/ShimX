import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tray_manager/tray_manager.dart';

part 'tray_service.g.dart';

@Riverpod(keepAlive: true)
TrayService trayService(Ref ref) {
  final service = TrayService();
  ref.onDispose(service.dispose);
  return service;
}

/// 跨平台系统托盘 service。
/// - 提供图标、tooltip、右键菜单
/// - 暴露 onShowWindow / onLaunchCodex / onQuit 三个回调入口
/// - 监听托盘事件，分发给 callback
class TrayService with TrayListener {
  bool _initialized = false;

  void Function()? onShowWindow;
  void Function()? onLaunchCodex;
  void Function()? onQuit;

  Future<void> install({
    required String tooltip,
    required String showWindowLabel,
    required String launchCodexLabel,
    required String quitLabel,
  }) async {
    if (!_initialized) {
      trayManager.addListener(this);
      _initialized = true;
    }

    await trayManager.setIcon(
      Platform.isWindows
          ? 'assets/images/tray_icon.ico'
          : 'assets/images/tray_icon.png',
    );
    await trayManager.setToolTip(tooltip);
    await trayManager.setContextMenu(
      Menu(items: [
        MenuItem(key: _kShow, label: showWindowLabel),
        MenuItem.separator(),
        MenuItem(key: _kLaunch, label: launchCodexLabel),
        MenuItem.separator(),
        MenuItem(key: _kQuit, label: quitLabel),
      ]),
    );
  }

  void dispose() {
    if (!_initialized) return;
    trayManager.removeListener(this);
    trayManager.destroy();
    _initialized = false;
  }

  @override
  void onTrayIconMouseDown() {
    onShowWindow?.call();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case _kShow:
        onShowWindow?.call();
        break;
      case _kLaunch:
        onLaunchCodex?.call();
        break;
      case _kQuit:
        onQuit?.call();
        break;
    }
  }
}

const _kShow = 'show';
const _kLaunch = 'launch';
const _kQuit = 'quit';
