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
