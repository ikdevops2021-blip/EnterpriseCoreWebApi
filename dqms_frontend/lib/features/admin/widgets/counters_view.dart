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
/// COUNTER STATIONS WORKSPACE VIEW (Domain 3)
/// Master-Detail management interface for physical windows and operator desks
/// ============================================================================
class CountersView extends ConsumerStatefulWidget {
  const CountersView({super.key});

  @override
  ConsumerState<CountersView> createState() => _CountersViewState();
}

class _CountersViewState extends ConsumerState<CountersView> {
  String _searchQuery = '';
  CounterModel? _selectedCounter;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminWorkspaceStateProvider);
    final filteredCounters = state.counters.where((c) {
      return c.counterName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.counterNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.assignedStaffName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return MasterDetailLayout(
      masterWidget: _buildMasterTable(filteredCounters),
      detailWidget: _selectedCounter != null ? _buildDetailInspector(_selectedCounter!) : null,
      detailTitle: _selectedCounter != null ? 'Counter Inspector — ${_selectedCounter!.counterNumber}' : 'Counter Inspector',
      onCloseDetail: () {
        setState(() {
          _selectedCounter = null;
        });
      },
    );
  }

  Widget _buildMasterTable(List<CounterModel> counters) {
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
                  hintText: 'Search Counter ID, Name, or Staff...',
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
                label: 'New Counter',
                icon: Icons.add_rounded,
                onPressed: () {
                  setState(() {
                    _selectedCounter = const CounterModel(
                      counterId: 999,
                      areaId: 1,
                      areaName: 'Main Service Hall A',
                      counterNumber: 'C-NEW',
                      counterName: 'New Operating Station',
                      mode: 'SingleProcess',
                      assignedStaffName: 'Unassigned Staff',
                      status: 'Idle',
                      isVoiceEnabled: true,
                    );
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // List / Table Content
          if (counters.isEmpty)
            const Expanded(
              child: DqmsEmptyState(
                title: 'No Counters Found',
                message: 'No physical counter stations match your search query.',
                icon: Icons.desk_rounded,
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
                        SizedBox(width: 70, child: Text('STATION', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                        Expanded(flex: 3, child: Text('COUNTER NAME', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                        Expanded(flex: 2, child: Text('FACILITY ZONE', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                        Expanded(flex: 2, child: Text('ASSIGNED OPERATOR', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                        SizedBox(width: 100, child: Text('MODE', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                        SizedBox(width: 90, child: Text('STATUS', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Rows
                  Expanded(
                    child: ListView.separated(
                      itemCount: counters.length,
                      separatorBuilder: (_, _) => const Divider(color: AppColors.borderSubtle, height: 1),
                      itemBuilder: (ctx, i) {
                        final ctr = counters[i];
                        final isSelected = _selectedCounter?.counterId == ctr.counterId;

                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedCounter = ctr;
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
                                  width: 70,
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
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    ctr.counterName,
                                    style: const TextStyle(color: AppColors.textMain, fontSize: 13, fontWeight: FontWeight.w600),
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
                                  child: Text(
                                    ctr.assignedStaffName,
                                    style: const TextStyle(color: AppColors.brandAccent, fontSize: 12, fontWeight: FontWeight.w600),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    ctr.mode,
                                    style: const TextStyle(color: AppColors.textSubtle, fontSize: 11),
                                  ),
                                ),
                                SizedBox(
                                  width: 90,
                                  child: DqmsStatusBadge.activeState(ctr.status == 'Active'),
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

  Widget _buildDetailInspector(CounterModel ctr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DqmsTextField(label: 'Counter Station Code', initialValue: ctr.counterNumber),
        const SizedBox(height: 14),
        DqmsTextField(label: 'Counter Name', initialValue: ctr.counterName),
        const SizedBox(height: 14),
        DqmsTextField(label: 'Assigned Operator', initialValue: ctr.assignedStaffName),
        const SizedBox(height: 14),
        DqmsTextField(label: 'Operating Mode', initialValue: ctr.mode),
        const SizedBox(height: 16),
        Row(
          children: [
            const Text('Audio Voice Announcement:', style: TextStyle(color: AppColors.textMain, fontSize: 12, fontWeight: FontWeight.w600)),
            const Spacer(),
            Switch(
              value: ctr.isVoiceEnabled,
              activeTrackColor: AppColors.brandPrimary,
              onChanged: (val) {},
            ),
          ],
        ),
        const SizedBox(height: 24),
        DqmsButton(
          label: 'Save Counter Setup',
          icon: Icons.save_rounded,
          isFullWidth: true,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Counter ${ctr.counterNumber} updated.'), backgroundColor: AppColors.statusActive),
            );
          },
        ),
      ],
    );
  }
}
