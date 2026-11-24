import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dqms_frontend/features/admin/models/edge_node_models.dart';
import 'package:dqms_frontend/features/admin/providers/edge_node_provider.dart';
import 'package:dqms_frontend/features/admin/repositories/edge_node_repository.dart';
import 'package:dqms_frontend/features/admin/widgets/edge_nodes_view.dart';
import 'package:dqms_frontend/features/admin/widgets/edge_resilience_banner.dart';

class _FakeEdgeNodeRepository extends Fake implements EdgeNodeRepository {
  @override
  Future<List<EdgeNodeRegistration>> getNodes({int organizationId = 1, int locationId = -1, String? nodeId}) async {
    return [
      EdgeNodeRegistration(
        id: 1,
        nodeId: 'EDGE-DXB-CLINIC-01',
        nodeName: 'Dubai Main Clinic Edge Server',
        organizationId: 1,
        locationId: 1,
        ipAddress: '192.168.1.50',
        macAddress: '00:1A:2B:3C:4D:5E',
        softwareVersion: '1.2.0',
        isActive: true,
        lastHeartbeatAt: DateTime.now().toUtc().subtract(const Duration(seconds: 15)),
        lastSyncAt: DateTime.now().toUtc().subtract(const Duration(minutes: 5)),
        pendingJournalCount: 0,
      ),
    ];
  }

  @override
  Future<List<EdgeSyncAuditLog>> getAuditLogs({int organizationId = 1, String? nodeId, int limit = 50}) async {
    return [
      EdgeSyncAuditLog(
        id: 101,
        batchId: 'batch_20261124_001',
        nodeId: 'EDGE-DXB-CLINIC-01',
        organizationId: 1,
        locationId: 1,
        recordsCount: 42,
        conflictsResolved: 1,
        durationMs: 145,
        status: 'Success',
      ),
    ];
  }
}

