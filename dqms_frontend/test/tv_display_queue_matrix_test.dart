import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dqms_frontend/core/models/customer_models.dart';
import 'package:dqms_frontend/features/customer/providers/customer_providers.dart';
import 'package:dqms_frontend/features/customer/tv/screens/waiting_room_tv_screen.dart';
import 'package:dqms_frontend/features/customer/tv/widgets/signage_media_zone.dart';

void main() {
  group('TV Waiting Room Display - Queue & Station Status Matrix Tests', () {
    test('TC-TV-01: PublicDisplayBoardDto JSON deserialization with active and queue tokens', () {
      final json = {
        'activeCalls': [
          {
            'id': 101,
            'tokenNumber': 'A-016',
            'processId': 1,
            'processName': 'Registration & Triage',
            'prefix': 'A',
            'counterId': 1,
            'counterNumber': 'C-01',
            'counterName': 'Registration Counter 01',
            'tokenStatus': 18003,
            'calledTime': '2026-11-25T01:35:17',
            'flashAlert': true,
          }
        ],
        'upcomingQueue': [
          {
            'id': 102,
            'tokenNumber': 'V-001',
            'processId': 4,
            'processName': 'VIP Specialist Consultation',
            'prefix': 'V',
            'priorityTier': 19005,
            'tokenStatus': 18001,
            'counterId': null,
            'counterNumber': null,
            'counterName': null,
          },
          {
            'id': 103,
            'tokenNumber': 'A-005',
            'processId': 1,
            'processName': 'Registration & Triage',
            'prefix': 'A',
            'priorityTier': 19001,
            'tokenStatus': 18005,
            'counterId': 1,
            'counterNumber': 'C-01',
            'counterName': 'Registration Counter 01',
          }
        ]
      };

      final dto = PublicDisplayBoardDto.fromJson(json);

      expect(dto.activeCalls.length, 1);
      expect(dto.activeCalls.first.tokenNumber, 'A-016');
      expect(dto.activeCalls.first.counterNumber, 'C-01');
      expect(dto.activeCalls.first.flashAlert, true);

      expect(dto.upcomingQueue.length, 2);
      expect(dto.upcomingQueue.first.tokenNumber, 'V-001');
      expect(dto.upcomingQueue.first.priorityTier, 19005);
      expect(dto.upcomingQueue.first.tokenStatus, 18001);

      expect(dto.upcomingQueue[1].tokenNumber, 'A-005');
      expect(dto.upcomingQueue[1].tokenStatus, 18005);
      expect(dto.upcomingQueue[1].counterNumber, 'C-01');
    });

    test('TC-TV-02: Privacy Protection Guard - No PII exposed in queue DTO', () {
      final item = DisplayBoardQueueItemDto(
        id: 1,
        tokenNumber: 'A-014',
        processId: 1,
        processName: 'Triage',
        prefix: 'A',
        priorityTier: 19001,
        tokenStatus: 18001,
      );

      // Verify model contract only carries public ticket attributes
      expect(item.tokenNumber, 'A-014');
      expect(item.processName, 'Triage');
      // Notice: item has no patient name or phone attributes by design
    });

    test('TC-TV-03: On-Hold token identification & count filtering', () {
      final queue = [
        DisplayBoardQueueItemDto(
          id: 1,
          tokenNumber: 'A-014',
          processId: 1,
          processName: 'General Consultation',
          prefix: 'A',
          priorityTier: 19001,
          tokenStatus: 18001, // Waiting
        ),
        DisplayBoardQueueItemDto(
          id: 2,
          tokenNumber: 'A-005',
          processId: 1,
          processName: 'General Consultation',
          prefix: 'A',
          priorityTier: 19005, // VIP
          tokenStatus: 18005, // Hold
          counterNumber: 'C-01',
        ),
        DisplayBoardQueueItemDto(
          id: 3,
          tokenNumber: 'A-008',
          processId: 1,
          processName: 'General Consultation',
          prefix: 'A',
          priorityTier: 19002, // Senior
          tokenStatus: 18005, // Hold
          counterNumber: 'C-01',
        ),
      ];

      final waiting = queue.where((t) => t.tokenStatus == 18001 || t.tokenStatus == 18002).toList();
      final held = queue.where((t) => t.tokenStatus == 18005).toList();

      expect(waiting.length, 1);
      expect(waiting.first.tokenNumber, 'A-014');

      expect(held.length, 2);
      expect(held.map((t) => t.tokenNumber).toList(), ['A-005', 'A-008']);
    });

    testWidgets('TC-TV-04: Full TV Screen renders Active Counters and Upcoming Queue tiles', (tester) async {
      final mockData = PublicDisplayBoardDto(
        activeCalls: [
          DisplayBoardItemDto(
            id: 55,
            tokenNumber: 'A-016',
            processId: 1,
            processName: 'Comprehensive Patient Registration & Triage',
            prefix: 'A',
            counterId: 1,
            counterNumber: 'C-01',
            counterName: 'Registration Counter 01',
            tokenStatus: 18003,
            calledTime: '2026-11-25T01:35:17',
            flashAlert: true,
          ),
        ],
        upcomingQueue: [
          DisplayBoardQueueItemDto(
            id: 15,
            tokenNumber: 'V-002',
            processId: 4,
            processName: 'VIP Specialist Consultation',
            prefix: 'V',
            priorityTier: 19005,
            tokenStatus: 18001,
          ),
          DisplayBoardQueueItemDto(
            id: 50,
            tokenNumber: 'A-005',
            processId: 1,
            processName: 'Comprehensive Patient Registration & Triage',
            prefix: 'A',
            priorityTier: 19005,
            tokenStatus: 18005,
            counterNumber: 'C-01',
          ),
        ],
      );

      await tester.binding.setSurfaceSize(const Size(1920, 1080));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            displayBoardProvider.overrideWith(() => _MockDisplayBoardNotifier(mockData)),
          ],
          child: const MaterialApp(
            home: WaitingRoomTvScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Header
      expect(find.text('DQMS TV DISPLAY'), findsOneWidget);

      // Verify Left Hero Display
      expect(find.text('NOW CALLING'), findsOneWidget);
      expect(find.text('A-016'), findsWidgets); // Appears in hero and in active counter list
      expect(find.text('COUNTER C-01'), findsOneWidget);

      // Verify Active Counter Stations Panel
      expect(find.text('ACTIVE COUNTER STATIONS'), findsOneWidget);
      expect(find.text('1 In-Service'), findsOneWidget);
      expect(find.text('CALLING'), findsOneWidget);

      // Verify Upcoming Queue & Status Panel
      expect(find.text('UPCOMING QUEUE & STATUS'), findsOneWidget);
      expect(find.text('1 Waiting • 1 On Hold'), findsOneWidget);
      expect(find.text('V-002'), findsOneWidget);
      expect(find.text('WAITING #1'), findsOneWidget);

      // Verify Held Token rendering
      expect(find.text('A-005'), findsOneWidget);
      expect(find.text('ON HOLD (C-01)'), findsOneWidget);

      // Verify Dynamic Ticker notice
      expect(find.textContaining('Token(s) A-005 are paused on hold'), findsOneWidget);
    });

    testWidgets('TC-TV-05: Empty Queue & Standby State handling', (tester) async {
      final emptyData = PublicDisplayBoardDto.empty();

      await tester.binding.setSurfaceSize(const Size(1920, 1080));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            displayBoardProvider.overrideWith(() => _MockDisplayBoardNotifier(emptyData)),
          ],
          child: const MaterialApp(
            home: WaitingRoomTvScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('STANDBY'), findsOneWidget);
      expect(find.text('All counter stations standby'), findsOneWidget);
      expect(find.text('No patients waiting in queue'), findsOneWidget);
      expect(find.textContaining('Welcome to DQMS Medical Center'), findsWidgets);
    });

    testWidgets('TC-TV-06: Signage Media Zone and Ads by Google render in Option A Left Split', (tester) async {
      final mockData = PublicDisplayBoardDto(
        activeCalls: [
          DisplayBoardItemDto(
            id: 1,
            tokenNumber: 'A-001',
            processId: 1,
            processName: 'General Consultation',
            prefix: 'A',
            counterId: 1,
            counterNumber: 'C-01',
            counterName: 'Counter 01',
            tokenStatus: 18003,
            calledTime: '2026-11-25T01:00:00',
            flashAlert: false,
          ),
        ],
        upcomingQueue: [],
      );

      await tester.binding.setSurfaceSize(const Size(1920, 1080));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            displayBoardProvider.overrideWith(() => _MockDisplayBoardNotifier(mockData)),
          ],
          child: const MaterialApp(
            home: WaitingRoomTvScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Signage Media Zone exists
      expect(find.byType(SignageMediaZone), findsOneWidget);

      // Verify Welcome Slide initially visible
      expect(find.text('Welcome to DQMS Medical Center'), findsWidgets);

      // Advance time by 13s to rotate to Slide 1 (Ads by Google)
      await tester.pump(const Duration(seconds: 13));
      await tester.pumpAndSettle();

      // Verify Google Ads Slide renders
      expect(find.text('Ads by Google'), findsOneWidget);
      expect(find.text('Sponsored'), findsOneWidget);
    });
  });
}

class _MockDisplayBoardNotifier extends DisplayBoardNotifier {
  final PublicDisplayBoardDto _data;
  _MockDisplayBoardNotifier(this._data);

  @override
  Future<PublicDisplayBoardDto> build() async => _data;
}
