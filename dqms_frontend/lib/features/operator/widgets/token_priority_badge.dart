import 'package:flutter/material.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/features/operator/providers/operator_console_provider.dart';

/// ============================================================================
/// REUSABLE TOKEN PRIORITY BADGE (TokenPriorityBadge)
/// Distinctive color-coded pills for ticket priority tiers
/// ============================================================================
class TokenPriorityBadge extends StatelessWidget {
  final TokenPriority priority;

  const TokenPriorityBadge({
    super.key,
    required this.priority,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    IconData icon;

    switch (priority) {
      case TokenPriority.vip:
        color = AppColors.statusSpecial;
        label = 'VIP PRIORITY';
        icon = Icons.star_rounded;
        break;
      case TokenPriority.emergency:
        color = AppColors.statusDeactive;
        label = 'EMERGENCY';
        icon = Icons.warning_rounded;
        break;
      case TokenPriority.senior:
        color = AppColors.brandAccent;
        label = 'SENIOR ASSIST';
        icon = Icons.elderly_rounded;
        break;
      case TokenPriority.disability:
        color = AppColors.statusWarning;
        label = 'ACCESSIBILITY';
        icon = Icons.accessible_rounded;
        break;
      case TokenPriority.standard:
        color = AppColors.textSubtle;
        label = 'STANDARD';
        icon = Icons.confirmation_number_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 12),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
