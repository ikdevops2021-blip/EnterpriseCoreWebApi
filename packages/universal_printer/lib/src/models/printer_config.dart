import 'package:meta/meta.dart';

enum PrinterMode { a4, thermal58, thermal80 }

@immutable
class PrinterConfig {
  final PrinterMode mode;
  final String? connectionType; // 'lan', 'bluetooth', 'usb', or null for PDF fallback
  final String? ipAddress;
  final int? port;

  const PrinterConfig({
    required this.mode,
    this.connectionType,
    this.ipAddress,
    this.port,
  });

  factory PrinterConfig.fromMap(Map<String, dynamic> map) {
    return PrinterConfig(
      mode: PrinterMode.values.firstWhere(
        (e) => e.name == (map['mode'] as String?),
        orElse: () => PrinterMode.a4,
      ),
      connectionType: map['connectionType'] as String?,
      ipAddress: map['ipAddress'] as String?,
      port: map['port'] as int?,
    );
  }

  Map<String, dynamic> toMap() => {
        'mode': mode.name,
        'connectionType': connectionType,
        'ipAddress': ipAddress,
        'port': port,
      };
}
