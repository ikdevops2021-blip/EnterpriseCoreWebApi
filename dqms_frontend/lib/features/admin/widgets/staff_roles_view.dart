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
/// STAFF & ROLES WORKSPACE VIEW (Domain 5)
/// Master-Detail management interface for personnel access control & counters
/// ============================================================================
class StaffRolesView extends ConsumerStatefulWidget {
  const StaffRolesView({super.key});

  @override
  ConsumerState<StaffRolesView> createState() => _StaffRolesViewState();
}

class _StaffRolesViewState extends ConsumerState<StaffRolesView> {
  String _searchQuery = '';
  StaffRoleModel? _selectedStaff;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminWorkspaceStateProvider);
    final filteredStaff = state.staffMembers.where((s) {
      return s.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.staffCode.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.roleName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return MasterDetailLayout(
      masterWidget: _buildMasterTable(filteredStaff),
      detailWidget: _selectedStaff != null ? _buildDetailInspector(_selectedStaff!) : null,
      detailTitle: _selectedStaff != null ? 'Staff Inspector — ${_selectedStaff!.staffCode}' : 'Staff Inspector',
      onCloseDetail: () {
        setState(() {
          _selectedStaff = null;
        });
      },
    );
  }

  Widget _buildMasterTable(List<StaffRoleModel> staffList) {
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
                  hintText: 'Search Staff Code, Name, Role, or Email...',
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
                label: 'Add Staff Member',
                icon: Icons.person_add_alt_1_rounded,
                onPressed: () {
                  setState(() {
                    _selectedStaff = const StaffRoleModel(
                      staffId: 999,
                      staffCode: 'STF-NEW',
                      fullName: 'New Staff Member',
                      email: 'new.staff@dqms.org',
                      roleName: 'CounterOperator',
                      assignedCounterNumber: 'C-01',
                      status: 'Active',
                    );
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Content
          if (staffList.isEmpty)
            const Expanded(
              child: DqmsEmptyState(
                title: 'No Staff Members Found',
                message: 'No staff personnel match your search criteria.',
                icon: Icons.people_outline_rounded,
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
                        SizedBox(width: 80, child: Text('STAFF ID', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                        Expanded(flex: 3, child: Text('FULL NAME & EMAIL', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                        Expanded(flex: 2, child: Text('ROLE PERMISSION', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                        SizedBox(width: 110, child: Text('ASSIGNED STATION', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                        SizedBox(width: 90, child: Text('STATUS', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Rows
                  Expanded(
                    child: ListView.separated(
                      itemCount: staffList.length,
                      separatorBuilder: (_, _) => const Divider(color: AppColors.borderSubtle, height: 1),
                      itemBuilder: (ctx, i) {
                        final stf = staffList[i];
                        final isSelected = _selectedStaff?.staffId == stf.staffId;

                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedStaff = stf;
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
                                    stf.staffCode,
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
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(stf.fullName, style: const TextStyle(color: AppColors.textMain, fontSize: 13, fontWeight: FontWeight.w700)),
                                      Text(stf.email, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: _buildRoleBadge(stf.roleName),
                                ),
                                SizedBox(
                                  width: 110,
                                  child: Text(
                                    stf.assignedCounterNumber,
                                    style: const TextStyle(color: AppColors.brandAccent, fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'monospace'),
                                  ),
                                ),
                                SizedBox(
                                  width: 90,
                                  child: DqmsStatusBadge.activeState(stf.status == 'Active'),
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

  Widget _buildRoleBadge(String role) {
    Color badgeColor;
    if (role == 'SuperAdmin') {
      badgeColor = AppColors.statusDeactive;
    } else if (role == 'BranchManager') {
      badgeColor = AppColors.statusSpecial;
    } else {
      badgeColor = AppColors.brandPrimary;
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: badgeColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
          ),
          child: Text(
            role,
            style: TextStyle(color: badgeColor, fontSize: 10, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailInspector(StaffRoleModel stf) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DqmsTextField(label: 'Staff Identification Code', initialValue: stf.staffCode),
        const SizedBox(height: 14),
        DqmsTextField(label: 'Full Name', initialValue: stf.fullName),
        const SizedBox(height: 14),
        DqmsTextField(label: 'Official Email', initialValue: stf.email),
        const SizedBox(height: 14),
        DqmsTextField(label: 'Role Permission Level', initialValue: stf.roleName),
        const SizedBox(height: 14),
        DqmsTextField(label: 'Assigned Counter Station', initialValue: stf.assignedCounterNumber),
        const SizedBox(height: 24),
        DqmsButton(
          label: 'Save Staff Profile',
          icon: Icons.save_rounded,
          isFullWidth: true,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Staff Profile for ${stf.fullName} updated.'), backgroundColor: AppColors.statusActive),
            );
          },
        ),
      ],
    );
  }
}
