import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dqms_frontend/features/admin/widgets/processes_view.dart';

void main() {
  testWidgets('ProcessesView does NOT overflow before or after process selection at 1536x703 and compact widths', (WidgetTester tester) async {
    // Exact user viewport: 1536 x 703
    tester.view.physicalSize = const Size(1536, 703);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: ProcessesView(),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    // Verify initial render (before selection) has no errors
    expect(find.text('Clinical Services & Process Pipeline SLA'), findsOneWidget);
    expect(find.text('Global SLA Target'), findsOneWidget);
    expect(find.text('Avg Waiting TAT'), findsOneWidget);

    // Select a process to open the side inspector (PROC-101)
    final procTile = find.text('PROC-101');
    if (procTile.evaluate().isNotEmpty) {
      await tester.tap(procTile.first);
      await tester.pump(const Duration(milliseconds: 500));
    }

    // Now test with narrower constrained widths (e.g. 724px, the exact master width when detail opens)
    tester.view.physicalSize = const Size(724, 703);
    await tester.pump(const Duration(milliseconds: 500));

    // Also test compact landscape (812 x 375)
    tester.view.physicalSize = const Size(812, 375);
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(ProcessesView), findsOneWidget);
  });
}
