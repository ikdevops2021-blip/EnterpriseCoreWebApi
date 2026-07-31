// Staff API DTOs — Serializes /api/v1/staff/* requests & responses

class CallNextTokenRequestDto {
  final int organizationId;
  final int locationId;
  final int counterId;
  final int processId;

  const CallNextTokenRequestDto({
    this.organizationId = 1,
    this.locationId = 1,
    this.counterId = 1,
    this.processId = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      'organizationId': organizationId,
      'locationId': locationId,
      'counterId': counterId,
      'processId': processId,
    };
  }
}

class UpdateTokenStatusRequestDto {
  final int tokenId;
  final int newStatus; // e_TokenStatus int value (e.g. 18004 Active/Serve, 18005 Hold, 18006 Canceled, 18007 Completed)
  final String? reason;

  const UpdateTokenStatusRequestDto({
    required this.tokenId,
    required this.newStatus,
    this.reason,
  });

  Map<String, dynamic> toJson() {
    return {
      'tokenId': tokenId,
      'newStatus': newStatus,
      'reason': reason,
    };
  }
}

class IssueTokenRequestDto {
  final int organizationId;
  final int locationId;
  final int areaId;
  final int processId;
  final int priorityTier; // e_PriorityTier int value (e.g. 19001 Standard, 19002 Senior, 19005 VIP)
  final String? customerName;
  final String? customerPhone;

  const IssueTokenRequestDto({
    this.organizationId = 1,
    this.locationId = 1,
    this.areaId = 1,
    this.processId = 1,
    this.priorityTier = 19001,
    this.customerName,
    this.customerPhone,
  });

  Map<String, dynamic> toJson() {
    return {
      'organizationId': organizationId,
      'locationId': locationId,
      'areaId': areaId,
      'processId': processId,
      'priorityTier': priorityTier,
      'customerName': customerName,
      'customerPhone': customerPhone,
    };
  }
}
