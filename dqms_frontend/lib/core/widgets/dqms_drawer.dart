import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';
import '../theme/app_typography.dart';

/// ============================================================================
/// DQMS ENTERPRISE CONTEXTUAL DRAWER COMPONENT
/// Side panel drawer container for filter options and contextual details
/// ============================================================================
class DqmsDrawer extends StatelessWidget {
  final String title;
  final Widget child;
  final double width;

  const DqmsDrawer({
    super.key,
    required this.title,
    required this.child,
    this.width = 360,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: width,
      backgroundColor: AppColors.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.md),
          bottomLeft: Radius.circular(AppRadius.md),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            decoration: const BoxDecoration(
              color: AppColors.bgHeader,
              border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
            ),
            child: Row(
              children: [
                Text(title, style: AppTypography.titleMedium),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textSubtle, size: 18),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          // Drawer Body
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
