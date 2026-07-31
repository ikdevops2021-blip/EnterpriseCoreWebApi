import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
/// ============================================================================
class ProcessesView extends ConsumerStatefulWidget {
  const ProcessesView({super.key});

  @override
  ConsumerState<ProcessesView> createState() => _ProcessesViewState();
}

class _ProcessesViewState extends ConsumerState<ProcessesView> {
  String _searchQuery = '';
  ProcessModel? _selectedProcess;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminWorkspaceStateProvider);
    final filteredProcesses = state.processes.where((p) {
      return p.processName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.processCode.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.areaName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return MasterDetailLayout(
      masterWidget: _buildMasterTable(filteredProcesses),
      detailWidget: _selectedProcess != null ? _buildDetailInspector(_selectedProcess!) : null,
      detailTitle: _selectedProcess != null ? 'Process Inspector — ${_selectedProcess!.processCode}' : 'Process Inspector',
      onCloseDetail: () {
        setState(() {
          _selectedProcess = null;
        });
      },
    );
  }

  Widget _buildMasterTable(List<ProcessModel> processes) {
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
                  hintText: 'Search Process Code, Name, or Zone...',
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
                label: 'New Process',
                icon: Icons.add_rounded,
                onPressed: () {
                  setState(() {
                    _selectedProcess = const ProcessModel(
                      processId: 999,
                      areaId: 1,
                      areaName: 'Main Service Hall A',
                      processCode: 'PROC-NEW',
                      processName: 'New Clinical Workflow',
                      targetSlaMins: 15,
                      allowSubTokens: true,
                      priorityLevel: 'Standard',
                      isActive: true,
                    );
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // List / Table Content
          if (processes.isEmpty)
            const Expanded(
              child: DqmsEmptyState(
                title: 'No Processes Found',
                message: 'No service pipeline workflows match your search query.',
                icon: Icons.account_tree_outlined,
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
                        SizedBox(width: 90, child: Text('CODE', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                        Expanded(flex: 3, child: Text('PROCESS PIPELINE NAME', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                        Expanded(flex: 2, child: Text('FACILITY ZONE', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                        SizedBox(width: 90, child: Text('SLA TAT', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                        SizedBox(width: 100, child: Text('SUB-TOKENS', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                        SizedBox(width: 90, child: Text('STATUS', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Rows
                  Expanded(
                    child: ListView.separated(
                      itemCount: processes.length,
                      separatorBuilder: (_, _) => const Divider(color: AppColors.borderSubtle, height: 1),
                      itemBuilder: (ctx, i) {
                        final proc = processes[i];
                        final isSelected = _selectedProcess?.processId == proc.processId;

                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedProcess = proc;
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
                                  width: 90,
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
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    proc.processName,
                                    style: const TextStyle(color: AppColors.textMain, fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    proc.areaName,
                                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(
                                  width: 90,
                                  child: Text(
                                    '${proc.targetSlaMins}m Target',
                                    style: const TextStyle(color: AppColors.brandAccent, fontSize: 11, fontWeight: FontWeight.w700),
                                  ),
                                ),
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    proc.allowSubTokens ? 'Allowed' : 'Disabled',
                                    style: TextStyle(
                                      color: proc.allowSubTokens ? AppColors.statusActive : AppColors.textDisabled,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 90,
                                  child: DqmsStatusBadge.activeState(proc.isActive),
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

  Widget _buildDetailInspector(ProcessModel proc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DqmsTextField(label: 'Process Code', initialValue: proc.processCode),
        const SizedBox(height: 14),
        DqmsTextField(label: 'Process Name', initialValue: proc.processName),
        const SizedBox(height: 14),
        DqmsTextField(label: 'Assigned Area / Zone', initialValue: proc.areaName),
        const SizedBox(height: 14),
        DqmsTextField(label: 'Target SLA Minutes', initialValue: '${proc.targetSlaMins}'),
        const SizedBox(height: 16),
        Row(
          children: [
            const Text('Allow Sub-Tokens:', style: TextStyle(color: AppColors.textMain, fontSize: 12, fontWeight: FontWeight.w600)),
            const Spacer(),
            Switch(
              value: proc.allowSubTokens,
              activeTrackColor: AppColors.brandPrimary,
              onChanged: (val) {},
            ),
          ],
        ),
        const SizedBox(height: 24),
        DqmsButton(
          label: 'Save Process Pipeline',
          icon: Icons.save_rounded,
          isFullWidth: true,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Process ${proc.processCode} updated.'), backgroundColor: AppColors.statusActive),
            );
          },
        ),
      ],
    );
  }
}
