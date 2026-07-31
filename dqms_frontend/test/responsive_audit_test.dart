import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dqms_frontend/features/dashboard/screens/dashboard_screen.dart';
import 'package:dqms_frontend/features/admin/screens/admin_workspace_screen.dart';
import 'package:dqms_frontend/features/operator/screens/operator_console_screen.dart';
import 'package:dqms_frontend/features/customer/kiosk/screens/kiosk_screen.dart';
import 'package:dqms_frontend/features/customer/mobile/screens/mobile_tracker_screen.dart';
import 'package:dqms_frontend/features/customer/appointment/screens/appointment_booking_screen.dart';
import 'package:dqms_frontend/features/customer/tv/screens/waiting_room_tv_screen.dart';

void main() {
  final viewports = <String, Size>{
    'Mobile Portrait': const Size(375, 812),
    'Mobile Landscape': const Size(812, 375),
    'Tablet Portrait': const Size(768, 1024),
    'Tablet Landscape': const Size(1024, 768),
    'Desktop 4K': const Size(1920, 1080),
  };

  group('DQMS Multi-Viewport Responsive Audit', () {
    for (final entry in viewports.entries) {
      final name = entry.key;
      final size = entry.value;

      testWidgets('Audit DashboardScreen on $name', (WidgetTester tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: DashboardScreen()),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.byType(DashboardScreen), findsOneWidget);
      });

      testWidgets('Audit AdminWorkspaceScreen on $name', (WidgetTester tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: AdminWorkspaceScreen()),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.byType(AdminWorkspaceScreen), findsOneWidget);
      });

      testWidgets('Audit OperatorConsoleScreen on $name', (WidgetTester tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: OperatorConsoleScreen()),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.byType(OperatorConsoleScreen), findsOneWidget);
      });

      testWidgets('Audit KioskScreen on $name', (WidgetTester tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: KioskScreen()),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.byType(KioskScreen), findsOneWidget);
      });

      testWidgets('Audit MobileTrackerScreen on $name', (WidgetTester tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: MobileTrackerScreen()),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.byType(MobileTrackerScreen), findsOneWidget);
      });

      testWidgets('Audit AppointmentBookingScreen on $name', (WidgetTester tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: AppointmentBookingScreen()),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.byType(AppointmentBookingScreen), findsOneWidget);
      });

      testWidgets('Audit WaitingRoomTvScreen on $name', (WidgetTester tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: WaitingRoomTvScreen()),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.byType(WaitingRoomTvScreen), findsOneWidget);
      });
    }
  });
}
