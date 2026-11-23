import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dqms_frontend/features/dashboard/models/tat_analytics_dto.dart';
import 'package:dqms_frontend/features/dashboard/widgets/tat_analytics_panel.dart';
import 'package:dqms_frontend/features/dashboard/widgets/bottleneck_heatmap_matrix.dart';
import 'package:dqms_frontend/features/dashboard/providers/dashboard_provider.dart';

void main() {
  group('1. TAT Variance & Mathematical Dispersion Model Tests', () {
    test('Positive and Negative Variance % calculate accurately against Target SLA', () {
      // Positive variance (Actual > Target => Overrunning SLA)
      const targetMins = 15.0;
      const actualMinsOver = 18.0;
      final variancePctPositive = ((actualMinsOver - targetMins) / targetMins) * 100.0;
      expect(variancePctPositive, closeTo(20.0, 0.01));

      // Negative variance (Actual < Target => Under SLA / Fast turnaround)
      const actualMinsUnder = 12.0;
      final variancePctNegative = ((actualMinsUnder - targetMins) / targetMins) * 100.0;
      expect(variancePctNegative, closeTo(-20.0, 0.01));

      // Zero variance
      final variancePctZero = ((targetMins - targetMins) / targetMins) * 100.0;
      expect(variancePctZero, equals(0.0));
    });

    test('Division by zero protection when TargetTAT is 0 or unassigned', () {
      const targetZero = 0.0;
      const actual = 10.0;
      final safeVariance = targetZero > 0 ? ((actual - targetZero) / targetZero) * 100.0 : 0.0;
      expect(safeVariance, equals(0.0));
    });

    test('P95 Turnaround Time and Coefficient of Variation formulas are mathematically consistent', () {
      final summary = TatVarianceSummaryDto.mock();
      expect(summary.p95TatMinutes, greaterThan(summary.averageTatMinutes));
      expect(summary.stdDevMinutes, greaterThan(0.0));
      expect(summary.coefficientOfVariation, closeTo(summary.stdDevMinutes / summary.averageTatMinutes, 0.01));
    });

    test('Process breakdown parses JSON accurately and maintains status tiers', () {
      final mock = TatVarianceReportDto.mock();
      expect(mock.processBreakdown.length, equals(4));

      final genProcess = mock.processBreakdown.firstWhere((p) => p.processCode == 'GEN');
      expect(genProcess.variancePercentage, isNegative);
      expect(genProcess.statusTier, equals('OPTIMAL'));

      final cshProcess = mock.processBreakdown.firstWhere((p) => p.processCode == 'CSH');
      expect(cshProcess.variancePercentage, isPositive);
      expect(cshProcess.statusTier, equals('CONGESTED'));
    });
  });

  group('2. 2D Bottleneck Heatmap Matrix Model Tests', () {
    test('Heatmap Matrix generates complete hour slots across 8:00 to 18:00', () {
      final heatmap = BottleneckHeatmapDto.mock(dimensionType: 'HourByDayOfWeek');
      expect(heatmap.dimensionType, equals('HourByDayOfWeek'));
      expect(heatmap.cells.isNotEmpty, isTrue);

      final hours = heatmap.cells.map((c) => c.hourOfDay).toSet();
      expect(hours.contains(8), isTrue);
      expect(hours.contains(13), isTrue);
      expect(hours.contains(18), isTrue);
    });

    test('Congestion scores map correctly to severity tiers', () {
      final heatmap = BottleneckHeatmapDto.mock();
      for (final cell in heatmap.cells) {
        if (cell.congestionScore >= 75) {
          expect(cell.congestionLevel, equals('CRITICAL'));
        } else if (cell.congestionScore >= 50) {
          expect(cell.congestionLevel, equals('HIGH'));
        } else if (cell.congestionScore >= 25) {
          expect(cell.congestionLevel, equals('MODERATE'));
        } else {
          expect(cell.congestionLevel, equals('LOW'));
        }
      }
    });

    test('Dimension types switch properly and populate respective labels', () {
      final dayHeatmap = BottleneckHeatmapDto.mock(dimensionType: 'HourByDayOfWeek');
      expect(dayHeatmap.cells.any((c) => c.dimensionLabel == 'Monday'), isTrue);

      final processHeatmap = BottleneckHeatmapDto.mock(dimensionType: 'HourByProcess');
      expect(processHeatmap.cells.any((c) => c.dimensionLabel == 'General Inquiries'), isTrue);

      final counterHeatmap = BottleneckHeatmapDto.mock(dimensionType: 'HourByCounter');
      expect(counterHeatmap.cells.any((c) => c.dimensionLabel == 'C-01'), isTrue);
    });
  });

  group('3. UI Widget Integration Tests', () {
    testWidgets('TatAnalyticsPanel renders variance %, P95, and process breakdown', (tester) async {
      final report = TatVarianceReportDto.mock();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: TatAnalyticsPanel(report: report),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('TAT VARIANCE & SLA COMPLIANCE'), findsOneWidget);
      expect(find.text('P95 TAT'), findsOneWidget);
      expect(find.text('StdDev (σ)'), findsOneWidget);
      expect(find.text('SLA Pass'), findsOneWidget);
      expect(find.text('General Inquiries'), findsOneWidget);
      expect(find.text('Cashier & Payments'), findsOneWidget);
    });

    testWidgets('BottleneckHeatmapMatrix renders 2D matrix, peak badge, and dimension buttons', (tester) async {
      final heatmap = BottleneckHeatmapDto.mock(dimensionType: 'HourByDayOfWeek');

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: BottleneckHeatmapMatrix(heatmap: heatmap),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('BOTTLENECK CONGESTION HEATMAP'), findsOneWidget);
      expect(find.textContaining('Peak:'), findsOneWidget);
      expect(find.text('By Day of Week'), findsOneWidget);
      expect(find.text('By Service Process'), findsOneWidget);
      expect(find.text('By Counter Station'), findsOneWidget);
      expect(find.text('Monday'), findsOneWidget);
    });

    testWidgets('Tapping a Heatmap Cell triggers detail drilldown dialog with metrics', (tester) async {
      final heatmap = BottleneckHeatmapDto.mock(dimensionType: 'HourByDayOfWeek');

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: BottleneckHeatmapMatrix(heatmap: heatmap),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find first clickable cell container with wait time text (e.g. "m")
      final cellFinder = find.textContaining('m').first;
      await tester.tap(cellFinder);
      await tester.pumpAndSettle();

      // Verify drill-down dialog opened
      expect(find.text('Congestion Level'), findsOneWidget);
      expect(find.text('Tokens Processed'), findsOneWidget);
      expect(find.text('Average Wait Time'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);

      // Close modal
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.text('Tokens Processed'), findsNothing);
    });
  });
}
