import 'package:flutter/material.dart';
import 'app_colors.dart';

/// ============================================================================
/// DQMS ENTERPRISE DECORATION & LAYOUT TOKENS
/// Spacing, Border Radius, Shadows, and Motion Standards
/// ============================================================================

/// Spacing Scale Tokens
class AppSpacing {
  AppSpacing._();

  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 48.0;
}

/// Border Radius Tokens (Consistent, subtle rounded corners — no giant rounded cards)
class AppRadius {
  AppRadius._();

  static const double xs = 3.0;
  static const double sm = 6.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double pill = 999.0;

  static final BorderRadius borderXs = BorderRadius.circular(xs);
  static final BorderRadius borderSm = BorderRadius.circular(sm);
  static final BorderRadius borderMd = BorderRadius.circular(md);
  static final BorderRadius borderLg = BorderRadius.circular(lg);
  static final BorderRadius borderPill = BorderRadius.circular(pill);
}

/// Controlled Depth & Shadows (Avoid floaty heavy shadows; favor crisp subtle borders)
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> none = [];

  static const List<BoxShadow> subtle = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> modal = [
    BoxShadow(
      color: Color(0x66000000),
      blurRadius: 16,
      spreadRadius: 2,
      offset: Offset(0, 4),
    ),
  ];

  static final List<BoxShadow> alertGlow = [
    BoxShadow(
      color: AppColors.statusActive.withValues(alpha: 0.35),
      blurRadius: 12,
      spreadRadius: 1,
    ),
  ];
}

/// Motion Tokens (Fast, purposeful, 150ms-250ms transitions without delaying user)
class AppMotion {
  AppMotion._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);

  static const Curve curveStandard = Curves.easeInOut;
  static const Curve curveEmphasized = Curves.fastOutSlowIn;
}
