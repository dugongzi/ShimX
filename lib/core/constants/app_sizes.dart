import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppSizes {
  AppSizes._();

  static double get sidebarWidth => 168.w.clamp(156.0, 204.0).toDouble();

  static double get pagePadding => 16.w.clamp(12.0, 24.0).toDouble();

  static double get sectionGap => 16.h.clamp(12.0, 24.0).toDouble();

  static double get itemGap => 8.h.clamp(6.0, 12.0).toDouble();

  static double get tabHeight => 40.h.clamp(36.0, 44.0).toDouble();

  static double get tabIconSize => 18.r.clamp(16.0, 20.0).toDouble();

  static double get dividerWidth => 1.w.clamp(1.0, 1.0).toDouble();

  static double get cardRadius => 12.r.clamp(8.0, 14.0).toDouble();
}
