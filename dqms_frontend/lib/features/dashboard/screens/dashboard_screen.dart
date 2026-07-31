import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/core/theme/app_breakpoints.dart';
import 'package:dqms_frontend/features/dashboard/providers/dashboard_provider.dart';
import 'package:dqms_frontend/features/dashboard/widgets/dashboard_header.dart';
import 'package:dqms_frontend/features/dashboard/widgets/dashboard_kpi_strip.dart';
import 'package:dqms_frontend/features/dashboard/widgets/queue_overview.dart';
import 'package:dqms_frontend/features/dashboard/widgets/counter_status_panel.dart';
import 'package:dqms_frontend/features/dashboard/widgets/queue_trend_chart.dart';
import 'package:dqms_frontend/features/dashboard/widgets/tat_analytics_panel.dart';
import 'package:dqms_frontend/features/dashboard/widgets/bottleneck_panel.dart';
import 'package:dqms_frontend/features/dashboard/widgets/recent_activity_panel.dart';

/// ============================================================================
/// COMMAND CENTER DASHBOARD SCREEN
/// Master responsive operational command center UI for DQMS Enterprise
/// ============================================================================
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardStateProvider);

    return Scaffold(
      backgroundColor: AppColors.bgCanvas,
      body: SafeArea(
        child: Column(
          children: [
            // Fixed Command Header
            const DashboardHeader(),

            // Offline/Notice Banner if API network is disconnected
            if (state.isOffline || state.errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                color: AppColors.statusWarning.withValues(alpha: 0.15),
                child: Row(
                  children: [
                    const Icon(Icons.wifi_off_rounded, color: AppColors.statusWarning, size: 14),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.errorMessage ?? 'Offline Mode: Displaying live cached snapshot.',
                        style: const TextStyle(
                          color: AppColors.statusWarning,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

            // Responsive Scrollable Dashboard Canvas
            Expanded(
              child: DqmsResponsiveLayout(
                desktop: _buildDesktopLayout(state),
                tablet: _buildTabletLayout(state),
                mobile: _buildMobileLayout(state),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Desktop Layout (Multi-Region Asymmetric Grid)
  Widget _buildDesktopLayout(DashboardState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top KPI Metric Strip
          DashboardKpiStrip(state: state),
          const SizedBox(height: 20),

          // Multi-Region Body Layout
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Operational Region (7 flex)
              Expanded(
                flex: 7,
                child: Column(
                  children: [
                    QueueTrendChart(trendData: state.queueTrend),
                    const SizedBox(height: 20),
                    CounterStatusPanel(state: state),
                    const SizedBox(height: 20),
                    BottleneckPanel(alerts: state.activeBottlenecks),
                  ],
                ),
              ),
              const SizedBox(width: 20),

              // Right Analytics Region (5 flex)
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    QueueOverviewPanel(state: state),
                    const SizedBox(height: 20),
                    TatAnalyticsPanel(tatItems: state.tatAnalytics),
                    const SizedBox(height: 20),
                    RecentActivityPanel(activities: state.recentActivities),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Tablet Layout (Dual-Column Stack)
  Widget _buildTabletLayout(DashboardState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardKpiStrip(state: state),
          const SizedBox(height: 16),
          BottleneckPanel(alerts: state.activeBottlenecks),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    QueueTrendChart(trendData: state.queueTrend),
                    const SizedBox(height: 16),
                    CounterStatusPanel(state: state),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    QueueOverviewPanel(state: state),
                    const SizedBox(height: 16),
                    TatAnalyticsPanel(tatItems: state.tatAnalytics),
                    const SizedBox(height: 16),
                    RecentActivityPanel(activities: state.recentActivities),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Mobile Layout (Single Column Prioritized Flow)
  Widget _buildMobileLayout(DashboardState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          DashboardKpiStrip(state: state),
          const SizedBox(height: 14),
          BottleneckPanel(alerts: state.activeBottlenecks),
          const SizedBox(height: 14),
          CounterStatusPanel(state: state),
          const SizedBox(height: 14),
          QueueOverviewPanel(state: state),
          const SizedBox(height: 14),
          QueueTrendChart(trendData: state.queueTrend),
          const SizedBox(height: 14),
          TatAnalyticsPanel(tatItems: state.tatAnalytics),
          const SizedBox(height: 14),
          RecentActivityPanel(activities: state.recentActivities),
        ],
      ),
    );
  }
}
