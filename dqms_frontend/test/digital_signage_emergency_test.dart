import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dqms_frontend/features/admin/models/signage_models.dart';
import 'package:dqms_frontend/features/admin/providers/navigation_menu_provider.dart';
import 'package:dqms_frontend/features/customer/tv/widgets/emergency_broadcast_overlay.dart';
import 'package:dqms_frontend/features/customer/tv/widgets/signage_media_zone.dart';

void main() {
  group('Digital Signage & Emergency Broadcast - Models Serialization', () {
    test('SignageCampaign and SignageMediaItem serialize and deserialize correctly', () {
      final json = {
        'id': 101,
        'organizationId': 1,
        'campaignName': 'Winter Wellness Campaign',
        'campaignType': 2,
        'priority': 8,
        'startDate': '2026-11-01T00:00:00.000',
        'endDate': '2026-12-31T23:59:59.000',
        'dailyStartTime': '08:00:00',
        'dailyEndTime': '18:00:00',
        'daysOfWeek': '1,2,3,4,5',
        'locationId': 2,
        'isActive': true,
        'mediaItems': [
          {
            'id': 501,
            'campaignId': 101,
            'mediaType': 1,
            'mediaUrl': 'https://example.com/banner.jpg',
            'title': 'Flu Vaccine Awareness',
            'durationSeconds': 20,
            'displayOrder': 1,
            'muteAudio': true,
            'isActive': true,
          }
        ],
      };

      final campaign = SignageCampaign.fromJson(json);
      expect(campaign.id, 101);
      expect(campaign.campaignName, 'Winter Wellness Campaign');
      expect(campaign.priority, 8);
      expect(campaign.mediaItems.length, 1);
      expect(campaign.mediaItems.first.title, 'Flu Vaccine Awareness');
      expect(campaign.mediaItems.first.durationSeconds, 20);

      final exportedJson = campaign.toJson();
      expect(exportedJson['campaignName'], 'Winter Wellness Campaign');
      expect(exportedJson['mediaItems'], isNotEmpty);
    });

    test('EmergencyBroadcast model parses critical emergency payload', () {
      final json = {
        'id': 99,
        'organizationId': 1,
        'locationId': 1,
        'broadcastCode': 'CODE_RED',
        'title': 'FIRE EVACUATION IN PROGRESS',
        'messageText': 'Evacuate via Stairwell B immediately.',
        'severity': 3,
        'audioSirenType': 2,
        'flashColorHex': '#FF1744',
        'isActive': true,
        'triggeredAt': '2026-11-24T10:00:00.000',
      };

      final alert = EmergencyBroadcast.fromJson(json);
      expect(alert.id, 99);
      expect(alert.broadcastCode, 'CODE_RED');
      expect(alert.severity, 3);
      expect(alert.title, 'FIRE EVACUATION IN PROGRESS');
      expect(alert.isActive, isTrue);

      final exported = alert.toJson();
      expect(exported['broadcastCode'], 'CODE_RED');
      expect(exported['severity'], 3);
    });
  });

  group('Navigation Menu Provider - Project Rules Compliance', () {
    test('Fallback menus contain /admin/signage-campaigns route', () {
      final fallbackMenus = NavigationMenuNotifier.fallbackMenus;
      final signageMenu = fallbackMenus.firstWhere(
        (m) => m.routePath == '/admin/signage-campaigns',
        orElse: () => throw Exception('Missing /admin/signage-campaigns fallback menu'),
      );

      expect(signageMenu.routePath, '/admin/signage-campaigns');
      expect(signageMenu.iconName, 'campaign_rounded');
      expect(signageMenu.requiredPermission, 'ManageSignage');
      expect(signageMenu.isActive, isTrue);
    });
  });

  group('EmergencyBroadcastOverlay Widget Tests', () {
    testWidgets('Renders nothing when emergency is null or inactive', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmergencyBroadcastOverlay(broadcast: null),
          ),
        ),
      );

      expect(find.byType(EmergencyBroadcastOverlay), findsOneWidget);
      expect(find.textContaining('EMERGENCY'), findsNothing);
    });

    testWidgets('Renders high-contrast pulsing alert when emergency is active', (tester) async {
      final alert = EmergencyBroadcast(
        id: 1,
        organizationId: 1,
        broadcastCode: 'CODE_RED',
        title: 'FIRE EVACUATION IN PROGRESS',
        messageText: 'Evacuate immediately via Stairwell B. Do not use elevators.',
        severity: 3,
        audioSirenType: 1,
        flashColorHex: '#FF1744',
        isActive: true,
        triggeredAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmergencyBroadcastOverlay(broadcast: alert),
          ),
        ),
      );

      // Verify title, message text, and siren warning
      expect(find.textContaining('FIRE EVACUATION IN PROGRESS'), findsOneWidget);
      expect(find.textContaining('Stairwell B'), findsOneWidget);
      expect(find.textContaining('AUDIO SIREN ACTIVE: CODE_RED'), findsOneWidget);
    });
  });

  group('SignageMediaZone Widget Tests', () {
    testWidgets('Renders default medical center promo card when playlist is empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: SignageMediaZone(items: []),
            ),
          ),
        ),
      );

      expect(find.text('Welcome to DQMS Medical Center'), findsOneWidget);
      expect(find.byIcon(Icons.health_and_safety_rounded), findsOneWidget);
    });

    testWidgets('Renders active media slide and shows audio ducking banner', (tester) async {
      final items = [
        const SignageMediaItem(
          id: 1,
          campaignId: 10,
          mediaType: 1,
          mediaUrl: 'assets/sample.png',
          title: 'Hand Hygiene Protocol',
          durationSeconds: 15,
          displayOrder: 1,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 500,
              height: 400,
              child: SignageMediaZone(
                items: items,
                isDucked: true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Hand Hygiene Protocol'), findsAtLeastNWidgets(1));
      expect(find.text('AUDIO DUCKED'), findsOneWidget);
      expect(find.byIcon(Icons.volume_mute_rounded), findsOneWidget);
      expect(find.text('1 / 1 • ADVISORY'), findsOneWidget);
    });
  });
}
