import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dqms_frontend/features/customer/kiosk/screens/kiosk_screen.dart';
import 'package:dqms_frontend/features/customer/providers/customer_experience_provider.dart';
import 'package:dqms_frontend/features/customer/tv/screens/waiting_room_tv_screen.dart';
import 'package:dqms_frontend/core/models/customer_models.dart';
import 'package:dqms_frontend/features/customer/providers/customer_providers.dart';
import 'package:dqms_frontend/features/admin/widgets/areas_zones_view.dart';
import 'package:dqms_frontend/features/admin/providers/admin_mock_providers.dart';
import 'package:dqms_frontend/features/admin/providers/signage_provider.dart';
import 'package:dqms_frontend/features/admin/models/signage_models.dart';
import 'package:dqms_frontend/features/admin/repositories/signage_repository.dart';

class FakeDisplayBoardNotifier extends DisplayBoardNotifier {
  final PublicDisplayBoardDto _data;
  FakeDisplayBoardNotifier(this._data);

  @override
  Future<PublicDisplayBoardDto> build() async {
    return _data;
  }
}

class FakeSignageRepository extends Fake implements SignageRepository {
  @override
  Future<List<SignageMediaItem>> getActivePlaylist({
    int organizationId = 1,
    int locationId = 1,
    int? areaId,
    int? serviceId,
  }) async => [];

