import 'package:codex_z/core/themes/app_colors.dart';
import 'package:codex_z/core/themes/app_fonts.dart';
import 'package:codex_z/core/themes/app_text_styles.dart';
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static ThemeData lightTheme([Color seedColor = AppColors.primary]) {
    return ThemeData(
      useMaterial3: true,
      fontFamily: AppFonts.primary,
      textTheme: AppTextStyles.lightTextTheme,
      primaryTextTheme: AppTextStyles.lightTextTheme,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
        primary: seedColor,
        primaryContainer: seedColor.withValues(alpha: 0.1),
        onPrimaryContainer: seedColor,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.surface,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: AppTextStyles.lightTextTheme.titleLarge,
        toolbarTextStyle: AppTextStyles.lightTextTheme.bodyMedium,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surface,
        selectedItemColor: seedColor,
        unselectedItemColor: AppColors.textSecondary,
        elevation: 0,
        selectedLabelStyle: AppTextStyles.lightTextTheme.labelSmall,
        unselectedLabelStyle: AppTextStyles.lightTextTheme.labelSmall,
      ),
      cardTheme: CardThemeData(
        color: Colors.grey[100],
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey[100],
        selectedColor: seedColor.withValues(alpha: 0.15),
        disabledColor: Colors.grey[200],
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: AppTextStyles.lightTextTheme.bodyMedium?.copyWith(
          color: AppColors.textPrimary,
          fontSize: 13,
        ),
        secondaryLabelStyle: AppTextStyles.lightTextTheme.bodyMedium?.copyWith(
          color: seedColor,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide.none,
        showCheckmark: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        labelStyle: AppTextStyles.lightTextTheme.bodyMedium,
        hintStyle: AppTextStyles.lightTextTheme.bodyMedium?.copyWith(
          color: AppColors.textHint,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: seedColor, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: AppTextStyles.lightTextTheme.labelLarge,
          backgroundColor: seedColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: AppTextStyles.lightTextTheme.labelLarge,
          foregroundColor: seedColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          textStyle: AppTextStyles.lightTextTheme.labelLarge,
          backgroundColor: seedColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: AppTextStyles.lightTextTheme.bodyMedium,
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: AppTextStyles.lightTextTheme.bodyLarge,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          labelStyle: AppTextStyles.lightTextTheme.bodyMedium,
          hintStyle: AppTextStyles.lightTextTheme.bodyMedium?.copyWith(
            color: AppColors.textHint,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.grey.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: seedColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.grey.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        menuStyle: MenuStyle(
          backgroundColor: const WidgetStatePropertyAll(AppColors.surface),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  static ThemeData darkTheme([Color seedColor = AppColors.primary]) {
    return ThemeData(
      useMaterial3: true,
      fontFamily: AppFonts.primary,
      textTheme: AppTextStyles.darkTextTheme,
      primaryTextTheme: AppTextStyles.darkTextTheme,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
        primary: seedColor,
        primaryContainer: seedColor.withValues(alpha: 0.2),
        onPrimaryContainer: seedColor,
        secondary: AppColors.secondary,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: const Color(0xFF121212),
        foregroundColor: Colors.white,
        titleTextStyle: AppTextStyles.darkTextTheme.titleLarge,
        toolbarTextStyle: AppTextStyles.darkTextTheme.bodyMedium,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: seedColor,
        unselectedItemColor: Colors.grey,
        elevation: 0,
        selectedLabelStyle: AppTextStyles.darkTextTheme.labelSmall,
        unselectedLabelStyle: AppTextStyles.darkTextTheme.labelSmall,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E1E),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF2C2C2C),
        selectedColor: seedColor.withValues(alpha: 0.2),
        disabledColor: const Color(0xFF1E1E1E),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: AppTextStyles.darkTextTheme.bodyMedium?.copyWith(
          color: Colors.white70,
          fontSize: 13,
        ),
        secondaryLabelStyle: AppTextStyles.darkTextTheme.bodyMedium?.copyWith(
          color: seedColor,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide.none,
        showCheckmark: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        labelStyle: AppTextStyles.darkTextTheme.bodyMedium,
        hintStyle: AppTextStyles.darkTextTheme.bodyMedium?.copyWith(
          color: Colors.white38,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: seedColor, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: AppTextStyles.darkTextTheme.labelLarge,
          backgroundColor: seedColor,
          foregroundColor: Colors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: AppTextStyles.darkTextTheme.labelLarge,
          foregroundColor: seedColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          textStyle: AppTextStyles.darkTextTheme.labelLarge,
          backgroundColor: seedColor,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF2C2C2C),
        thickness: 1,
        space: 1,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: const Color(0xFF2C2C2C),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: AppTextStyles.darkTextTheme.bodyMedium,
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: AppTextStyles.darkTextTheme.bodyLarge,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2C2C2C),
          labelStyle: AppTextStyles.darkTextTheme.bodyMedium,
          hintStyle: AppTextStyles.darkTextTheme.bodyMedium?.copyWith(
            color: Colors.white38,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.grey.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: seedColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.grey.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        menuStyle: MenuStyle(
          backgroundColor: const WidgetStatePropertyAll(Color(0xFF2C2C2C)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}
