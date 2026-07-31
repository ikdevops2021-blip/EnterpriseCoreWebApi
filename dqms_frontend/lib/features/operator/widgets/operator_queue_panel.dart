import 'package:flutter/material.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/features/operator/providers/operator_console_provider.dart';
import 'package:dqms_frontend/features/operator/widgets/token_priority_badge.dart';

/// ============================================================================
/// OPERATOR QUEUE PANEL (OperatorQueuePanel)
/// Live queue density list showing waiting tokens, priority tiers, & wait times
/// ============================================================================
class OperatorQueuePanel extends StatelessWidget {
  final List<OperatorQueueItem> queueItems;

  const OperatorQueuePanel({
    super.key,
    required this.queueItems,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.people_outline_rounded, color: AppColors.brandPrimary, size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'WAITING QUEUE DENSITY',
                  style: TextStyle(
                    color: AppColors.textMain,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.brandPrimary.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '${queueItems.length} Waiting',
                  style: const TextStyle(
                    color: AppColors.brandPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Queue List View
          if (queueItems.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: const Center(
                child: Column(
                  children: [
                    Icon(Icons.check_circle_outline_rounded, color: AppColors.statusActive, size: 32),
                    SizedBox(height: 8),
                    Text(
                      'No Customers Waiting',
                      style: TextStyle(color: AppColors.statusActive, fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'All queue requests in this zone are clear.',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: queueItems.length,
              separatorBuilder: (_, _) => const Divider(color: AppColors.borderSubtle, height: 8),
              itemBuilder: (ctx, i) {
                final item = queueItems[i];

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      // Position Index
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: AppColors.bgSubtle,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${i + 1}',
                            style: const TextStyle(
                              color: AppColors.textSubtle,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Token Number
                      Text(
                        item.tokenNumber,
                        style: const TextStyle(
                          color: AppColors.brandPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Priority Badge
                      Flexible(
                        child: TokenPriorityBadge(priority: item.priority),
                      ),

                      const Spacer(),

                      // Wait Time Duration
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'WAIT TIME',
                            style: TextStyle(color: AppColors.textSubtle, fontSize: 9, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            '${item.waitTimeMinutes}m 00s',
                            style: TextStyle(
                              color: item.waitTimeMinutes > 15 ? AppColors.statusDeactive : AppColors.textMain,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
