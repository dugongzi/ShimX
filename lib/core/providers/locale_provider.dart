import 'package:shimx/core/services/app_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'locale_provider.g.dart';

@riverpod
class LocaleNotifier extends _$LocaleNotifier {
  static const _localeKey = 'locale';

  @override
  Locale build() {
    Future.microtask(loadLocale);
    return const Locale('zh', 'CN');
  }

  Future<void> loadLocale() async {
    final storage = ref.read(appStorageProvider);
    final value = await storage.getString(_localeKey);
    state = _localeFromCode(value);
  }

  Future<void> setZh() async {
    await _setLocale(const Locale('zh', 'CN'));
  }

  Future<void> setEn() async {
    await _setLocale(const Locale('en', 'US'));
  }

  void toggleLanguage() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (state.languageCode == 'zh') {
        setEn();
      } else {
        setZh();
      }
    });
  }

  Future<void> _setLocale(Locale locale) async {
    state = locale;
    final storage = ref.read(appStorageProvider);
    await storage.setString(_localeKey, locale.languageCode);
  }

  Locale _localeFromCode(String? code) {
    return code == 'en' ? const Locale('en', 'US') : const Locale('zh', 'CN');
  }

  String get languageCode => state.languageCode;

  bool get isChinese => state.languageCode == 'zh';

  bool get isEnglish => state.languageCode == 'en';
}
