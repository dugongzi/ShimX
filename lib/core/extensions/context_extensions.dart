import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimx/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

extension BuildContextExtensions on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => Theme.of(this).textTheme;

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  bool get isEnglish => Localizations.localeOf(this).languageCode == 'en';

  bool get isChinese => Localizations.localeOf(this).languageCode == 'zh';

  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  double get screenWidth => MediaQuery.of(this).size.width;

  double get screenHeight => MediaQuery.of(this).size.height;

  String get location => GoRouterState.of(this).matchedLocation;

  String get languageCode => Localizations.localeOf(this).languageCode;

  bool get isZh => Localizations.localeOf(this).languageCode == 'zh';

  bool get isEn => Localizations.localeOf(this).languageCode == 'en';
}

extension ResponsiveSizeExtensions on num {
  double cw({double min = 0, double max = double.infinity}) {
    return w.clamp(min, max).toDouble();
  }

  double ch({double min = 0, double max = double.infinity}) {
    return h.clamp(min, max).toDouble();
  }

  double csp({double min = 0, double max = double.infinity}) {
    return sp.clamp(min, max).toDouble();
  }

  double cr({double min = 0, double max = double.infinity}) {
    return r.clamp(min, max).toDouble();
  }
}
