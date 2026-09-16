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

  // Compact Enterprise Density Tokens
  static const double compactPadding = 10.0;
  static const double compactGutter = 8.0;
  static const double denseRowHeight = 36.0;
  static const double compactButtonHeight = 32.0;
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

/// Controlled Depth & Shadows (3D Micro-Skeuomorphism + Controlled Glows)
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

  /// 3D Raised Bevel: Top-left specular micro-highlight + bottom-right ambient depth
  static const List<BoxShadow> depth3dRaised = [
    BoxShadow(
      color: Color(0x1AFFFFFF),
      blurRadius: 1,
      offset: Offset(-1, -1),
    ),
    BoxShadow(
      color: Color(0x73000000),
      blurRadius: 8,
      offset: Offset(2, 4),
    ),
  ];

  /// 3D Floating / Hover Depth
  static const List<BoxShadow> floating3d = [
    BoxShadow(
      color: Color(0x2EFFFFFF),
      blurRadius: 2,
      offset: Offset(-1, -1),
    ),
    BoxShadow(
      color: Color(0x99000000),
      blurRadius: 16,
      spreadRadius: 1,
      offset: Offset(0, 8),
    ),
  ];

  /// 3D Sunken / Inset Depth for inputs and active pressed states
  static const List<BoxShadow> sunken3d = [
    BoxShadow(
      color: Color(0x80000000),
      blurRadius: 4,
      offset: Offset(1, 2),
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

  /// Dynamic Sci-fi Neon Rim Glow
  static List<BoxShadow> neonGlow(Color color, {double radius = 10, double spread = 0.5}) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.35),
        blurRadius: radius,
        spreadRadius: spread,
      ),
    ];
  }
}

/// Motion Tokens (Fast, purposeful, 150ms-250ms transitions without delaying user)
class AppMotion {
  AppMotion._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);

  static const Curve curveStandard = Curves.easeInOut;
  static const Curve curveEmphasized = Curves.fastOutSlowIn;
  static const Curve curveSpring = Curves.easeOutCubic;
}

/// Sci-fi & 3D Surface Styles
class AppDecorations {
  AppDecorations._();

  /// Sci-fi diagonal specular reflection gradient
  static const LinearGradient specularSheen = LinearGradient(
    begin: Alignment(-0.8, -1.0),
    end: Alignment(0.8, 1.0),
    colors: [
      Color(0x1FFFFFFF),
      Color(0x05FFFFFF),
      Colors.transparent,
    ],
    stops: [0.0, 0.45, 1.0],
  );

  /// Sci-fi translucent glass panel decoration
  static BoxDecoration scifiGlass({
    Color? borderColor,
    Color? fillColor,
    double borderRadius = AppRadius.sm,
    bool showRimGlow = false,
    Color? glowColor,
  }) {
    final borderCol = borderColor ?? AppColors.borderSubtle.withValues(alpha: 0.8);
    final bgCol = fillColor ?? AppColors.bgSurface.withValues(alpha: 0.72);
    return BoxDecoration(
      color: bgCol,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: borderCol, width: 1),
      boxShadow: [
        ...AppShadows.depth3dRaised,
        if (showRimGlow && glowColor != null) ...AppShadows.neonGlow(glowColor),
      ],
    );
  }
}
