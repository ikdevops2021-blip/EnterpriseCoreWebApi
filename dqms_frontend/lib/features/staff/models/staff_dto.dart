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

class ForwardTokenRequestDto {
  final int tokenId;
  final int? targetProcessId;
  final int? targetCounterId;
  final bool isSubToken;
  final String? reason;
  final int staffUserId;

  const ForwardTokenRequestDto({
    required this.tokenId,
    this.targetProcessId,
    this.targetCounterId,
    this.isSubToken = false,
    this.reason,
    this.staffUserId = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      'tokenId': tokenId,
      'targetProcessId': targetProcessId,
      'targetCounterId': targetCounterId,
      'isSubToken': isSubToken,
      'reason': reason,
      'staffUserId': staffUserId,
    };
  }
}

class ProcessStepDto {
  final int id;
  final int processId;
  final String processName;
  final String processCode;
  final int stepOrder;
  final String stepName;
  final int targetTATMinutes;
  final bool isActive;

  const ProcessStepDto({
    required this.id,
    required this.processId,
    required this.processName,
    required this.processCode,
    required this.stepOrder,
    required this.stepName,
    required this.targetTATMinutes,
    required this.isActive,
  });

  factory ProcessStepDto.fromJson(Map<String, dynamic> json) {
    return ProcessStepDto(
      id: json['id'] ?? 0,
      processId: json['processId'] ?? 0,
      processName: json['processName'] ?? '',
      processCode: json['processCode'] ?? '',
      stepOrder: json['stepOrder'] ?? 1,
      stepName: json['stepName'] ?? '',
      targetTATMinutes: json['targetTATMinutes'] ?? 10,
      isActive: json['isActive'] ?? true,
    );
  }
}

class TokenWorkflowStepDto {
  final int transactionId;
  final String tokenNumber;
  final int stepOrder;
  final String stepName;
  final int targetTATMinutes;
  final int processId;
  final String processName;
  final int? counterId;
  final String? counterNumber;
  final String? counterName;
  final int tokenStatus;
  final String statusName;
  final DateTime? issuedTime;
  final DateTime? calledTime;
  final DateTime? servedTime;
  final DateTime? completedTime;
  final int durationSeconds;
  final String? notes;

  const TokenWorkflowStepDto({
    required this.transactionId,
    required this.tokenNumber,
    required this.stepOrder,
    required this.stepName,
    required this.targetTATMinutes,
    required this.processId,
    required this.processName,
    this.counterId,
    this.counterNumber,
    this.counterName,
    required this.tokenStatus,
    required this.statusName,
    this.issuedTime,
    this.calledTime,
    this.servedTime,
    this.completedTime,
    this.durationSeconds = 0,
    this.notes,
  });

  factory TokenWorkflowStepDto.fromJson(Map<String, dynamic> json) {
    return TokenWorkflowStepDto(
      transactionId: json['transactionId'] ?? 0,
      tokenNumber: json['tokenNumber'] ?? '',
      stepOrder: json['stepOrder'] ?? 1,
      stepName: json['stepName'] ?? '',
      targetTATMinutes: json['targetTATMinutes'] ?? 10,
      processId: json['processId'] ?? 0,
      processName: json['processName'] ?? '',
      counterId: json['counterId'],
      counterNumber: json['counterNumber'],
      counterName: json['counterName'],
      tokenStatus: json['tokenStatus'] ?? 18001,
      statusName: json['statusName'] ?? 'Queued',
      issuedTime: json['issuedTime'] != null ? DateTime.tryParse(json['issuedTime']) : null,
      calledTime: json['calledTime'] != null ? DateTime.tryParse(json['calledTime']) : null,
      servedTime: json['servedTime'] != null ? DateTime.tryParse(json['servedTime']) : null,
      completedTime: json['completedTime'] != null ? DateTime.tryParse(json['completedTime']) : null,
      durationSeconds: json['durationSeconds'] ?? 0,
      notes: json['notes'],
    );
  }
}

