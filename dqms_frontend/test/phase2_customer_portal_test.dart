import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dqms_frontend/features/customer/mobile/screens/mobile_tracker_screen.dart';
import 'package:dqms_frontend/features/customer/providers/customer_experience_provider.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('Phase 2 — Customer Experience Portal Verification', () {
    testWidgets('Tab 0 (Home): Renders Header, Hero Appointment, Quick Actions, and Stats', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MobileTrackerScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      // 1. Header & Title
      expect(find.text('DQMS Mobile Tracker'), findsOneWidget);
      expect(find.textContaining('Good Morning'), findsOneWidget);
      expect(find.text('Green Valley Medical Center'), findsOneWidget);

      // 2. Hero Card & Token Label
      expect(find.text('Your Next Appointment'), findsOneWidget);
      expect(find.text('YOUR TOKEN NUMBER'), findsOneWidget);
      expect(find.text('View Details'), findsOneWidget);

      // 3. Quick Actions
      expect(find.text('Book Appointment'), findsOneWidget);
      expect(find.text('Check In / Scan QR'), findsOneWidget);
      expect(find.text('My Queue Status'), findsOneWidget);
      expect(find.text('View Reports'), findsOneWidget);

      // 4. Quick Stats
      expect(find.text('WAITING'), findsOneWidget);
      expect(find.text('IN SERVICE'), findsOneWidget);
      expect(find.text('COMPLETED'), findsOneWidget);
    });

    testWidgets('Tab 1 (Live Queue): Filter chips and Now Serving card render', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final container = ProviderContainer();
      // Set active tab to Tab 1
      container.read(customerPortalTabProvider.notifier).state = 1;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: MobileTrackerScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      // Live Queue Monitor header
      expect(find.text('Live Queue Monitor'), findsOneWidget);
      expect(find.text('NOW SERVING'), findsWidgets);
      expect(find.text('Dr. Ahmed Rahman'), findsOneWidget);

      // Department Filter Chips
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Consultation'), findsWidgets);
      expect(find.text('Lab'), findsWidgets);
      expect(find.text('Pharmacy'), findsWidgets);

      // Token pills in strip
      expect(find.text('A012'), findsWidgets);
      expect(find.text('A013'), findsWidgets);
    });

    testWidgets('Tab 2 (Appointments): Segmented control and appointment cards render', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final container = ProviderContainer();
      container.read(customerPortalTabProvider.notifier).state = 2;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: MobileTrackerScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('My Appointments'), findsOneWidget);
      expect(find.textContaining('Upcoming'), findsOneWidget);
      expect(find.textContaining('Past'), findsOneWidget);
      expect(find.text('View Pass'), findsWidgets);
    });

    testWidgets('Tab 3 (Profile): Header, statistics, and menu items render', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final container = ProviderContainer();
      container.read(customerPortalTabProvider.notifier).state = 3;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: MobileTrackerScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Verified Patient'), findsOneWidget);
      expect(find.text('Personal Information'), findsOneWidget);
      expect(find.text('Queue History'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('Help & Support'), findsOneWidget);
      expect(find.text('Sign Out'), findsOneWidget);
    });

    testWidgets('Calling simulation toggle activates proceed to counter banner', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MobileTrackerScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      // In initial demo state, calling is active
      expect(find.text('YOUR NUMBER HAS BEEN CALLED!'), findsOneWidget);
      expect(find.text('PROCEED TO C-01'), findsOneWidget);

      // Toggle calling off
      final toggleButton = find.byTooltip('Simulate Called/Waiting State');
      expect(toggleButton, findsOneWidget);
      await tester.tap(toggleButton);
      await tester.pump(const Duration(milliseconds: 500));

      // Now banner should be gone
      expect(find.text('YOUR NUMBER HAS BEEN CALLED!'), findsNothing);
    });
  });
}
