import 'package:flutter/material.dart';
import '../enums/dqms_enums.dart';
import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';
import '../theme/app_typography.dart';

/// ============================================================================
/// DQMS ENTERPRISE STATUS BADGE COMPONENT
/// Standardized status indicator pill mapping ConfigParameter enums & active states
/// ============================================================================
class DqmsStatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const DqmsStatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  /// Factory constructor for Active / Deactive status
  factory DqmsStatusBadge.activeState(bool isActive) {
    return DqmsStatusBadge(
      label: isActive ? 'Active' : 'Deactive',
      color: isActive ? AppColors.statusActive : AppColors.statusDeactive,
      icon: isActive ? Icons.check_circle_outline_rounded : Icons.cancel_outlined,
    );
  }

  /// Factory constructor for Token Status enum (Category 18)
  factory DqmsStatusBadge.fromTokenStatus(e_TokenStatus status) {
    switch (status) {
      case e_TokenStatus.queued:
        return const DqmsStatusBadge(label: 'Queued', color: AppColors.textSubtle, icon: Icons.inbox_rounded);
      case e_TokenStatus.waiting:
        return const DqmsStatusBadge(label: 'Waiting', color: AppColors.statusWarning, icon: Icons.hourglass_empty_rounded);
      case e_TokenStatus.calling:
        return const DqmsStatusBadge(label: 'Calling', color: AppColors.brandPrimary, icon: Icons.campaign_rounded);
      case e_TokenStatus.active:
        return const DqmsStatusBadge(label: 'Active Serving', color: AppColors.statusActive, icon: Icons.play_arrow_rounded);
      case e_TokenStatus.hold:
        return const DqmsStatusBadge(label: 'On Hold', color: AppColors.statusSpecial, icon: Icons.pause_rounded);
      case e_TokenStatus.canceled:
        return const DqmsStatusBadge(label: 'Canceled', color: AppColors.statusDeactive, icon: Icons.close_rounded);
      case e_TokenStatus.completed:
        return const DqmsStatusBadge(label: 'Completed', color: AppColors.statusActive, icon: Icons.check_circle_rounded);
      case e_TokenStatus.forwarded:
        return const DqmsStatusBadge(label: 'Forwarded', color: AppColors.brandAccent, icon: Icons.forward_rounded);
    }
  }

  /// Factory constructor for Priority Tier enum (Category 19)
  factory DqmsStatusBadge.fromPriorityTier(int priorityValue) {
    if (priorityValue == e_PriorityTier.vip.value) {
      return const DqmsStatusBadge(label: 'VIP', color: AppColors.statusSpecial, icon: Icons.star_rounded);
    } else if (priorityValue == e_PriorityTier.emergency.value) {
      return const DqmsStatusBadge(label: 'Emergency', color: AppColors.statusDeactive, icon: Icons.warning_rounded);
    } else if (priorityValue == e_PriorityTier.seniorCitizen.value) {
      return const DqmsStatusBadge(label: 'Senior', color: AppColors.brandAccent, icon: Icons.elderly_rounded);
    } else if (priorityValue == e_PriorityTier.disabled.value) {
      return const DqmsStatusBadge(label: 'Disability', color: AppColors.statusWarning, icon: Icons.accessible_rounded);
    } else {
      return const DqmsStatusBadge(label: 'Standard', color: AppColors.textSubtle);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Status: $label',
      readOnly: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: AppRadius.borderXs,
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 12, color: color),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: AppTypography.tableHeader.copyWith(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