class SubTokenDto {
  final int subTokenId;
  final String tokenNumber;
  final int subTokenSequence;
  final int processId;
  final String processName;
  final int? counterId;
  final String? counterNumber;
  final int tokenStatus;
  final String statusName;
  final DateTime? issuedTime;
  final DateTime? servedTime;
  final DateTime? completedTime;
  final String? notes;

  const SubTokenDto({
    required this.subTokenId,
    required this.tokenNumber,
    required this.subTokenSequence,
    required this.processId,
    required this.processName,
    this.counterId,
    this.counterNumber,
    required this.tokenStatus,
    required this.statusName,
    this.issuedTime,
    this.servedTime,
    this.completedTime,
    this.notes,
  });

  factory SubTokenDto.fromJson(Map<String, dynamic> json) {
    return SubTokenDto(
      subTokenId: json['subTokenId'] ?? 0,
      tokenNumber: json['tokenNumber'] ?? '',
      subTokenSequence: json['subTokenSequence'] ?? 1,
      processId: json['processId'] ?? 0,
      processName: json['processName'] ?? '',
      counterId: json['counterId'],
      counterNumber: json['counterNumber'],
      tokenStatus: json['tokenStatus'] ?? 18001,
      statusName: json['statusName'] ?? 'Queued',
      issuedTime: json['issuedTime'] != null ? DateTime.tryParse(json['issuedTime']) : null,
      servedTime: json['servedTime'] != null ? DateTime.tryParse(json['servedTime']) : null,
      completedTime: json['completedTime'] != null ? DateTime.tryParse(json['completedTime']) : null,
      notes: json['notes'],
    );
  }
}

class TokenWorkflowHistoryDto {
  final int rootTokenId;
  final String tokenNumber;
  final int organizationId;
  final int locationId;
  final int processId;
  final String processName;
  final String processCode;
  final String? customerName;
  final String? customerPhone;
  final int priorityTier;
  final DateTime? issuedTime;
  final int totalConfiguredSteps;
  final int currentStepOrder;
  final List<TokenWorkflowStepDto> steps;
  final List<SubTokenDto> subTokens;

  const TokenWorkflowHistoryDto({
    required this.rootTokenId,
    required this.tokenNumber,
    required this.organizationId,
    required this.locationId,
    required this.processId,
    required this.processName,
    required this.processCode,
    this.customerName,
    this.customerPhone,
    required this.priorityTier,
    this.issuedTime,
    required this.totalConfiguredSteps,
    required this.currentStepOrder,
    this.steps = const [],
    this.subTokens = const [],
  });

  factory TokenWorkflowHistoryDto.fromJson(Map<String, dynamic> json) {
    return TokenWorkflowHistoryDto(
      rootTokenId: json['rootTokenId'] ?? 0,
      tokenNumber: json['tokenNumber'] ?? '',
      organizationId: json['organizationId'] ?? 1,
      locationId: json['locationId'] ?? 1,
      processId: json['processId'] ?? 0,
      processName: json['processName'] ?? '',
      processCode: json['processCode'] ?? '',
      customerName: json['customerName'],
      customerPhone: json['customerPhone'],
      priorityTier: json['priorityTier'] ?? 19001,
      issuedTime: json['issuedTime'] != null ? DateTime.tryParse(json['issuedTime']) : null,
      totalConfiguredSteps: json['totalConfiguredSteps'] ?? 1,
      currentStepOrder: json['currentStepOrder'] ?? 1,
      steps: (json['steps'] as List?)?.map((s) => TokenWorkflowStepDto.fromJson(s as Map<String, dynamic>)).toList() ?? [],
      subTokens: (json['subTokens'] as List?)?.map((s) => SubTokenDto.fromJson(s as Map<String, dynamic>)).toList() ?? [],
    );
  }
}
