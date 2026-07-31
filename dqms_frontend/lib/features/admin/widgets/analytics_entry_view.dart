import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/core/widgets/dqms_button.dart';
import 'package:dqms_frontend/core/widgets/dqms_text_field.dart';
import 'package:dqms_frontend/core/widgets/dqms_states.dart';
import 'package:dqms_frontend/features/admin/providers/admin_mock_providers.dart';
import 'package:dqms_frontend/features/admin/widgets/master_detail_layout.dart';

/// ============================================================================
/// ANALYTICS & REPORTS WORKSPACE VIEW (Domain 8)
/// Master-Detail management interface for SLA reports, exports, & audit logs
/// ============================================================================
class AnalyticsEntryView extends ConsumerStatefulWidget {
  const AnalyticsEntryView({super.key});

  @override
  ConsumerState<AnalyticsEntryView> createState() => _AnalyticsEntryViewState();
}

class _AnalyticsEntryViewState extends ConsumerState<AnalyticsEntryView> {
  String _searchQuery = '';
  AnalyticsReportEntryModel? _selectedReport;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminWorkspaceStateProvider);
    final filteredReports = state.analyticsReports.where((r) {
      return r.reportName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          r.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          r.reportId.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return MasterDetailLayout(
      masterWidget: _buildMasterTable(filteredReports),
      detailWidget: _selectedReport != null ? _buildDetailInspector(_selectedReport!) : null,
      detailTitle: _selectedReport != null ? 'Report Inspector — ${_selectedReport!.reportId}' : 'Report Inspector',
      onCloseDetail: () {
        setState(() {
          _selectedReport = null;
        });
      },
    );
  }

  Widget _buildMasterTable(List<AnalyticsReportEntryModel> reports) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Toolbar
          Row(
            children: [
              Expanded(
                child: DqmsTextField(
                  hintText: 'Search Report Name, ID, or Category...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 18),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              DqmsButton(
                label: 'Generate New Audit Report',
                icon: Icons.analytics_rounded,
                onPressed: () {
                  setState(() {
                    _selectedReport = const AnalyticsReportEntryModel(
                      reportId: 'REP-NEW',
                      reportName: 'Live Ad-Hoc SLA Audit',
                      category: 'SLA Compliance',
                      format: 'PDF',
                      lastGeneratedTime: '2026-07-30 17:00',
                      totalRecords: 500,
                    );
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Content
          if (reports.isEmpty)
            const Expanded(
              child: DqmsEmptyState(
                title: 'No Reports Found',
                message: 'No analytics report entries match your search criteria.',
                icon: Icons.assessment_outlined,
              ),
            )
          else
            Expanded(
              child: Column(
                children: [
                  // Table Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.bgHeader,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: const Row(
                      children: [
                        SizedBox(width: 80, child: Text('REPORT ID', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                        Expanded(flex: 3, child: Text('REPORT NAME', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                        Expanded(flex: 2, child: Text('CATEGORY', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                        SizedBox(width: 80, child: Text('FORMAT', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                        SizedBox(width: 130, child: Text('LAST GENERATED', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Rows
                  Expanded(
                    child: ListView.separated(
                      itemCount: reports.length,
                      separatorBuilder: (_, _) => const Divider(color: AppColors.borderSubtle, height: 1),
                      itemBuilder: (ctx, i) {
                        final rpt = reports[i];
                        final isSelected = _selectedReport?.reportId == rpt.reportId;

                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedReport = rpt;
                            });
                          },
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.brandPrimary.withValues(alpha: 0.12) : AppColors.bgCard,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 80,
                                  child: Text(
                                    rpt.reportId,
                                    style: const TextStyle(
                                      color: AppColors.brandPrimary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    rpt.reportName,
                                    style: const TextStyle(color: AppColors.textMain, fontSize: 13, fontWeight: FontWeight.w700),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    rpt.category,
                                    style: const TextStyle(color: AppColors.brandAccent, fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                SizedBox(
                                  width: 80,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.bgSubtle,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      rpt.format,
                                      style: const TextStyle(color: AppColors.textMain, fontSize: 10, fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 130,
                                  child: Text(
                                    rpt.lastGeneratedTime,
                                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontFamily: 'monospace'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailInspector(AnalyticsReportEntryModel rpt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DqmsTextField(label: 'Report Identification ID', initialValue: rpt.reportId),
        const SizedBox(height: 14),
        DqmsTextField(label: 'Report Title', initialValue: rpt.reportName),
        const SizedBox(height: 14),
        DqmsTextField(label: 'Analytics Category', initialValue: rpt.category),
        const SizedBox(height: 14),
        DqmsTextField(label: 'Export Format', initialValue: rpt.format),
        const SizedBox(height: 14),
        DqmsTextField(label: 'Total Audit Records', initialValue: '${rpt.totalRecords} Entries'),
        const SizedBox(height: 24),
        DqmsButton(
          label: 'Export Report (${rpt.format})',
          icon: Icons.file_download_rounded,
          isFullWidth: true,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Exporting ${rpt.reportName} as ${rpt.format}...'), backgroundColor: AppColors.brandPrimary),
            );
          },
        ),
      ],
    );
  }
}
