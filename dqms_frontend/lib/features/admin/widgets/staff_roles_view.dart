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
/// Master-Detail management interface for personnel access control & RolePermission Matrix
/// ============================================================================
class StaffRolesView extends ConsumerStatefulWidget {
  const StaffRolesView({super.key});

  @override
  ConsumerState<StaffRolesView> createState() => _StaffRolesViewState();
}

class _StaffRolesViewState extends ConsumerState<StaffRolesView> {
  int _activeTab = 0; // 0 = Staff Personnel, 1 = Role & Permission Matrix
  String _searchQuery = '';
  StaffRoleModel? _selectedStaff;

  // RolePermission Matrix State
  String _selectedRole = 'BranchManager';
  
  final Map<String, Set<String>> _rolePermissions = {
    'SuperAdmin': {
      'areas.read', 'areas.write', 'processes.read', 'processes.write',
      'counters.read', 'counters.write', 'counters.manage', 'staff.read',
      'staff.write', 'users.read', 'users.write', 'tenants.read',
      'config.read', 'config.write', 'sysconfig.read', 'notif.read',
      'email.read', 'analytics.read', 'logs.read', 'navmenu.admin', 'reports.export'
    },
    'BranchManager': {
      'areas.read', 'areas.write', 'processes.read', 'processes.write',
      'counters.read', 'counters.write', 'counters.manage', 'staff.read',
      'staff.write', 'users.read', 'config.read', 'analytics.read', 'reports.export'
    },
    'CounterOperator': {
      'counters.read', 'staff.read', 'processes.read', 'areas.read'
    },
    'Receptionist': {
      'areas.read', 'processes.read', 'counters.read', 'staff.read'
    },
    'QualityAuditor': {
      'analytics.read', 'logs.read', 'reports.export', 'areas.read', 'processes.read'
    },
  };

