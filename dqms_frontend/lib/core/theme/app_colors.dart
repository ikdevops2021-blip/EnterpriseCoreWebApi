import 'package:flutter/material.dart';

/// ============================================================================
/// DQMS ENTERPRISE COLOR TOKENS (Per UI_UX_DESIGN_SPEC.md)
/// Command Center Palette: Precision | Clarity | Speed | Trust | Control
/// ============================================================================
class AppColors {
  // Prevent instantiation
  AppColors._();

  // ---------------------------------------------------------------------------
  // DARK CANVAS & SURFACE TOKENS (Stitch Clinical Design System)
  // ---------------------------------------------------------------------------
  static const Color bgCanvas = Color(0xFF101418);
  static const Color bgSurface = Color(0xFF181C20);
  static const Color bgSurfaceHover = Color(0xFF262A2F);
  static const Color bgHeader = Color(0xFF101418);
  static const Color bgCard = Color(0xFF181C20);
  static const Color bgSubtle = Color(0xFF262A2F);

  // ---------------------------------------------------------------------------
  // BORDER TOKENS
  // ---------------------------------------------------------------------------
  static const Color borderSubtle = Color(0xFF3F4850);
  static const Color borderHighlight = Color(0xFF93CCFF);
  static const Color borderFocus = Color(0xFF3198DC);

  // ---------------------------------------------------------------------------
  // BRAND & ACCENT TOKENS
  // ---------------------------------------------------------------------------
  static const Color brandPrimary = Color(0xFF3198DC);
  static const Color brandPrimaryHover = Color(0xFF93CCFF);
  static const Color brandAccent = Color(0xFF93CCFF);
  static const Color brandSecondary = Color(0xFFC0C1FF);

  // ---------------------------------------------------------------------------
  // NEON ACCENT TOKENS (Dark Mode Gradient Borders & Glowing Nodes)
  // ---------------------------------------------------------------------------
  static const Color neonCyan = Color(0xFF93CCFF);
  static const Color neonMagenta = Color(0xFFC0C1FF);
  static const Color neonPurple = Color(0xFFC0C1FF);
  static const Color neonEmerald = Color(0xFF4EDEA3);
  static const Color neonAmber = Color(0xFFF59E0B);

  // ---------------------------------------------------------------------------
  // SEMANTIC STATUS TOKENS
  // ---------------------------------------------------------------------------
  static const Color statusActive = Color(0xFF4EDEA3);     // Active, Success, Live
  static const Color statusDeactive = Color(0xFFFFB4AB);   // Canceled, Offline, Error
  static const Color statusError = Color(0xFFFFB4AB);      // Error, Failed, Breach
  static const Color statusWarning = Color(0xFFF59E0B);    // SLA Alert, Waiting, Hold
  static const Color statusSpecial = Color(0xFFC0C1FF);    // Priority Tiers, VIP, Prefixes
  static const Color statusInfo = Color(0xFF93CCFF);       // Informational, Calling

  // ---------------------------------------------------------------------------
  // TYPOGRAPHY TOKENS (Dark Mode High-Contrast Contrast Ratios)
  // ---------------------------------------------------------------------------
  static const Color textMain = Color(0xFFE0E3E8);
  static const Color textMuted = Color(0xFF89929B);
  static const Color textSubtle = Color(0xFFBFC7D2);
  static const Color textDisabled = Color(0xFF484F58);

  // ---------------------------------------------------------------------------
  // LIGHT CANVAS & SURFACE TOKENS (Optional Light Theme Fallback)
  // ---------------------------------------------------------------------------
  static const Color lightBgCanvas = Color(0xFFF6F8FA);
  static const Color lightBgSurface = Color(0xFFFFFFFF);
  static const Color lightBgHeader = Color(0xFFEEF2F6);
  static const Color lightBorderSubtle = Color(0xFFD0D7DE);
  static const Color lightTextMain = Color(0xFF1F2328);
  static const Color lightTextMuted = Color(0xFF656D76);

