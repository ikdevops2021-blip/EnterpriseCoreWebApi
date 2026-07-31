import 'package:flutter/material.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/features/dashboard/providers/dashboard_provider.dart';

/// ============================================================================
/// QUEUE TREND CHART — HOURLY TRAFFIC & CAPACITY ANALYTICS
/// Visual chart illustrating hourly queue load vs served volume & capacity
/// ============================================================================
class QueueTrendChart extends StatelessWidget {
  final List<QueueTrendDataPoint> trendData;

  const QueueTrendChart({
    super.key,
    required this.trendData,
  });

  @override
  Widget build(BuildContext context) {
    // Determine max scale factor
    int maxVal = 80;
    for (final dp in trendData) {
      if (dp.waitingCount > maxVal) maxVal = dp.waitingCount;
      if (dp.servedCount > maxVal) maxVal = dp.servedCount;
    }

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Accent Glow Stroke
          Container(
            height: 2,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.brandPrimary,
                  AppColors.neonCyan,
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header & Legend Bar
                Row(
                  children: [
                    const Icon(Icons.show_chart_rounded, color: AppColors.neonCyan, size: 18),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'HOURLY QUEUE TRAFFIC & CAPACITY TREND',
                        style: TextStyle(
                          color: AppColors.textMain,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Legend
                    Flexible(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildLegendItem('Waiting', AppColors.neonAmber),
                            const SizedBox(width: 12),
                            _buildLegendItem('Served', AppColors.neonEmerald),
                            const SizedBox(width: 12),
                            _buildLegendItem('SLA Threshold', AppColors.statusDeactive, isLine: true),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Custom Bar Chart Area
                SizedBox(
                  height: 160,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: trendData.map((dp) {
                      final waitingHeightPct = (dp.waitingCount / maxVal).clamp(0.05, 1.0);
                      final servedHeightPct = (dp.servedCount / maxVal).clamp(0.05, 1.0);

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Stacked Dual Bars
                              Expanded(
                                child: Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    // Reference Capacity Threshold Line
                                    Positioned(
                                      top: (1.0 - (dp.capacityLimit / maxVal).clamp(0.0, 1.0)) * 120,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        height: 1,
                                        color: AppColors.statusDeactive.withValues(alpha: 0.4),
                                      ),
                                    ),

                                    // Bars Row
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Expanded(
                                          child: FractionallySizedBox(
                                            heightFactor: waitingHeightPct,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    AppColors.neonAmber,
                                                    AppColors.neonAmber.withValues(alpha: 0.4),
                                                  ],
                                                ),
                                                borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        Expanded(
                                          child: FractionallySizedBox(
                                            heightFactor: servedHeightPct,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    AppColors.neonEmerald,
                                                    AppColors.neonEmerald.withValues(alpha: 0.4),
                                                  ],
                                                ),
                                                borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                        const SizedBox(height: 8),
                        Text(
                          dp.hour,
                          style: const TextStyle(
                            color: AppColors.textSubtle,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, {bool isLine = false}) {
    return Row(
      children: [
        if (isLine)
          Container(width: 12, height: 2, color: color)
        else
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
