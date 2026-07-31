import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';
import '../theme/app_typography.dart';

enum DqmsButtonVariant { primary, secondary, outline, destructive, ghost }

/// ============================================================================
/// DQMS ENTERPRISE BUTTON COMPONENT
/// Standardized button component consuming AppTheme design tokens
/// ============================================================================
class DqmsButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final DqmsButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final String? hotkey;

  const DqmsButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.variant = DqmsButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = false,
    this.hotkey,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    BorderSide border = BorderSide.none;

    switch (variant) {
      case DqmsButtonVariant.primary:
        bg = AppColors.brandPrimary;
        fg = Colors.white;
        break;
      case DqmsButtonVariant.secondary:
        bg = AppColors.bgSurfaceHover;
        fg = AppColors.textMain;
        border = const BorderSide(color: AppColors.borderSubtle);
        break;
      case DqmsButtonVariant.outline:
        bg = Colors.transparent;
        fg = AppColors.brandPrimary;
        border = const BorderSide(color: AppColors.brandPrimary);
        break;
      case DqmsButtonVariant.destructive:
        bg = AppColors.statusDeactive;
        fg = Colors.white;
        break;
      case DqmsButtonVariant.ghost:
        bg = Colors.transparent;
        fg = AppColors.textMuted;
        break;
    }

    final childWidget = Semantics(
      button: true,
      label: label,
      hint: hotkey != null ? 'Hotkey $hotkey' : null,
      enabled: onPressed != null && !isLoading,
      child: Row(
        mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLoading)
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: fg,
              ),
            )
          else ...[
            if (hotkey != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: fg.withValues(alpha: 0.15),
                  borderRadius: AppRadius.borderXs,
                ),
                child: Text(
                  hotkey!,
                  style: AppTypography.tableHeader.copyWith(
                    color: fg,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            if (icon != null) ...[
              Icon(icon, size: 16, color: fg),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: AppTypography.titleSmall.copyWith(
                color: fg,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 0,
          side: border,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderSm),
        ),
        onPressed: isLoading ? null : onPressed,
        child: childWidget,
      ),
    );
  }
}