void main() {
  group('1. UUIDv7 Anti-Collision & Monotonic Ordering Logic', () {
    String generateUuidV7({int? timestampMs, Random? random}) {
      final now = timestampMs ?? DateTime.now().toUtc().millisecondsSinceEpoch;
      final rand = random ?? Random(42);

      final timeHex = now.toRadixString(16).padLeft(12, '0');
      final randA = (rand.nextInt(0x0fff) | 0x7000).toRadixString(16).padLeft(4, '0'); // version 7
      final randB = (rand.nextInt(0x3fff) | 0x8000).toRadixString(16).padLeft(4, '0'); // variant 1
      final randC = rand.nextInt(0xffffff).toRadixString(16).padLeft(6, '0') +
          rand.nextInt(0xffffff).toRadixString(16).padLeft(6, '0');

      return '${timeHex.substring(0, 8)}-${timeHex.substring(8, 12)}-$randA-$randB-$randC';
    }

    test('UUIDv7 generates valid format and chronological ordering', () {
      final t1 = 1700000000000;
      final t2 = 1700000005000;

      final uuid1 = generateUuidV7(timestampMs: t1);
      final uuid2 = generateUuidV7(timestampMs: t2);

      expect(uuid1.length, equals(36));
      expect(uuid2.length, equals(36));
      expect(uuid1[14], equals('7')); // version 7

      // Chronological sort order matches string comparison
      expect(uuid1.compareTo(uuid2), lessThan(0));
    });

    test('High volume generation exhibits 0 collisions', () {
      final set = <String>{};
      final rand = Random();
      const count = 5000;

      for (int i = 0; i < count; i++) {
        final uuid = generateUuidV7(timestampMs: 1700000000000 + i, random: rand);
        set.add(uuid);
      }

      expect(set.length, equals(count));
    });
  });

  group('2. Conflict Resolution State Machine Dominance Engine', () {
    int resolveConflict({required int cloudStatus, required int edgeStatus}) {
      // Dominance Hierarchy:
      // Completed (18007) > Forwarded (18008) > Active (18004) > Calling (18003) > Waiting (18002) > Queued (18001)
      if (cloudStatus == 18007 || edgeStatus == 18007) return 18007;
      if (cloudStatus == 18008 || edgeStatus == 18008) return 18008;
      if (cloudStatus == 18004 || edgeStatus == 18004) return 18004;
      if (cloudStatus == 18003 || edgeStatus == 18003) return 18003;
      if (cloudStatus == 18002 || edgeStatus == 18002) return 18002;
      return 18001;
    }

    test('Completed state dominates over Canceled or Waiting state', () {
      const canceled = 18006;
      const completed = 18007;

      expect(resolveConflict(cloudStatus: canceled, edgeStatus: completed), equals(completed));
    });

    test('Active state dominates over Queued or Waiting state', () {
      const queued = 18001;
      const active = 18004;

      expect(resolveConflict(cloudStatus: queued, edgeStatus: active), equals(active));
    });
  });

  group('3. Models & Serialization Tests', () {
    test('EdgeNodeRegistration parses JSON and computes online state', () {
      final json = {
        'id': 10,
        'nodeId': 'EDGE-SHJ-01',
        'nodeName': 'Sharjah Branch Appliance',
        'organizationId': 1,
        'locationId': 2,
        'ipAddress': '10.0.0.12',
        'softwareVersion': '1.0.0',
        'isActive': true,
        'lastHeartbeatAt': DateTime.now().toUtc().subtract(const Duration(seconds: 20)).toIso8601String(),
        'pendingJournalCount': 5,
      };

      final node = EdgeNodeRegistration.fromJson(json);

      expect(node.id, equals(10));
      expect(node.nodeId, equals('EDGE-SHJ-01'));
      expect(node.isOnline, isTrue);
      expect(node.pendingJournalCount, equals(5));
    });

    test('EdgeSyncAuditLog parses reconciliation telemetry', () {
      final logJson = {
        'id': 200,
        'batchId': 'b_123',
        'nodeId': 'EDGE-DXB-01',
        'organizationId': 1,
        'locationId': 1,
        'recordsCount': 10,
        'conflictsResolved': 2,
        'durationMs': 75,
        'status': 'Success',
      };

      final log = EdgeSyncAuditLog.fromJson(logJson);

      expect(log.id, equals(200));
      expect(log.recordsCount, equals(10));
      expect(log.conflictsResolved, equals(2));
      expect(log.durationMs, equals(75));
      expect(log.status, equals('Success'));
    });
  });

  group('4. UI Widget Rendering Tests', () {
    testWidgets('EdgeResilienceBanner renders Cloud Online state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EdgeResilienceBanner(
              status: EdgeConnectivityStatus.cloudOnline,
            ),
          ),
        ),
      );

      expect(find.text('Cloud Connected'), findsOneWidget);
      expect(find.text('Operating in real-time Cloud SaaS mode'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_done_rounded), findsOneWidget);
    });

    testWidgets('EdgeResilienceBanner renders Autonomous Offline state with queue count', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EdgeResilienceBanner(
              status: EdgeConnectivityStatus.edgeAutonomous,
              pendingJournalCount: 14,
            ),
          ),
        ),
      );

      expect(find.text('Edge Autonomous (Offline)'), findsOneWidget);
      expect(find.text('Branch LAN operational • 14 offline events queued in local journal'), findsOneWidget);
      expect(find.byIcon(Icons.router_rounded), findsOneWidget);
    });

    testWidgets('EdgeNodesView renders master list, banner, and action buttons', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            edgeNodeRepositoryProvider.overrideWithValue(_FakeEdgeNodeRepository()),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: EdgeNodesView(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Header
      expect(find.text('Branch Edge Appliances & Hybrid Sync'), findsOneWidget);
      expect(
        find.text('Local Kiosk, Counter Station & TV chime autonomy with automated cloud delta reconciliation'),
        findsOneWidget,
      );

      // Verify Action Button
      expect(find.text('+ Register Edge Appliance'), findsOneWidget);
      expect(find.byIcon(Icons.add_to_queue_rounded), findsWidgets);

      // Verify Master List Item from Fake Repository
      expect(find.text('EDGE-DXB-CLINIC-01'), findsOneWidget);
      expect(find.text('ONLINE (HEALTHY)'), findsOneWidget);
    });
  });
}
