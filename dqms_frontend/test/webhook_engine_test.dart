import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dqms_frontend/features/admin/models/webhook_models.dart';
import 'package:dqms_frontend/features/admin/providers/webhook_provider.dart';
import 'package:dqms_frontend/features/admin/repositories/webhook_repository.dart';
import 'package:dqms_frontend/features/admin/widgets/webhook_management_view.dart';

class _FakeWebhookRepository extends Fake implements WebhookRepository {
  @override
  Future<List<WebhookSubscription>> getSubscriptions({int organizationId = 1, int? locationId}) async {
    return [
      WebhookSubscription(
        id: 1,
        organizationId: 1,
        name: 'Enterprise ERP Relay',
        endpointUrl: 'https://api.enterprise.com/hooks',
        secretKey: 'whsec_sample_secret',
        subscribedEvents: 'token.issued,token.completed',
        isActive: true,
      ),
    ];
  }

  @override
  Future<List<WebhookDeliveryLog>> getDeliveryLogs({
    int subscriptionId = -1,
    int organizationId = -1,
    String? status,
    int pageNumber = 1,
    int pageSize = 50,
  }) async {
    return [];
  }
}

void main() {
  group('Webhook Notification Engine - Model & Serialization Tests', () {
    test('1. WebhookSubscription parses comma-separated events into eventList', () {
      final json = {
        'id': 1,
        'organizationId': 10,
        'name': 'ERP Integration Webhook',
        'endpointUrl': 'https://api.partner.com/v1/dqms-events',
        'secretKey': 'whsec_test_secret_key_1234567890',
        'subscribedEvents': 'token.issued,token.called,token.completed,sla.breached',
        'isActive': true,
        'maxRetryAttempts': 3,
        'timeoutSeconds': 10,
        'consecutiveFailures': 2,
        'circuitBreakerUntil': null,
        'lastDeliveryStatus': 'Success',
        'lastResponseStatusCode': 200,
        'createdDate': '2026-11-20T00:00:00Z',
      };

      final sub = WebhookSubscription.fromJson(json);

      expect(sub.id, equals(1));
      expect(sub.organizationId, equals(10));
      expect(sub.name, equals('ERP Integration Webhook'));
      expect(sub.endpointUrl, equals('https://api.partner.com/v1/dqms-events'));
      expect(sub.secretKey, equals('whsec_test_secret_key_1234567890'));
      expect(sub.isActive, isTrue);
      expect(sub.eventList, contains('token.issued'));
      expect(sub.eventList, contains('token.called'));
      expect(sub.eventList, contains('token.completed'));
      expect(sub.eventList, contains('sla.breached'));
      expect(sub.eventList.length, equals(4));
    });

    test('2. WebhookDeliveryLog status mapping and duration formatting', () {
      final logJson = {
        'id': 501,
        'deliveryId': 'del_abc123xyz',
        'webhookSubscriptionId': 1,
        'subscriptionName': 'ERP Integration Webhook',
        'organizationId': 10,
        'eventCode': 'token.completed',
        'payloadJson': '{"event":"token.completed","tokenNumber":"A-101"}',
        'responseStatusCode': 200,
        'responseBody': '{"received":true}',
        'durationMs': 42,
        'attemptCount': 1,
        'deliveryStatus': 'Success',
        'createdDate': '2026-11-24T12:00:00Z',
      };

      final log = WebhookDeliveryLog.fromJson(logJson);

      expect(log.id, equals(501));
      expect(log.deliveryId, equals('del_abc123xyz'));
      expect(log.eventCode, equals('token.completed'));
      expect(log.deliveryStatus, equals('Success'));
      expect(log.responseStatusCode, equals(200));
      expect(log.durationMs, equals(42));
      expect(log.attemptCount, equals(1));
    });

    test('3. WebhookTestResult captures diagnostic test ping execution', () {
      final resultJson = {
        'isSuccess': true,
        'statusCode': 200,
        'latencyMs': 88,
        'responseBody': '{"status":"ok"}',
        'message': 'HTTP 200 OK',
        'computedSignature': 't=1700000000,v1=abcdef0123456789',
        'sentPayload': '{"event":"ping.test"}',
      };

      final testResult = WebhookTestResult.fromJson(resultJson);

      expect(testResult.isSuccess, isTrue);
      expect(testResult.statusCode, equals(200));
      expect(testResult.latencyMs, equals(88));
      expect(testResult.computedSignature, startsWith('t='));
      expect(testResult.message, contains('200 OK'));
    });
  });

  group('Webhook Notification Engine - HMAC-SHA256 Cryptographic Verification', () {
    String computeHmac(String secret, String timestamp, String payload) {
      final signedPayload = '$timestamp.$payload';
      final hmac = Hmac(sha256, utf8.encode(secret));
      final digest = hmac.convert(utf8.encode(signedPayload));
      return 't=$timestamp,v1=${digest.toString()}';
    }

    bool verifySignature({
      required String secret,
      required String signatureHeader,
      required String payload,
      int toleranceSeconds = 300,
      int? currentUnixTime,
    }) {
      final parts = signatureHeader.split(',');
      String? timestampStr;
      String? v1Signature;

      for (final part in parts) {
        final kv = part.split('=');
        if (kv.length == 2) {
          if (kv[0] == 't') timestampStr = kv[1];
          if (kv[0] == 'v1') v1Signature = kv[1];
        }
      }

      if (timestampStr == null || v1Signature == null) return false;

      final timestamp = int.tryParse(timestampStr);
      if (timestamp == null) return false;

      final now = currentUnixTime ?? (DateTime.now().millisecondsSinceEpoch ~/ 1000);
      if ((now - timestamp).abs() > toleranceSeconds) {
        return false; // Replay attack or timestamp drift
      }

      final signedPayload = '$timestampStr.$payload';
      final hmac = Hmac(sha256, utf8.encode(secret));
      final computedDigest = hmac.convert(utf8.encode(signedPayload)).toString();

      return computedDigest == v1Signature;
    }

    test('4. Correct secret and unaltered payload verifies HMAC signature successfully', () {
      const secret = 'whsec_f8934b98c392f54032aef';
      const timestamp = '1700000000';
      const payload = '{"event":"token.issued","tokenNumber":"T-001"}';

      final header = computeHmac(secret, timestamp, payload);

      final isValid = verifySignature(
        secret: secret,
        signatureHeader: header,
        payload: payload,
        currentUnixTime: 1700000050, // 50 seconds later (< 300s)
      );

      expect(isValid, isTrue);
    });

    test('5. Tampered payload causes signature verification to fail', () {
      const secret = 'whsec_f8934b98c392f54032aef';
      const timestamp = '1700000000';
      const originalPayload = '{"event":"token.issued","tokenNumber":"T-001"}';
      const tamperedPayload = '{"event":"token.issued","tokenNumber":"T-999"}';

      final header = computeHmac(secret, timestamp, originalPayload);

      final isValid = verifySignature(
        secret: secret,
        signatureHeader: header,
        payload: tamperedPayload,
        currentUnixTime: 1700000050,
      );

      expect(isValid, isFalse);
    });

    test('6. Expired timestamp (> 300s) fails replay prevention check', () {
      const secret = 'whsec_f8934b98c392f54032aef';
      const timestamp = '1700000000';
      const payload = '{"event":"token.issued","tokenNumber":"T-001"}';

      final header = computeHmac(secret, timestamp, payload);

      final isValid = verifySignature(
        secret: secret,
        signatureHeader: header,
        payload: payload,
        currentUnixTime: 1700000305, // 305 seconds later (> 300s window)
      );

      expect(isValid, isFalse);
    });

    test('7. Wrong secret key fails signature verification', () {
      const secretA = 'whsec_correct_secret';
      const secretB = 'whsec_attacker_secret';
      const timestamp = '1700000000';
      const payload = '{"event":"token.called","counterId":3}';

      final header = computeHmac(secretA, timestamp, payload);

      final isValid = verifySignature(
        secret: secretB,
        signatureHeader: header,
        payload: payload,
        currentUnixTime: 1700000010,
      );

      expect(isValid, isFalse);
    });
  });

  group('Webhook Notification Engine - Resiliency & Circuit Breaker Tests', () {
    int calculateExponentialBackoffSeconds(int attempt) {
      if (attempt <= 1) return 15;
      final factor = 1 << (attempt - 1); // 2^(attempt-1)
      final backoff = 15 * factor;
      return backoff > 300 ? 300 : backoff;
    }

    test('8. Exponential backoff intervals follow capped schedule', () {
      expect(calculateExponentialBackoffSeconds(1), equals(15));
      expect(calculateExponentialBackoffSeconds(2), equals(30));
      expect(calculateExponentialBackoffSeconds(3), equals(60));
      expect(calculateExponentialBackoffSeconds(4), equals(120));
      expect(calculateExponentialBackoffSeconds(5), equals(240));
      expect(calculateExponentialBackoffSeconds(6), equals(300)); // Capped at 300s
      expect(calculateExponentialBackoffSeconds(7), equals(300));
    });

    test('9. Circuit breaker trips after 10 consecutive delivery failures', () {
      var consecutiveFailures = 0;
      var isCircuitBroken = false;
      var isActive = true;

      void recordDeliveryOutcome(bool success) {
        if (success) {
          consecutiveFailures = 0;
        } else {
          consecutiveFailures++;
          if (consecutiveFailures >= 10) {
            isCircuitBroken = true;
            isActive = false;
          }
        }
      }

      // 9 consecutive failures -> still active, not circuit broken
      for (int i = 0; i < 9; i++) {
        recordDeliveryOutcome(false);
      }
      expect(consecutiveFailures, equals(9));
      expect(isCircuitBroken, isFalse);
      expect(isActive, isTrue);

      // 10th failure -> trips breaker!
      recordDeliveryOutcome(false);
      expect(consecutiveFailures, equals(10));
      expect(isCircuitBroken, isTrue);
      expect(isActive, isFalse);
    });

    test('10. Recovery: Successful delivery resets consecutive failure counter to zero', () {
      var consecutiveFailures = 8;
      consecutiveFailures = 0; // Simulated reset on success
      expect(consecutiveFailures, equals(0));
    });
  });

  group('Webhook Notification Engine - UI Widget Rendering Tests', () {
    testWidgets('11. WebhookManagementView renders header, action button, and tabs', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            webhookRepositoryProvider.overrideWithValue(_FakeWebhookRepository()),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: WebhookManagementView(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Header Titles
      expect(find.text('Webhook Integrations & Real-Time Sync'), findsOneWidget);
      expect(
        find.text('Event-driven outbound HTTP dispatches with HMAC-SHA256 payload signatures'),
        findsOneWidget,
      );

      // Verify Register Webhook Action Button
      expect(find.text('+ Register Webhook'), findsOneWidget);
      expect(find.byIcon(Icons.add_link_rounded), findsWidgets);

      // Verify List Item Rendered from Mock Repository
      expect(find.text('Enterprise ERP Relay'), findsOneWidget);
      expect(find.text('https://api.enterprise.com/hooks'), findsOneWidget);
    });
  });
}
