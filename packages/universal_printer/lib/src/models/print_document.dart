// src/models/print_document.dart
import 'package:meta/meta.dart';

@immutable
class PrintDocument {
  final String title;
  final String? header;
  final String? businessInfo;
  final List<PrintLineItem> items;
  final double subtotal;
  final double taxes;
  final double discounts;
  final double total;
  final String? qrData;
  final String? footer;
  final PaperProfile paperProfile;

  const PrintDocument({
    required this.title,
    this.header,
    this.businessInfo,
    required this.items,
    required this.subtotal,
    required this.taxes,
    required this.discounts,
    required this.total,
    this.qrData,
    this.footer,
    this.paperProfile = PaperProfile.a4,
  });
}

@immutable
class PrintLineItem {
  final String description;
  final int quantity;
  final double unitPrice;
  final double total;

  const PrintLineItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });
}

enum PaperProfile {
  a4,
  letter,
  thermal58,
  thermal80,
}
