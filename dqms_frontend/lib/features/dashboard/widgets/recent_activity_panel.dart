import 'package:flutter/material.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/features/dashboard/providers/dashboard_provider.dart';

/// ============================================================================
/// RECENT ACTIVITY PANEL — LIVE OPERATIONAL LOG STREAM
/// Real-time stream of queue events, calls, SLA warnings, and status changes
/// ============================================================================
class RecentActivityPanel extends StatelessWidget {
  final List<OperationalActivityEntry> activities;

  const RecentActivityPanel({
    super.key,
    required this.activities,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.history_rounded, color: AppColors.brandPrimary, size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'RECENT OPERATIONAL ACTIVITY',
                  style: TextStyle(
                    color: AppColors.textMain,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.bgSubtle,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Live Stream',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Log Entries List
          ...activities.map((activity) {
            Color categoryColor;
            IconData categoryIcon;

            switch (activity.category) {
              case 'Call':
                categoryColor = AppColors.brandPrimary;
                categoryIcon = Icons.volume_up_rounded;
                break;
              case 'SLA':
                categoryColor = AppColors.statusDeactive;
                categoryIcon = Icons.error_outline_rounded;
                break;
              case 'Status':
                categoryColor = AppColors.statusWarning;
                categoryIcon = Icons.swap_horiz_rounded;
                break;
              case 'Issue':
                categoryColor = AppColors.statusDeactive;
                categoryIcon = Icons.warning_rounded;
                break;
              default:
                categoryColor = AppColors.textMuted;
                categoryIcon = Icons.info_outline_rounded;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(categoryIcon, color: categoryColor, size: 14),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                activity.title,
                                style: const TextStyle(
                                  color: AppColors.textMain,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Text(
                              activity.time,
                              style: const TextStyle(
                                color: AppColors.textSubtle,
                                fontSize: 10,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          activity.detail,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
