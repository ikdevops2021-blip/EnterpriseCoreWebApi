import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';
import '../theme/app_typography.dart';

/// ============================================================================
/// QUEUEPRO LUXURY GLASSMORPHISM COMPONENT SUITE
/// Reusable, production-ready, performant glass widgets
/// ============================================================================

// -----------------------------------------------------------------------------
// 1. GLASS CONTAINER
// -----------------------------------------------------------------------------
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final Color? color;
  final Gradient? gradient;
  final Color? borderColor;
  final double borderWidth;
  final List<BoxShadow>? shadows;
  final Clip clipBehavior;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = AppRadius.card,
    this.blur = 10.0,
    this.color,
    this.gradient,
    this.borderColor,
    this.borderWidth = 1.0,
    this.shadows,
    this.clipBehavior = Clip.antiAlias,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = borderColor ?? AppColors.glassBorderLight;
    final effectiveColor = (gradient == null && color == null)
        ? AppColors.glassSurfaceDark
        : color;

    final boxDecoration = BoxDecoration(
      color: effectiveColor,
      gradient: gradient,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: effectiveBorderColor, width: borderWidth),
      boxShadow: shadows ?? AppShadows.glassCard,
    );

    Widget content = Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: boxDecoration,
      child: child,
    );

    // Apply BackdropFilter when blur > 0
    if (blur > 0) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        clipBehavior: clipBehavior,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: content,
        ),
      );
    }

    return content;
  }
}

// -----------------------------------------------------------------------------
// 2. GLASS CARD (Interactive Glass Surface with Specular Sheen)
// -----------------------------------------------------------------------------
class GlassCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? color;
  final Gradient? gradient;
  final Color? borderColor;
  final Color? hoverBorderColor;
  final double blur;
  final bool enableHover;
  final double? width;
  final double? height;

  const GlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.borderRadius = AppRadius.card,
    this.color,
    this.gradient,
    this.borderColor,
    this.hoverBorderColor,
    this.blur = 10.0,
    this.enableHover = true,
    this.width,
    this.height,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final defaultBorder = widget.borderColor ?? AppColors.glassBorderLight;
    final hoverBorder = widget.hoverBorderColor ?? AppColors.electricBlue.withValues(alpha: 0.6);

    return MouseRegion(
      onEnter: widget.enableHover ? (_) => setState(() => _isHovered = true) : null,
      onExit: widget.enableHover ? (_) => setState(() => _isHovered = false) : null,
      cursor: widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 1.015 : 1.0,
          duration: AppMotion.fast,
          curve: AppMotion.curveSpring,
          child: GlassContainer(
            width: widget.width,
            height: widget.height,
            padding: widget.padding ?? const EdgeInsets.all(AppSpacing.lg),
            margin: widget.margin,
            borderRadius: widget.borderRadius,
            blur: widget.blur,
            color: widget.color,
            gradient: widget.gradient,
            borderColor: _isHovered ? hoverBorder : defaultBorder,
            shadows: _isHovered
                ? [
                    ...AppShadows.glassCard,
                    BoxShadow(
                      color: AppColors.electricBlue.withValues(alpha: 0.15),
                      blurRadius: 16,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : AppShadows.glassCard,
            child: Stack(
              children: [
                // Diagonal Specular Light Reflection
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(widget.borderRadius),
                        gradient: AppColors.cardGlassHighlight,
                      ),
                    ),
                  ),
                ),
                widget.child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 3. GLASS SQUIRCLE ICON (Rounded Icon Container from Reference Image)
// -----------------------------------------------------------------------------
class GlassSquircleIcon extends StatelessWidget {
  final IconData? icon;
  final Widget? child;
  final Color backgroundColor;
  final Color iconColor;
  final double size;
  final double iconSize;
  final double borderRadius;
  final VoidCallback? onTap;

  const GlassSquircleIcon({
    super.key,
    this.icon,
    this.child,
    required this.backgroundColor,
    required this.iconColor,
    this.size = 48.0,
    this.iconSize = 22.0,
    this.borderRadius = AppRadius.squircle,
    this.onTap,
  }) : assert(icon != null || child != null);

  @override
  Widget build(BuildContext context) {
    final widgetContent = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: iconColor.withValues(alpha: 0.25),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: child ??
            Icon(
              icon,
              color: iconColor,
              size: iconSize,
            ),
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: widgetContent,
      );
    }

    return widgetContent;
  }
}

