import 'package:flutter/material.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/features/dashboard/providers/dashboard_provider.dart';

/// ============================================================================
/// DASHBOARD KPI STRIP — ASYMMETRIC COMMAND CENTER METRIC BAR
/// High-density operational metric cards built with dark command center aesthetics
/// ============================================================================
class DashboardKpiStrip extends StatelessWidget {
  final DashboardState state;

  const DashboardKpiStrip({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Adapt card layout based on container width
        final isWide = constraints.maxWidth >= 900;
        final isMedium = constraints.maxWidth >= 600 && constraints.maxWidth < 900;

        if (isWide) {
          return Row(
            children: [
              Expanded(flex: 3, child: _buildPrimaryCard('WAITING CUSTOMERS', '${state.waitingCustomers}', state.waitingTrend, Icons.people_alt_rounded, AppColors.statusWarning, 'Live Queue Load')),
              const SizedBox(width: 12),
              Expanded(flex: 3, child: _buildPrimaryCard('CURRENTLY SERVING', '${state.currentlyServing}', '${state.activeCounters}/${state.totalCounters} Counters', Icons.record_voice_over_rounded, AppColors.brandPrimary, 'Active Dispatch')),
              const SizedBox(width: 12),
              Expanded(flex: 3, child: _buildAlertCard('SLA BREACHES TODAY', '${state.slaBreachesToday}', 'Attention Needed', Icons.warning_amber_rounded, AppColors.statusDeactive)),
              const SizedBox(width: 12),
              Expanded(flex: 4, child: _buildDualMetricCard('AVG WAIT TIME', '${state.avgWaitTimeMins}m', 'AVG SERVICE', '${state.avgServiceTimeMins}m', Icons.timer_outlined, AppColors.brandAccent)),
              const SizedBox(width: 12),
              Expanded(flex: 3, child: _buildPrimaryCard('COMPLETED TODAY', '${state.completedToday}', '99.2% Succeeded', Icons.check_circle_rounded, AppColors.statusActive, 'Daily Volume')),
            ],
          );
        } else if (isMedium) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildPrimaryCard('WAITING CUSTOMERS', '${state.waitingCustomers}', state.waitingTrend, Icons.people_alt_rounded, AppColors.statusWarning, 'Live Queue Load')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildPrimaryCard('CURRENTLY SERVING', '${state.currentlyServing}', '${state.activeCounters}/${state.totalCounters} Counters', Icons.record_voice_over_rounded, AppColors.brandPrimary, 'Active Dispatch')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildAlertCard('SLA BREACHES TODAY', '${state.slaBreachesToday}', 'Attention Needed', Icons.warning_amber_rounded, AppColors.statusDeactive)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildDualMetricCard('AVG WAIT TIME', '${state.avgWaitTimeMins}m', 'AVG SERVICE', '${state.avgServiceTimeMins}m', Icons.timer_outlined, AppColors.brandAccent)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildPrimaryCard('COMPLETED TODAY', '${state.completedToday}', '99.2% Succeeded', Icons.check_circle_rounded, AppColors.statusActive, 'Daily Volume')),
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
                SizedBox(width: 220, child: _buildPrimaryCard('WAITING CUSTOMERS', '${state.waitingCustomers}', state.waitingTrend, Icons.people_alt_rounded, AppColors.statusWarning, 'Live Queue Load')),
                const SizedBox(width: 10),
                SizedBox(width: 220, child: _buildPrimaryCard('CURRENTLY SERVING', '${state.currentlyServing}', '${state.activeCounters}/${state.totalCounters} Counters', Icons.record_voice_over_rounded, AppColors.brandPrimary, 'Active Dispatch')),
                const SizedBox(width: 10),
                SizedBox(width: 220, child: _buildAlertCard('SLA BREACHES TODAY', '${state.slaBreachesToday}', 'Attention Needed', Icons.warning_amber_rounded, AppColors.statusDeactive)),
                const SizedBox(width: 10),
                SizedBox(width: 260, child: _buildDualMetricCard('AVG WAIT TIME', '${state.avgWaitTimeMins}m', 'AVG SERVICE', '${state.avgServiceTimeMins}m', Icons.timer_outlined, AppColors.brandAccent)),
                const SizedBox(width: 10),
                SizedBox(width: 220, child: _buildPrimaryCard('COMPLETED TODAY', '${state.completedToday}', '99.2% Succeeded', Icons.check_circle_rounded, AppColors.statusActive, 'Daily Volume')),
              ],
            ),
          );
        }
      },
    );
  }

  /// Single Primary Operational Card
  Widget _buildPrimaryCard(String label, String value, String subtext, IconData icon, Color color, String subtitle) {
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
          // Top Gradient Glow Stroke
          Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color,
                  color.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: AppColors.textSubtle,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        value,
                        style: const TextStyle(
                          color: AppColors.textMain,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          subtext,
                          style: TextStyle(
                            color: color,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Alert / Incident Card
  Widget _buildAlertCard(String label, String value, String subtext, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  subtext,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Target Sla: 0 Breaches',
            style: TextStyle(
              color: AppColors.textSubtle,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  /// Dual Metric Card (Wait + Service Time side-by-side)
  Widget _buildDualMetricCard(String label1, String val1, String label2, String val2, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'HANDLING TAT PERFORMANCE',
                  style: TextStyle(
                    color: AppColors.textSubtle,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      val1,
                      style: const TextStyle(
                        color: AppColors.textMain,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      label1,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(height: 28, width: 1, color: AppColors.borderSubtle),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      val2,
                      style: const TextStyle(
                        color: AppColors.statusActive,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      label2,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 9,
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
    );
  }
}
