import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/core/theme/app_breakpoints.dart';
import 'package:dqms_frontend/features/dashboard/screens/dashboard_screen.dart';
import 'package:dqms_frontend/features/admin/widgets/areas_zones_view.dart';
import 'package:dqms_frontend/features/admin/widgets/processes_view.dart';
import 'package:dqms_frontend/features/admin/widgets/counters_view.dart';
import 'package:dqms_frontend/features/admin/widgets/display_templates_view.dart';
import 'package:dqms_frontend/features/admin/widgets/staff_roles_view.dart';
import 'package:dqms_frontend/features/admin/widgets/user_profiles_view.dart';
import 'package:dqms_frontend/features/admin/widgets/tenant_master_view.dart';
import 'package:dqms_frontend/features/admin/widgets/config_category_parameters_view.dart';
import 'package:dqms_frontend/features/admin/widgets/system_config_view.dart';
import 'package:dqms_frontend/features/admin/widgets/notification_config_view.dart';
import 'package:dqms_frontend/features/admin/widgets/email_config_view.dart';
import 'package:dqms_frontend/features/admin/widgets/analytics_entry_view.dart';

import 'package:dqms_frontend/core/network/dio_provider.dart';
import 'package:dqms_frontend/features/admin/providers/admin_mock_providers.dart';

/// Navigation Item Model
class _AdminNavItem {
  final String title;
  final IconData icon;
  final Widget view;

  const _AdminNavItem({
    required this.title,
    required this.icon,
    required this.view,
  });
}

/// ============================================================================
/// MASTER ADMINISTRATIVE WORKSPACE SCREEN
/// Master container unifying all administrative domain views
/// ============================================================================
class AdminWorkspaceScreen extends ConsumerStatefulWidget {
  const AdminWorkspaceScreen({super.key});

  @override
  ConsumerState<AdminWorkspaceScreen> createState() => _AdminWorkspaceScreenState();
}

