import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// ============================================================================
/// DQMS ENTERPRISE TYPOGRAPHY SYSTEM (GoogleFonts Inter)
/// Strict typographic hierarchy for high-density command center scannability
/// ============================================================================
class AppTypography {
  AppTypography._();

  // ---------------------------------------------------------------------------
  // HEADINGS
  // ---------------------------------------------------------------------------
  static TextStyle displayLarge = GoogleFonts.inter(
    fontSize: 48,
    fontWeight: FontWeight.w900,
    letterSpacing: -1.5,
    color: AppColors.textMain,
  );

  static TextStyle displayMedium = GoogleFonts.inter(
    fontSize: 36,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.0,
    color: AppColors.textMain,
  );

  static TextStyle titleLarge = GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: AppColors.textMain,
  );

  static TextStyle titleMedium = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    color: AppColors.textMain,
  );

  static TextStyle titleSmall = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textMain,
  );

  // ---------------------------------------------------------------------------
  // BODY & DATA TEXT
  // ---------------------------------------------------------------------------
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textMain,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textMain,
  );

  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  // ---------------------------------------------------------------------------
  // TABLE & METRIC LABELS
  // ---------------------------------------------------------------------------
  static TextStyle tableHeader = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
    color: AppColors.textSubtle,
  );

  static TextStyle kpiLabel = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textSubtle,
  );

  static TextStyle kpiValue = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textMain,
  );

  // ---------------------------------------------------------------------------
  // MONOSPACE / QUEUE TOKEN NUMBER TYPOGRAPHY
  // ---------------------------------------------------------------------------
  static TextStyle tokenDisplay = GoogleFonts.firaCode(
    fontSize: 64,
    fontWeight: FontWeight.w900,
    letterSpacing: -2.0,
    color: AppColors.brandPrimary,
  );

  static TextStyle tokenBadge = GoogleFonts.firaCode(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    color: AppColors.textMain,
  );
}
