import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';
import '../theme/app_typography.dart';
import 'dqms_button.dart';

/// ============================================================================
/// DQMS ENTERPRISE DIALOG COMPONENT
/// Command center modal dialog wrapper
/// ============================================================================
class DqmsDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final String? confirmLabel;
  final String cancelLabel;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isConfirmLoading;
  final double width;

  const DqmsDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmLabel = 'Save Master',
    this.cancelLabel = 'Cancel',
    this.onConfirm,
    this.onCancel,
    this.isConfirmLoading = false,
    this.width = 420,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.bgSurface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.borderMd,
        side: const BorderSide(color: AppColors.borderSubtle),
      ),
      titlePadding: const EdgeInsets.all(AppSpacing.lg),
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      actionsPadding: const EdgeInsets.all(AppSpacing.lg),
      title: Row(
        children: [
          Text(title, style: AppTypography.titleMedium),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textSubtle),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      content: SizedBox(
        width: width,
        child: content,
      ),
      actions: [
        DqmsButton(
          label: cancelLabel,
          variant: DqmsButtonVariant.ghost,
          onPressed: onCancel ?? () => Navigator.of(context).pop(),
        ),
        if (confirmLabel != null)
          DqmsButton(
            label: confirmLabel!,
            variant: DqmsButtonVariant.primary,
            isLoading: isConfirmLoading,
            onPressed: onConfirm,
          ),
      ],
    );
  }
}
