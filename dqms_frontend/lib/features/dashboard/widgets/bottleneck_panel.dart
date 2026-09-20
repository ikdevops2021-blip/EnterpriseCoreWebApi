import 'package:flutter/material.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/core/theme/app_decorations.dart';
import 'package:dqms_frontend/core/widgets/glass_widgets.dart';
import 'package:dqms_frontend/features/dashboard/providers/dashboard_provider.dart';

/// ============================================================================
/// BOTTLENECK PANEL — OPERATIONAL DISPATCH & INCIDENT ALERTS
/// Identifies real-time queue congestion & extended handling bottlenecks
/// ============================================================================
class BottleneckPanel extends StatelessWidget {
  final List<BottleneckAlert> alerts;

  const BottleneckPanel({
    super.key,
    required this.alerts,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(18),
      borderRadius: AppRadius.card,
      borderColor: AppColors.statusDeactive.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.statusDeactive, size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'BOTTLENECK & CONGESTION ALERTS',
                  style: TextStyle(
                    color: AppColors.statusDeactive,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              GlassPillBadge(
                label: '${alerts.length} Active Incidents',
                variant: GlassPillVariant.custom,
                customColor: AppColors.statusDeactive,
                icon: Icons.priority_high_rounded,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Alerts List
          if (alerts.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No active operational bottlenecks detected.',
                style: TextStyle(color: AppColors.statusActive, fontSize: 12),
              ),
            )
          else
            ...alerts.map((alert) {
              final isHigh = alert.severity == 'High';
              final severityColor = isHigh ? AppColors.statusDeactive : AppColors.statusWarning;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: severityColor.withValues(alpha: 0.35)),
                  boxShadow: [
                    BoxShadow(
                      color: severityColor.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        color: severityColor,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: severityColor.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '${alert.severity.toUpperCase()} SEVERITY',
                                      style: TextStyle(
                                        color: severityColor,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      alert.location,
                                      style: const TextStyle(
                                        color: AppColors.textMain,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    alert.timestamp,
                                    style: const TextStyle(
                                      color: AppColors.textSubtle,
                                      fontSize: 10,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                alert.description,
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.bgSurfaceHover,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.lightbulb_outline_rounded, color: AppColors.brandAccent, size: 14),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        alert.suggestedAction,
                                        style: const TextStyle(
                                          color: AppColors.brandAccent,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Action dispatched for ${alert.id}'),
                                            backgroundColor: AppColors.brandPrimary,
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.brandPrimary,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'Dispatch',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