  @override
  Future<EmergencyBroadcast?> getActiveEmergency({
    int organizationId = 1,
    int? locationId,
    int? areaId,
  }) async => null;
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('gstack-qa Regression Suite — 1. Kiosk (#/kiosk)', () {
    testWidgets('Kiosk Wizard: Welcome -> Search Filter -> Category Tabs -> Service Card -> Ticket Issuance', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final container = ProviderContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: KioskScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // 1. Verify Welcome Screen (Step 0)
      expect(find.text('WELCOME TO DQMS ENTERPRISE'), findsOneWidget);
      expect(find.text('TOUCH TO BEGIN'), findsOneWidget);

      // Tap TOUCH TO BEGIN
      await tester.tap(find.text('TOUCH TO BEGIN'));
      await tester.pumpAndSettle();

      // 2. Verify Step 1: Search & Service Selection
      expect(find.text('STEP 1: SEARCH & SELECT SERVICE'), findsOneWidget);
      expect(find.text('All Services (5)'), findsOneWidget);
      expect(find.text('Patient Registration & Check-in'), findsOneWidget);
      expect(find.text('Priority Medical Screening'), findsOneWidget);

      // Test Search Filter: Search for "Screening"
      await tester.enterText(find.byType(TextField).first, 'Screening');
      await tester.pumpAndSettle();

      expect(find.text('Priority Medical Screening'), findsOneWidget);
      expect(find.text('Patient Registration & Check-in'), findsNothing);

      // Clear search
      await tester.enterText(find.byType(TextField).first, '');
      await tester.pumpAndSettle();

      // Test Category Filter Tab: Click "Priority Wing B" chip
      await tester.tap(find.text('Priority Wing B').first);
      await tester.pumpAndSettle();
      expect(find.text('Priority Medical Screening'), findsOneWidget);

      // Select Service Card: "Priority Medical Screening"
      await tester.tap(find.text('Priority Medical Screening'));
      await tester.pumpAndSettle();

      // 3. Verify Step 2: Customer Category Selection
      expect(find.text('STEP 2: SELECT CUSTOMER CATEGORY'), findsOneWidget);
      expect(find.text('Senior Citizen (65+)'), findsOneWidget);
      expect(find.text('VIP / Executive Pass'), findsOneWidget);

      // Select Senior Citizen
      await tester.tap(find.text('Senior Citizen (65+)'));
      await tester.pumpAndSettle();

      // 4. Verify Step 3: Review & Confirm Details
      expect(find.text('STEP 3: CONFIRM TICKET DETAILS'), findsOneWidget);
      expect(find.text('Senior Citizen (65+)'), findsWidgets);
      expect(find.text('GENERATE TICKET NOW'), findsOneWidget);

      // Tap GENERATE TICKET NOW
      await tester.tap(find.text('GENERATE TICKET NOW'));
      await tester.pumpAndSettle();

      // 5. Verify Step 4: Ticket Generated Successfully
      expect(find.text('TICKET GENERATED SUCCESSFULLY!'), findsOneWidget);
      expect(find.text('YOUR QUEUE TICKET NUMBER'), findsOneWidget);
      final kioskState = container.read(kioskStateProvider);
      expect(kioskState.activeStep, equals(4));
      expect(kioskState.generatedTokenNumber, isNotEmpty);
      expect(find.text(kioskState.generatedTokenNumber), findsOneWidget);
    });
  });

  group('gstack-qa Regression Suite — 2. TV Display (#/tv)', () {
    testWidgets('TV Waiting Room 4K Display: Option A 50/50 Split, Now Calling Hero, Service Name, Counters & Upcoming Queue', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final mockBoard = PublicDisplayBoardDto(
        activeCalls: [
          DisplayBoardItemDto(
            id: 1,
            tokenNumber: 'A-016',
            processId: 1,
            processName: 'Comprehensive Patient Registration & Triage',
            prefix: 'A',
            counterNumber: 'C-01',
            counterName: 'Registration Counter 01',
            calledTime: '2026-11-28 00:30',
            flashAlert: false,
            tokenStatus: 18003,
          ),
          DisplayBoardItemDto(
            id: 2,
            tokenNumber: 'B-002',
            processId: 2,
            processName: 'Priority Medical Screening',
            prefix: 'B',
            counterNumber: 'C-02',
            counterName: 'Priority Counter 02',
            calledTime: '2026-11-28 00:31',
            flashAlert: false,
            tokenStatus: 18003,
          ),
        ],
        upcomingQueue: [
          DisplayBoardQueueItemDto(
            id: 10,
            tokenNumber: 'V-002',
            processId: 3,
            processName: 'VIP Specialist Consultation',
            prefix: 'V',
            priorityTier: 19005,
            tokenStatus: 18001,
          ),
          DisplayBoardQueueItemDto(
            id: 11,
            tokenNumber: 'A-005',
            processId: 1,
            processName: 'Patient Registration',
            prefix: 'A',
            priorityTier: 19001,
            counterNumber: 'C-01',
            tokenStatus: 18005, // On Hold
          ),
        ],
      );

      final container = ProviderContainer(
        overrides: [
          displayBoardProvider.overrideWith(() => FakeDisplayBoardNotifier(mockBoard)),
          signageRepositoryProvider.overrideWithValue(FakeSignageRepository()),
          nextWaitingTokenProvider.overrideWith((ref) => Future.value(null)),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: WaitingRoomTvScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      // 1. Header
      expect(find.text('DQMS TV DISPLAY'), findsOneWidget);

      // 2. NOW CALLING Top-Left Hero Capsule
      expect(find.text('NOW CALLING'), findsOneWidget);
      expect(find.text('A-016'), findsWidgets);
      expect(find.textContaining('C-01'), findsWidgets);
      expect(find.text('Comprehensive Patient Registration & Triage'), findsOneWidget);

      // 3. Active Counter Stations (Top-Right)
      expect(find.text('ACTIVE COUNTER STATIONS'), findsOneWidget);
      expect(find.textContaining('C-01'), findsWidgets);
      expect(find.textContaining('C-02'), findsWidgets);
      expect(find.text('C-03'), findsOneWidget);
      expect(find.text('C-04'), findsOneWidget);

      // 4. Upcoming Queue & Status Matrix (Bottom-Right)
      expect(find.text('UPCOMING QUEUE & STATUS'), findsOneWidget);
      expect(find.text('V-002'), findsOneWidget);
      expect(find.text('A-005'), findsWidgets);
      expect(find.text('ON HOLD (C-01)'), findsOneWidget);

      // 5. Digital Signage Media Zone (Bottom-Left)
      expect(find.textContaining('DIGITAL SIGNAGE MEDIA ZONE'), findsOneWidget);
    });
  });

  group('gstack-qa Regression Suite — 3. Admin Areas (#/admin/areas)', () {
    testWidgets('Admin Areas Workspace: Select AZ-03, Update SLA Minutes, and Verify Persistence', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final container = ProviderContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: AreasZonesView(),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // 1. Verify Master Header and Table
      expect(find.text('Hospital Areas & Physical Zones'), findsOneWidget);
      expect(find.text('AZ-03'), findsOneWidget);
      expect(find.text('Express Desk C'), findsOneWidget);
      expect(find.text('5m avg'), findsOneWidget);

      // 2. Click zone AZ-03 to open Zone Inspector
      await tester.tap(find.text('AZ-03'));
      await tester.pump(const Duration(milliseconds: 300));

      // 3. Verify Inspector is Open for AZ-03
      expect(find.text('Zone Inspector — AZ-03'), findsOneWidget);
      expect(find.text('Save Area Changes'), findsOneWidget);

      // Find the Target SLA input field in Inspector (pre-filled with 5)
      final slaFinder = find.widgetWithText(TextField, '5');
      expect(slaFinder, findsOneWidget);

      // 4. Update SLA minutes to 25
      await tester.enterText(slaFinder, '25');
      await tester.pump(const Duration(milliseconds: 300));

      // 5. Click Save Area Changes
      await tester.tap(find.text('Save Area Changes'));
      await tester.pump(const Duration(milliseconds: 300));

      // 6. Verify Model Updated in Provider State
      final updatedArea = container
          .read(adminWorkspaceStateProvider)
          .areas
          .firstWhere((a) => a.areaCode == 'AZ-03');
      expect(updatedArea.targetSlaMins, equals(25));

      // Verify the Master list now shows 25m avg
      expect(find.text('25m avg'), findsOneWidget);
    });
  });
}
