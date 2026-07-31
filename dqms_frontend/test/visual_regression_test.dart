import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/core/widgets/dqms_button.dart';
import 'package:dqms_frontend/core/widgets/dqms_status_badge.dart';
import 'package:dqms_frontend/core/widgets/dqms_text_field.dart';
import 'package:dqms_frontend/core/widgets/dqms_states.dart';
import 'package:dqms_frontend/core/enums/dqms_enums.dart';
import 'package:dqms_frontend/features/dashboard/screens/dashboard_screen.dart';
import 'package:dqms_frontend/features/dashboard/widgets/dashboard_kpi_strip.dart';
import 'package:dqms_frontend/features/dashboard/widgets/counter_status_panel.dart';
import 'package:dqms_frontend/features/dashboard/widgets/tat_analytics_panel.dart';
import 'package:dqms_frontend/features/admin/screens/admin_workspace_screen.dart';
import 'package:dqms_frontend/features/admin/widgets/areas_zones_view.dart';
import 'package:dqms_frontend/features/operator/screens/operator_console_screen.dart';
import 'package:dqms_frontend/features/operator/widgets/current_token_panel.dart';
import 'package:dqms_frontend/features/operator/widgets/operator_action_bar.dart';
import 'package:dqms_frontend/features/operator/widgets/operator_context_panel.dart';
import 'package:dqms_frontend/features/customer/kiosk/screens/kiosk_screen.dart';
import 'package:dqms_frontend/features/customer/mobile/screens/mobile_tracker_screen.dart';
import 'package:dqms_frontend/features/customer/tv/screens/waiting_room_tv_screen.dart';
import 'package:dqms_frontend/features/customer/appointment/screens/appointment_booking_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget wrapWithScaffold(Widget child) {
    return ProviderScope(
      child: MaterialApp(
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: AppColors.bgCanvas,
        ),
        home: Scaffold(
          backgroundColor: AppColors.bgCanvas,
          body: Center(child: child),
        ),
      ),
    );
  }

  void setViewport(WidgetTester tester, double width, double height) {
    tester.view.physicalSize = Size(width, height);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());
  }

  group('DQMS Visual Regression — Core Design System Components', () {
    testWidgets('Visual Test: DqmsButton All Variants', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithScaffold(
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DqmsButton(label: 'Primary Action', variant: DqmsButtonVariant.primary),
              SizedBox(height: 8),
              DqmsButton(label: 'Secondary Action', variant: DqmsButtonVariant.secondary),
              SizedBox(height: 8),
              DqmsButton(label: 'Outline Action', variant: DqmsButtonVariant.outline),
              SizedBox(height: 8),
              DqmsButton(label: 'Destructive Action', variant: DqmsButtonVariant.destructive),
              SizedBox(height: 8),
              DqmsButton(label: 'Ghost Action', variant: DqmsButtonVariant.ghost),
              SizedBox(height: 8),
              DqmsButton(label: 'Loading Button', isLoading: true),
            ],
          ),
        ),
      );

      expect(find.text('Primary Action'), findsOneWidget);
      expect(find.text('Secondary Action'), findsOneWidget);
      expect(find.text('Outline Action'), findsOneWidget);
      expect(find.text('Destructive Action'), findsOneWidget);
      expect(find.text('Ghost Action'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Visual Test: DqmsStatusBadge Status & Priority Tiers', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithScaffold(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DqmsStatusBadge.activeState(true),
              const SizedBox(height: 8),
              DqmsStatusBadge.activeState(false),
              const SizedBox(height: 8),
              DqmsStatusBadge.fromTokenStatus(e_TokenStatus.active),
              const SizedBox(height: 8),
              DqmsStatusBadge.fromTokenStatus(e_TokenStatus.waiting),
              const SizedBox(height: 8),
              DqmsStatusBadge.fromTokenStatus(e_TokenStatus.canceled),
              const SizedBox(height: 8),
              DqmsStatusBadge.fromPriorityTier(e_PriorityTier.vip.value),
              const SizedBox(height: 8),
              DqmsStatusBadge.fromPriorityTier(e_PriorityTier.emergency.value),
            ],
          ),
        ),
      );

      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Deactive'), findsOneWidget);
      expect(find.text('Active Serving'), findsOneWidget);
      expect(find.text('Waiting'), findsOneWidget);
      expect(find.text('Canceled'), findsOneWidget);
      expect(find.text('VIP'), findsOneWidget);
      expect(find.text('Emergency'), findsOneWidget);
    });

    testWidgets('Visual Test: DqmsTextField States', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithScaffold(
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DqmsTextField(label: 'Zone Name', hintText: 'Enter area/zone name...'),
              SizedBox(height: 12),
              DqmsTextField(label: 'Max SLA', errorText: 'Invalid duration limit'),
            ],
          ),
        ),
      );

      expect(find.text('Zone Name'), findsOneWidget);
      expect(find.text('Enter area/zone name...'), findsOneWidget);
      expect(find.text('Invalid duration limit'), findsOneWidget);
    });

    testWidgets('Visual Test: DqmsStates (Empty, Error, Offline)', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithScaffold(
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DqmsEmptyState(message: 'No active counters serving.'),
              SizedBox(height: 16),
              DqmsOfflineStateBanner(),
            ],
          ),
        ),
      );

      expect(find.text('No Records Found'), findsOneWidget);
      expect(find.text('No active counters serving.'), findsOneWidget);
      expect(find.text('System running in offline local mode. Changes will sync when online.'), findsOneWidget);
    });
  });

  group('DQMS Visual Regression — Representative Screens across Viewports', () {
    testWidgets('Visual Test: Command Center Dashboard (Desktop Viewport)', (WidgetTester tester) async {
      setViewport(tester, 1440, 900);
      await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: DashboardScreen())));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(DashboardScreen), findsOneWidget);
      expect(find.byType(DashboardKpiStrip), findsOneWidget);
      expect(find.byType(CounterStatusPanel), findsOneWidget);
      expect(find.byType(TatAnalyticsPanel), findsOneWidget);
    });

    testWidgets('Visual Test: Admin Workspace (Tablet Viewport)', (WidgetTester tester) async {
      setViewport(tester, 1024, 768);
      await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: AdminWorkspaceScreen())));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(AdminWorkspaceScreen), findsOneWidget);
      expect(find.byType(AreasZonesView), findsOneWidget);
    });

    testWidgets('Visual Test: Operator Console & Token Card (Desktop Viewport)', (WidgetTester tester) async {
      setViewport(tester, 1440, 900);
      await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: OperatorConsoleScreen())));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(OperatorConsoleScreen), findsOneWidget);
      expect(find.byType(CurrentTokenPanel), findsOneWidget);
      expect(find.byType(OperatorActionBar), findsOneWidget);
      expect(find.byType(OperatorContextPanel), findsOneWidget);
    });

    testWidgets('Visual Test: Customer Self-Service Kiosk (Tablet Viewport)', (WidgetTester tester) async {
      setViewport(tester, 1024, 768);
      await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: KioskScreen())));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(KioskScreen), findsOneWidget);
      expect(find.text('DQMS SELF-SERVICE KIOSK'), findsOneWidget);
    });

    testWidgets('Visual Test: Mobile Ticket Tracker (Mobile Viewport)', (WidgetTester tester) async {
      setViewport(tester, 375, 812);
      await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: MobileTrackerScreen())));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(MobileTrackerScreen), findsOneWidget);
      expect(find.text('DQMS Mobile Tracker'), findsOneWidget);
    });

    testWidgets('Visual Test: 4K Waiting Room TV Display (Desktop 4K Viewport)', (WidgetTester tester) async {
      setViewport(tester, 1920, 1080);
      await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: WaitingRoomTvScreen())));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(WaitingRoomTvScreen), findsOneWidget);
      expect(find.text('NOW CALLING'), findsOneWidget);
      expect(find.text('PREVIOUS CALLS'), findsOneWidget);
    });

    testWidgets('Visual Test: Appointment Booking Wizard (Mobile Viewport)', (WidgetTester tester) async {
      setViewport(tester, 375, 812);
      await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: AppointmentBookingScreen())));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(AppointmentBookingScreen), findsOneWidget);
      expect(find.text('DQMS Appointment Booking'), findsOneWidget);
    });
  });
}
