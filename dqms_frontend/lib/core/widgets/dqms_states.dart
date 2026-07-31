import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';
import '../theme/app_typography.dart';
import 'dqms_button.dart';

/// ============================================================================
/// DQMS ENTERPRISE STATE COMPONENTS
/// Standardized Empty, Loading, Error, and Offline States
/// ============================================================================

/// Loading State Spinner Widget
class DqmsLoadingState extends StatelessWidget {
  final String? message;

  const DqmsLoadingState({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.brandPrimary, strokeWidth: 2.5),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(message!, style: AppTypography.bodySmall),
          ],
        ],
      ),
    );
  }
}

/// Empty State Widget
class DqmsEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const DqmsEmptyState({
    super.key,
    this.title = 'No Records Found',
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.textSubtle, size: 48),
            const SizedBox(height: AppSpacing.md),
            Text(title, style: AppTypography.titleMedium.copyWith(color: AppColors.textMuted)),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              DqmsButton(
                label: actionLabel!,
                variant: DqmsButtonVariant.primary,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Error State Widget
class DqmsErrorState extends StatelessWidget {
  final String errorMessage;
  final VoidCallback? onRetry;

  const DqmsErrorState({
    super.key,
    required this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.statusDeactive.withValues(alpha: 0.1),
          borderRadius: AppRadius.borderMd,
          border: Border.all(color: AppColors.statusDeactive.withValues(alpha: 0.4)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.statusDeactive, size: 36),
            const SizedBox(height: AppSpacing.md),
            Text('Operational Exception', style: AppTypography.titleSmall.copyWith(color: AppColors.statusDeactive)),
            const SizedBox(height: AppSpacing.xs),
            Text(errorMessage, textAlign: TextAlign.center, style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.md),
              DqmsButton(
                label: 'Retry Connection',
                variant: DqmsButtonVariant.outline,
                icon: Icons.refresh_rounded,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Offline State Alert Banner Widget
class DqmsOfflineStateBanner extends StatelessWidget {
  final String message;

  const DqmsOfflineStateBanner({
    super.key,
    this.message = 'System running in offline local mode. Changes will sync when online.',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.statusWarning.withValues(alpha: 0.15),
        border: Border.all(color: AppColors.statusWarning.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded, color: AppColors.statusWarning, size: 16),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySmall.copyWith(color: AppColors.statusWarning, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
