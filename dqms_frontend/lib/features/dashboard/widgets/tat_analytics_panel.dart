import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/core/theme/app_decorations.dart';
import 'package:dqms_frontend/core/widgets/glass_widgets.dart';
import 'package:dqms_frontend/features/dashboard/models/tat_analytics_dto.dart';
import 'package:dqms_frontend/features/dashboard/providers/dashboard_provider.dart';

/// ============================================================================
/// TAT & SLA VARIANCE ANALYTICS PANEL
/// Visualizes Turnaround Times, Variance %, StdDev, P95, and SLA Compliance
/// ============================================================================
class TatAnalyticsPanel extends StatelessWidget {
  final List<TatAnalyticsItem>? tatItems;
  final TatVarianceReportDto? report;

  const TatAnalyticsPanel({
    super.key,
    this.tatItems,
    this.report,
  });

  @override
  Widget build(BuildContext context) {
    final varianceReport = report ?? TatVarianceReportDto.mock();
    final summary = varianceReport.summary;
    final breakdown = varianceReport.processBreakdown;

    final isOverSla = summary.variancePercentage > 0;
    final overallVarianceColor = summary.variancePercentage > 20
        ? AppColors.statusDeactive
        : (isOverSla ? AppColors.statusWarning : AppColors.statusActive);

    return GlassContainer(
      padding: const EdgeInsets.all(18),
      borderRadius: AppRadius.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Row
          Row(
            children: [
              const Icon(Icons.speed_rounded, color: AppColors.brandPrimary, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'TAT VARIANCE & SLA COMPLIANCE',
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
                  color: overallVarianceColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isOverSla ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                      color: overallVarianceColor,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${summary.variancePercentage > 0 ? "+" : ""}${summary.variancePercentage.toStringAsFixed(1)}% Variance',
                      style: TextStyle(
                        color: overallVarianceColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Executive Dispersion Metrics Strip (P95, StdDev, SLA Pass)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bgSurface.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              children: [
                Expanded(child: _buildStatPill('P95 TAT', '${summary.p95TatMinutes.toStringAsFixed(1)}m', Icons.query_builder_rounded)),
                Container(width: 1, height: 26, color: AppColors.borderSubtle),
                Expanded(child: _buildStatPill('StdDev (σ)', '±${summary.stdDevMinutes.toStringAsFixed(1)}m', Icons.show_chart_rounded)),
                Container(width: 1, height: 26, color: AppColors.borderSubtle),
                Expanded(child: _buildStatPill('SLA Pass', '${summary.slaPassPercentage.toStringAsFixed(1)}%', Icons.check_circle_outline_rounded)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Process Breakdown List
          ...breakdown.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            final isItemOverSla = item.variancePercentage > 0;
            final itemColor = item.variancePercentage > 20
                ? AppColors.statusDeactive
                : (isItemOverSla ? AppColors.statusWarning : AppColors.statusActive);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.brandPrimary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Text(
                                item.processCode,
                                style: const TextStyle(
                                  color: AppColors.brandPrimary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              item.processName,
                              style: const TextStyle(
                                color: AppColors.textMain,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Target ${item.targetTATMinutes}m | Actual ${item.actualTatMinutes.toStringAsFixed(1)}m',
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: itemColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${item.variancePercentage > 0 ? "+" : ""}${item.variancePercentage.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  color: itemColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Progress Bar with smooth animation
                  Stack(
                    children: [
                      Container(
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColors.bgSubtle,
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: (item.slaPassRate / 100.0).clamp(0.0, 1.0),
                        child: Container(
                          height: 5,
                          decoration: BoxDecoration(
                            color: itemColor,
                            borderRadius: BorderRadius.circular(2.5),
                          ),
                        ),
                      )
                          .animate()
                          .scaleX(
                            begin: 0,
                            end: 1,
                            alignment: Alignment.centerLeft,
                            duration: 500.ms,
                            delay: (50 * i).ms,
                            curve: Curves.easeOutCubic,
                          ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatPill(String label, String value, IconData icon) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 10, color: AppColors.textSubtle, fontWeight: FontWeight.w500),
              ),
              Text(
                value,
                style: const TextStyle(fontSize: 12, color: AppColors.textMain, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
