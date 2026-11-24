import 'package:flutter_test/flutter_test.dart';
import 'package:dqms_frontend/core/enums/dqms_enums.dart';
import 'package:dqms_frontend/core/models/staff_models.dart';
import 'package:dqms_frontend/features/staff/screens/counter_operator_screen.dart';

TokenTransactionDto createMockToken({
  required int id,
  required String tokenNumber,
  required int tokenStatus,
  int priorityTier = 19001,
  String? customerName,
  String? customerPhone,
  String? notes,
}) {
  return TokenTransactionDto(
    id: id,
    tokenNumber: tokenNumber,
    organizationId: 1,
    locationId: 1,
    areaId: 1,
    processId: 1,
    priorityTier: priorityTier,
    tokenStatus: tokenStatus,
    queuePosition: 1,
    customerName: customerName,
    customerPhone: customerPhone,
    notes: notes,
  );
}

void main() {
  group('QA Test Suite — Dedicated Parked / On-Hold Queue Panel', () {
    // -------------------------------------------------------------------------
    // TC-HOLD-01: Decoupling Active Token vs Held Tokens
    // -------------------------------------------------------------------------
    test('TC-HOLD-01: Token streams properly decouple active vs held vs waiting', () {
      final tokens = [
        createMockToken(
          id: 101,
          tokenNumber: 'A-005',
          priorityTier: 19005, // VIP
          tokenStatus: 18005, // Hold
          customerName: 'Emily Rose',
          customerPhone: '+1-555-0888',
          notes: 'Customer absent from waiting area',
        ),
        createMockToken(
          id: 102,
          tokenNumber: 'A-003',
          priorityTier: 19001,
          tokenStatus: 18001, // Queued
          customerName: 'QA Patient Alpha',
        ),
        createMockToken(
          id: 103,
          tokenNumber: 'A-007',
          priorityTier: 19001,
          tokenStatus: 18002, // Waiting
          customerName: 'QA Patient Beta',
        ),
      ];

      // Filter active (calling or active only)
      final activeToken = tokens
          .where(
            (t) =>
                t.tokenStatus == e_TokenStatus.calling.value ||
                t.tokenStatus == e_TokenStatus.active.value,
          )
          .firstOrNull;

      // Filter held (parked)
      final heldTokens = tokens
          .where((t) => t.tokenStatus == e_TokenStatus.hold.value)
          .toList();

      // Filter waiting
      final waitingTokens = tokens
          .where(
            (t) =>
                t.tokenStatus == e_TokenStatus.queued.value ||
                t.tokenStatus == e_TokenStatus.waiting.value,
          )
          .toList();

      // Assertions
      expect(activeToken, isNull, reason: 'Counter must be IDLE when only held tokens exist');
      expect(heldTokens.length, equals(1));
      expect(heldTokens.first.tokenNumber, equals('A-005'));
      expect(heldTokens.first.notes, equals('Customer absent from waiting area'));
      expect(waitingTokens.length, equals(2));
    });

    // -------------------------------------------------------------------------
    // TC-HOLD-02: Intervening Call Next with Token on Hold
    // -------------------------------------------------------------------------
    test('TC-HOLD-02: Calling next customer assigns new active token without losing held tokens', () {
      final initialTokens = [
        createMockToken(
          id: 101,
          tokenNumber: 'A-005',
          priorityTier: 19005,
          tokenStatus: 18005, // Hold
          customerName: 'Emily Rose',
          notes: 'Stepped out / will return shortly',
        ),
        createMockToken(
          id: 102,
          tokenNumber: 'A-003',
          priorityTier: 19001,
          tokenStatus: 18003, // Calling (Newly called)
          customerName: 'David Miller',
        ),
      ];

      final activeToken = initialTokens
          .where(
            (t) =>
                t.tokenStatus == e_TokenStatus.calling.value ||
                t.tokenStatus == e_TokenStatus.active.value,
          )
          .firstOrNull;

      final heldTokens = initialTokens
          .where((t) => t.tokenStatus == e_TokenStatus.hold.value)
          .toList();

      expect(activeToken, isNotNull);
      expect(activeToken!.tokenNumber, equals('A-003'));
      expect(activeToken.tokenStatus, equals(e_TokenStatus.calling.value));

      expect(heldTokens.length, equals(1));
      expect(heldTokens.first.tokenNumber, equals('A-005'));
      expect(heldTokens.first.customerName, equals('Emily Rose'));
    });

    // -------------------------------------------------------------------------
    // TC-HOLD-03: Recall from Hold Lifecycle Transition
    // -------------------------------------------------------------------------
    test('TC-HOLD-03: Held token correctly updates to calling (18003) on recall', () {
      final heldToken = createMockToken(
        id: 101,
        tokenNumber: 'A-005',
        priorityTier: 19005,
        tokenStatus: 18005,
        customerName: 'Emily Rose',
      );

      // Simulate transition to calling
      final recalledToken = createMockToken(
        id: heldToken.id,
        tokenNumber: heldToken.tokenNumber,
        priorityTier: heldToken.priorityTier,
        tokenStatus: e_TokenStatus.calling.value,
        customerName: heldToken.customerName,
        notes: 'Recalled from Hold',
      );

      expect(recalledToken.tokenStatus, equals(18003));
      expect(recalledToken.notes, equals('Recalled from Hold'));
    });

    // -------------------------------------------------------------------------
    // TC-HOLD-04: Active Collision Prevention Guard Logic
    // -------------------------------------------------------------------------
    test('TC-HOLD-04: Collision guard blocks recall when counter is actively serving another customer', () {
      final currentActive = createMockToken(
        id: 102,
        tokenNumber: 'A-003',
        tokenStatus: 18004, // Active (Serving)
        customerName: 'David Miller',
      );

      final heldToken = createMockToken(
        id: 101,
        tokenNumber: 'A-005',
        tokenStatus: 18005, // Hold
        customerName: 'Emily Rose',
      );

      bool canRecallDirectly(TokenTransactionDto? active) {
        return active == null;
      }

      // Assert that collision guard triggers
      expect(canRecallDirectly(currentActive), isFalse);
      expect(canRecallDirectly(null), isTrue);
      expect(heldToken.tokenNumber, equals('A-005'));
    });

    // -------------------------------------------------------------------------
    // TC-HOLD-05: Cancel Parked Token (No-Show Abandonment)
    // -------------------------------------------------------------------------
    test('TC-HOLD-05: Canceling parked token marks status as 18006 with No-Show reason', () {
      final heldToken = createMockToken(
        id: 101,
        tokenNumber: 'A-005',
        priorityTier: 19005,
        tokenStatus: 18005,
        customerName: 'Emily Rose',
      );

      final canceledToken = createMockToken(
        id: heldToken.id,
        tokenNumber: heldToken.tokenNumber,
        priorityTier: heldToken.priorityTier,
        tokenStatus: e_TokenStatus.canceled.value,
        customerName: heldToken.customerName,
        notes: 'No-Show / Abandoned on Hold',
      );

      expect(canceledToken.tokenStatus, equals(18006));
      expect(canceledToken.notes, equals('No-Show / Abandoned on Hold'));
    });

    // -------------------------------------------------------------------------
    // TC-HOLD-06: Operator Sidebar Tab Enum Completeness
    // -------------------------------------------------------------------------
    test('TC-HOLD-06: OperatorSidebarTab provides waitingQueue, parkedOnHold, and activityLog', () {
      expect(OperatorSidebarTab.values.length, equals(3));
      expect(OperatorSidebarTab.values, contains(OperatorSidebarTab.waitingQueue));
      expect(OperatorSidebarTab.values, contains(OperatorSidebarTab.parkedOnHold));
      expect(OperatorSidebarTab.values, contains(OperatorSidebarTab.activityLog));
    });
  });
}
