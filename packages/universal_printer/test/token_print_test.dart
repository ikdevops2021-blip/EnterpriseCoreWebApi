import 'package:flutter_test/flutter_test.dart';
import 'package:universal_printer/universal_printer.dart';
import 'package:universal_printer/src/models/token_print_helper.dart';

void main() {
  test('Print token document generates PDF', () async {
    const token = 'TEST-12345';
    final doc = TokenPrintHelper.createTokenDocument(token);
    final printer = UniversalPrinterService();
    await printer.printDocument(doc);
    // No assertions; just ensure no exception.
  });
}
