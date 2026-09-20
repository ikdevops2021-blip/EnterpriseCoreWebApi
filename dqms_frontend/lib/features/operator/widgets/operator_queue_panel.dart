import 'package:flutter/material.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/core/theme/app_decorations.dart';
import 'package:dqms_frontend/core/widgets/glass_widgets.dart';
import 'package:dqms_frontend/features/operator/providers/operator_console_provider.dart';
import 'package:dqms_frontend/features/operator/widgets/token_priority_badge.dart';

/// ============================================================================
/// OPERATOR QUEUE PANEL (OperatorQueuePanel)
/// Live queue density list showing waiting tokens, priority tiers, & wait times
/// Modernized with luxury glass surface, neon badges & clean metrics
/// ============================================================================
class OperatorQueuePanel extends StatelessWidget {
  final List<OperatorQueueItem> queueItems;

  const OperatorQueuePanel({
    super.key,
    required this.queueItems,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(18),
      borderRadius: AppRadius.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const GlassSquircleIcon(
                icon: Icons.people_outline_rounded,
                backgroundColor: AppColors.darkBlueIconBg,
                iconColor: AppColors.cyanGlow,
                size: 34,
                iconSize: 18,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'WAITING QUEUE DENSITY',
                  style: TextStyle(
                    color: AppColors.textMain,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: AppColors.cyanGlow.withValues(alpha: 0.4)),
                ),
                child: Text(
                  '${queueItems.length} Waiting',
                  style: const TextStyle(
                    color: AppColors.cyanGlow,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Queue List View
          if (queueItems.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: const Center(
                child: Column(
                  children: [
                    Icon(Icons.check_circle_outline_rounded, color: AppColors.emeraldSuccess, size: 36),
                    SizedBox(height: 8),
                    Text(
                      'No Customers Waiting',
                      style: TextStyle(color: AppColors.emeraldSuccess, fontSize: 13, fontWeight: FontWeight.w800),
                    ),
                    SizedBox(height: 2),
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
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) {
                final item = queueItems[i];

                return GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  borderRadius: AppRadius.md,
                  child: Row(
                    children: [
                      // Position Index
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: AppColors.glassSurfaceDarkSubtle,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.glassBorderLight),
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
                          color: AppColors.cyanGlow,
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
