import 'package:flutter_test/flutter_test.dart';
import 'package:dqms_frontend/main.dart';

void main() {
  testWidgets('DQMS app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const DqmsApp());
    expect(find.text('DQMS'), findsOneWidget);
  });
}