// -----------------------------------------------------------------------------
// 4. GLASS PILL BADGE (Status Indicators: Now Serving, Waiting, Verified, etc.)
// -----------------------------------------------------------------------------
enum GlassPillVariant {
  nowServing,
  waiting,
  upcoming,
  completed,
  verified,
  canceled,
  custom,
}

class GlassPillBadge extends StatelessWidget {
  final String label;
  final GlassPillVariant variant;
  final Color? customColor;
  final IconData? icon;
  final bool showDot;

  const GlassPillBadge({
    super.key,
    required this.label,
    this.variant = GlassPillVariant.nowServing,
    this.customColor,
    this.icon,
    this.showDot = true,
  });

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    Color textColor;

    switch (variant) {
      case GlassPillVariant.nowServing:
        badgeColor = AppColors.emeraldSuccess;
        textColor = Colors.white;
        break;
      case GlassPillVariant.waiting:
        badgeColor = AppColors.amberOrange;
        textColor = Colors.white;
        break;
      case GlassPillVariant.upcoming:
        badgeColor = AppColors.cyanGlow;
        textColor = const Color(0xFF0F172A);
        break;
      case GlassPillVariant.completed:
        badgeColor = AppColors.emeraldSuccess;
        textColor = Colors.white;
        break;
      case GlassPillVariant.verified:
        badgeColor = AppColors.emeraldSuccess;
        textColor = Colors.white;
        break;
      case GlassPillVariant.canceled:
        badgeColor = AppColors.statusError;
        textColor = Colors.white;
        break;
      case GlassPillVariant.custom:
        badgeColor = customColor ?? AppColors.brandPrimary;
        textColor = Colors.white;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.45),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: badgeColor.withValues(alpha: 0.20),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: badgeColor, size: 12),
            const SizedBox(width: 4),
          ] else if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: badgeColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: badgeColor.withValues(alpha: 0.8),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 5),
          ],
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: textColor == Colors.white ? badgeColor : textColor,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 5. GLASS TOKEN CARD (Signature 3D Floating Token from Reference Image)
// -----------------------------------------------------------------------------
class GlassTokenCard extends StatelessWidget {
  final String tokenNumber;
  final String status;
  final String serviceName;
  final String? doctorName;
  final String? roomInfo;
  final String? timeInfo;
  final int? queuePosition;
  final int? estimatedWaitMinutes;
  final String? qrData;
  final VoidCallback? onShare;
  final VoidCallback? onTap;