  // ---------------------------------------------------------------------------
  // QUEUEPRO LUXURY ACCENTS (Matching Visual Reference Image)
  // ---------------------------------------------------------------------------
  static const Color electricBlue = Color(0xFF2563EB);
  static const Color electricBlueLight = Color(0xFF3B82F6);
  static const Color violetPrimary = Color(0xFF8B5CF6);
  static const Color violetDeep = Color(0xFF6D28D9);
  static const Color violetSoft = Color(0xFF7C3AED);
  static const Color cyanAccent = Color(0xFF06B6D4);
  static const Color cyanGlow = Color(0xFF00E5FF);
  static const Color coralPink = Color(0xFFEC4899);
  static const Color emeraldSuccess = Color(0xFF10B981);
  static const Color amberWarning = Color(0xFFF59E0B);
  static const Color amberOrange = Color(0xFFF97316);

  // ---------------------------------------------------------------------------
  // GLASSMORPHISM SURFACE & BORDER TOKENS
  // ---------------------------------------------------------------------------
  static const Color glassSurfaceDark = Color(0xD913192B);     // 85% opacity deep navy
  static const Color glassSurfaceDarkSubtle = Color(0x8013192B); // 50% opacity
  static const Color glassSurfaceLight = Color(0xCCFFFFFF);    // 80% opacity white
  static const Color glassSurfaceLightSubtle = Color(0x80FFFFFF); // 50% opacity
  static const Color glassBorderLight = Color(0x40FFFFFF);     // 25% white specular rim
  static const Color glassBorderDark = Color(0x2E388BFD);      // Translucent electric border
  static const Color glassBorderSubtle = Color(0x1FFFFFFF);    // 12% white subtle border

  // Tinted Icon Squircle Backgrounds (from reference image)
  static const Color peachIconBg = Color(0xFFFFF1E6);
  static const Color peachIconText = Color(0xFFEA580C);
  static const Color blueIconBg = Color(0xFFEFF6FF);
  static const Color blueIconText = Color(0xFF2563EB);
  static const Color purpleIconBg = Color(0xFFF3E8FF);
  static const Color purpleIconText = Color(0xFF7C3AED);
  static const Color cyanIconBg = Color(0xFFECFEFF);
  static const Color cyanIconText = Color(0xFF0891B2);
  static const Color emeraldIconBg = Color(0xFFECFDF5);
  static const Color emeraldIconText = Color(0xFF059669);
  static const Color pinkIconBg = Color(0xFFFDF2F8);
  static const Color pinkIconText = Color(0xFFDB2777);

  // Dark-mode counterparts for squircle containers
  static const Color darkPeachIconBg = Color(0x33F97316);
  static const Color darkBlueIconBg = Color(0x332563EB);
  static const Color darkPurpleIconBg = Color(0x338B5CF6);
  static const Color darkCyanIconBg = Color(0x3306B6D4);
  static const Color darkEmeraldIconBg = Color(0x3310B981);
  static const Color darkPinkIconBg = Color(0x33EC4899);

  // ---------------------------------------------------------------------------
  // SIGNATURE LINEAR & RADIAL GRADIENTS
  // ---------------------------------------------------------------------------
  /// Primary Hero Gradient: Electric Blue -> Violet
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2563EB), Color(0xFF8B5CF6)],
  );

  /// Serving Live Queue Gradient: Cyan -> Blue -> Violet
  static const LinearGradient servingGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00E5FF), Color(0xFF3B82F6), Color(0xFF8B5CF6)],
  );

  /// Subtle Card Shimmer / Specular Highlight
  static const LinearGradient cardGlassHighlight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x33FFFFFF),
      Color(0x0AFFFFFF),
      Colors.transparent,
    ],
    stops: [0.0, 0.45, 1.0],
  );

  /// Ambient Dark Fluid Backdrop Gradient
  static const LinearGradient darkFluidBackdrop = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0B1120),
      Color(0xFF0F172A),
      Color(0xFF090D16),
    ],
  );
}
