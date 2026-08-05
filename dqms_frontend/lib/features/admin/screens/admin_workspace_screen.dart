import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/core/theme/app_breakpoints.dart';
import 'package:dqms_frontend/features/admin/widgets/areas_zones_view.dart';
import 'package:dqms_frontend/features/admin/widgets/side_menu.dart';

import 'package:dqms_frontend/core/network/dio_provider.dart';
import 'package:dqms_frontend/features/admin/providers/admin_mock_providers.dart';
import 'package:dqms_frontend/features/auth/providers/auth_provider.dart';
import 'package:dqms_frontend/features/admin/providers/config_cache_provider.dart';
import 'package:dqms_frontend/features/admin/providers/navigation_menu_provider.dart';

/// ============================================================================
/// MASTER ADMINISTRATIVE WORKSPACE SCREEN
/// Master container unifying all administrative domain views.
/// Navigation sidebar is dynamically driven from the NavigationMenu database table.
/// ============================================================================
class AdminWorkspaceScreen extends ConsumerStatefulWidget {
  final Widget? child;
  const AdminWorkspaceScreen({super.key, this.child});

  @override
  ConsumerState<AdminWorkspaceScreen> createState() => _AdminWorkspaceScreenState();
}

class _AdminWorkspaceScreenState extends ConsumerState<AdminWorkspaceScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dio = ref.read(dioProvider);
      ref.read(adminWorkspaceStateProvider.notifier).fetchApiData(dio);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppBreakpoints.isDesktop(context);
    final location = GoRouterState.of(context).uri.path;

    // Dynamically load the navigation menu from the provider
    final menuAsync = ref.watch(navigationMenuProvider);
    final navItems = menuAsync.valueOrNull ?? [];

    final activeIndex = navItems.indexWhere((item) => item.routePath == location);
    final currentTitle = activeIndex >= 0 ? navItems[activeIndex].title : 'Admin Workspace';

    return Scaffold(
      backgroundColor: AppColors.bgCanvas,
      drawer: !isDesktop
          ? Drawer(
              child: SideMenu(
                navItems: navItems,
                activeIndex: activeIndex,
                isDrawer: true,
              ),
            )
          : null,
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Full Height Left Sidebar Navigation (Desktop) — Responsive Abu Anwar Pattern
            if (isDesktop)
              SideMenu(
                navItems: navItems,
                activeIndex: activeIndex,
              ),

            // Main Workspace Right Column (Top Header + Dynamic View Content)
            Expanded(
              child: Column(
                children: [
                  // Top Command Header Bar
                  _buildTopCommandHeader(context, currentTitle, isDesktop),

                  // Dynamic View Content
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      color: AppColors.bgCanvas,
                      child: widget.child ?? const AreasZonesView(),
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
  Widget _buildTopCommandHeader(BuildContext context, String currentTitle, bool isDesktop) {
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
            // Mobile / Tablet Drawer Toggle Button
            if (!isDesktop) ...[
              Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.menu_rounded, color: AppColors.textMain),
                  tooltip: 'Open Navigation Menu',
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              ),
              const SizedBox(width: 8),
            ],
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

            // Interactive Master Sync & Cache Purge Button
            InkWell(
              onTap: () {
                ref.read(systemConfigCacheProvider.notifier).invalidate();
                ref.read(categoryParametersCacheProvider.notifier).invalidate();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('⚡ System Configuration & Category Parameters cache invalidated! Re-fetching fresh data from API...'),
                    backgroundColor: AppColors.brandPrimary,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.statusActive.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.statusActive.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.bolt_rounded, color: AppColors.statusActive, size: 12),
                    SizedBox(width: 4),
                    Text('MASTER SYNC (CACHED)', style: TextStyle(color: AppColors.statusActive, fontSize: 10, fontWeight: FontWeight.w800)),
                  ],
                ),
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
                context.push('/dashboard');
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

            // Logged-In User Profile Details with Dropdown & Logout
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'logout') {
                  ref.read(authStateProvider.notifier).logout();
                  context.go('/login');
                }
              },
              tooltip: 'Account Session Options',
              color: AppColors.bgSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: AppColors.borderSubtle),
              ),
              itemBuilder: (context) {
                final user = ref.read(authStateProvider).currentUser;
                return [
                  PopupMenuItem<String>(
                    enabled: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(user?.fullName ?? 'System Admin', style: const TextStyle(color: AppColors.textMain, fontSize: 13, fontWeight: FontWeight.w800)),
                        Text(user?.email ?? 'admin@dnaqms.com', style: const TextStyle(color: AppColors.textSubtle, fontSize: 11)),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout_rounded, size: 16, color: AppColors.statusDeactive),
                        SizedBox(width: 8),
                        Text('Log Out / Switch Tenant', style: TextStyle(color: AppColors.statusDeactive, fontSize: 12, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ];
              },
              child: Builder(
                builder: (context) {
                  final user = ref.watch(authStateProvider).currentUser;
                  return Container(
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
                          child: Text(
                            (user?.fullName.isNotEmpty == true) ? user!.fullName[0].toUpperCase() : 'S',
                            style: const TextStyle(color: AppColors.brandPrimary, fontSize: 10, fontWeight: FontWeight.w800),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Text(user?.fullName ?? 'System Admin', style: const TextStyle(color: AppColors.textMain, fontSize: 11, fontWeight: FontWeight.w700)),
                                const SizedBox(width: 4),
                                Text('(ID: ${user?.userId ?? 1})', style: const TextStyle(color: AppColors.textSubtle, fontSize: 10)),
                              ],
                            ),
                            Text('${user?.roleName ?? "SuperAdmin"} • Role ID: 1', style: const TextStyle(color: AppColors.brandAccent, fontSize: 9, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_drop_down_rounded, size: 16, color: AppColors.textSubtle),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),

            // Standalone Logout Button
            IconButton(
              icon: const Icon(Icons.power_settings_new_rounded, color: AppColors.statusDeactive, size: 20),
              tooltip: 'Sign Out of Account',
              onPressed: () {
                ref.read(authStateProvider.notifier).logout();
                context.go('/login');
              },
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
}
