import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';
import '../theme/app_typography.dart';

enum DqmsButtonVariant { primary, secondary, outline, destructive, ghost }

/// ============================================================================
/// DQMS ENTERPRISE 3D TACTILE BUTTON COMPONENT
/// Features 3D bevel micro-skeuomorphism, mechanical press depression animation,
/// specular rim lighting, sci-fi neon hover glow, and compact mode.
/// ============================================================================
class DqmsButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final DqmsButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final bool isCompact;
  final String? hotkey;

  const DqmsButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.variant = DqmsButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = false,
    this.isCompact = false,
    this.hotkey,
  });

  @override
  State<DqmsButton> createState() => _DqmsButtonState();
}

class _DqmsButtonState extends State<DqmsButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Color borderColor = Colors.transparent;
    Color glowColor = AppColors.brandPrimary;

    switch (widget.variant) {
      case DqmsButtonVariant.primary:
        bg = _isHovered ? AppColors.brandPrimaryHover : AppColors.brandPrimary;
        fg = Colors.white;
        borderColor = Colors.white.withValues(alpha: 0.25);
        glowColor = AppColors.brandPrimary;
        break;
      case DqmsButtonVariant.secondary:
        bg = _isHovered ? AppColors.bgSurfaceHover : AppColors.bgSurface;
        fg = AppColors.textMain;
        borderColor = _isHovered ? AppColors.borderHighlight : AppColors.borderSubtle;
        glowColor = AppColors.borderHighlight;
        break;
      case DqmsButtonVariant.outline:
        bg = _isHovered ? AppColors.brandPrimary.withValues(alpha: 0.12) : Colors.transparent;
        fg = AppColors.brandPrimary;
        borderColor = AppColors.brandPrimary;
        glowColor = AppColors.brandPrimary;
        break;
      case DqmsButtonVariant.destructive:
        bg = _isHovered ? const Color(0xFFE5534B) : AppColors.statusDeactive;
        fg = Colors.white;
        borderColor = Colors.white.withValues(alpha: 0.25);
        glowColor = AppColors.statusDeactive;
        break;
      case DqmsButtonVariant.ghost:
        bg = _isHovered ? AppColors.bgSurfaceHover.withValues(alpha: 0.5) : Colors.transparent;
        fg = _isHovered ? AppColors.textMain : AppColors.textMuted;
        borderColor = Colors.transparent;
        glowColor = Colors.transparent;
        break;
    }

    final isEnabled = widget.onPressed != null && !widget.isLoading;
    final double buttonHeight = widget.isCompact ? AppSpacing.compactButtonHeight : 38.0;
    final double horizontalPadding = widget.isCompact ? 10.0 : 14.0;

    final childWidget = Semantics(
      button: true,
      label: widget.label,
      hint: widget.hotkey != null ? 'Hotkey ${widget.hotkey}' : null,
      enabled: isEnabled,
      child: Row(
        mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.isLoading)
            SizedBox(
              width: widget.isCompact ? 12 : 14,
              height: widget.isCompact ? 12 : 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: fg,
              ),
            )
          else ...[
            if (widget.hotkey != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: fg.withValues(alpha: 0.18),
                  borderRadius: AppRadius.borderXs,
                ),
                child: Text(
                  widget.hotkey!,
                  style: AppTypography.tableHeader.copyWith(
                    color: fg,
                    fontSize: widget.isCompact ? 9 : 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],
            if (widget.icon != null) ...[
              Icon(widget.icon, size: widget.isCompact ? 14 : 16, color: fg),
              const SizedBox(width: 6),
            ],
            Text(
              widget.label,
              style: AppTypography.titleSmall.copyWith(
                color: fg,
                fontSize: widget.isCompact ? 12 : 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ],
      ),
    );

    // 3D Tactile Shadows
    List<BoxShadow> shadows = [];
    if (isEnabled && widget.variant != DqmsButtonVariant.ghost) {
      if (_isPressed) {
        shadows = AppShadows.sunken3d;
      } else if (_isHovered) {
        shadows = [
          ...AppShadows.floating3d,
          if (glowColor != Colors.transparent)
            ...AppShadows.neonGlow(glowColor, radius: 10, spread: 0.4),
        ];
      } else {
        shadows = [
          const BoxShadow(
            color: Color(0x1FFFFFFF),
            offset: Offset(-0.5, -0.5),
            blurRadius: 0.5,
          ),
          const BoxShadow(
            color: Color(0x66000000),
            offset: Offset(1, 2.5),
            blurRadius: 3,
          ),
        ];
      }
    }

    final double verticalShift = _isPressed ? 1.5 : (_isHovered ? -1.0 : 0.0);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
      transform: Matrix4.translationValues(0.0, verticalShift, 0.0),
      width: widget.isFullWidth ? double.infinity : null,
      height: buttonHeight,
      decoration: BoxDecoration(
        color: isEnabled ? bg : bg.withValues(alpha: 0.4),
        borderRadius: AppRadius.borderSm,
        border: Border.all(
          color: isEnabled ? borderColor : AppColors.borderSubtle.withValues(alpha: 0.4),
          width: 1.0,
        ),
        boxShadow: shadows,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.borderSm,
        child: InkWell(
          borderRadius: AppRadius.borderSm,
          onTap: isEnabled ? widget.onPressed : null,
          onTapDown: (_) => isEnabled ? setState(() => _isPressed = true) : null,
          onTapUp: (_) => isEnabled ? setState(() => _isPressed = false) : null,
          onTapCancel: () => isEnabled ? setState(() => _isPressed = false) : null,
          onHover: (hover) => isEnabled ? setState(() => _isHovered = hover) : null,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: widget.isCompact ? 4.0 : 6.0,
            ),
            child: childWidget,
          ),
        ),
      ),
    );
  }
}
