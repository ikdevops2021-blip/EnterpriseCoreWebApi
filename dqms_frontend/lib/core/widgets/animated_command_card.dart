import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';

/// ============================================================================
/// ANIMATED COMMAND CARD
/// High-density command center card with micro-elevation lift (-2.5px),
/// subtle cyan border luminescence, and easeOutCubic curve on hover.
/// Optimized for Web, Desktop, and Touch devices.
/// ============================================================================
class AnimatedCommandCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? borderColor;
  final Color? backgroundColor;
  final bool isSelected;
  final bool enableHoverLift;

  const AnimatedCommandCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.borderRadius = AppRadius.md,
    this.borderColor,
    this.backgroundColor,
    this.isSelected = false,
    this.enableHoverLift = true,
  });

  @override
  State<AnimatedCommandCard> createState() => _AnimatedCommandCardState();
}

class _AnimatedCommandCardState extends State<AnimatedCommandCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _liftAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _liftAnimation = Tween<double>(begin: 0.0, end: -2.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHover(bool hovering) {
    if (!widget.enableHoverLift) return;
    setState(() => _isHovered = hovering);
    if (hovering) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeBorderColor = widget.isSelected
        ? AppColors.brandPrimary
        : (_isHovered
            ? (widget.borderColor ?? AppColors.brandPrimary).withValues(alpha: 0.7)
            : (widget.borderColor ?? AppColors.borderSubtle));

    final activeBgColor = widget.backgroundColor ??
        (_isHovered ? AppColors.bgSurfaceHover : AppColors.bgSurface);

    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _liftAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _liftAnimation.value),
              child: child,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            padding: widget.padding,
            decoration: BoxDecoration(
              color: activeBgColor,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: Border.all(
                color: activeBorderColor,
                width: widget.isSelected ? 1.5 : 1.0,
              ),
              boxShadow: _isHovered || widget.isSelected
                  ? [
                      BoxShadow(
                        color: activeBorderColor.withValues(alpha: 0.15),
                        blurRadius: 14,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : AppShadows.subtle,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
