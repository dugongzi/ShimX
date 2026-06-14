import 'package:shim/core/services/app_storage.dart';
import 'package:shim/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_provider.g.dart';

@riverpod
class ThemeModeNotifier extends _$ThemeModeNotifier {
  static const _themeModeKey = 'themeMode';

  @override
  ThemeMode build() {
    Future.microtask(loadThemeMode);
    return ThemeMode.dark;
  }

  Future<void> loadThemeMode() async {
    final storage = ref.read(appStorageProvider);
    final value = await storage.getString(_themeModeKey);
    state = _themeModeFromName(value);
  }

  Future<void> setSystem() async {
    await _setThemeMode(ThemeMode.system);
  }

  Future<void> setLight() async {
    await _setThemeMode(ThemeMode.light);
  }

  Future<void> setDark() async {
    await _setThemeMode(ThemeMode.dark);
  }

  void toggleTheme() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (state == ThemeMode.dark) {
        setLight();
      } else {
        setDark();
      }
    });
  }

  Future<void> _setThemeMode(ThemeMode mode) async {
    state = mode;
    final storage = ref.read(appStorageProvider);
    await storage.setString(_themeModeKey, mode.name);
  }

  ThemeMode _themeModeFromName(String? name) {
    return switch (name) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.dark,
    };
  }

  String get themeModeName => state.name;
}

@riverpod
class ThemeColorNotifier extends _$ThemeColorNotifier {
  static const _themeColorKey = 'themeColor';

  @override
  Color build() {
    Future.microtask(loadThemeColor);
    return AppColors.primary;
  }

  Future<void> loadThemeColor() async {
    final storage = ref.read(appStorageProvider);
    final value = await storage.getInt(_themeColorKey);
    if (value != null) {
      state = Color(value);
    }
  }

  Future<void> updatePrimaryColor(Color color) async {
    state = color;
    final storage = ref.read(appStorageProvider);
    await storage.setInt(_themeColorKey, color.toARGB32());
  }

  Future<void> resetPrimaryColor() async {
    state = AppColors.primary;
    final storage = ref.read(appStorageProvider);
    await storage.remove(_themeColorKey);
  }
}
