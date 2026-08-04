import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';

// Screens & Views Imports
import 'features/auth/screens/login_screen.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/admin/screens/admin_workspace_screen.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/admin/widgets/areas_zones_view.dart';
import 'features/admin/widgets/processes_view.dart';
import 'features/admin/widgets/counters_view.dart';
import 'features/admin/widgets/display_templates_view.dart';
import 'features/admin/widgets/staff_roles_view.dart';
import 'features/admin/widgets/user_profiles_view.dart';
import 'features/admin/widgets/tenant_master_view.dart';
import 'features/admin/widgets/config_category_parameters_view.dart';
import 'features/admin/widgets/system_config_view.dart';
import 'features/admin/widgets/notification_config_view.dart';
import 'features/admin/widgets/email_config_view.dart';
import 'features/admin/widgets/analytics_entry_view.dart';
import 'features/admin/widgets/app_logs_view.dart';
import 'features/admin/widgets/navigation_menu_view.dart';

import 'features/customer/kiosk/screens/kiosk_screen.dart';
import 'features/customer/mobile/screens/mobile_tracker_screen.dart';
import 'features/customer/appointment/screens/appointment_booking_screen.dart';
import 'features/customer/tv/screens/waiting_room_tv_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: authState.isAuthenticated ? '/admin/areas' : '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return AdminWorkspaceScreen(child: child);
        },
        routes: [
          GoRoute(
            path: '/admin/areas',
            builder: (context, state) => const AreasZonesView(),
          ),
          GoRoute(
            path: '/admin/processes',
            builder: (context, state) => const ProcessesView(),
          ),
          GoRoute(
            path: '/admin/counters',
            builder: (context, state) => const CountersView(),
          ),
          GoRoute(
            path: '/admin/display-templates',
            builder: (context, state) => const DisplayTemplatesView(),
          ),
          GoRoute(
            path: '/admin/staff',
            builder: (context, state) => const StaffRolesView(),
          ),
          GoRoute(
            path: '/admin/user-profiles',
            builder: (context, state) => const UserProfilesView(),
          ),
          GoRoute(
            path: '/admin/tenants',
            builder: (context, state) => const TenantMasterView(),
          ),
          GoRoute(
            path: '/admin/config-categories',
            builder: (context, state) => const ConfigCategoryParametersView(),
          ),
          GoRoute(
            path: '/admin/system-config',
            builder: (context, state) => const SystemConfigView(),
          ),
          GoRoute(
            path: '/admin/notifications',
            builder: (context, state) => const NotificationConfigView(),
          ),
          GoRoute(
            path: '/admin/email',
            builder: (context, state) => const EmailConfigView(),
          ),
          GoRoute(
            path: '/admin/analytics',
            builder: (context, state) => const AnalyticsEntryView(),
          ),
          GoRoute(
            path: '/admin/logs',
            builder: (context, state) => const AppLogsView(),
          ),
          GoRoute(
            path: '/admin/navigation-menu',
            builder: (context, state) => const NavigationMenuView(),
          ),
        ],
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/kiosk',
        builder: (context, state) => const KioskScreen(),
      ),
      GoRoute(
        path: '/mobile',
        builder: (context, state) => const MobileTrackerScreen(),
      ),
      GoRoute(
        path: '/appointment',
        builder: (context, state) => const AppointmentBookingScreen(),
      ),
      GoRoute(
        path: '/tv',
        builder: (context, state) => const WaitingRoomTvScreen(),
      ),
    ],
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isLoggingIn = state.uri.path == '/login';

      if (!isAuthenticated && !isLoggingIn) {
        return '/login';
      }
      if (isAuthenticated && isLoggingIn) {
        return '/admin/areas';
      }
      return null;
    },
  );
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.loadRuntimeConfig();
  runApp(const ProviderScope(child: DqmsApp()));
}

class DqmsApp extends ConsumerWidget {
  const DqmsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'DQMS - Digital Queue Management System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Default Command Center Dark Aesthetic
      routerConfig: router,
    );
  }
}
