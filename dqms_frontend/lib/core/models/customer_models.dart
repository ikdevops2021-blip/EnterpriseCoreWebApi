// ignore_for_file: dangling_library_doc_comments

/// ============================================================================
/// Stage 3 Customer & Display DTO Models
/// Maps to C# DqmsCustomerModels.cs in Shared Core
/// ============================================================================

class DisplayBoardItemDto {
  final int id;
  final String tokenNumber;
  final int processId;
  final String processName;
  final String prefix;
  final int? counterId;
  final String? counterNumber;
  final String? counterName;
  final int tokenStatus;
  final String? calledTime;
  final bool flashAlert;

  DisplayBoardItemDto({
    required this.id,
    required this.tokenNumber,
    required this.processId,
    required this.processName,
    required this.prefix,
    this.counterId,
    this.counterNumber,
    this.counterName,
    required this.tokenStatus,
    this.calledTime,
    required this.flashAlert,
  });

  factory DisplayBoardItemDto.fromJson(Map<String, dynamic> json) {
    return DisplayBoardItemDto(
      id: json['id'] ?? 0,
      tokenNumber: json['tokenNumber'] ?? '',
      processId: json['processId'] ?? 0,
      processName: json['processName'] ?? '',
      prefix: json['prefix'] ?? 'A',
      counterId: json['counterId'],
      counterNumber: json['counterNumber'],
      counterName: json['counterName'],
      tokenStatus: json['tokenStatus'] ?? 18003,
      calledTime: json['calledTime']?.toString(),
      flashAlert: json['flashAlert'] ?? false,
    );
  }
}

class PublicTokenStatusDto {
  final int id;
  final String tokenNumber;
  final String processName;
  final int tokenStatus;
  final int customersAhead;
  final int estimatedWaitMinutes;
  final String? counterNumber;
  final String? counterName;

  PublicTokenStatusDto({
    required this.id,
    required this.tokenNumber,
    required this.processName,
    required this.tokenStatus,
    required this.customersAhead,
    required this.estimatedWaitMinutes,
    this.counterNumber,
    this.counterName,
  });

  factory PublicTokenStatusDto.fromJson(Map<String, dynamic> json) {
    return PublicTokenStatusDto(
      id: json['id'] ?? 0,
      tokenNumber: json['tokenNumber'] ?? '',
      processName: json['processName'] ?? '',
      tokenStatus: json['tokenStatus'] ?? 18001,
      customersAhead: json['customersAhead'] ?? 0,
      estimatedWaitMinutes: json['estimatedWaitMinutes'] ?? 0,
      counterNumber: json['counterNumber'],
      counterName: json['counterName'],
    );
  }
}
