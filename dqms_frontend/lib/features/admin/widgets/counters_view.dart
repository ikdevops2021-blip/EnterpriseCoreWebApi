import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dqms_frontend/core/config/app_config.dart';
import 'package:dqms_frontend/core/network/dio_provider.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/core/widgets/dqms_button.dart';
import 'package:dqms_frontend/core/widgets/dqms_text_field.dart';
import 'package:dqms_frontend/core/widgets/dqms_status_badge.dart';
import 'package:dqms_frontend/core/widgets/dqms_states.dart';
import 'package:dqms_frontend/features/admin/providers/admin_mock_providers.dart';
import 'package:dqms_frontend/features/admin/widgets/master_detail_layout.dart';

/// ============================================================================
/// COUNTER STATIONS WORKSPACE VIEW (Domain 3)
/// Master-Detail management interface for physical windows and operator desks
/// 1:1 Matched to Stitch Screen: "Counter Stations & Physical Bay Allocation"
/// ============================================================================
class CountersView extends ConsumerStatefulWidget {
  const CountersView({super.key});

  @override
  ConsumerState<CountersView> createState() => _CountersViewState();
}

class _CountersViewState extends ConsumerState<CountersView> {
  String _searchQuery = '';
  String _wingFilter = 'All Wings';
  CounterModel? _selectedCounter;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminWorkspaceStateProvider);
    final filteredCounters = state.counters.where((c) {
      final matchesSearch = c.counterName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.counterNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.assignedStaffName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.areaName.toLowerCase().contains(_searchQuery.toLowerCase());
      if (_wingFilter == 'All Wings') return matchesSearch;
      return matchesSearch && c.areaName.toLowerCase().contains(_wingFilter.toLowerCase());
    }).toList();

    return MasterDetailLayout(
      masterWidget: _buildMasterTable(filteredCounters, state),
      detailWidget: _selectedCounter != null ? _buildDetailInspector(_selectedCounter!) : null,
      detailTitle: _selectedCounter != null ? 'Bay Inspector — ${_selectedCounter!.counterNumber}' : 'Counter Inspector',
      onCloseDetail: () {
        setState(() {
          _selectedCounter = null;
        });
      },
    );
  }

  Widget _buildMasterTable(List<CounterModel> counters, AdminWorkspaceState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompactHeight = constraints.maxHeight < 550;

        // --------------------------------------------------------------------
        // 1. PAGE TITLE & CONTEXT HEADER
        // --------------------------------------------------------------------
        final headerWidget = Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.brandPrimary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.brandPrimary.withValues(alpha: 0.3)),
                        ),
                        child: const Icon(Icons.desktop_windows_rounded, color: AppColors.brandPrimary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                const Text(
                                  'Counter Stations & Physical Bay Allocation',
                                  style: TextStyle(
                                    color: AppColors.textMain,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.3,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.statusActive.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppColors.statusActive.withValues(alpha: 0.3)),
                                  ),
                                  child: const Text(
                                    'Floor Plan Node Alpha',
                                    style: TextStyle(color: AppColors.statusActive, fontSize: 10, fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Real-time physical service bays, calling desks, and hardware telemetry allocation matrix.',
                              style: TextStyle(color: AppColors.textSubtle, fontSize: 11),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Quick Action Controls
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      DqmsButton(
                        label: '+ Add Physical Counter',
                        icon: Icons.add_circle_outline_rounded,
                        onPressed: _onAddNewCounter,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );

        // --------------------------------------------------------------------
        // 2. TOP KPI SUMMARY METRIC STRIP (4 KPI METRIC GLASS CARDS)
        // --------------------------------------------------------------------
        final kpiBarWidget = LayoutBuilder(
          builder: (context, kpiConstraints) {
            final cardWidth = kpiConstraints.maxWidth < 550
                ? kpiConstraints.maxWidth
                : kpiConstraints.maxWidth < 960
                    ? (kpiConstraints.maxWidth - 8) / 2
                    : (kpiConstraints.maxWidth - 24) / 4;
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildKpiCard(
                  width: cardWidth,
                  title: 'Total Configured Bays',
                  value: '${counters.length}',
                  trend: 'Allocated',
                  footerLeft: 'Calling & Standby',
                  footerRight: '${counters.where((c) => c.status == "Active").length} Live',
                  footerColor: AppColors.statusActive,
                  icon: Icons.desktop_windows_outlined,
                  accentColor: AppColors.brandPrimary,
                ),
                _buildKpiCard(
                  width: cardWidth,
                  title: 'Clinicians Checked-In',
                  value: '09',
                  trend: 'Staff On-Station',
                  footerLeft: 'Capacity: 9 / 12 (75%)',
                  footerRight: 'Optimal',
                  footerColor: AppColors.statusActive,
                  icon: Icons.badge_outlined,
                  accentColor: AppColors.brandAccent,
                ),
                _buildKpiCard(
                  width: cardWidth,
                  title: 'Fleet Hardware Health',
                  value: '100%',
                  trend: '0% Loss',
                  footerLeft: '24 IOT Devices Synced',
                  footerRight: 'Online',
                  footerColor: AppColors.statusActive,
                  icon: Icons.router_outlined,
                  accentColor: AppColors.brandSecondary,
                ),
                _buildKpiCard(
                  width: cardWidth,
                  title: 'Avg Counter TAT (Today)',
                  value: '06m 42s',
                  trend: 'Under SLA',
                  footerLeft: 'Threshold Target: <8m',
                  footerRight: 'In Spec',
                  footerColor: AppColors.statusActive,
                  icon: Icons.timer_outlined,
                  accentColor: AppColors.statusActive,
                ),
              ],
            );
          },
        );

        // --------------------------------------------------------------------
        // 3. TOOLBAR CONTROLS BAR & WING TABS
        // --------------------------------------------------------------------
        final toolbarWidget = Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Search field
              SizedBox(
                width: 250,
                child: DqmsTextField(
                  hintText: 'Search Counter, Bay ID, or Teller...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 16),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                ),
              ),

              // Wing Selector Tabs
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final wing in ['All Wings', 'Level 1 - OPD', 'Level 2 - Pediatrics', 'Trauma Unit'])
                    InkWell(
                      onTap: () => setState(() => _wingFilter = wing),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _wingFilter == wing
                              ? AppColors.brandPrimary.withValues(alpha: 0.2)
                              : AppColors.bgCard,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: _wingFilter == wing ? AppColors.brandPrimary : AppColors.borderSubtle,
                          ),
                        ),
                        child: Text(
                          wing,
                          style: TextStyle(
                            color: _wingFilter == wing ? AppColors.brandPrimary : AppColors.textSubtle,
                            fontSize: 11,
                            fontWeight: _wingFilter == wing ? FontWeight.w800 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );

        // --------------------------------------------------------------------
        // 4. MASTER TABLE / LIST
        // --------------------------------------------------------------------
        final tableContainer = Container(
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: counters.isEmpty
                ? const DqmsEmptyState(
                    title: 'No Counters Found',
                    message: 'No physical counter stations match your search query.',
                    icon: Icons.desk_rounded,
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 700;
                      if (isMobile) {
                        return ListView.separated(
                          padding: const EdgeInsets.all(12),
                          itemCount: counters.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (ctx, i) {
                            final ctr = counters[i];
                            final isSelected = _selectedCounter?.counterId == ctr.counterId;
                            return _buildMobileCounterCard(ctr, isSelected);
                          },
                        );
                      }

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: 880,
                          child: Column(
                            children: [
                              // Table Header
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.bgSurfaceHover,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                  border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
                                ),
                                child: const Row(
                                  children: [
                                    SizedBox(width: 90, child: Text('STATION ID', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'monospace'))),
                                    Expanded(flex: 3, child: Text('COUNTER / PHYSICAL BAY NAME', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                                    Expanded(flex: 2, child: Text('FACILITY ZONE', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                                    Expanded(flex: 2, child: Text('ASSIGNED CLINICIAN', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                                    SizedBox(width: 110, child: Text('CALLING MODE', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                                    SizedBox(width: 80, child: Text('STATUS', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                                    SizedBox(width: 50, child: Text('ACTION', textAlign: TextAlign.right, style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                                  ],
                                ),
                              ),

                              // Table Rows
                              Expanded(
                                child: ListView.separated(
                                  itemCount: counters.length,
                                  separatorBuilder: (_, _) => const Divider(color: AppColors.borderSubtle, height: 1),
                                  itemBuilder: (ctx, i) {
                                    final ctr = counters[i];
                                    final isSelected = _selectedCounter?.counterId == ctr.counterId;
                                    return _buildDesktopRow(ctr, isSelected);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          );

        // --------------------------------------------------------------------
        // 5. FOOTER STATUS
        // --------------------------------------------------------------------
        final footerWidget = Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Showing ${counters.length} of ${ref.read(adminWorkspaceStateProvider).counters.length} Physical Counter Stations',
                style: const TextStyle(color: AppColors.textSubtle, fontSize: 11),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Row(
              children: [
                Icon(Icons.chevron_left_rounded, color: AppColors.textMuted, size: 18),
                SizedBox(width: 8),
                Text('Page 1 of 1', style: TextStyle(color: AppColors.textMain, fontSize: 11, fontWeight: FontWeight.w600)),
                SizedBox(width: 8),
                Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 18),
              ],
            ),
          ],
        );

        if (isCompactHeight) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                headerWidget,
                const SizedBox(height: 12),
                kpiBarWidget,
                const SizedBox(height: 12),
                toolbarWidget,
                const SizedBox(height: 12),
                SizedBox(height: 380, child: tableContainer),
                const SizedBox(height: 8),
                footerWidget,
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            headerWidget,
            const SizedBox(height: 12),
            kpiBarWidget,
            const SizedBox(height: 12),
            toolbarWidget,
            const SizedBox(height: 12),
            Expanded(child: tableContainer),
            const SizedBox(height: 8),
            footerWidget,
          ],
        );
      },
    );
  }

  Widget _buildKpiCard({
    required double width,
    required String title,
    required String value,
    required String trend,
    required String footerLeft,
    required String footerRight,
    required Color footerColor,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 16, color: accentColor),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textMain,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'monospace',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                trend,
                style: TextStyle(color: accentColor, fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: AppColors.borderSubtle, height: 1),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  footerLeft,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                footerRight,
                style: TextStyle(color: footerColor, fontSize: 10, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileCounterCard(CounterModel ctr, bool isSelected) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedCounter = ctr;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandPrimary.withValues(alpha: 0.12) : AppColors.bgCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.brandPrimary : AppColors.borderSubtle,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.brandPrimary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.brandPrimary.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    ctr.counterNumber,
                    style: const TextStyle(
                      color: AppColors.brandPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                DqmsStatusBadge.activeState(ctr.status == 'Active'),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              ctr.counterName,
              style: const TextStyle(
                color: AppColors.textMain,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    ctr.areaName,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.brandAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.person_outline_rounded, size: 12, color: AppColors.brandAccent),
                      const SizedBox(width: 4),
                      Text(
                        ctr.assignedStaffName,
                        style: const TextStyle(
                          color: AppColors.brandAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.bgCanvas,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Text(
                    ctr.mode,
                    style: const TextStyle(color: AppColors.textSubtle, fontSize: 10),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopRow(CounterModel ctr, bool isSelected) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedCounter = ctr;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandPrimary.withValues(alpha: 0.12) : AppColors.bgCard,
          border: isSelected ? const Border(left: BorderSide(color: AppColors.brandPrimary, width: 3)) : null,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 90,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.brandPrimary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.brandPrimary.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    ctr.counterNumber,
                    style: const TextStyle(
                      color: AppColors.brandPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ctr.counterName,
                    style: const TextStyle(color: AppColors.textMain, fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Physical Calling Station',
                    style: TextStyle(color: AppColors.textSubtle, fontSize: 11),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                ctr.areaName,
                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: AppColors.brandPrimary.withValues(alpha: 0.2),
                    child: Text(
                      ctr.assignedStaffName.isNotEmpty ? ctr.assignedStaffName[0] : 'U',
                      style: const TextStyle(color: AppColors.brandPrimary, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      ctr.assignedStaffName,
                      style: const TextStyle(color: AppColors.brandAccent, fontSize: 12, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 110,
              child: Text(
                ctr.mode,
                style: const TextStyle(color: AppColors.textSubtle, fontSize: 11),
              ),
            ),
            SizedBox(
              width: 80,
              child: DqmsStatusBadge.activeState(ctr.status == 'Active'),
            ),
            SizedBox(
              width: 50,
              child: IconButton(
                icon: const Icon(Icons.edit_note_rounded, size: 20, color: AppColors.brandPrimary),
                tooltip: 'Inspect & Edit',
                onPressed: () {
                  setState(() {
                    _selectedCounter = ctr;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onAddNewCounter() {
    setState(() {
      _selectedCounter = const CounterModel(
        counterId: 999,
        areaId: 1,
        areaName: 'Main Service Hall A',
        counterNumber: 'CTR-NEW',
        counterName: 'New Counter Station',
        assignedStaffName: 'Agent Unassigned',
        mode: 'Multi-Service Call',
        status: 'Active',
        isVoiceEnabled: true,
      );
    });
  }

  Widget _buildDetailInspector(CounterModel ctr) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Inspector Header Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.brandPrimary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.brandPrimary.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.brandPrimary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.desktop_windows_rounded, color: AppColors.brandPrimary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ctr.counterNumber,
                        style: const TextStyle(
                          color: AppColors.brandPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        ctr.counterName,
                        style: const TextStyle(color: AppColors.textMain, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                DqmsStatusBadge.activeState(ctr.status == 'Active'),
              ],
            ),
          ),
          const SizedBox(height: 18),

          DqmsTextField(
            label: 'Counter Station Code',
            initialValue: ctr.counterNumber,
            onChanged: (val) {
              setState(() {
                _selectedCounter = ctr.copyWith(counterNumber: val);
              });
            },
          ),
          const SizedBox(height: 14),
          DqmsTextField(
            label: 'Counter Name',
            initialValue: ctr.counterName,
            onChanged: (val) {
              setState(() {
                _selectedCounter = ctr.copyWith(counterName: val);
              });
            },
          ),
          const SizedBox(height: 14),
          DqmsTextField(
            label: 'Assigned Operator',
            initialValue: ctr.assignedStaffName,
            onChanged: (val) {
              setState(() {
                _selectedCounter = ctr.copyWith(assignedStaffName: val);
              });
            },
          ),
          const SizedBox(height: 14),
          DqmsTextField(
            label: 'Operating Mode',
            initialValue: ctr.mode,
            onChanged: (val) {
              setState(() {
                _selectedCounter = ctr.copyWith(mode: val);
              });
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Audio Voice Announcement:', style: TextStyle(color: AppColors.textMain, fontSize: 12, fontWeight: FontWeight.w600)),
              const Spacer(),
              Switch(
                value: ctr.isVoiceEnabled,
                activeTrackColor: AppColors.brandPrimary,
                onChanged: (val) {
                  setState(() {
                    _selectedCounter = ctr.copyWith(isVoiceEnabled: val);
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Operational Status Provision (Active / Inactive Toggle)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: (ctr.status == 'Active')
                  ? AppColors.statusActive.withValues(alpha: 0.08)
                  : AppColors.statusDeactive.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: (ctr.status == 'Active')
                    ? AppColors.statusActive.withValues(alpha: 0.3)
                    : AppColors.statusDeactive.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  (ctr.status == 'Active') ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  color: (ctr.status == 'Active') ? AppColors.statusActive : AppColors.statusDeactive,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'OPERATIONAL STATUS',
                        style: TextStyle(
                          color: AppColors.textSubtle,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        (ctr.status == 'Active') ? 'Active (Ready to Serve Tokens)' : 'Inactive / Closed',
                        style: TextStyle(
                          color: (ctr.status == 'Active') ? AppColors.statusActive : AppColors.statusDeactive,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: ctr.status == 'Active',
                  activeThumbColor: AppColors.statusActive,
                  activeTrackColor: AppColors.statusActive.withValues(alpha: 0.4),
                  inactiveThumbColor: AppColors.textSubtle,
                  inactiveTrackColor: AppColors.bgSurfaceHover,
                  onChanged: (val) {
                    setState(() {
                      _selectedCounter = ctr.copyWith(status: val ? 'Active' : 'Inactive');
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          DqmsButton(
            label: 'Save Counter Setup',
            icon: Icons.save_rounded,
            isFullWidth: true,
            onPressed: () async {
              try {
                final dio = ref.read(dioProvider);
                await dio.post('${AppConfig.adminApiBase}/counter', data: {
                  'id': ctr.counterId,
                  'areaId': ctr.areaId,
                  'counterNumber': ctr.counterNumber,
                  'counterName': ctr.counterName,
                  'mode': ctr.mode,
                  'assignedStaffName': ctr.assignedStaffName,
                  'status': ctr.status,
                  'isVoiceEnabled': ctr.isVoiceEnabled,
                  'organizationId': 1,
                  'locationId': 1,
                  'isActive': ctr.status == 'Active',
                });
                ref.read(adminWorkspaceStateProvider.notifier).updateCounter(ctr);
                await ref.read(adminWorkspaceStateProvider.notifier).fetchApiData(dio);
              } catch (_) {}

              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Counter ${ctr.counterNumber} saved to backend API (${ctr.status}).'), backgroundColor: ctr.status == 'Active' ? AppColors.statusActive : AppColors.statusDeactive),
              );
            },
          ),
        ],
      ),
    );
  }
}
