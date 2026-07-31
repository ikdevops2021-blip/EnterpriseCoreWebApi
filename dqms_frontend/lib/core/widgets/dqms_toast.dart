import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';
import '../theme/app_typography.dart';

enum DqmsToastType { info, success, warning, error }

/// ============================================================================
/// DQMS ENTERPRISE TOAST & SNACKBAR UTILITY
/// Standardized toast notifications matching Command Center theme
/// ============================================================================
class DqmsToast {
  DqmsToast._();

  static void show(
    BuildContext context, {
    required String message,
    DqmsToastType type = DqmsToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    Color bg;
    Color border;
    IconData icon;

    switch (type) {
      case DqmsToastType.info:
        bg = AppColors.bgSurface;
        border = AppColors.brandPrimary;
        icon = Icons.info_outline_rounded;
        break;
      case DqmsToastType.success:
        bg = AppColors.statusActive.withValues(alpha: 0.15);
        border = AppColors.statusActive;
        icon = Icons.check_circle_outline_rounded;
        break;
      case DqmsToastType.warning:
        bg = AppColors.statusWarning.withValues(alpha: 0.15);
        border = AppColors.statusWarning;
        icon = Icons.warning_amber_rounded;
        break;
      case DqmsToastType.error:
        bg = AppColors.statusDeactive.withValues(alpha: 0.15);
        border = AppColors.statusDeactive;
        icon = Icons.error_outline_rounded;
        break;
    }

    final snackBar = SnackBar(
      elevation: 4,
      backgroundColor: bg,
      duration: duration,
      margin: const EdgeInsets.all(AppSpacing.lg),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.borderSm,
        side: BorderSide(color: border),
      ),
      content: Row(
        children: [
          Icon(icon, color: border, size: 18),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textMain),
            ),
          ),
        ],
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