class _AdminWorkspaceScreenState extends ConsumerState<AdminWorkspaceScreen> {
  int _selectedDomainIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dio = ref.read(dioProvider);
      ref.read(adminWorkspaceStateProvider.notifier).fetchApiData(dio);
    });
  }

  static const List<_AdminNavItem> _navItems = [
    _AdminNavItem(title: 'Areas & Zones', icon: Icons.grid_view_rounded, view: AreasZonesView()),
    _AdminNavItem(title: 'Process Pipelines', icon: Icons.account_tree_rounded, view: ProcessesView()),
    _AdminNavItem(title: 'Counter Stations', icon: Icons.desk_rounded, view: CountersView()),
    _AdminNavItem(title: 'Display Templates', icon: Icons.tv_rounded, view: DisplayTemplatesView()),
    _AdminNavItem(title: 'Staff & Roles', icon: Icons.badge_rounded, view: StaffRolesView()),
    _AdminNavItem(title: 'User Profiles & Add/Edit', icon: Icons.person_search_rounded, view: UserProfilesView()),
    _AdminNavItem(title: 'Tenant / Organization Master', icon: Icons.business_rounded, view: TenantMasterView()),
    _AdminNavItem(title: 'Config Categories & Params', icon: Icons.category_rounded, view: ConfigCategoryParametersView()),
    _AdminNavItem(title: 'System Config Keys', icon: Icons.settings_suggest_rounded, view: SystemConfigView()),
    _AdminNavItem(title: 'Notification Channels', icon: Icons.notifications_active_rounded, view: NotificationConfigView()),
    _AdminNavItem(title: 'Email Gateway Setup', icon: Icons.mark_email_read_rounded, view: EmailConfigView()),
    _AdminNavItem(title: 'Analytics Hub', icon: Icons.analytics_rounded, view: AnalyticsEntryView()),
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppBreakpoints.isDesktop(context);
    final currentDomain = _navItems[_selectedDomainIndex];

    return Scaffold(
      backgroundColor: AppColors.bgCanvas,
      body: SafeArea(
        child: Column(
          children: [
            // Top Workspace Command Header
            _buildTopCommandHeader(context, currentDomain.title),

            // Workspace Body Layout
            Expanded(
              child: Row(
                children: [
                  // Sidebar Navigation (Desktop)
                  if (isDesktop) _buildSidebarNav(),

                  // Main Content View
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      color: AppColors.bgCanvas,
                      child: IndexedStack(
                        index: _selectedDomainIndex,
                        children: _navItems.map((item) => item.view).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Top Operational Command Header
  Widget _buildTopCommandHeader(BuildContext context, String currentTitle) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: AppColors.bgHeader,
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle, width: 1)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.brandPrimary.withValues(alpha: 0.15),
                border: Border.all(color: AppColors.brandPrimary.withValues(alpha: 0.4)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'ADMIN WORKSPACE',
                style: TextStyle(
                  color: AppColors.brandPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(width: 14),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSubtle, size: 18),
            const SizedBox(width: 8),

            // Current Domain Breadcrumb
            Text(
              currentTitle,
              style: const TextStyle(
                color: AppColors.textMain,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 14),

            // Live Sync Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.statusActive.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.statusActive.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.fiber_manual_record, color: AppColors.statusActive, size: 8),
                  SizedBox(width: 5),
                  Text('MASTER SYNC', style: TextStyle(color: AppColors.statusActive, fontSize: 10, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const SizedBox(width: 20),

            // Link to Command Center Dashboard
            OutlinedButton.icon(
              icon: const Icon(Icons.dashboard_customize_rounded, size: 14),
              label: const Text('Command Center Dashboard', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.brandPrimary,
                side: const BorderSide(color: AppColors.brandPrimary),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
              },
            ),
            const SizedBox(width: 20),

            // Notification Bell with Unread Count Badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_rounded, color: AppColors.textMain, size: 20),
                  tooltip: 'In-App Notification Feed',
                  onPressed: () => _showNotificationFeedModal(context),
                ),
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.statusDeactive,
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      '3',
                      style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),

            // Logged-In System Admin User Profile Details
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: AppColors.brandPrimary.withValues(alpha: 0.2),
                    child: const Text(
                      'SA',
                      style: TextStyle(color: AppColors.brandPrimary, fontSize: 10, fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Text('System Admin', style: TextStyle(color: AppColors.textMain, fontSize: 11, fontWeight: FontWeight.w700)),
                          SizedBox(width: 4),
                          Text('(ID: 1)', style: TextStyle(color: AppColors.textSubtle, fontSize: 10)),
                        ],
                      ),
                      Text('SuperAdmin • Role ID: 1', style: TextStyle(color: AppColors.brandAccent, fontSize: 9, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.statusActive,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Interactive In-App Notification Feed Drawer/Modal
  void _showNotificationFeedModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.borderSubtle),
        ),
        title: Row(
          children: [
            const Icon(Icons.notifications_active_rounded, color: AppColors.brandPrimary, size: 20),
            const SizedBox(width: 10),
            const Text('In-App Notification Feed', style: TextStyle(color: AppColors.textMain, fontSize: 16, fontWeight: FontWeight.w700)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.statusDeactive.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('3 Unread Intimations', style: TextStyle(color: AppColors.statusDeactive, fontSize: 10, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildNotificationTile(
                title: 'Payment Received — INV-2026-0091',
                message: '\$499.00 USD received for Main HQ Center. Event ID: 17001',
                time: '2 Mins Ago',
                channel: 'InApp + Email',
                isUnread: true,
                icon: Icons.payments_rounded,
                iconColor: AppColors.statusActive,
              ),
              const Divider(color: AppColors.borderSubtle, height: 1),
              _buildNotificationTile(
                title: 'System SLA Breach Alert',
                message: 'Counter C-04 SLA exceeded 15 minute warning threshold.',
                time: '18 Mins Ago',
                channel: 'InApp + SMS',
                isUnread: true,
                icon: Icons.warning_amber_rounded,
                iconColor: AppColors.statusWarning,
              ),
              const Divider(color: AppColors.borderSubtle, height: 1),
              _buildNotificationTile(
                title: 'Approval Requested — Process Pipeline',
                message: 'New Consultation Pipeline PROC-501 pending admin sign-off.',
                time: '1 Hour Ago',
                channel: 'InApp',
                isUnread: true,
                icon: Icons.assignment_ind_rounded,
                iconColor: AppColors.brandPrimary,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close Feed', style: TextStyle(color: AppColors.textMuted)),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile({
    required String title,
    required String message,
    required String time,
    required String channel,
    required bool isUnread,
    required IconData icon,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(title, style: const TextStyle(color: AppColors.textMain, fontSize: 13, fontWeight: FontWeight.w700)),
                    ),
                    Text(time, style: const TextStyle(color: AppColors.textSubtle, fontSize: 10)),
                  ],
                ),
                const SizedBox(height: 3),
                Text(message, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                const SizedBox(height: 4),
                Text('Channels: $channel', style: const TextStyle(color: AppColors.brandAccent, fontSize: 10, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }


  /// Left Sidebar Navigation Bar
  Widget _buildSidebarNav() {
    return Container(
      width: 240,
      decoration: const BoxDecoration(
        color: AppColors.bgSurface,
        border: Border(right: BorderSide(color: AppColors.borderSubtle, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Text(
              'ADMIN DOMAINS',
              style: TextStyle(
                color: AppColors.textSubtle,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
          ),

          // Domain Navigation Items
          Expanded(
            child: ListView.builder(
              itemCount: _navItems.length,
              itemBuilder: (ctx, i) {
                final item = _navItems[i];
                final isSelected = _selectedDomainIndex == i;

                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedDomainIndex = i;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.brandPrimary.withValues(alpha: 0.15) : Colors.transparent,
                      border: Border(
                        left: BorderSide(
                          color: isSelected ? AppColors.brandPrimary : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          item.icon,
                          color: isSelected ? AppColors.brandPrimary : AppColors.textMuted,
                          size: 18,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              color: isSelected ? AppColors.textMain : AppColors.textMuted,
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Footer Org Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.borderSubtle)),
            ),
            child: const Row(
              children: [
                Icon(Icons.business_rounded, color: AppColors.textSubtle, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'DQMS Enterprise v1.0',
                    style: TextStyle(color: AppColors.textSubtle, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
