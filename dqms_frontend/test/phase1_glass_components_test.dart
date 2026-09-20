import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/core/theme/app_decorations.dart';
import 'package:dqms_frontend/core/theme/app_typography.dart';
import 'package:dqms_frontend/core/widgets/glass_widgets.dart';
import 'package:dqms_frontend/core/widgets/dqms_button.dart';
import 'package:dqms_frontend/core/widgets/dqms_3d_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget wrapWithMaterial(Widget child) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: AppColors.bgCanvas,
        body: SingleChildScrollView(child: Center(child: child)),
      ),
    );
  }

  group('Phase 1 — Core Design System Tokens Verification', () {
    test('AppColors QueuePro tokens are properly defined', () {
      expect(AppColors.electricBlue, const Color(0xFF2563EB));
      expect(AppColors.violetPrimary, const Color(0xFF8B5CF6));
      expect(AppColors.cyanGlow, const Color(0xFF00E5FF));
      expect(AppColors.emeraldSuccess, const Color(0xFF10B981));
      expect(AppColors.heroGradient.colors.length, 2);
      expect(AppColors.servingGradient.colors.length, 3);
    });

    test('AppRadius tokens are properly defined', () {
      expect(AppRadius.squircle, 14.0);
      expect(AppRadius.card, 18.0);
      expect(AppRadius.hero, 24.0);
      expect(AppRadius.sheet, 28.0);
      expect(AppRadius.pill, 999.0);
    });

    testWidgets('AppTypography tokens are properly initialized', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Text('Probe', style: AppTypography.tokenHero),
        ),
      );
      expect(AppTypography.tokenHero.fontSize, 48);
      expect(AppTypography.heroGreeting.fontSize, 22);
      expect(AppTypography.sectionTitle.fontSize, 16);
      expect(AppTypography.squircleLabel.fontSize, 11);
    });
  });

  group('Phase 1 — Reusable Glass Components Widget Tests', () {
    testWidgets('GlassContainer renders child with styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithMaterial(
          const GlassContainer(
            borderRadius: AppRadius.card,
            child: Text('Glass Content Test'),
          ),
        ),
      );

      expect(find.text('Glass Content Test'), findsOneWidget);
    });

    testWidgets('GlassCard handles tap interactions and renders specular layer', (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        wrapWithMaterial(
          GlassCard(
            onTap: () => tapped = true,
            child: const Text('Interactive Glass Card'),
          ),
        ),
      );

      expect(find.text('Interactive Glass Card'), findsOneWidget);
      await tester.tap(find.text('Interactive Glass Card'));
      expect(tapped, isTrue);
    });

    testWidgets('GlassSquircleIcon renders icon inside tinted squircle container', (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        wrapWithMaterial(
          GlassSquircleIcon(
            icon: Icons.calendar_month_rounded,
            backgroundColor: AppColors.blueIconBg,
            iconColor: AppColors.blueIconText,
            onTap: () => tapped = true,
          ),
        ),
      );

      expect(find.byIcon(Icons.calendar_month_rounded), findsOneWidget);
      await tester.tap(find.byIcon(Icons.calendar_month_rounded));
      expect(tapped, isTrue);
    });

    testWidgets('GlassPillBadge renders all status variants properly', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithMaterial(
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GlassPillBadge(label: 'Now Serving', variant: GlassPillVariant.nowServing),
              GlassPillBadge(label: 'Waiting', variant: GlassPillVariant.waiting),
              GlassPillBadge(label: 'Upcoming', variant: GlassPillVariant.upcoming),
              GlassPillBadge(label: 'Completed', variant: GlassPillVariant.completed),
              GlassPillBadge(label: 'Verified', variant: GlassPillVariant.verified),
              GlassPillBadge(label: 'Canceled', variant: GlassPillVariant.canceled),
            ],
          ),
        ),
      );

      expect(find.text('Now Serving'), findsOneWidget);
      expect(find.text('Waiting'), findsOneWidget);
      expect(find.text('Upcoming'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('Verified'), findsOneWidget);
      expect(find.text('Canceled'), findsOneWidget);
    });

    testWidgets('GlassTokenCard renders token, status, QR code, and triggers actions', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      bool shareTapped = false;
      await tester.pumpWidget(
        wrapWithMaterial(
          GlassTokenCard(
            tokenNumber: 'A012',
            status: 'Now Serving',
            serviceName: 'Consultation - General Physician',
            doctorName: 'Dr. Ahmed Rahman',
            roomInfo: 'Room 2',
            timeInfo: '10:20 AM',
            queuePosition: 2,
            estimatedWaitMinutes: 12,
            onShare: () => shareTapped = true,
          ),
        ),
      );

      expect(find.text('YOUR QUEUE TOKEN'), findsOneWidget);
      expect(find.text('A012'), findsOneWidget);
      expect(find.text('NOW SERVING'), findsOneWidget);
      expect(find.text('Consultation - General Physician'), findsOneWidget);
      expect(find.text('Dr. Ahmed Rahman'), findsOneWidget);
      expect(find.text('Room 2  •  10:20 AM'), findsOneWidget);
      expect(find.text('Queue Position'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('Estimated Wait'), findsOneWidget);
      expect(find.text('~12 min'), findsOneWidget);
      expect(find.text('Share Token'), findsOneWidget);

      await tester.tap(find.text('Share Token'));
      expect(shareTapped, isTrue);
    });

    testWidgets('GlassBottomNav renders navigation items and responds to tab switches', (WidgetTester tester) async {
      int activeTab = 0;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return wrapWithMaterial(
              GlassBottomNav(
                currentIndex: activeTab,
                onTap: (index) => setState(() => activeTab = index),
                items: const [
                  GlassNavItem(icon: Icons.home_rounded, label: 'Home'),
                  GlassNavItem(icon: Icons.group_rounded, label: 'Queue'),
                  GlassNavItem(icon: Icons.calendar_today_rounded, label: 'Appointments'),
                  GlassNavItem(icon: Icons.person_rounded, label: 'Profile'),
                ],
              ),
            );
          },
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.byIcon(Icons.group_rounded), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today_rounded), findsOneWidget);
      expect(find.byIcon(Icons.person_rounded), findsOneWidget);

      // Switch to Queue tab
      await tester.tap(find.byIcon(Icons.group_rounded));
      await tester.pump();
      expect(activeTab, 1);
      expect(find.text('Queue'), findsOneWidget);
    });

    testWidgets('DqmsButton gradientPill variant renders with label and trailingIcon', (WidgetTester tester) async {
      bool buttonPressed = false;
      await tester.pumpWidget(
        wrapWithMaterial(
          DqmsButton(
            label: 'View Details',
            variant: DqmsButtonVariant.gradientPill,
            trailingIcon: Icons.arrow_forward_rounded,
            onPressed: () => buttonPressed = true,
          ),
        ),
      );

      expect(find.text('View Details'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
      await tester.tap(find.text('View Details'));
      expect(buttonPressed, isTrue);
    });

    testWidgets('Dqms3dCard renders with upgraded AppRadius.card', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithMaterial(
          const Dqms3dCard(
            child: Text('3D Card Content'),
          ),
        ),
      );

      expect(find.text('3D Card Content'), findsOneWidget);
    });
  });
}
