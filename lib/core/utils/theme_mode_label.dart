import 'package:flutter/material.dart';
import 'package:shim/core/extensions/context_extensions.dart';

extension ThemeModeLabel on ThemeMode {
  /// 给当前 [ThemeMode] 取本地化文案,跟设置 tab 段控保持一致。
  String localizedName(BuildContext context) {
    return switch (this) {
      ThemeMode.system => context.l10n.systemTheme,
      ThemeMode.light => context.l10n.lightTheme,
      ThemeMode.dark => context.l10n.darkTheme,
    };
  }
}
