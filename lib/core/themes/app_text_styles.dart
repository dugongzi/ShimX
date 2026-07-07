import 'package:shimx/core/themes/app_colors.dart';
import 'package:shimx/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle base = TextStyle(
    fontFamily: AppFonts.primary,
    letterSpacing: 0,
    height: 1.35,
  );

  static TextTheme lightTextTheme = TextTheme(
    displayLarge: base.copyWith(
      fontSize: 57,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    displayMedium: base.copyWith(
      fontSize: 45,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    displaySmall: base.copyWith(
      fontSize: 36,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    headlineLarge: base.copyWith(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    headlineMedium: base.copyWith(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    headlineSmall: base.copyWith(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    titleLarge: base.copyWith(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    titleMedium: base.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    titleSmall: base.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    bodyLarge: base.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
    ),
    bodyMedium: base.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
    ),
    bodySmall: base.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.textHint,
    ),
    labelLarge: base.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    labelMedium: base.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: AppColors.textSecondary,
    ),
    labelSmall: base.copyWith(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: AppColors.textHint,
    ),
  );

  static TextTheme darkTextTheme = lightTextTheme.apply(
    bodyColor: Colors.white70,
    displayColor: Colors.white,
  );

  static const TextStyle code = TextStyle(
    fontFamily: AppFonts.code,
    fontSize: 13,
    height: 1.4,
    letterSpacing: 0,
  );
}
