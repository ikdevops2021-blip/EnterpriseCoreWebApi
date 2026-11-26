import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dqms_frontend/features/admin/models/data_residency_models.dart';
import 'package:dqms_frontend/features/admin/providers/data_residency_provider.dart';
import 'package:dqms_frontend/features/admin/widgets/data_residency_view.dart';

void main() {
  final mockConfig = OrganizationDataResidency(
    id: 1,
    organizationId: 1,
    dataRegion: 'eu-central-1',
    jurisdiction: 'GDPR',
    kmsKeyArn: 'arn:aws:kms:eu-central-1:123456789012:key/test-gdpr-key',
    dataRetentionDays: 90,
    autoAnonymizeOnComplete: true,
    enableBlindIndexing: true,
    allowCrossBorderDiagnostics: false,
    createdDate: DateTime(2026, 11, 25),
    modifiedDate: DateTime(2026, 11, 26),
  );

  final mockLogs = [
    GdprAuditLog(
      id: 1,
      organizationId: 1,
      actionType: 'Article17_RightToBeForgotten',
      recordsAffected: 5,
      requestedByUserId: 42,
      auditReason: 'Subject requested data erasure',
      executionTime: DateTime(2026, 11, 26, 15, 30),
    ),
  ];

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        dataResidencyConfigProvider(1).overrideWith((ref) => mockConfig),
        gdprAuditLogsProvider(1).overrideWith((ref) => mockLogs),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: DataResidencyView(),
        ),
      ),
    );
  }

  group('1. Data Residency Domain Models Serialization & Edge Cases', () {
    test('OrganizationDataResidency serialization and deserialization', () {
      final json = {
        'id': 10,
        'organizationId': 101,
        'dataRegion': 'eu-central-1',
        'jurisdiction': 'GDPR',
        'kmsKeyArn': 'arn:aws:kms:eu-central-1:123456789012:key/test-gdpr-key',
        'dataRetentionDays': 90,
        'autoAnonymizeOnComplete': true,
        'enableBlindIndexing': true,
        'allowCrossBorderDiagnostics': false,
        'createdDate': '2026-11-25T10:00:00Z',
        'modifiedDate': '2026-11-26T12:00:00Z',
      };

      final model = OrganizationDataResidency.fromJson(json);

      expect(model.id, 10);
      expect(model.organizationId, 101);
      expect(model.dataRegion, 'eu-central-1');
      expect(model.jurisdiction, 'GDPR');
      expect(model.kmsKeyArn, contains('test-gdpr-key'));
      expect(model.dataRetentionDays, 90);
      expect(model.autoAnonymizeOnComplete, isTrue);
      expect(model.enableBlindIndexing, isTrue);
      expect(model.allowCrossBorderDiagnostics, isFalse);

      final serialized = model.toJson();
      expect(serialized['organizationId'], 101);
      expect(serialized['dataRegion'], 'eu-central-1');
      expect(serialized['jurisdiction'], 'GDPR');
      expect(serialized['dataRetentionDays'], 90);
    });

    test('OrganizationDataResidency handles null optional fields gracefully', () {
      final json = {
        'organizationId': 202,
        'dataRegion': 'me-central-1',
        'jurisdiction': 'NESA',
      };

      final model = OrganizationDataResidency.fromJson(json);

      expect(model.id, 0);
      expect(model.organizationId, 202);
      expect(model.dataRegion, 'me-central-1');
      expect(model.kmsKeyArn, isNull);
      expect(model.dataRetentionDays, 90); // default
      expect(model.autoAnonymizeOnComplete, isFalse);
      expect(model.enableBlindIndexing, isTrue);
      expect(model.allowCrossBorderDiagnostics, isFalse);
    });

    test('GdprAuditLog serialization handles ISO dates and details', () {
      final json = {
        'id': 505,
        'organizationId': 101,
        'actionType': 'Article17_RightToBeForgotten',
        'recordsAffected': 14,
        'requestedByUserId': 42,
        'auditReason': 'Subject requested data deletion per GDPR Art. 17',
        'executionTime': '2026-11-26T15:30:00Z',
      };

      final log = GdprAuditLog.fromJson(json);

      expect(log.id, 505);
      expect(log.organizationId, 101);
      expect(log.actionType, 'Article17_RightToBeForgotten');
      expect(log.recordsAffected, 14);
      expect(log.requestedByUserId, 42);
      expect(log.auditReason, contains('Art. 17'));
      expect(log.executionTime.year, 2026);
    });

    test('GdprRightToBeForgottenResult and CustomerDataExport parsing', () {
      final rtfResultJson = {
        'success': true,
        'organizationId': 101,
        'affectedRecordsCount': 7,
        'message': 'Successfully shredded PII across 7 records.',
        'executionTimestamp': '2026-11-26T16:00:00Z',
      };

      final rtfResult = GdprRightToBeForgottenResult.fromJson(rtfResultJson);
      expect(rtfResult.success, isTrue);
      expect(rtfResult.affectedRecordsCount, 7);
      expect(rtfResult.message, contains('shredded PII'));

      final exportJson = {
        'organizationId': 101,
        'customerPhoneNumber': '+971501234567',
        'exportGeneratedAt': '2026-11-26T16:05:00Z',
        'visits': [
          {
            'tokenId': 1001,
            'tokenNumber': 'A-101',
            'processName': 'General Inquiries',
            'counterName': 'Counter 1',
            'tokenStatus': 4,
            'waitDurationSeconds': 120,
            'serviceDurationSeconds': 300,
          }
        ]
      };

      final exportModel = CustomerDataExport.fromJson(exportJson);
      expect(exportModel.organizationId, 101);
      expect(exportModel.customerPhoneNumber, '+971501234567');
      expect(exportModel.visits.length, 1);
      expect(exportModel.visits.first.tokenNumber, 'A-101');
    });
  });

  group('2. Data Residency UI Widget & Sovereignty Badge Tests', () {
    testWidgets('DataResidencyView renders tabs and default mock data', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify Header
      expect(find.text('Data Residency & GDPR Privacy Engine'), findsOneWidget);

      // Verify Tab items
      expect(find.text('Data Sovereignty & Retention'), findsOneWidget);
      expect(find.text('GDPR Article 17 & 20 Tools'), findsOneWidget);
      expect(find.text('Sovereign Audit Trail'), findsOneWidget);
    });

    testWidgets('DataResidencyView switches tabs to GDPR Tools and Audit Trail', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap GDPR Tools Tab
      await tester.tap(find.text('GDPR Article 17 & 20 Tools'));
      await tester.pumpAndSettle();

      // Verify GDPR actions are displayed
      expect(find.text('GDPR Article 17: Right-To-Be-Forgotten (Cryptographic Erasure)'), findsOneWidget);
      expect(find.text('GDPR Article 20: Right to Data Portability Export'), findsOneWidget);
      expect(find.text('Scheduled Data Retention Purge Daemon'), findsOneWidget);
      expect(find.text('Execute Article 17 Erasure'), findsOneWidget);

      // Tap Audit Trail Tab
      await tester.tap(find.text('Sovereign Audit Trail'));
      await tester.pumpAndSettle();

      // Verify Audit tab view header or elements
      expect(find.text('Sovereign Audit Trail'), findsWidgets);
    });

    testWidgets('Article 17 Erasure dialog opens and dismisses cleanly', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Switch to GDPR tab
      await tester.tap(find.text('GDPR Article 17 & 20 Tools'));
      await tester.pumpAndSettle();

      // Enter customer phone first
      await tester.enterText(find.byType(TextField).at(0), '+971501234567');
      await tester.pumpAndSettle();

      // Tap "Execute Article 17 Erasure" button to open modal dialog
      await tester.tap(find.text('Execute Article 17 Erasure'));
      await tester.pumpAndSettle();

      // Verify dialog opened
      expect(find.text('Confirm GDPR Article 17 Erasure'), findsOneWidget);
      expect(find.textContaining('Are you sure you want to scrub all PII for +971501234567'), findsOneWidget);

      // Tap Cancel to dismiss
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Modal closed
      expect(find.text('Confirm GDPR Article 17 Erasure'), findsNothing);
    });
  });
}
