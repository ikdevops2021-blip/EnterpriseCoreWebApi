import 'package:flutter/material.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/core/theme/app_decorations.dart';
import 'package:dqms_frontend/core/widgets/glass_widgets.dart';
import 'package:dqms_frontend/features/dashboard/providers/dashboard_provider.dart';

/// ============================================================================
/// COUNTER STATUS PANEL — STATION MATRIX GRID
/// Displays real-time operational status, active tokens, & operator metrics
/// ============================================================================
class CounterStatusPanel extends StatefulWidget {
  final DashboardState state;

  const CounterStatusPanel({
    super.key,
    required this.state,
  });

  @override
  State<CounterStatusPanel> createState() => _CounterStatusPanelState();
}

class _CounterStatusPanelState extends State<CounterStatusPanel> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final allCounters = widget.state.counters;
    final filteredCounters = allCounters.where((c) {
      if (_filter == 'Active') return c.status == 'Active';
      if (_filter == 'Idle') return c.status == 'Idle';
      if (_filter == 'SLA Risk') return c.isSlaBreached || c.status == 'SLA Risk';
      if (_filter == 'Closed') return c.status == 'Closed';
      return true;
    }).toList();

    return GlassContainer(
      padding: const EdgeInsets.all(18),
      borderRadius: AppRadius.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Bar with Filter Tabs
          Row(
            children: [
              const Icon(Icons.desk_rounded, color: AppColors.brandPrimary, size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'COUNTER STATIONS MATRIX',
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
              Flexible(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', allCounters.length),
                      const SizedBox(width: 4),
                      _buildFilterChip('Active', allCounters.where((c) => c.status == 'Active').length, color: AppColors.statusActive),
                      const SizedBox(width: 4),
                      _buildFilterChip('Idle', allCounters.where((c) => c.status == 'Idle').length, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      _buildFilterChip('SLA Risk', allCounters.where((c) => c.isSlaBreached || c.status == 'SLA Risk').length, color: AppColors.statusDeactive),
                      const SizedBox(width: 4),
                      _buildFilterChip('Closed', allCounters.where((c) => c.status == 'Closed').length, color: AppColors.textDisabled),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Station Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 1100
                  ? 5
                  : (constraints.maxWidth > 800
                      ? 3
                      : (constraints.maxWidth > 500 ? 2 : 1));

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredCounters.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.85,
                ),
                itemBuilder: (context, index) {
                  final counter = filteredCounters[index];
                  return _buildCounterCard(counter);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int count, {Color? color}) {
    final isSelected = _filter == label;
    final activeColor = color ?? AppColors.brandPrimary;

    return InkWell(
      onTap: () {
        setState(() {
          _filter = label;
        });
      },
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.22) : AppColors.bgCard,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: isSelected ? activeColor.withValues(alpha: 0.7) : AppColors.glassBorderLight,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.25),
                    blurRadius: 6,
                    spreadRadius: 0.5,
                  ),
                ]
              : null,
        ),
        child: Text(
          '$label ($count)',
          style: TextStyle(
            color: isSelected ? activeColor : AppColors.textMuted,
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildCounterCard(DashboardCounterDetail counter) {
    Color statusColor;
    IconData statusIcon;

    if (counter.isSlaBreached || counter.status == 'SLA Risk') {
      statusColor = AppColors.statusDeactive;
      statusIcon = Icons.error_outline_rounded;
    } else if (counter.status == 'Active') {
      statusColor = AppColors.statusActive;
      statusIcon = Icons.check_circle_outline_rounded;
    } else if (counter.status == 'Idle') {
      statusColor = AppColors.statusWarning;
      statusIcon = Icons.hourglass_empty_rounded;
    } else {
      statusColor = AppColors.textDisabled;
      statusIcon = Icons.remove_circle_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: counter.isSlaBreached
              ? AppColors.statusDeactive.withValues(alpha: 0.6)
              : AppColors.glassBorderLight,
          width: counter.isSlaBreached ? 1.5 : 1.0,
        ),
        boxShadow: counter.isSlaBreached
            ? [
                BoxShadow(
                  color: AppColors.statusDeactive.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Station ID & Status Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                  border: Border.all(color: AppColors.brandPrimary.withValues(alpha: 0.35)),
                ),
                child: Text(
                  counter.counterNumber,
                  style: const TextStyle(
                    color: AppColors.cyanGlow,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  counter.counterName,
                  style: const TextStyle(
                    color: AppColors.textSubtle,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withValues(alpha: 0.7),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(statusIcon, color: statusColor, size: 14),
                ],
              ),
            ],
          ),

          // Serving Token Display
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    counter.currentToken ?? '— — —',
                    style: TextStyle(
                      color: counter.currentToken != null ? AppColors.neonCyan : AppColors.textDisabled,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      shadows: counter.currentToken != null
                          ? [
                              Shadow(
                                color: AppColors.neonCyan.withValues(alpha: 0.4),
                                blurRadius: 6,
                              ),
                            ]
                          : null,
                    ),
                  ),
                ),
              ),
              if (counter.currentToken != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    counter.handlingTime,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ],
          ),

          // Operator Name Footer
          Row(
            children: [
              const Icon(Icons.person_outline_rounded, color: AppColors.textMuted, size: 12),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  counter.operatorName,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
