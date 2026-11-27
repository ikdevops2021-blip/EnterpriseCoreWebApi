import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/core/theme/app_decorations.dart';
import 'package:dqms_frontend/core/widgets/glass_widgets.dart';
import 'package:dqms_frontend/features/dashboard/models/tat_analytics_dto.dart';
import 'package:dqms_frontend/features/dashboard/providers/dashboard_provider.dart';

/// ============================================================================
/// 2D BOTTLENECK HEATMAP MATRIX WIDGET
/// Slices queue congestion across Hour-of-Day and Days/Processes/Counters
/// ============================================================================
class BottleneckHeatmapMatrix extends ConsumerWidget {
  final BottleneckHeatmapDto heatmap;

  const BottleneckHeatmapMatrix({
    super.key,
    required this.heatmap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentDimension = heatmap.dimensionType;
    final cells = heatmap.cells;

    // Distinct Y dimensions (Labels)
    final yLabels = cells.map((c) => c.dimensionLabel).toSet().toList();
    // Distinct X hours
    final xHours = cells.map((c) => c.hourOfDay).toSet().toList()..sort();

    return GlassContainer(
      padding: const EdgeInsets.all(18),
      borderRadius: AppRadius.card,
      borderColor: AppColors.statusWarning.withValues(alpha: 0.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Row
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              const FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.grid_on_rounded, color: AppColors.statusWarning, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'BOTTLENECK CONGESTION HEATMAP',
                      style: TextStyle(
                        color: AppColors.textMain,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              // Peak Congestion Badge
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.statusDeactive.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.statusDeactive.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_fire_department_rounded, size: 14, color: AppColors.statusDeactive),
                      const SizedBox(width: 4),
                      Text(
                        'Peak: ${heatmap.peakCongestionLabel} (${heatmap.peakCongestionScore}%)',
                        style: const TextStyle(
                          color: AppColors.statusDeactive,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Dimension Slicing Controls (Segmented Control)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildDimensionButton(ref, 'HourByDayOfWeek', 'By Day of Week', currentDimension == 'HourByDayOfWeek'),
                const SizedBox(width: 8),
                _buildDimensionButton(ref, 'HourByProcess', 'By Service Process', currentDimension == 'HourByProcess'),
                const SizedBox(width: 8),
                _buildDimensionButton(ref, 'HourByCounter', 'By Counter Station', currentDimension == 'HourByCounter'),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 2D Scrollable Matrix Canvas
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header: Hours row
                Row(
                  children: [
                    // Empty Top-Left Cell for Y-axis Labels
                    Container(
                      width: 130,
                      height: 28,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        currentDimension == 'HourByDayOfWeek'
                            ? 'DAY \\ HOUR'
                            : (currentDimension == 'HourByProcess' ? 'PROCESS \\ HOUR' : 'COUNTER \\ HOUR'),
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textSubtle,
                        ),
                      ),
                    ),
                    ...xHours.map((h) {
                      return Container(
                        width: 44,
                        height: 28,
                        alignment: Alignment.center,
                        child: Text(
                          '${h.toString().padLeft(2, '0')}:00',
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 4),

                // Matrix Rows
                ...yLabels.map((yLabel) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        // Left Y-axis Label
                        Container(
                          width: 130,
                          height: 32,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            yLabel,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMain,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Cells for each hour
                        ...xHours.map((h) {
                          final cell = cells.firstWhere(
                            (c) => c.dimensionLabel == yLabel && c.hourOfDay == h,
                            orElse: () => HeatmapCellDto(
                              hourOfDay: h,
                              dimensionKey: 0,
                              dimensionLabel: yLabel,
                              tokenCount: 0,
                              avgWaitMinutes: 0.0,
                              avgServiceMinutes: 0.0,
                              avgTatMinutes: 0.0,
                              variancePercentage: 0.0,
                              congestionScore: 0,
                              congestionLevel: 'LOW',
                            ),
                          );

                          return _buildHeatmapCell(context, cell);
                        }),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Legend
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 12,
            runSpacing: 6,
            children: [
              _buildLegendItem(AppColors.statusActive, 'Normal (<5m)'),
              _buildLegendItem(AppColors.statusWarning, 'Moderate (5-10m)'),
              _buildLegendItem(Colors.orange, 'High (10-20m)'),
              _buildLegendItem(AppColors.statusDeactive, 'Critical (>20m)'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDimensionButton(WidgetRef ref, String dimension, String title, bool isSelected) {
    return InkWell(
      onTap: () {
        ref.read(dashboardStateProvider.notifier).switchHeatmapDimension(dimension);
      },
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandPrimary.withValues(alpha: 0.2) : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: isSelected ? AppColors.brandPrimary : AppColors.borderSubtle,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.brandPrimary : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildHeatmapCell(BuildContext context, HeatmapCellDto cell) {
    final score = cell.congestionScore;
    Color cellColor;
    if (score >= 75) {
      cellColor = AppColors.statusDeactive;
    } else if (score >= 50) {
      cellColor = Colors.orange;
    } else if (score >= 25) {
      cellColor = AppColors.statusWarning;
    } else {
      cellColor = AppColors.statusActive;
    }

    final double alpha = (score / 100.0).clamp(0.2, 0.95);

    return InkWell(
      onTap: () => _showCellDetails(context, cell),
      child: Container(
        width: 44,
        height: 32,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          color: cell.tokenCount == 0 ? AppColors.bgSubtle.withValues(alpha: 0.3) : cellColor.withValues(alpha: alpha),
          borderRadius: BorderRadius.circular(3),
          border: Border.all(
            color: cellColor.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          cell.tokenCount == 0 ? '-' : '${cell.avgWaitMinutes.toStringAsFixed(0)}m',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: alpha > 0.6 ? Colors.white : AppColors.textMain,
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textSubtle),
        ),
      ],
    );
  }

  void _showCellDetails(BuildContext context, HeatmapCellDto cell) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.bgCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
          title: Row(
            children: [
              const Icon(Icons.analytics_outlined, color: AppColors.brandPrimary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${cell.dimensionLabel} @ ${cell.hourOfDay}:00',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textMain),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Congestion Level', cell.congestionLevel, isPill: true),
              const SizedBox(height: 8),
              _buildDetailRow('Congestion Score', '${cell.congestionScore} / 100'),
              _buildDetailRow('Tokens Processed', '${cell.tokenCount} tokens'),
              _buildDetailRow('Average Wait Time', '${cell.avgWaitMinutes.toStringAsFixed(1)} minutes'),
              _buildDetailRow('Average Service Time', '${cell.avgServiceMinutes.toStringAsFixed(1)} minutes'),
              _buildDetailRow('Average Turnaround Time', '${cell.avgTatMinutes.toStringAsFixed(1)} minutes'),
              _buildDetailRow(
                'TAT Variance from SLA',
                '${cell.variancePercentage > 0 ? "+" : ""}${cell.variancePercentage.toStringAsFixed(1)}%',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close', style: TextStyle(color: AppColors.brandPrimary)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isPill = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          if (isPill)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: (value == 'CRITICAL' ? AppColors.statusDeactive : AppColors.statusActive).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: value == 'CRITICAL' ? AppColors.statusDeactive : AppColors.statusActive,
                ),
              ),
            )
          else
            Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMain)),
        ],
      ),
    );
  }
}
