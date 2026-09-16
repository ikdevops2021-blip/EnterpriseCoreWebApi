import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';

/// ============================================================================
/// DQMS ENTERPRISE 3D SCI-FI TRANSPARENT PANEL / CARD
/// Provides interactive 3D perspective tilt, frosted glass backdrop filter,
/// specular sheen reflection, and futuristic sci-fi corner bracket accents.
/// ============================================================================
class Dqms3dCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? accentColor;
  final bool isScifiGlass;
  final bool enableTilt;
  final bool isCompact;
  final VoidCallback? onTap;
  final double borderRadius;
  final bool showCornerBrackets;

  const Dqms3dCard({
    super.key,
    required this.child,
    this.padding,
    this.accentColor,
    this.isScifiGlass = true,
    this.enableTilt = true,
    this.isCompact = false,
    this.onTap,
    this.borderRadius = AppRadius.sm,
    this.showCornerBrackets = false,
  });

  @override
  State<Dqms3dCard> createState() => _Dqms3dCardState();
}

class _Dqms3dCardState extends State<Dqms3dCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _tiltXAnimation;
  late Animation<double> _tiltYAnimation;

  double _tiltX = 0.0;
  double _tiltY = 0.0;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.medium,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHover(PointerEvent event, Size size) {
    if (!widget.enableTilt || size.width == 0 || size.height == 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final dx = (event.localPosition.dx - center.dx) / (size.width / 2);
    final dy = (event.localPosition.dy - center.dy) / (size.height / 2);

    setState(() {
      _tiltX = dx.clamp(-1.0, 1.0);
      _tiltY = dy.clamp(-1.0, 1.0);
      _isHovered = true;
    });
  }

  void _onExit(PointerEvent event) {
    if (!widget.enableTilt) return;
    _tiltXAnimation = Tween<double>(begin: _tiltX, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: AppMotion.curveSpring),
    );
    _tiltYAnimation = Tween<double>(begin: _tiltY, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: AppMotion.curveSpring),
    );

    _controller.reset();
    _controller.forward();
    _controller.addListener(_handleAnimationUpdate);

    setState(() {
      _isHovered = false;
    });
  }

  void _handleAnimationUpdate() {
    setState(() {
      _tiltX = _tiltXAnimation.value;
      _tiltY = _tiltYAnimation.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final effectivePadding = widget.padding ??
        EdgeInsets.all(widget.isCompact ? AppSpacing.compactPadding : AppSpacing.md);

    final glowColor = widget.accentColor ?? AppColors.brandPrimary;
    final borderColor = _isHovered
        ? glowColor.withValues(alpha: 0.55)
        : (widget.accentColor?.withValues(alpha: 0.25) ?? AppColors.borderSubtle);

    final cardContent = Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: widget.isScifiGlass
            ? AppColors.bgSurface.withValues(alpha: 0.75)
            : AppColors.bgSurface,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(
          color: borderColor,
          width: _isHovered ? 1.2 : 1.0,
        ),
        boxShadow: _isHovered
            ? [
                ...AppShadows.floating3d,
                ...AppShadows.neonGlow(glowColor, radius: 14, spread: 0.8),
              ]
            : AppShadows.depth3dRaised,
      ),
      child: Stack(
        children: [
          // Specular Light Sheen Layer (Follows Tilt)
          if (_isHovered)
            Positioned.fill(
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.65,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                      gradient: LinearGradient(
                        begin: Alignment(-_tiltX, -_tiltY),
                        end: Alignment(_tiltX, _tiltY),
                        colors: [
                          glowColor.withValues(alpha: 0.12),
                          Colors.transparent,
                          Colors.white.withValues(alpha: 0.04),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Optional Sci-Fi Corner Brackets
          if (widget.showCornerBrackets)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _SciFiCornerPainter(
                    color: glowColor.withValues(alpha: _isHovered ? 0.9 : 0.4),
                  ),
                ),
              ),
            ),

          // Main Children with Optional Padding
          Padding(
            padding: effectivePadding,
            child: widget.child,
          ),
        ],
      ),
    );

    // Apply Backdrop Filter for Frosted Glass Effect
    Widget result = widget.isScifiGlass
        ? ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: cardContent,
            ),
          )
        : cardContent;

    // Apply 3D Perspective Transform
    if (widget.enableTilt) {
      final transform = Matrix4.identity()
        ..setEntry(3, 2, 0.0012)
        ..rotateX(-_tiltY * 0.05)
        ..rotateY(_tiltX * 0.05)
        ..setTranslationRaw(0.0, _isHovered ? -2.5 : 0.0, 0.0);

      result = Transform(
        transform: transform,
        alignment: FractionalOffset.center,
        child: result,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return MouseRegion(
          onHover: (e) => _onHover(e, size),
          onExit: _onExit,
          cursor: widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
          child: GestureDetector(
            onTap: widget.onTap,
            child: result,
          ),
        );
      },
    );
  }
}

/// Custom Painter for Sci-Fi Tech Corner Brackets
class _SciFiCornerPainter extends CustomPainter {
  final Color color;
  static const double bracketSize = 8.0;

  const _SciFiCornerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Top-Left
    canvas.drawLine(const Offset(2, 2), Offset(2 + bracketSize, 2), paint);
    canvas.drawLine(const Offset(2, 2), Offset(2, 2 + bracketSize), paint);

    // Top-Right
    canvas.drawLine(Offset(size.width - 2, 2), Offset(size.width - 2 - bracketSize, 2), paint);
    canvas.drawLine(Offset(size.width - 2, 2), Offset(size.width - 2, 2 + bracketSize), paint);

    // Bottom-Left
    canvas.drawLine(Offset(2, size.height - 2), Offset(2 + bracketSize, size.height - 2), paint);
    canvas.drawLine(Offset(2, size.height - 2), Offset(2, size.height - 2 - bracketSize), paint);

    // Bottom-Right
    canvas.drawLine(Offset(size.width - 2, size.height - 2), Offset(size.width - 2 - bracketSize, size.height - 2), paint);
    canvas.drawLine(Offset(size.width - 2, size.height - 2), Offset(size.width - 2, size.height - 2 - bracketSize), paint);
  }

  @override
  bool shouldRepaint(covariant _SciFiCornerPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
