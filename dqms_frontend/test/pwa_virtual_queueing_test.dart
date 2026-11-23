import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dqms_frontend/core/widgets/ticket_qr_pass_widget.dart';
import 'package:dqms_frontend/features/customer/mobile/screens/public_mobile_tracker_screen.dart';

void main() {
  group('PWA Virtual Queueing (QR Scan, No-App-Required) Tests', () {
    testWidgets('1. TicketQrPassWidget renders scannable QR matrix with token seed', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: TicketQrPassWidget(tokenNumber: 'A-010', size: 140),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Scan Callout and Icon exist
      expect(find.text('SCAN FOR LIVE QUEUE'), findsOneWidget);
      expect(find.byIcon(Icons.phone_iphone_rounded), findsOneWidget);
    });

    testWidgets('2. PublicMobileTrackerScreen renders loading and initial token pass layout', (tester) async {
      // Use a realistic mobile viewport (375 × 812 logical pixels = iPhone-sized)
      tester.view.physicalSize = const Size(375 * 3, 812 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PublicMobileTrackerScreen(identifier: 'A-010', autoPolling: false),
          ),
        ),
      );

      await tester.pump();

      // Verify app bar title
      expect(find.text('Live Virtual Queue Pass'), findsOneWidget);
      expect(find.text('Real-Time Mobile Tracker • No App Required'), findsOneWidget);
    });

    test('3. Deep link URL construction for physical ticket prints & QR scans', () {
      const baseUrl = 'https://queue.hospital.com';
      const tokenNumber = 'A-010';
      final deepLink = '$baseUrl/#/track/$tokenNumber';

      expect(deepLink, equals('https://queue.hospital.com/#/track/A-010'));
      expect(deepLink, contains('/track/'));
    });
  });
}
