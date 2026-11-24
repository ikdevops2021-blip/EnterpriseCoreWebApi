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

class DisplayBoardQueueItemDto {
  final int id;
  final String tokenNumber;
  final int processId;
  final String processName;
  final String prefix;
  final int priorityTier;
  final int tokenStatus;
  final int? counterId;
  final String? counterNumber;
  final String? counterName;
  final String? issuedTime;
  final String? calledTime;

  DisplayBoardQueueItemDto({
    required this.id,
    required this.tokenNumber,
    required this.processId,
    required this.processName,
    required this.prefix,
    required this.priorityTier,
    required this.tokenStatus,
    this.counterId,
    this.counterNumber,
    this.counterName,
    this.issuedTime,
    this.calledTime,
  });

  factory DisplayBoardQueueItemDto.fromJson(Map<String, dynamic> json) {
    return DisplayBoardQueueItemDto(
      id: json['id'] ?? 0,
      tokenNumber: json['tokenNumber'] ?? '',
      processId: json['processId'] ?? 0,
      processName: json['processName'] ?? '',
      prefix: json['prefix'] ?? 'A',
      priorityTier: json['priorityTier'] ?? 19001,
      tokenStatus: json['tokenStatus'] ?? 18001,
      counterId: json['counterId'],
      counterNumber: json['counterNumber'],
      counterName: json['counterName'],
      issuedTime: json['issuedTime']?.toString(),
      calledTime: json['calledTime']?.toString(),
    );
  }
}

class PublicDisplayBoardDto {
  final List<DisplayBoardItemDto> activeCalls;
  final List<DisplayBoardQueueItemDto> upcomingQueue;

  PublicDisplayBoardDto({
    required this.activeCalls,
    required this.upcomingQueue,
  });

  factory PublicDisplayBoardDto.empty() => PublicDisplayBoardDto(
        activeCalls: [],
        upcomingQueue: [],
      );

  factory PublicDisplayBoardDto.fromJson(Map<String, dynamic> json) {
    final active = (json['activeCalls'] as List?)
            ?.map((e) => DisplayBoardItemDto.fromJson(Map<String, dynamic>.from(e)))
            .toList() ??
        [];
    final queue = (json['upcomingQueue'] as List?)
            ?.map((e) =>
                DisplayBoardQueueItemDto.fromJson(Map<String, dynamic>.from(e)))
            .toList() ??
        [];
    return PublicDisplayBoardDto(activeCalls: active, upcomingQueue: queue);
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