  const GlassTokenCard({
    super.key,
    required this.tokenNumber,
    this.status = 'Now Serving',
    required this.serviceName,
    this.doctorName,
    this.roomInfo,
    this.timeInfo,
    this.queuePosition,
    this.estimatedWaitMinutes,
    this.qrData,
    this.onShare,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isNowServing = status.toLowerCase().contains('serving') || status.toLowerCase().contains('now');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.hero),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E1B4B), // Deep indigo
              Color(0xFF0F172A), // Slate midnight
              Color(0xFF1E293B),
            ],
          ),
          border: Border.all(
            color: isNowServing
                ? AppColors.cyanGlow.withValues(alpha: 0.5)
                : AppColors.glassBorderLight,
            width: 1.5,
          ),
          boxShadow: AppShadows.token3dGlow(
            glowColor: isNowServing ? AppColors.cyanGlow : AppColors.electricBlue,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.hero),
          child: Stack(
            children: [
              // Ambient radial glow in background
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        (isNowServing ? AppColors.cyanGlow : AppColors.violetPrimary)
                            .withValues(alpha: 0.25),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Diagonal specular sheen
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.cardGlassHighlight,
                    ),
                  ),
                ),
              ),

              // Card Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Subtitle Header
                    Text(
                      'YOUR QUEUE TOKEN',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.8,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Floating Glowing Token Number Capsule
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: AppColors.servingGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.cyanGlow.withValues(alpha: 0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            tokenNumber,
                            style: AppTypography.tokenHero,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Service & Doctor Info
                    Text(
                      serviceName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (doctorName != null && doctorName!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        doctorName!,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    if (roomInfo != null || timeInfo != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        [?roomInfo, ?timeInfo].join('  •  '),
                        style: TextStyle(
                          color: AppColors.cyanGlow.withValues(alpha: 0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],

                    // Queue Position & Estimated Wait Row
                    if (queuePosition != null || estimatedWaitMinutes != null) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            if (queuePosition != null) ...[
                              Column(
                                children: [
                                  Text(
                                    'Queue Position',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.6),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '$queuePosition',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (queuePosition != null && estimatedWaitMinutes != null)
                              Container(
                                width: 1,
                                height: 28,
                                color: Colors.white.withValues(alpha: 0.15),
                              ),
                            if (estimatedWaitMinutes != null) ...[
                              Column(
                                children: [
                                  Text(
                                    'Estimated Wait',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.6),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '~$estimatedWaitMinutes min',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],

                    // Clean High-Contrast QR Code Card
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 16,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: _buildQrCodeRepresentation(tokenNumber),
                    ),
                    const SizedBox(height: 12),

                    Text(
                      'Please wait for your number to be called.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    // Share Token Button
                    if (onShare != null) ...[
                      const SizedBox(height: 18),
                      InkWell(
                        onTap: onShare,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          decoration: BoxDecoration(
                            gradient: AppColors.heroGradient,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.electricBlue.withValues(alpha: 0.4),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.share_rounded, color: Colors.white, size: 16),
                                SizedBox(width: 8),
                                Text(
                                  'Share Token',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Clean Geometric QR Code Pattern
  Widget _buildQrCodeRepresentation(String code) {
    return SizedBox(
      width: 120,
      height: 120,
      child: CustomPaint(
        painter: _QrMatrixPainter(code: code),
      ),
    );
  }
}

/// Custom Painter for High-Fidelity Geometric QR Code Representation
class _QrMatrixPainter extends CustomPainter {
  final String code;
  const _QrMatrixPainter({required this.code});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;

    // Outer Position Marker Corners (Top-Left, Top-Right, Bottom-Left)
    _drawFinderPattern(canvas, const Offset(0, 0), paint, size);
    _drawFinderPattern(canvas, Offset(size.width - 32, 0), paint, size);
    _drawFinderPattern(canvas, Offset(0, size.height - 32), paint, size);

    // Inner Data Dots Simulation
    final dotSize = size.width / 15;
    final hash = code.hashCode;

    for (int r = 0; r < 15; r++) {
      for (int c = 0; c < 15; c++) {
        // Skip finder pattern zones
        final inTL = r < 5 && c < 5;
        final inTR = r < 5 && c >= 10;
        final inBL = r >= 10 && c < 5;
        if (inTL || inTR || inBL) continue;

        final isFilled = ((hash ^ (r * 17 + c * 31)) % 3) == 0;
        if (isFilled) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(c * dotSize + 1, r * dotSize + 1, dotSize - 2, dotSize - 2),
              const Radius.circular(1.5),
            ),
            paint,
          );
        }
      }
    }
  }

  void _drawFinderPattern(Canvas canvas, Offset offset, Paint paint, Size size) {
    // Outer Box (7x7 module relative)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(offset.dx, offset.dy, 32, 32),
        const Radius.circular(5),
      ),
      paint,
    );
    // Inner White Cutout
    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(offset.dx + 4, offset.dy + 4, 24, 24),
        const Radius.circular(3),
      ),
      whitePaint,
    );
    // Center Solid Dot
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(offset.dx + 9, offset.dy + 9, 14, 14),
        const Radius.circular(3),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _QrMatrixPainter oldDelegate) => oldDelegate.code != code;
}

// -----------------------------------------------------------------------------
// 6. GLASS BOTTOM NAVIGATION (Translucent Mobile Floating Bar)
// -----------------------------------------------------------------------------
class GlassNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;

  const GlassNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
  });
}

class GlassBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<GlassNavItem> items;

  const GlassBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.glassSurfaceDark,
        borderRadius: BorderRadius.circular(AppRadius.hero),
        border: Border.all(color: AppColors.glassBorderLight, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.hero),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(items.length, (index) {
                final item = items[index];
                final isSelected = index == currentIndex;

                return InkWell(
                  onTap: () => onTap(index),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: AnimatedContainer(
                    duration: AppMotion.fast,
                    curve: AppMotion.curveSpring,
                    padding: EdgeInsets.symmetric(
                      horizontal: isSelected ? 16 : 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.electricBlue.withValues(alpha: 0.20)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: isSelected
                          ? Border.all(
                              color: AppColors.electricBlue.withValues(alpha: 0.45),
                              width: 1.0,
                            )
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSelected ? (item.activeIcon ?? item.icon) : item.icon,
                          color: isSelected
                              ? AppColors.cyanGlow
                              : AppColors.textMuted,
                          size: 20,
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 8),
                          Text(
                            item.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

/// ============================================================================
/// 8. CLINICAL SPATIAL 3D GLASS CARDS (MATCHING REFERENCE DESIGNS)
/// ============================================================================

/// ── Card 1: 'Your Next Appointment' Hero Card (Web, Mobile, Desktop Responsive) ──
class NextAppointmentGlassCard extends StatefulWidget {
  final String ticketNumber;
  final String serviceName;
  final String time;
  final String dateText;
  final VoidCallback? onViewDetails;
  final double? maxWidth;

  const NextAppointmentGlassCard({
    super.key,
    this.ticketNumber = 'A012',
    this.serviceName = 'Consultation - General Physician',
    this.time = '10:20 AM',
    this.dateText = 'SEPT 16',
    this.onViewDetails,
    this.maxWidth,
  });

  @override
  State<NextAppointmentGlassCard> createState() => _NextAppointmentGlassCardState();
}

class _NextAppointmentGlassCardState extends State<NextAppointmentGlassCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: 180,
          maxWidth: widget.maxWidth ?? double.infinity,
        ),
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          cursor: widget.onViewDetails != null ? SystemMouseCursors.click : MouseCursor.defer,
          child: AnimatedScale(
            scale: _isHovered ? 1.012 : 1.0,
            duration: AppMotion.fast,
            curve: AppMotion.curveSpring,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF0284C7),
                    Color(0xFF2563EB),
                    Color(0xFF1D4ED8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: _isHovered
                      ? Colors.white.withValues(alpha: 0.65)
                      : Colors.white.withValues(alpha: 0.35),
                  width: _isHovered ? 1.5 : 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0284C7).withValues(alpha: _isHovered ? 0.45 : 0.35),
                    blurRadius: _isHovered ? 30 : 24,
                    offset: Offset(0, _isHovered ? 12 : 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    // Atmospheric Radial Caustics
                    Positioned(
                      top: -30,
                      right: -20,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.18),
                        ),
                      ),
                    ),
                    // Diagonal Glass Sheen
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.25),
                              Colors.transparent,
                              Colors.white.withValues(alpha: 0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ),
                    // Responsive Content Layout
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isCompact = constraints.maxWidth < 360;
                        return Padding(
                          padding: EdgeInsets.all(isCompact ? 14.0 : 20.0),
                          child: Row(
                            children: [
                              // Left Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Pill label
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.20),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.circle, color: Color(0xFF6FFBBE), size: 8),
                                            SizedBox(width: 6),
                                            Text(
                                              'YOUR NEXT APPOINTMENT',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    // Big Ticket (Scales down gracefully on small mobile screens)
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        widget.ticketNumber,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: isCompact ? 32 : 38,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: -1.0,
                                          height: 1.1,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    // Service
                                    Text(
                                      widget.serviceName,
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.90),
                                        fontSize: isCompact ? 12 : 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 12),
                                    // Bottom row: Time + View Details
                                    Wrap(
                                      spacing: 10,
                                      runSpacing: 8,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.access_time_rounded, color: Colors.white, size: 14),
                                            const SizedBox(width: 5),
                                            Text(
                                              widget.time,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        InkWell(
                                          onTap: widget.onViewDetails,
                                          borderRadius: BorderRadius.circular(20),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                              ),
                                              borderRadius: BorderRadius.circular(20),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  'View Details',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                SizedBox(width: 4),
                                                Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 13),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: isCompact ? 8 : 12),
                              // Right 3D Calendar & Stethoscope Graphic
                              _build3DCalendarBadge(widget.dateText, isCompact),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _build3DCalendarBadge(String dateText, bool isCompact) {
    final width = isCompact ? 76.0 : 90.0;
    final height = isCompact ? 82.0 : 95.0;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Blue Top Header
          Container(
            height: isCompact ? 24 : 28,
            decoration: const BoxDecoration(
              color: Color(0xFF2563EB),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(width: 5, height: 5, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                Text(
                  dateText,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isCompact ? 9 : 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                Container(width: 5, height: 5, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
              ],
            ),
          ),
          // Center Date & Stethoscope
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '16',
                  style: TextStyle(
                    color: const Color(0xFF1E293B),
                    fontSize: isCompact ? 22 : 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Positioned(
                  bottom: isCompact ? 2 : 4,
                  child: Icon(
                    Icons.medical_services_outlined,
                    color: const Color(0xFF0284C7).withValues(alpha: 0.6),
                    size: isCompact ? 14 : 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ── Card 2: 'Now Serving' Consultation Banner Card (Web, Mobile, Desktop Responsive) ──
class NowServingBannerGlassCard extends StatefulWidget {
  final String ticketNumber;
  final String serviceName;
  final String doctorName;
  final String time;
  final String room;
  final String? avatarUrl;
  final VoidCallback? onTapRoom;
  final VoidCallback? onTap;
  final double? maxWidth;

  const NowServingBannerGlassCard({
    super.key,
    this.ticketNumber = 'A012',
    this.serviceName = 'Consultation - General Physician',
    this.doctorName = 'Rahman, A.',
    this.time = '10:20 AM',
    this.room = 'Room 2',
    this.avatarUrl,
    this.onTapRoom,
    this.onTap,
    this.maxWidth,
  });

  @override
  State<NowServingBannerGlassCard> createState() => _NowServingBannerGlassCardState();
}

class _NowServingBannerGlassCardState extends State<NowServingBannerGlassCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: widget.maxWidth ?? double.infinity,
        ),
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          cursor: widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
          child: GestureDetector(
            onTap: widget.onTap,
            child: AnimatedScale(
              scale: _isHovered ? 1.012 : 1.0,
              duration: AppMotion.fast,
              curve: AppMotion.curveSpring,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF06B6D4),
                      Color(0xFF0284C7),
                      Color(0xFF3B82F6),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  border: Border.all(
                    color: _isHovered
                        ? Colors.white.withValues(alpha: 0.70)
                        : Colors.white.withValues(alpha: 0.40),
                    width: _isHovered ? 1.5 : 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0284C7).withValues(alpha: _isHovered ? 0.45 : 0.30),
                      blurRadius: _isHovered ? 24 : 18,
                      offset: Offset(0, _isHovered ? 8 : 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      // Diagonal Sheen
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.20),
                                Colors.transparent,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isCompact = constraints.maxWidth < 380;
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: isCompact ? 12 : 16,
                              vertical: isCompact ? 10 : 14,
                            ),
                            child: Row(
                              children: [
                                // Circular Avatar with Blue Verified Badge
                                Stack(
                                  children: [
                                    Container(
                                      width: isCompact ? 44 : 52,
                                      height: isCompact ? 44 : 52,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.15),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: ClipOval(
                                        child: widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty
                                            ? Image.network(widget.avatarUrl!, fit: BoxFit.cover, errorBuilder: (_, _, _) => _defaultAvatar())
                                            : _defaultAvatar(),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF2563EB),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.check_rounded, color: Colors.white, size: isCompact ? 8 : 10),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(width: isCompact ? 10 : 14),
                                // Center Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            widget.ticketNumber,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: isCompact ? 16 : 18,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              widget.serviceName,
                                              style: TextStyle(
                                                color: Colors.white.withValues(alpha: 0.9),
                                                fontSize: isCompact ? 11 : 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        widget.doctorName,
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.95),
                                          fontSize: isCompact ? 12 : 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          const Icon(Icons.access_time_rounded, color: Colors.white70, size: 12),
                                          const SizedBox(width: 4),
                                          Text(
                                            widget.time,
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Right Indicators (Now Serving + Room)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Mint Green Now Serving Pill
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isCompact ? 8 : 10,
                                        vertical: isCompact ? 3 : 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF6FFBBE),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF6FFBBE).withValues(alpha: 0.5),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        'Now Serving',
                                        style: TextStyle(
                                          color: const Color(0xFF065F46),
                                          fontSize: isCompact ? 10 : 11,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: isCompact ? 6 : 8),
                                    // Room Link
                                    MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: InkWell(
                                        onTap: widget.onTapRoom,
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.20),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                widget.room,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: isCompact ? 11 : 12,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Icon(Icons.chevron_right_rounded, color: Colors.white, size: isCompact ? 12 : 14),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _defaultAvatar() {
    return Container(
      color: const Color(0xFF0284C7),
      child: const Center(
        child: Icon(Icons.person, color: Colors.white, size: 28),
      ),
    );
  }
}

/// ── Card 3: 'You're in Queue' Live Modal Status Card (Web, Mobile, Desktop Responsive) ──
class QueueProgressModalGlassCard extends StatefulWidget {
  final String ticketNumber;
  final int position;
  final int currentStep; // 1, 2, or 3
  final String reassuranceText;
  final VoidCallback? onExploreMore;
  final double? maxWidth;

  const QueueProgressModalGlassCard({
    super.key,
    this.ticketNumber = 'A012',
    this.position = 2,
    this.currentStep = 2,
    this.reassuranceText = "Relax, we'll call you shortly",
    this.onExploreMore,
    this.maxWidth = 440,
  });

  @override
  State<QueueProgressModalGlassCard> createState() => _QueueProgressModalGlassCardState();
}

class _QueueProgressModalGlassCardState extends State<QueueProgressModalGlassCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: widget.maxWidth ?? 440),
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedScale(
            scale: _isHovered ? 1.01 : 1.0,
            duration: AppMotion.fast,
            curve: AppMotion.curveSpring,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: _isHovered
                      ? const Color(0xFF00F0FF).withValues(alpha: 0.6)
                      : const Color(0xFF00F0FF).withValues(alpha: 0.35),
                  width: _isHovered ? 1.6 : 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00F0FF).withValues(alpha: _isHovered ? 0.30 : 0.20),
                    blurRadius: _isHovered ? 40 : 30,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Green Glowing Checkmark Badge
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF10B981),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withValues(alpha: 0.55),
                          blurRadius: 18,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.check_rounded, color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: 16),
                  // Title
                  const Text(
                    "You're in Queue",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Large Hero Ticket (Responsive Scaling)
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      widget.ticketNumber,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Position Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF00F0FF).withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Position ${widget.position}',
                          style: const TextStyle(
                            color: Color(0xFF7DF4FF),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right_rounded, color: Color(0xFF7DF4FF), size: 14),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 3-Step Glowing Cyan Beam Track
                  _build3StepTrack(widget.currentStep),
                  const SizedBox(height: 14),
                  // Reassurance
                  Text(
                    widget.reassuranceText,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 22),
                  // Bottom CTA
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: InkWell(
                      onTap: widget.onExploreMore,
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x33000000),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Explore More',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 14),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _build3StepTrack(int activeStep) {
    return Row(
      children: [
        _buildNode(1 <= activeStep, true),
        Expanded(child: _buildLine(2 <= activeStep)),
        _buildNode(2 <= activeStep, 2 == activeStep),
        Expanded(child: _buildLine(3 <= activeStep)),
        _buildNode(3 <= activeStep, 3 == activeStep),
      ],
    );
  }

  Widget _buildNode(bool isCompleted, bool isCurrent) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted ? const Color(0xFF00F0FF) : const Color(0xFF334155),
        boxShadow: isCompleted
            ? [
                BoxShadow(
                  color: const Color(0xFF00F0FF).withValues(alpha: 0.8),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildLine(bool isActive) {
    return Container(
      height: 3,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF00F0FF) : const Color(0xFF334155),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: const Color(0xFF00F0FF).withValues(alpha: 0.6),
                  blurRadius: 6,
                ),
              ]
            : null,
      ),
    );
  }
}

/// ── Card 4: 'Choose Your Service' Concierge Card (Web, Mobile, Desktop Responsive) ──
class ConciergeServiceGlassCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final double? maxWidth;

  const ConciergeServiceGlassCard({
    super.key,
    this.title = 'Choose Your Service',
    this.subtitle = 'Select a department to book an appointment',
    this.onTap,
    this.maxWidth,
  });

  @override
  State<ConciergeServiceGlassCard> createState() => _ConciergeServiceGlassCardState();
}

class _ConciergeServiceGlassCardState extends State<ConciergeServiceGlassCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: widget.maxWidth ?? double.infinity),
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: widget.onTap,
            child: AnimatedScale(
              scale: _isHovered ? 1.015 : 1.0,
              duration: AppMotion.fast,
              curve: AppMotion.curveSpring,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: _isHovered ? 0.22 : 0.15),
                      Colors.white.withValues(alpha: _isHovered ? 0.08 : 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: _isHovered
                        ? Colors.white.withValues(alpha: 0.55)
                        : Colors.white.withValues(alpha: 0.25),
                    width: _isHovered ? 1.5 : 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: _isHovered ? 0.30 : 0.20),
                      blurRadius: _isHovered ? 24 : 16,
                      offset: Offset(0, _isHovered ? 6 : 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // 3D Bubble Physician Sphere with Specular Glow
                    AnimatedScale(
                      scale: _isHovered ? 1.06 : 1.0,
                      duration: AppMotion.fast,
                      curve: AppMotion.curveSpring,
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const RadialGradient(
                            colors: [
                              Color(0xFF38BDF8),
                              Color(0xFF0284C7),
                              Color(0xFF1E3A8A),
                            ],
                            center: Alignment(-0.3, -0.3),
                            radius: 0.8,
                          ),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0284C7).withValues(alpha: _isHovered ? 0.6 : 0.4),
                              blurRadius: _isHovered ? 18 : 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.medical_information_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Text Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.subtitle,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    AnimatedSlide(
                      offset: _isHovered ? const Offset(0.2, 0) : Offset.zero,
                      duration: AppMotion.fast,
                      child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ============================================================================
/// 9. ADAPTIVE CLINICAL CARDS SECTION (MULTI-PLATFORM BREAKPOINT CONTAINER)
/// Dynamically arranges cards for Mobile (<600px), Tablet (600-1024px),
/// and Desktop / Web (>1024px).
/// ============================================================================
class AdaptiveClinicalCardsSection extends StatelessWidget {
  final Widget? nextAppointmentCard;
  final Widget? nowServingCard;
  final Widget? queueProgressCard;
  final Widget? conciergeCard;

  const AdaptiveClinicalCardsSection({
    super.key,
    this.nextAppointmentCard,
    this.nowServingCard,
    this.queueProgressCard,
    this.conciergeCard,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // 1. Desktop & Wide Web (> 960px): Dual Column Grid
        if (width >= 960) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (nextAppointmentCard != null)
                    Expanded(child: nextAppointmentCard!),
                  if (nextAppointmentCard != null && queueProgressCard != null)
                    const SizedBox(width: 20),
                  if (queueProgressCard != null)
                    Expanded(child: queueProgressCard!),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (nowServingCard != null)
                    Expanded(child: nowServingCard!),
                  if (nowServingCard != null && conciergeCard != null)
                    const SizedBox(width: 20),
                  if (conciergeCard != null)
                    Expanded(child: conciergeCard!),
                ],
              ),
            ],
          );
        }

        // 2. Tablet (600px - 959px): Balanced Stacking
        if (width >= 600) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (nowServingCard != null) ...[
                nowServingCard!,
                const SizedBox(height: 16),
              ],
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (nextAppointmentCard != null)
                    Expanded(child: nextAppointmentCard!),
                  if (nextAppointmentCard != null && conciergeCard != null)
                    const SizedBox(width: 16),
                  if (conciergeCard != null)
                    Expanded(child: conciergeCard!),
                ],
              ),
              if (queueProgressCard != null) ...[
                const SizedBox(height: 16),
                queueProgressCard!,
              ],
            ],
          );
        }

        // 3. Mobile (< 600px): Vertical Fluid Stack
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (nowServingCard != null) ...[
              nowServingCard!,
              const SizedBox(height: 14),
            ],
            if (nextAppointmentCard != null) ...[
              nextAppointmentCard!,
              const SizedBox(height: 14),
            ],
            if (conciergeCard != null) ...[
              conciergeCard!,
              const SizedBox(height: 14),
            ],
            if (queueProgressCard != null) ...[
              queueProgressCard!,
            ],
          ],
        );
      },
    );
  }
}
