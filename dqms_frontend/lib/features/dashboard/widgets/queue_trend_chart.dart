import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/features/dashboard/providers/dashboard_provider.dart';

/// ============================================================================
/// QUEUE TREND CHART — HOURLY TRAFFIC & CAPACITY ANALYTICS
/// Interactive fl_chart illustrating hourly queue load vs served volume & capacity
/// ============================================================================
class QueueTrendChart extends StatelessWidget {
  final List<QueueTrendDataPoint> trendData;

  const QueueTrendChart({
    super.key,
    required this.trendData,
  });

  @override
  Widget build(BuildContext context) {
    if (trendData.isEmpty) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: const Center(
          child: Text('No trend data available for current shift', style: TextStyle(color: AppColors.textSubtle)),
        ),
      );
    }

    double maxY = 40;
    for (final dp in trendData) {
      if (dp.waitingCount > maxY) maxY = dp.waitingCount.toDouble();
      if (dp.servedCount > maxY) maxY = dp.servedCount.toDouble();
    }
    maxY = (maxY * 1.25).ceilToDouble();

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
                const SizedBox(height: 24),

                // Interactive FL Chart
                SizedBox(
                  height: 180,
                  child: LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: (trendData.length - 1).toDouble().clamp(1.0, 24.0),
                      minY: 0,
                      maxY: maxY,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: maxY > 60 ? 20 : 10,
                        getDrawingHorizontalLine: (val) => FlLine(
                          color: AppColors.borderSubtle.withValues(alpha: 0.4),
                          strokeWidth: 1,
                          dashArray: [4, 4],
                        ),
                      ),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 32,
                            interval: maxY > 60 ? 20 : 10,
                            getTitlesWidget: (val, meta) => Text(
                              val.toInt().toString(),
                              style: const TextStyle(
                                color: AppColors.textSubtle,
                                fontSize: 10,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 24,
                            interval: 1,
                            getTitlesWidget: (val, meta) {
                              final idx = val.toInt();
                              if (idx >= 0 && idx < trendData.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    trendData[idx].hour,
                                    style: const TextStyle(
                                      color: AppColors.textSubtle,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineTouchData: LineTouchData(
                        handleBuiltInTouches: true,
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              final isWaiting = spot.barIndex == 0;
                              final label = isWaiting ? 'Waiting' : 'Served';
                              final color = isWaiting ? AppColors.neonAmber : AppColors.neonEmerald;
                              return LineTooltipItem(
                                '$label: ${spot.y.toInt()}',
                                TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                      lineBarsData: [
                        // Series 1: Waiting Load (Neon Amber with smooth gradient area)
                        LineChartBarData(
                          spots: trendData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.waitingCount.toDouble())).toList(),
                          isCurved: true,
                          curveSmoothness: 0.35,
                          color: AppColors.neonAmber,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.neonAmber.withValues(alpha: 0.25),
                                AppColors.neonAmber.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                        // Series 2: Served Count (Neon Emerald with subtle area fill)
                        LineChartBarData(
                          spots: trendData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.servedCount.toDouble())).toList(),
                          isCurved: true,
                          curveSmoothness: 0.35,
                          color: AppColors.neonEmerald,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.neonEmerald.withValues(alpha: 0.2),
                                AppColors.neonEmerald.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
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
