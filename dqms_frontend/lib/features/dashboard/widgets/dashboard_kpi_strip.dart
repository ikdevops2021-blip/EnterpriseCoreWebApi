import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/core/widgets/dqms_3d_card.dart';
import 'package:dqms_frontend/features/dashboard/providers/dashboard_provider.dart';

/// ============================================================================
/// DASHBOARD KPI STRIP — ASYMMETRIC COMMAND CENTER METRIC BAR
/// High-density operational metric cards built with dark command center aesthetics
/// ============================================================================
class DashboardKpiStrip extends StatelessWidget {
  final DashboardState state;

  const DashboardKpiStrip({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return _buildSkeletonKpiStrip();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Adapt card layout based on container width
        final isWide = constraints.maxWidth >= 900;
        final isMedium =
            constraints.maxWidth >= 600 && constraints.maxWidth < 900;

        if (isWide) {
          return Row(
            children: [
              Expanded(
                flex: 3,
                child: _buildPrimaryCard(
                  'WAITING CUSTOMERS',
                  '${state.waitingCustomers}',
                  state.waitingTrend,
                  Icons.people_alt_rounded,
                  AppColors.statusWarning,
                  'Live Queue Load',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: _buildPrimaryCard(
                  'CURRENTLY SERVING',
                  '${state.currentlyServing}',
                  '${state.activeCounters}/${state.totalCounters} Counters',
                  Icons.record_voice_over_rounded,
                  AppColors.brandPrimary,
                  'Active Dispatch',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: _buildAlertCard(
                  'SLA BREACHES TODAY',
                  '${state.slaBreachesToday}',
                  'Attention Needed',
                  Icons.warning_amber_rounded,
                  AppColors.statusDeactive,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 4,
                child: _buildDualMetricCard(
                  'AVG WAIT TIME',
                  '${state.avgWaitTimeMins}m',
                  'AVG SERVICE',
                  '${state.avgServiceTimeMins}m',
                  Icons.timer_outlined,
                  AppColors.brandAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: _buildPrimaryCard(
                  'COMPLETED TODAY',
                  '${state.completedToday}',
                  '99.2% Succeeded',
                  Icons.check_circle_rounded,
                  AppColors.statusActive,
                  'Daily Volume',
                ),
              ),
            ],
          );
        } else if (isMedium) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildPrimaryCard(
                      'WAITING CUSTOMERS',
                      '${state.waitingCustomers}',
                      state.waitingTrend,
                      Icons.people_alt_rounded,
                      AppColors.statusWarning,
                      'Live Queue Load',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPrimaryCard(
                      'CURRENTLY SERVING',
                      '${state.currentlyServing}',
                      '${state.activeCounters}/${state.totalCounters} Counters',
                      Icons.record_voice_over_rounded,
                      AppColors.brandPrimary,
                      'Active Dispatch',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildAlertCard(
                      'SLA BREACHES TODAY',
                      '${state.slaBreachesToday}',
                      'Attention Needed',
                      Icons.warning_amber_rounded,
                      AppColors.statusDeactive,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildDualMetricCard(
                      'AVG WAIT TIME',
                      '${state.avgWaitTimeMins}m',
                      'AVG SERVICE',
                      '${state.avgServiceTimeMins}m',
                      Icons.timer_outlined,
                      AppColors.brandAccent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPrimaryCard(
                      'COMPLETED TODAY',
                      '${state.completedToday}',
                      '99.2% Succeeded',
                      Icons.check_circle_rounded,
                      AppColors.statusActive,
                      'Daily Volume',
                    ),
                  ),
                ],
              ),
            ],
          );
        } else {
          // Mobile layout
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                SizedBox(
                  width: 220,
                  child: _buildPrimaryCard(
                    'WAITING CUSTOMERS',
                    '${state.waitingCustomers}',
                    state.waitingTrend,
                    Icons.people_alt_rounded,
                    AppColors.statusWarning,
                    'Live Queue Load',
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 220,
                  child: _buildPrimaryCard(
                    'CURRENTLY SERVING',
                    '${state.currentlyServing}',
                    '${state.activeCounters}/${state.totalCounters} Counters',
                    Icons.record_voice_over_rounded,
                    AppColors.brandPrimary,
                    'Active Dispatch',
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 220,
                  child: _buildAlertCard(
                    'SLA BREACHES TODAY',
                    '${state.slaBreachesToday}',
                    'Attention Needed',
                    Icons.warning_amber_rounded,
                    AppColors.statusDeactive,
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 260,
                  child: _buildDualMetricCard(
                    'AVG WAIT TIME',
                    '${state.avgWaitTimeMins}m',
                    'AVG SERVICE',
                    '${state.avgServiceTimeMins}m',
                    Icons.timer_outlined,
                    AppColors.brandAccent,
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 220,
                  child: _buildPrimaryCard(
                    'COMPLETED TODAY',
                    '${state.completedToday}',
                    '99.2% Succeeded',
                    Icons.check_circle_rounded,
                    AppColors.statusActive,
                    'Daily Volume',
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  /// Single Primary Operational Card (3D Sci-Fi Glass Panel)
  Widget _buildPrimaryCard(
    String label,
    String value,
    String subtext,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Dqms3dCard(
      accentColor: color,
      isScifiGlass: true,
      showCornerBrackets: true,
      enableTilt: true,
      isCompact: true,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Neon Glow Stroke
          Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color,
                  color.withValues(alpha: 0.35),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: AppColors.textSubtle,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.8),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          value,
                          key: ValueKey<String>(value),
                          style: const TextStyle(
                            color: AppColors.textMain,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: color.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Text(
                          subtext,
                          style: TextStyle(
                            color: color,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Alert / Incident Card (3D Sci-Fi Glass Panel)
  Widget _buildAlertCard(
    String label,
    String value,
    String subtext,
    IconData icon,
    Color color,
  ) {
    return Dqms3dCard(
      accentColor: color,
      isScifiGlass: true,
      showCornerBrackets: true,
      enableTilt: true,
      isCompact: true,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color,
                  color.withValues(alpha: 0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          color: color,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.8),
                            blurRadius: 5,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          value,
                          key: ValueKey<String>(value),
                          style: TextStyle(
                            color: color,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        subtext,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Target SLA: 0 Breaches',
                  style: TextStyle(color: AppColors.textSubtle, fontSize: 9.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Dual Metric Card (Wait + Service Time side-by-side with 3D Sci-Fi Glass)
  Widget _buildDualMetricCard(
    String label1,
    String val1,
    String label2,
    String val2,
    IconData icon,
    Color color,
  ) {
    return Dqms3dCard(
      accentColor: color,
      isScifiGlass: true,
      showCornerBrackets: true,
      enableTilt: true,
      isCompact: true,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color,
                  color.withValues(alpha: 0.35),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color, size: 16),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        'HANDLING TAT PERFORMANCE',
                        style: TextStyle(
                          color: AppColors.textSubtle,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              val1,
                              key: ValueKey<String>(val1),
                              style: const TextStyle(
                                color: AppColors.textMain,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Text(
                            label1,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 24,
                      width: 1,
                      color: AppColors.borderSubtle,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              val2,
                              key: ValueKey<String>(val2),
                              style: const TextStyle(
                                color: AppColors.statusActive,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Text(
                            label2,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Skeleton Shimmer Loading Strip
  Widget _buildSkeletonKpiStrip() {
    return Shimmer.fromColors(
      baseColor: AppColors.bgSurface,
      highlightColor: AppColors.bgCard,
      child: Row(
        children: List.generate(
          5,
          (i) => Expanded(
            child: Container(
              height: 100,
              margin: EdgeInsets.only(left: i == 0 ? 0 : 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
