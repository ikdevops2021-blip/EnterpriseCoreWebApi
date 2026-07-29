/// ============================================================================
/// DQMS Staff Operator & Token DTO Models
/// Maps to C# DqmsStaffModels.cs in Shared Core
/// ============================================================================

class TokenTransactionDto {
  final int id;
  final String tokenNumber;
  final int organizationId;
  final int locationId;
  final int areaId;
  final int processId;
  final int? counterId;
  final int? userId;
  final int priorityTier;
  final int tokenStatus;
  final int queuePosition;
  final String? customerName;
  final String? customerPhone;
  final String? notes;
  final String? issuedTime;
  final String? calledTime;
  final String? servedTime;
  final String? completedTime;

  TokenTransactionDto({
    required this.id,
    required this.tokenNumber,
    required this.organizationId,
    required this.locationId,
    required this.areaId,
    required this.processId,
    this.counterId,
    this.userId,
    required this.priorityTier,
    required this.tokenStatus,
    required this.queuePosition,
    this.customerName,
    this.customerPhone,
    this.notes,
    this.issuedTime,
    this.calledTime,
    this.servedTime,
    this.completedTime,
  });

  factory TokenTransactionDto.fromJson(Map<String, dynamic> json) {
    return TokenTransactionDto(
      id: json['id'] ?? 0,
      tokenNumber: json['tokenNumber'] ?? '',
      organizationId: json['organizationId'] ?? 1,
      locationId: json['locationId'] ?? 1,
      areaId: json['areaId'] ?? 1,
      processId: json['processId'] ?? 1,
      counterId: json['counterId'],
      userId: json['userId'],
      priorityTier: json['priorityTier'] ?? 19001,
      tokenStatus: json['tokenStatus'] ?? 18001,
      queuePosition: json['queuePosition'] ?? 1,
      customerName: json['customerName'],
      customerPhone: json['customerPhone'],
      notes: json['notes'],
      issuedTime: json['issuedTime']?.toString(),
      calledTime: json['calledTime']?.toString(),
      servedTime: json['servedTime']?.toString(),
      completedTime: json['completedTime']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'tokenNumber': tokenNumber,
        'organizationId': organizationId,
        'locationId': locationId,
        'areaId': areaId,
        'processId': processId,
        'counterId': counterId,
        'userId': userId,
        'priorityTier': priorityTier,
        'tokenStatus': tokenStatus,
        'queuePosition': queuePosition,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'notes': notes,
      };
}
