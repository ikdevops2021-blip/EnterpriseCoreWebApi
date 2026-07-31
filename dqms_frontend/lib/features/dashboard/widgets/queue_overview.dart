import 'package:flutter/material.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/features/dashboard/providers/dashboard_provider.dart';

/// ============================================================================
/// QUEUE OVERVIEW PANEL
/// Displays real-time Queue Density by Zone and Priority Tier breakdown
/// ============================================================================
class QueueOverviewPanel extends StatelessWidget {
  final DashboardState state;

  const QueueOverviewPanel({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final totalWaiting = state.waitingCustomers;

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
          // Header Bar
          Row(
            children: [
              const Icon(Icons.hub_rounded, color: AppColors.brandPrimary, size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'LIVE QUEUE DENSITY BY ZONE',
                  style: TextStyle(
                    color: AppColors.textMain,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$totalWaiting Total Waiting',
                  style: const TextStyle(
                    color: AppColors.brandPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Zone Breakdown Bars
          ...state.queueDensityByArea.entries.map((entry) {
            final areaName = entry.key;
            final count = entry.value;
            final pct = totalWaiting > 0 ? (count / totalWaiting) : 0.0;
            final isHighDensity = count > 20;
            final statusColor = isHighDensity ? AppColors.statusDeactive : (count > 10 ? AppColors.statusWarning : AppColors.statusActive);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          areaName,
                          style: const TextStyle(
                            color: AppColors.textMain,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '$count waiting',
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${(pct * 100).toStringAsFixed(0)}%)',
                        style: const TextStyle(
                          color: AppColors.textSubtle,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Stack(
                    children: [
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.bgSubtle,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: pct.clamp(0.0, 1.0),
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),

          const Divider(color: AppColors.borderSubtle, height: 20),

          // Priority Tier Distribution Summary
          const Text(
            'PRIORITY TIER DISTRIBUTION',
            style: TextStyle(
              color: AppColors.textSubtle,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(child: _buildTierChip('Regular (Standard)', '38', AppColors.brandPrimary)),
              const SizedBox(width: 8),
              Expanded(child: _buildTierChip('Elderly / Assist', '13', AppColors.statusWarning)),
              const SizedBox(width: 8),
              Expanded(child: _buildTierChip('VIP Platinum', '6', AppColors.statusSpecial)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTierChip(String label, String count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
