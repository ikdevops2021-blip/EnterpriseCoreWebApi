// src/drivers/printer_driver.dart
import 'package:pdf/widgets.dart' as pw;
import '../models/print_document.dart';
import '../models/printer_config.dart';

/// Abstract driver that knows how to turn a [PrintDocument] into either
/// raw ESC/POS bytes or a PDF document.
abstract class PrinterDriver {
  /// Returns a list of bytes ready to be sent to the printer.
  /// For PDF based drivers this will be a PDF file; for native thermal
  /// drivers it will be ESC/POS commands.
  Future<List<int>> generateBytes(PrintDocument document, PrinterConfig config);

  /// Optional method to directly send the bytes to the printer. Implementations
  /// may choose to skip this (e.g., PDF drivers rely on the `printing` package).
  Future<void> sendToPrinter(List<int> bytes, PrinterConfig config);
}