  final List<Map<String, String>> _allPermissions = [
    {'code': 'areas.read', 'name': 'View Areas & Zones', 'category': 'Workspace Layout'},
    {'code': 'areas.write', 'name': 'Manage Areas & Zones', 'category': 'Workspace Layout'},
    {'code': 'processes.read', 'name': 'View Process Pipelines', 'category': 'Process Flow'},
    {'code': 'processes.write', 'name': 'Manage Process Pipelines', 'category': 'Process Flow'},
    {'code': 'counters.read', 'name': 'View Counter Stations', 'category': 'Counter Station'},
    {'code': 'counters.write', 'name': 'Manage Counter Stations', 'category': 'Counter Station'},
    {'code': 'counters.manage', 'name': 'Assign Operator to Counter', 'category': 'Counter Station'},
    {'code': 'staff.read', 'name': 'View Staff Roster', 'category': 'Personnel Access'},
    {'code': 'staff.write', 'name': 'Create & Edit Staff', 'category': 'Personnel Access'},
    {'code': 'users.read', 'name': 'View User Profiles', 'category': 'Personnel Access'},
    {'code': 'users.write', 'name': 'Manage User Credentials', 'category': 'Personnel Access'},
    {'code': 'navmenu.admin', 'name': 'Administer Navigation Menu', 'category': 'System Administration'},
    {'code': 'config.read', 'name': 'View Config Parameters', 'category': 'System Configuration'},
    {'code': 'config.write', 'name': 'Edit System Parameters', 'category': 'System Configuration'},
    {'code': 'sysconfig.read', 'name': 'View Key Vault Configs', 'category': 'System Configuration'},
    {'code': 'analytics.read', 'name': 'View Analytics & KPI Hub', 'category': 'Audit & Reporting'},
    {'code': 'logs.read', 'name': 'View Application & Audit Logs', 'category': 'Audit & Reporting'},
    {'code': 'reports.export', 'name': 'Export Compliance Reports', 'category': 'Audit & Reporting'},
  ];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminWorkspaceStateProvider);
    final filteredStaff = state.staffMembers.where((s) {
      return s.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.staffCode.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.roleName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tab Header Switcher
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Row(
            children: [
              _buildTabButton(0, 'Staff Roster & Accounts', Icons.people_alt_rounded),
              const SizedBox(width: 12),
              _buildTabButton(1, 'Role & Permission Matrix Configurator', Icons.shield_rounded),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Active View Body
        Expanded(
          child: _activeTab == 0
              ? MasterDetailLayout(
                  masterWidget: _buildMasterTable(filteredStaff),
                  detailWidget: _selectedStaff != null ? _buildDetailInspector(_selectedStaff!) : null,
                  detailTitle: _selectedStaff != null ? 'Staff Inspector — ${_selectedStaff!.staffCode}' : 'Staff Inspector',
                  onCloseDetail: () => setState(() => _selectedStaff = null),
                )
              : _buildRolePermissionMatrixConfigurator(),
        ),
      ],
    );
  }

  Widget _buildTabButton(int index, String label, IconData icon) {
    final isSelected = _activeTab == index;
    return InkWell(
      onTap: () => setState(() => _activeTab = index),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandPrimary.withValues(alpha: 0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isSelected ? AppColors.brandPrimary : Colors.transparent),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isSelected ? AppColors.brandPrimary : AppColors.textSubtle),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.brandPrimary : AppColors.textSubtle,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRolePermissionMatrixConfigurator() {
    final currentPermissions = _rolePermissions[_selectedRole] ?? {};

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selector Bar
          Row(
            children: [
              const Icon(Icons.security_rounded, size: 20, color: AppColors.brandAccent),
              const SizedBox(width: 10),
              const Text('Select Target Role:', style: TextStyle(color: AppColors.textMain, fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(width: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedRole,
                    dropdownColor: AppColors.bgSurface,
                    style: const TextStyle(color: AppColors.brandPrimary, fontSize: 13, fontWeight: FontWeight.w800),
                    items: _rolePermissions.keys.map((r) {
                      return DropdownMenuItem(value: r, child: Text('Role: $r'));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedRole = val);
                    },
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                icon: const Icon(Icons.save_rounded, size: 16),
                label: Text('Save Permissions for $_selectedRole', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('RolePermission matrix updated for $_selectedRole (${currentPermissions.length} permissions assigned).'),
                      backgroundColor: AppColors.statusActive,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.borderSubtle),
          const SizedBox(height: 12),

          Row(
            children: [
              Text('Assigned Permissions (${currentPermissions.length} / ${_allPermissions.length})', style: const TextStyle(color: AppColors.textMain, fontSize: 13, fontWeight: FontWeight.w700)),
              const Spacer(),
              TextButton.icon(
                icon: const Icon(Icons.select_all_rounded, size: 14),
                label: const Text('Select All', style: TextStyle(fontSize: 11)),
                onPressed: () {
                  setState(() {
                    _rolePermissions[_selectedRole] = _allPermissions.map((p) => p['code']!).toSet();
                  });
                },
              ),
              TextButton.icon(
                icon: const Icon(Icons.deselect_rounded, size: 14),
                label: const Text('Deselect All', style: TextStyle(fontSize: 11)),
                onPressed: () {
                  setState(() {
                    _rolePermissions[_selectedRole] = {};
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Checkbox Grid Matrix
          Expanded(
            child: ListView.separated(
              itemCount: _allPermissions.length,
              separatorBuilder: (_, _) => const Divider(color: AppColors.borderSubtle, height: 1),
              itemBuilder: (ctx, i) {
                final perm = _allPermissions[i];
                final code = perm['code']!;
                final name = perm['name']!;
                final category = perm['category']!;
                final isGranted = currentPermissions.contains(code);

                return CheckboxListTile(
                  dense: true,
                  activeColor: AppColors.brandPrimary,
                  checkColor: Colors.white,
                  title: Row(
                    children: [
                      Text(name, style: const TextStyle(color: AppColors.textMain, fontSize: 13, fontWeight: FontWeight.w700)),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.brandAccent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(category, style: const TextStyle(color: AppColors.brandAccent, fontSize: 10, fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                  subtitle: Text('Permission Code: $code', style: const TextStyle(color: AppColors.textSubtle, fontSize: 11, fontFamily: 'monospace')),
                  value: isGranted,
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        currentPermissions.add(code);
                      } else {
                        currentPermissions.remove(code);
                      }
                      _rolePermissions[_selectedRole] = currentPermissions;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
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

