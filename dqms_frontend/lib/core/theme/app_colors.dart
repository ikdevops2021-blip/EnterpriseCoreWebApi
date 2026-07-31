import 'package:flutter/material.dart';

/// ============================================================================
/// DQMS ENTERPRISE COLOR TOKENS (Per UI_UX_DESIGN_SPEC.md)
/// Command Center Palette: Precision | Clarity | Speed | Trust | Control
/// ============================================================================
class AppColors {
  // Prevent instantiation
  AppColors._();

  // ---------------------------------------------------------------------------
  // DARK CANVAS & SURFACE TOKENS (Default Operational Aesthetic)
  // ---------------------------------------------------------------------------
  static const Color bgCanvas = Color(0xFF090D11);
  static const Color bgSurface = Color(0xFF12171F);
  static const Color bgSurfaceHover = Color(0xFF1A212B);
  static const Color bgHeader = Color(0xFF0E131A);
  static const Color bgCard = Color(0xFF141C26);
  static const Color bgSubtle = Color(0xFF182230);

  // ---------------------------------------------------------------------------
  // BORDER TOKENS
  // ---------------------------------------------------------------------------
  static const Color borderSubtle = Color(0xFF222B36);
  static const Color borderHighlight = Color(0xFF2F81F7);
  static const Color borderFocus = Color(0xFF388BFD);

  // ---------------------------------------------------------------------------
  // BRAND & ACCENT TOKENS
  // ---------------------------------------------------------------------------
  static const Color brandPrimary = Color(0xFF2F81F7);
  static const Color brandPrimaryHover = Color(0xFF388BFD);
  static const Color brandAccent = Color(0xFF58A6FF);

  // ---------------------------------------------------------------------------
  // NEON ACCENT TOKENS (Dark Mode Gradient Borders & Glowing Nodes)
  // ---------------------------------------------------------------------------
  static const Color neonCyan = Color(0xFF00E5FF);
  static const Color neonMagenta = Color(0xFFD946EF);
  static const Color neonPurple = Color(0xFF8B5CF6);
  static const Color neonEmerald = Color(0xFF10B981);
  static const Color neonAmber = Color(0xFFF59E0B);

  // ---------------------------------------------------------------------------
  // SEMANTIC STATUS TOKENS
  // ---------------------------------------------------------------------------
  static const Color statusActive = Color(0xFF238636);     // Active, Success, Live
  static const Color statusDeactive = Color(0xFFDA3633);   // Canceled, Offline, Error
  static const Color statusWarning = Color(0xFFD29922);    // SLA Alert, Waiting, Hold
  static const Color statusSpecial = Color(0xFF8957E5);    // Priority Tiers, VIP, Prefixes
  static const Color statusInfo = Color(0xFF388BFD);       // Informational, Calling

  // ---------------------------------------------------------------------------
  // TYPOGRAPHY TOKENS (Dark Mode High-Contrast Contrast Ratios)
  // ---------------------------------------------------------------------------
  static const Color textMain = Color(0xFFF0F6FC);
  static const Color textMuted = Color(0xFF8B949E);
  static const Color textSubtle = Color(0xFF848D97);
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
}
