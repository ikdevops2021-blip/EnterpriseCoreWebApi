import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dqms_frontend/main.dart';
import 'package:dqms_frontend/core/theme/app_theme.dart';
import 'package:dqms_frontend/core/widgets/dqms_button.dart';
import 'package:dqms_frontend/core/widgets/dqms_status_badge.dart';
import 'package:dqms_frontend/features/dashboard/screens/dashboard_screen.dart';
import 'package:dqms_frontend/features/admin/screens/admin_workspace_screen.dart';
import 'package:dqms_frontend/features/operator/screens/operator_console_screen.dart';
import 'package:dqms_frontend/features/customer/kiosk/screens/kiosk_screen.dart';
import 'package:dqms_frontend/features/customer/mobile/screens/mobile_tracker_screen.dart';
import 'package:dqms_frontend/features/customer/appointment/screens/appointment_booking_screen.dart';
import 'package:dqms_frontend/features/customer/tv/screens/waiting_room_tv_screen.dart';

void main() {
  testWidgets('DQMS Design System components smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: Column(
            children: [
              const DqmsButton(label: 'Test Button'),
              DqmsStatusBadge.activeState(true),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Test Button'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
  });

  testWidgets('DQMS App startup test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: DqmsApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    // LoginScreen is the entry point — verify login form text is visible
    expect(find.text('Sign In to Account'), findsOneWidget);
  });

  testWidgets('DQMS Command Center DashboardScreen smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: DashboardScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('COMMAND CENTER'), findsOneWidget);
    expect(find.text('WAITING CUSTOMERS'), findsOneWidget);
    expect(find.text('CURRENTLY SERVING'), findsOneWidget);
    expect(find.text('COUNTER STATIONS MATRIX'), findsOneWidget);
    expect(find.text('BOTTLENECK & CONGESTION ALERTS'), findsOneWidget);
  });

  testWidgets('DQMS Admin Workspace Screen smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: AdminWorkspaceScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('ADMIN WORKSPACE'), findsOneWidget);
    expect(find.text('Areas & Zones'), findsWidgets);
    expect(find.text('Process Pipelines'), findsWidgets);
    expect(find.text('Counter Stations'), findsWidgets);
  });

  testWidgets('DQMS Counter Operator Console smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: OperatorConsoleScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('COUNTER OPERATOR CONSOLE'), findsOneWidget);
    expect(find.text('CURRENT ACTIVE TOKEN'), findsOneWidget);
    expect(find.text('CALL NEXT CUSTOMER'), findsOneWidget);
    expect(find.text('WAITING QUEUE DENSITY'), findsOneWidget);
  });

  testWidgets('DQMS Phase 6 Kiosk Screen smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: KioskScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('DQMS SELF-SERVICE KIOSK'), findsOneWidget);
    expect(find.text('TOUCH TO BEGIN'), findsOneWidget);
  });

  testWidgets('DQMS Phase 6 Mobile Tracker Screen smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: MobileTrackerScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('DQMS Mobile Tracker'), findsOneWidget);
    expect(find.text('YOUR TOKEN NUMBER'), findsOneWidget);
  });

  testWidgets('DQMS Phase 6 Appointment Booking Screen smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: AppointmentBookingScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('DQMS Appointment Booking'), findsOneWidget);
    expect(find.text('HQ Main Medical Center'), findsOneWidget);
  });

  testWidgets('DQMS Phase 6 Waiting Room 4K TV Screen smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: WaitingRoomTvScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('DQMS TV DISPLAY'), findsOneWidget);
    expect(find.text('NOW CALLING'), findsOneWidget);
    expect(find.text('PREVIOUS CALLS'), findsOneWidget);
  });
}
