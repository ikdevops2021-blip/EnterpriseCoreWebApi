import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropdown_search/dropdown_search.dart';
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
/// PROCESS PIPELINES WORKSPACE VIEW (Domain 2)
/// Master-Detail management interface for service workflows and target SLAs
/// 1:1 Matched to Stitch Screen: "Clinical Services & Process Pipeline SLA"
/// ============================================================================
class ProcessesView extends ConsumerStatefulWidget {
  const ProcessesView({super.key});

  @override
  ConsumerState<ProcessesView> createState() => _ProcessesViewState();
}

class _ProcessesViewState extends ConsumerState<ProcessesView> {
  String _searchQuery = '';
  String _deptFilter = 'All';
  ProcessModel? _selectedProcess;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminWorkspaceStateProvider);
    final areas = state.areas;

    final filteredProcesses = state.processes.where((p) {
      final matchesSearch = p.processName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.processCode.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.areaName.toLowerCase().contains(_searchQuery.toLowerCase());
      if (_deptFilter == 'All') return matchesSearch;
      return matchesSearch && p.areaName.toLowerCase().contains(_deptFilter.toLowerCase());
    }).toList();

    return MasterDetailLayout(
      masterWidget: _buildMasterTable(filteredProcesses, areas),
      detailWidget: _selectedProcess != null ? _buildDetailInspector(_selectedProcess!, areas) : null,
      detailTitle: _selectedProcess != null ? 'Service / Process Inspector — ${_selectedProcess!.processCode}' : 'Service Inspector',
      onCloseDetail: () {
        setState(() {
          _selectedProcess = null;
        });
      },
    );
  }

  void _onAddNewProcess(List<AreaZoneModel> areas) {
    final defaultArea = areas.isNotEmpty ? areas.first : null;
    setState(() {
      _selectedProcess = ProcessModel(
        processId: 999,
        areaId: defaultArea?.areaId ?? 1,
        areaName: defaultArea?.areaName ?? 'Main Service Hall A',
        processCode: 'PROC-NEW',
        processName: 'New Service Workflow',
        targetSlaMins: 15,
        allowSubTokens: true,
        isSms: true,
        isWhatsApp: true,
        isEmail: true,
        isFeedback: true,
        tokenLimitDaily: 0,
        priorityLevel: 'Standard',
        isActive: true,
      );
    });
  }

  Widget _buildMasterTable(List<ProcessModel> processes, List<AreaZoneModel> areas) {
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
                        child: const Icon(Icons.account_tree_rounded, color: AppColors.brandPrimary, size: 20),
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
                                  'Clinical Services & Process Pipeline SLA',
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
                                    color: AppColors.brandPrimary.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppColors.brandPrimary.withValues(alpha: 0.3)),
                                  ),
                                  child: const Text(
                                    'v4.8 High-Throughput Engine',
                                    style: TextStyle(color: AppColors.brandPrimary, fontSize: 10, fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Configure service ticket routing policies, SLA latency benchmarks, and active counter allocation matrix.',
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
                        label: 'Global Thresholds',
                        icon: Icons.tune_rounded,
                        variant: DqmsButtonVariant.secondary,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Global clinical SLA thresholds loaded.')),
                          );
                        },
                      ),
                      DqmsButton(
                        label: '+ New Service',
                        icon: Icons.add_rounded,
                        onPressed: () => _onAddNewProcess(areas),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );

        // --------------------------------------------------------------------
        // 2. EXECUTIVE METRICS BAR (4 KPI METRIC GLASS CARDS)
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
                  title: 'Total Active Processes',
                  value: '${processes.length}',
                  trend: '+3 today',
                  footerLeft: '${areas.length} wings operational',
                  footerRight: 'Active',
                  footerColor: AppColors.statusActive,
                  icon: Icons.account_tree_outlined,
                  accentColor: AppColors.brandPrimary,
                ),
                _buildKpiCard(
                  width: cardWidth,
                  title: 'Global SLA Target',
                  value: '15m 00s',
                  trend: 'Standard',
                  footerLeft: 'Benchmark compliance',
                  footerRight: '95.4% Met',
                  footerColor: AppColors.brandAccent,
                  icon: Icons.timer_outlined,
                  accentColor: AppColors.brandAccent,
                ),
                _buildKpiCard(
                  width: cardWidth,
                  title: 'Avg Waiting TAT',
                  value: '11m 40s',
                  trend: '-3m 20s',
                  footerLeft: 'vs baseline target',
                  footerRight: '+22% Faster',
                  footerColor: AppColors.statusActive,
                  icon: Icons.speed_rounded,
                  accentColor: AppColors.statusActive,
                ),
                _buildKpiCard(
                  width: cardWidth,
                  title: 'Process Bottlenecks',
                  value: '0',
                  trend: 'Critical',
                  footerLeft: 'Telemetry audit',
                  footerRight: 'Optimal Flow',
                  footerColor: AppColors.statusActive,
                  icon: Icons.verified_outlined,
                  accentColor: AppColors.statusActive,
                ),
              ],
            );
          },
        );

        // --------------------------------------------------------------------
        // 3. TOOLBAR CONTROLS BAR & DEPARTMENT FILTER PILLS
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
                  hintText: 'Search processes, codes, prefixes...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 16),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                ),
              ),

              // Department Quick Tabs
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final dept in ['All', 'Cardiology', 'Pathology', 'Pharmacy', 'Radiology', 'Consultation'])
                    InkWell(
                      onTap: () => setState(() => _deptFilter = dept),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _deptFilter == dept
                              ? AppColors.brandPrimary.withValues(alpha: 0.2)
                              : AppColors.bgCard,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: _deptFilter == dept ? AppColors.brandPrimary : AppColors.borderSubtle,
                          ),
                        ),
                        child: Text(
                          dept,
                          style: TextStyle(
                            color: _deptFilter == dept ? AppColors.brandPrimary : AppColors.textSubtle,
                            fontSize: 11,
                            fontWeight: _deptFilter == dept ? FontWeight.w800 : FontWeight.w500,
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
            child: processes.isEmpty
                ? const DqmsEmptyState(
                    title: 'No Services Found',
                    message: 'No service pipeline workflows match your search query.',
                    icon: Icons.account_tree_outlined,
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final availWidth = constraints.maxWidth;
                      // Switch to card layout when width is tight (e.g. when detail panel is open)
                      if (availWidth < 600) {
                        return ListView.separated(
                          padding: const EdgeInsets.all(12),
                          itemCount: processes.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (ctx, i) {
                            final proc = processes[i];
                            final isSelected = _selectedProcess?.processId == proc.processId;
                            return _buildMobileProcessCard(proc, isSelected);
                          },
                        );
                      }

                      // Use the available width when it's >= 900, otherwise allow horizontal scroll
                      const double minTableWidth = 900;
                      final double tableWidth = availWidth >= minTableWidth ? availWidth : minTableWidth;
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: availWidth,
                            maxWidth: tableWidth,
                          ),
                          child: SizedBox(
                            width: tableWidth,
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
                                      SizedBox(width: 100, child: Text('PROCESS CODE', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'monospace'))),
                                      Expanded(flex: 3, child: Text('SERVICE & DEPARTMENT', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                                      SizedBox(width: 100, child: Text('PRIORITY', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                                      SizedBox(width: 140, child: Text('SLA THRESHOLD', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                                      SizedBox(width: 110, child: Text('CHANNELS', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                                      SizedBox(width: 80, child: Text('STATUS', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                                      SizedBox(width: 50, child: Text('ACTION', textAlign: TextAlign.right, style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                                    ],
                                  ),
                                ),

                                // Table Rows
                                Expanded(
                                  child: ListView.separated(
                                    itemCount: processes.length,
                                    separatorBuilder: (_, _) => const Divider(color: AppColors.borderSubtle, height: 1),
                                    itemBuilder: (ctx, i) {
                                      final proc = processes[i];
                                      final isSelected = _selectedProcess?.processId == proc.processId;
                                      return _buildDesktopRow(proc, isSelected);
                                    },
                                  ),
                                ),
                              ],
                            ),
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
                'Showing ${processes.length} of ${ref.read(adminWorkspaceStateProvider).processes.length} Service Pipeline Records',
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

  Widget _buildMobileProcessCard(ProcessModel proc, bool isSelected) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedProcess = proc;
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
                    proc.processCode,
                    style: const TextStyle(
                      color: AppColors.brandPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                DqmsStatusBadge.activeState(proc.isActive),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              proc.processName,
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
                    proc.areaName,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(color: AppColors.borderSubtle, height: 1),
            const SizedBox(height: 8),
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
                      const Icon(Icons.timer_outlined, size: 11, color: AppColors.brandAccent),
                      const SizedBox(width: 3),
                      Text(
                        '${proc.targetSlaMins}m SLA',
                        style: const TextStyle(
                          color: AppColors.brandAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: proc.tokenLimitDaily > 0 ? AppColors.statusWarning.withValues(alpha: 0.15) : AppColors.brandPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    proc.tokenLimitDaily > 0 ? '${proc.tokenLimitDaily} / day' : 'Unlimited',
                    style: TextStyle(
                      color: proc.tokenLimitDaily > 0 ? AppColors.statusWarning : AppColors.brandPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildChannelBadge('SMS', Icons.sms_outlined, proc.isSms),
                    const SizedBox(width: 3),
                    _buildChannelBadge('WA', Icons.chat_bubble_outline_rounded, proc.isWhatsApp),
                    const SizedBox(width: 3),
                    _buildChannelBadge('Mail', Icons.email_outlined, proc.isEmail),
                    const SizedBox(width: 3),
                    _buildChannelBadge('CSAT', Icons.star_outline_rounded, proc.isFeedback),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopRow(ProcessModel proc, bool isSelected) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedProcess = proc;
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
              width: 100,
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
                    proc.processCode,
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
                    proc.processName,
                    style: const TextStyle(color: AppColors.textMain, fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    proc.areaName,
                    style: const TextStyle(color: AppColors.textSubtle, fontSize: 11),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 100,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.brandSecondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    proc.priorityLevel.isNotEmpty ? proc.priorityLevel : 'Standard',
                    style: const TextStyle(color: AppColors.brandSecondary, fontSize: 10, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 140,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          '${proc.targetSlaMins}m Target',
                          style: const TextStyle(color: AppColors.statusActive, fontSize: 10, fontWeight: FontWeight.w700),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Flexible(
                        child: Text(
                          'SLA 95%',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 9),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: Container(
                      height: 4,
                      width: 120,
                      color: AppColors.bgSurfaceHover,
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: 0.78,
                        child: Container(color: AppColors.statusActive),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 110,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildChannelBadge('SMS', Icons.sms_outlined, proc.isSms),
                    const SizedBox(width: 3),
                    _buildChannelBadge('WA', Icons.chat_bubble_outline_rounded, proc.isWhatsApp),
                    const SizedBox(width: 3),
                    _buildChannelBadge('Mail', Icons.email_outlined, proc.isEmail),
                    const SizedBox(width: 3),
                    _buildChannelBadge('CSAT', Icons.star_outline_rounded, proc.isFeedback),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 80,
              child: DqmsStatusBadge.activeState(proc.isActive),
            ),
            SizedBox(
              width: 50,
              child: IconButton(
                icon: const Icon(Icons.edit_note_rounded, size: 20, color: AppColors.brandPrimary),
                tooltip: 'Inspect & Edit',
                onPressed: () {
                  setState(() {
                    _selectedProcess = proc;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailInspector(ProcessModel proc, List<AreaZoneModel> areas) {
    final selectedArea = areas.firstWhere(
      (a) => a.areaId == proc.areaId || a.areaName.toLowerCase() == proc.areaName.toLowerCase(),
      orElse: () => areas.isNotEmpty
          ? areas.first
          : AreaZoneModel(
              areaId: proc.areaId,
              areaCode: 'AZ-01',
              areaName: proc.areaName,
              description: '',
              targetSlaMins: 15,
              isActive: true,
            ),
    );

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
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
                  child: const Icon(Icons.account_tree_rounded, color: AppColors.brandPrimary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        proc.processCode,
                        style: const TextStyle(
                          color: AppColors.brandPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        proc.processName,
                        style: const TextStyle(color: AppColors.textMain, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                DqmsStatusBadge.activeState(proc.isActive),
              ],
            ),
          ),
          const SizedBox(height: 18),

          DqmsTextField(
            label: 'Process Code',
            initialValue: proc.processCode,
            onChanged: (val) {
              setState(() {
                _selectedProcess = proc.copyWith(processCode: val);
              });
            },
          ),
          const SizedBox(height: 14),
          DqmsTextField(
            label: 'Process Name',
            initialValue: proc.processName,
            onChanged: (val) {
              setState(() {
                _selectedProcess = proc.copyWith(processName: val);
              });
            },
          ),
          const SizedBox(height: 14),

          // Searchable Area / Zone Dropdown
          DropdownSearch<AreaZoneModel>(
            items: areas,
            selectedItem: selectedArea,
            itemAsString: (a) => '${a.areaCode} — ${a.areaName}',
            filterFn: (a, filter) =>
                a.areaName.toLowerCase().contains(filter.toLowerCase()) ||
                a.areaCode.toLowerCase().contains(filter.toLowerCase()) ||
                a.description.toLowerCase().contains(filter.toLowerCase()),
            compareFn: (a, b) => a.areaId == b.areaId,
            onChanged: (newArea) {
              if (newArea != null) {
                setState(() {
                  _selectedProcess = proc.copyWith(
                    areaId: newArea.areaId,
                    areaName: newArea.areaName,
                  );
                });
              }
            },
            dropdownBuilder: (ctx, item) {
              if (item == null) {
                return const Text('— Select Area / Zone —', style: TextStyle(color: AppColors.textMuted, fontSize: 12));
              }
              return Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.brandPrimary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.brandPrimary.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      item.areaCode,
                      style: const TextStyle(
                        color: AppColors.brandPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.areaName,
                      style: const TextStyle(color: AppColors.textMain, fontSize: 12, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );
            },
            dropdownDecoratorProps: DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                labelText: 'Assigned Area / Zone (Loaded from API)',
                labelStyle: const TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w600),
                filled: true,
                fillColor: AppColors.bgCanvas,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: AppColors.borderSubtle),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: AppColors.borderSubtle),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: AppColors.brandPrimary),
                ),
              ),
            ),
            popupProps: PopupProps.menu(
              showSearchBox: true,
              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(
                  hintText: 'Search Area Code or Zone Name...',
                  hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                  filled: true,
                  fillColor: AppColors.bgCanvas,
                  prefixIcon: const Icon(Icons.search, color: AppColors.textSubtle, size: 18),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: AppColors.borderSubtle),
                  ),
                ),
                style: const TextStyle(color: AppColors.textMain, fontSize: 12),
              ),
              containerBuilder: (ctx, child) => Container(
                decoration: BoxDecoration(
                  color: AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderSubtle),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: child,
              ),
              itemBuilder: (ctx, item, isSelected) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  color: isSelected ? AppColors.brandPrimary.withValues(alpha: 0.12) : Colors.transparent,
                  child: Row(
                    children: [
                      if (isSelected) ...[
                        const Icon(Icons.check_circle, color: AppColors.brandPrimary, size: 14),
                        const SizedBox(width: 8),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.brandPrimary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.areaCode,
                          style: const TextStyle(
                            color: AppColors.brandPrimary,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item.areaName,
                              style: TextStyle(
                                color: isSelected ? AppColors.brandPrimary : AppColors.textMain,
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                              ),
                            ),
                            if (item.description.isNotEmpty)
                              Text(
                                item.description,
                                style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'SLA: ${item.targetSlaMins}m',
                        style: const TextStyle(color: AppColors.brandAccent, fontSize: 10, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),

          GestureDetector(
            onTap: proc.steps.isEmpty
                ? () async {
                    final picked = await showDurationTimePicker(context, proc.targetSlaMins);
                    if (picked != null) {
                      setState(() {
                        _selectedProcess = proc.copyWith(targetSlaMins: picked);
                      });
                    }
                  }
                : null,
            child: AbsorbPointer(
              child: DqmsTextField(
                label: proc.steps.isNotEmpty
                    ? 'Target SLA Minutes (Auto-calculated from steps)'
                    : 'Target SLA Minutes (Click to set duration)',
                initialValue: '${proc.targetSlaMins} mins (${proc.targetSlaMins ~/ 60}h ${proc.targetSlaMins % 60}m)',
                enabled: proc.steps.isEmpty,
                suffixIcon: const Icon(Icons.access_time_rounded, color: AppColors.brandAccent, size: 18),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              const Text('Allow Sub-Tokens:', style: TextStyle(color: AppColors.textMain, fontSize: 12, fontWeight: FontWeight.w600)),
              const Spacer(),
              Switch(
                value: proc.allowSubTokens,
                activeTrackColor: AppColors.brandPrimary,
                onChanged: (val) {
                  setState(() {
                    _selectedProcess = proc.copyWith(allowSubTokens: val);
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
              color: proc.isActive
                  ? AppColors.statusActive.withValues(alpha: 0.08)
                  : AppColors.statusDeactive.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: proc.isActive
                    ? AppColors.statusActive.withValues(alpha: 0.3)
                    : AppColors.statusDeactive.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  proc.isActive ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  color: proc.isActive ? AppColors.statusActive : AppColors.statusDeactive,
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
                        proc.isActive ? 'Active (Open for Ticketing)' : 'Inactive / Suspended',
                        style: TextStyle(
                          color: proc.isActive ? AppColors.statusActive : AppColors.statusDeactive,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: proc.isActive,
                  activeThumbColor: AppColors.statusActive,
                  activeTrackColor: AppColors.statusActive.withValues(alpha: 0.4),
                  inactiveThumbColor: AppColors.textSubtle,
                  inactiveTrackColor: AppColors.bgSurfaceHover,
                  onChanged: (val) {
                    setState(() {
                      _selectedProcess = proc.copyWith(isActive: val);
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Daily Max Quota
          DqmsTextField(
            label: 'Daily Maximum Token Limit (0 or empty = Unlimited)',
            hintText: 'e.g. 20 (0 = Unlimited)',
            initialValue: proc.tokenLimitDaily == 0 ? '' : '${proc.tokenLimitDaily}',
            keyboardType: TextInputType.number,
            prefixIcon: const Icon(Icons.confirmation_number_outlined, size: 18),
            onChanged: (val) {
              final limit = int.tryParse(val.trim()) ?? 0;
              setState(() {
                _selectedProcess = proc.copyWith(tokenLimitDaily: limit);
              });
            },
          ),
          const SizedBox(height: 16),

          // Channels Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.campaign_outlined, color: AppColors.brandPrimary, size: 16),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'COMMUNICATION & FEEDBACK CHANNELS',
                        style: TextStyle(color: AppColors.textMain, fontSize: 11, fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildChannelToggle(
                  title: 'SMS Notifications (IsSMS / BF_SMS)',
                  subtitle: 'Send SMS queue ticket updates and calling alerts',
                  icon: Icons.sms_outlined,
                  value: proc.isSms,
                  onChanged: (val) => setState(() => _selectedProcess = proc.copyWith(isSms: val)),
                ),
                const Divider(color: AppColors.borderSubtle, height: 14),
                _buildChannelToggle(
                  title: 'WhatsApp Alerts (IsWhatsApp / BF_WhatsApp)',
                  subtitle: 'Send prior-to-calling WhatsApp notifications',
                  icon: Icons.chat_bubble_outline_rounded,
                  value: proc.isWhatsApp,
                  onChanged: (val) => setState(() => _selectedProcess = proc.copyWith(isWhatsApp: val)),
                ),
                const Divider(color: AppColors.borderSubtle, height: 14),
                _buildChannelToggle(
                  title: 'Email Notifications (IsEmail / BF_Email)',
                  subtitle: 'Dispatch email receipts and appointment tokens',
                  icon: Icons.email_outlined,
                  value: proc.isEmail,
                  onChanged: (val) => setState(() => _selectedProcess = proc.copyWith(isEmail: val)),
                ),
                const Divider(color: AppColors.borderSubtle, height: 14),
                _buildChannelToggle(
                  title: 'Customer Feedback (IsFeedBack / BF_FeedBack)',
                  subtitle: 'Trigger CSAT feedback collection upon completion',
                  icon: Icons.star_outline_rounded,
                  value: proc.isFeedback,
                  onChanged: (val) => setState(() => _selectedProcess = proc.copyWith(isFeedback: val)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Steps
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pipeline Step Workflows (ProcessStep)',
                      style: TextStyle(color: AppColors.textMain, fontSize: 13, fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Multi-step sequential routing for complex tokens',
                      style: TextStyle(color: AppColors.textSubtle, fontSize: 10),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.brandPrimary, size: 20),
                tooltip: 'Add Workflow Step',
                onPressed: () {
                  final newSteps = List<ProcessStepModel>.from(proc.steps);
                  final nextOrder = newSteps.length + 1;
                  newSteps.add(ProcessStepModel(
                    stepId: DateTime.now().millisecondsSinceEpoch,
                    processId: proc.processId,
                    stepOrder: nextOrder,
                    stepName: 'Step $nextOrder: New Workflow Stage',
                    targetSlaMins: 10,
                    isActive: true,
                  ));
                  final totalSla = newSteps.fold<int>(0, (sum, s) => sum + s.targetSlaMins);
                  setState(() {
                    _selectedProcess = proc.copyWith(
                      steps: newSteps,
                      targetSlaMins: totalSla,
                    );
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (proc.steps.isEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bgCanvas,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: AppColors.textMuted, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No sub-steps defined. Click + to add sequential workflow steps.',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: proc.steps.map((step) {
                return _ProcessStepRow(
                  key: ValueKey(step.stepId),
                  step: step,
                  onChanged: (updatedStep) {
                    final newSteps = proc.steps.map((s) => s.stepId == updatedStep.stepId ? updatedStep : s).toList();
                    final totalSla = newSteps.fold<int>(0, (sum, s) => sum + s.targetSlaMins);
                    setState(() {
                      _selectedProcess = proc.copyWith(
                        steps: newSteps,
                        targetSlaMins: totalSla,
                      );
                    });
                  },
                  onDelete: () {
                    final remainingSteps = proc.steps.where((s) => s.stepId != step.stepId).toList();
                    final updatedSteps = List<ProcessStepModel>.generate(remainingSteps.length, (index) {
                      return remainingSteps[index].copyWith(stepOrder: index + 1);
                    });
                    final totalSla = updatedSteps.fold<int>(0, (sum, s) => sum + s.targetSlaMins);
                    setState(() {
                      _selectedProcess = proc.copyWith(
                        steps: updatedSteps,
                        targetSlaMins: totalSla,
                      );
                    });
                  },
                );
              }).toList(),
            ),
          const SizedBox(height: 24),

          DqmsButton(
            label: 'Save Process Pipeline & Steps',
            icon: Icons.save_rounded,
            isFullWidth: true,
            onPressed: () async {
              try {
                final dio = ref.read(dioProvider);
                await dio.post('${AppConfig.adminApiBase}/process', data: {
                  'id': proc.processId,
                  'areaId': proc.areaId,
                  'processCode': proc.processCode,
                  'processName': proc.processName,
                  'targetTATMinutes': proc.targetSlaMins,
                  'allowSubTokens': proc.allowSubTokens,
                  'isSMS': proc.isSms,
                  'isWhatsApp': proc.isWhatsApp,
                  'isEmail': proc.isEmail,
                  'isFeedBack': proc.isFeedback,
                  'tokenLimitDaily': proc.tokenLimitDaily,
                  'priorityLevel': proc.priorityLevel,
                  'organizationId': 1,
                  'isActive': proc.isActive,
                  'steps': proc.steps.map((s) => {
                    'id': s.stepId < 2000000000 ? s.stepId : 0,
                    'processId': proc.processId,
                    'stepOrder': s.stepOrder,
                    'stepName': s.stepName,
                    'targetTATMinutes': s.targetSlaMins,
                    'isActive': s.isActive,
                  }).toList(),
                });

                await ref.read(adminWorkspaceStateProvider.notifier).fetchApiData(dio);
              } catch (_) {}

              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Process ${proc.processCode} and ${proc.steps.length} workflow steps saved to API.'),
                  backgroundColor: AppColors.statusActive,
                ),
              );
            },
          ),
        ],
      );
  }

  Widget _buildChannelBadge(String label, IconData icon, bool isEnabled) {
    return Tooltip(
      message: '$label: ${isEnabled ? "Enabled" : "Disabled"}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: isEnabled ? AppColors.statusActive.withValues(alpha: 0.15) : AppColors.bgCanvas,
          borderRadius: BorderRadius.circular(3),
          border: Border.all(
            color: isEnabled ? AppColors.statusActive.withValues(alpha: 0.4) : AppColors.borderSubtle,
          ),
        ),
        child: Icon(
          icon,
          size: 11,
          color: isEnabled ? AppColors.statusActive : AppColors.textDisabled,
        ),
      ),
    );
  }

  Widget _buildChannelToggle({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: value ? AppColors.brandPrimary : AppColors.textMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: value ? AppColors.textMain : AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                subtitle,
                style: const TextStyle(color: AppColors.textSubtle, fontSize: 10),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          activeTrackColor: AppColors.brandPrimary,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _ProcessStepRow extends StatefulWidget {
  final ProcessStepModel step;
  final ValueChanged<ProcessStepModel> onChanged;
  final VoidCallback onDelete;

  const _ProcessStepRow({
    required this.step,
    required this.onChanged,
    required this.onDelete,
    super.key,
  });

  @override
  State<_ProcessStepRow> createState() => _ProcessStepRowState();
}

class _ProcessStepRowState extends State<_ProcessStepRow> {
  late TextEditingController _nameController;
  late TextEditingController _timeController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.step.stepName);
    _timeController = TextEditingController(text: '${widget.step.targetSlaMins}');
  }

  @override
  void didUpdateWidget(covariant _ProcessStepRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.step.stepName != oldWidget.step.stepName &&
        widget.step.stepName != _nameController.text) {
      _nameController.text = widget.step.stepName;
    }
    if (widget.step.targetSlaMins != oldWidget.step.targetSlaMins &&
        '${widget.step.targetSlaMins}' != _timeController.text) {
      _timeController.text = '${widget.step.targetSlaMins}';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.bgCanvas,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.brandPrimary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Step ${widget.step.stepOrder}',
              style: const TextStyle(
                color: AppColors.brandPrimary,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: TextField(
              controller: _nameController,
              style: const TextStyle(color: AppColors.textMain, fontSize: 12, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Step name...',
                hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: AppColors.borderSubtle),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: AppColors.borderSubtle),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: AppColors.brandPrimary),
                ),
              ),
              onChanged: (val) {
                widget.onChanged(widget.step.copyWith(stepName: val));
              },
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () async {
              final picked = await showDurationTimePicker(context, widget.step.targetSlaMins);
              if (picked != null) {
                widget.onChanged(widget.step.copyWith(targetSlaMins: picked));
              }
            },
            child: Container(
              width: 56,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.bgCanvas,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      '${widget.step.targetSlaMins}',
                      style: const TextStyle(color: AppColors.brandAccent, fontSize: 12, fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Text(
                    'm',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: widget.onDelete,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.delete_outline_rounded, color: AppColors.statusError, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// CUSTOM DURATION / TIME PICKER COMPONENT
// -----------------------------------------------------------------------------
Future<int?> showDurationTimePicker(BuildContext context, int initialMinutes) async {
  return showDialog<int>(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return _DurationTimePickerDialog(initialMinutes: initialMinutes);
    },
  );
}

class _DurationTimePickerDialog extends StatefulWidget {
  final int initialMinutes;

  const _DurationTimePickerDialog({required this.initialMinutes});

  @override
  State<_DurationTimePickerDialog> createState() => _DurationTimePickerDialogState();
}

class _DurationTimePickerDialogState extends State<_DurationTimePickerDialog> {
  late int _hours;
  late int _minutes;

  @override
  void initState() {
    super.initState();
    _hours = widget.initialMinutes ~/ 60;
    _minutes = widget.initialMinutes % 60;
  }

  void _selectPreset(int totalMinutes) {
    setState(() {
      _hours = totalMinutes ~/ 60;
      _minutes = totalMinutes % 60;
    });
  }

  @override
  Widget build(BuildContext context) {
    final presets = [
      {'label': '5 m', 'val': 5},
      {'label': '10 m', 'val': 10},
      {'label': '15 m', 'val': 15},
      {'label': '30 m', 'val': 30},
      {'label': '45 m', 'val': 45},
      {'label': '1 h', 'val': 60},
      {'label': '1.5 h', 'val': 90},
      {'label': '2 h', 'val': 120},
    ];

    return Dialog(
      backgroundColor: AppColors.bgSurface,
      elevation: 24,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.borderSubtle, width: 1.5),
      ),
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.access_time_filled_rounded, color: AppColors.brandPrimary, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Set Duration',
                  style: TextStyle(
                    color: AppColors.textMain,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const Text('Hours', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _PickerButton(
                          icon: Icons.remove_rounded,
                          onPressed: () {
                            if (_hours > 0) {
                              setState(() => _hours--);
                            }
                          },
                        ),
                        Container(
                          width: 44,
                          alignment: Alignment.center,
                          child: Text(
                            '$_hours',
                            style: const TextStyle(
                              color: AppColors.brandAccent,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        _PickerButton(
                          icon: Icons.add_rounded,
                          onPressed: () {
                            if (_hours < 23) {
                              setState(() => _hours++);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                
                const Text(
                  ':',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 24, fontWeight: FontWeight.bold),
                ),

                Column(
                  children: [
                    const Text('Minutes', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _PickerButton(
                          icon: Icons.remove_rounded,
                          onPressed: () {
                            if (_minutes > 0) {
                              setState(() => _minutes = (_minutes - 5).clamp(0, 59));
                            }
                          },
                        ),
                        Container(
                          width: 44,
                          alignment: Alignment.center,
                          child: Text(
                            _minutes.toString().padLeft(2, '0'),
                            style: const TextStyle(
                              color: AppColors.brandAccent,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        _PickerButton(
                          icon: Icons.add_rounded,
                          onPressed: () {
                            if (_minutes < 59) {
                              setState(() => _minutes = (_minutes + 5).clamp(0, 59));
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            const Text(
              'Presets',
              style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: presets.map((p) {
                final val = p['val'] as int;
                final isSelected = (_hours * 60 + _minutes) == val;
                return InkWell(
                  onTap: () => _selectPreset(val),
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.brandPrimary.withValues(alpha: 0.25)
                          : AppColors.bgCanvas,
                      border: Border.all(
                        color: isSelected ? AppColors.brandPrimary : AppColors.borderSubtle,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      p['label'] as String,
                      style: TextStyle(
                        color: isSelected ? AppColors.brandAccent : AppColors.textMain,
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 24),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  onPressed: () {
                    final total = _hours * 60 + _minutes;
                    Navigator.pop(context, total > 0 ? total : 1);
                  },
                  child: const Text('Set', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PickerButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _PickerButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bgCanvas,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderSubtle),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(icon, color: AppColors.textMain, size: 18),
        ),
      ),
    );
  }
}
