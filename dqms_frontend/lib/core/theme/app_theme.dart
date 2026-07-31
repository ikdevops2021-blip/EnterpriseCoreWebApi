import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_decorations.dart';
import 'app_typography.dart';

/// ============================================================================
/// DQMS ENTERPRISE MATERIAL 3 THEME DATA CONFIGURATION
/// Standardized Dark (Default Command Center) & Light Themes
/// ============================================================================
class AppTheme {
  AppTheme._();

  // ---------------------------------------------------------------------------
  // DARK COMMAND CENTER THEME (DEFAULT OPERATIONAL THEME)
  // ---------------------------------------------------------------------------
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgCanvas,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.bgSurface,
        primary: AppColors.brandPrimary,
        secondary: AppColors.brandAccent,
        error: AppColors.statusDeactive,
        onSurface: AppColors.textMain,
        onPrimary: Colors.white,
        outline: AppColors.borderSubtle,
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge,
        displayMedium: AppTypography.displayMedium,
        titleLarge: AppTypography.titleLarge,
        titleMedium: AppTypography.titleMedium,
        titleSmall: AppTypography.titleSmall,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.bodySmall,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.bgSurface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderMd,
          side: const BorderSide(color: AppColors.borderSubtle),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.bgSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderSm,
          side: const BorderSide(color: AppColors.borderSubtle),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderSubtle,
        space: 1,
        thickness: 1,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.bgHeader,
          borderRadius: AppRadius.borderXs,
          border: Border.all(color: AppColors.borderSubtle),
        ),
        textStyle: AppTypography.bodySmall.copyWith(color: AppColors.textMain),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // LIGHT ENTERPRISE THEME (FALLBACK)
  // ---------------------------------------------------------------------------
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBgCanvas,
      colorScheme: const ColorScheme.light(
        surface: AppColors.lightBgSurface,
        primary: AppColors.brandPrimary,
        error: AppColors.statusDeactive,
        onSurface: AppColors.lightTextMain,
        outline: AppColors.lightBorderSubtle,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightBorderSubtle,
        space: 1,
        thickness: 1,
      ),
    );
  }
}
