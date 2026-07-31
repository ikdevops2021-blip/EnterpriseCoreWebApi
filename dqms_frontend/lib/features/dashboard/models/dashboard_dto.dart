/// ============================================================================
/// DASHBOARD DTO — Serializes backend GET /api/v1/dqms/dashboard JSON
/// ============================================================================
class DashboardDto {
  final int waitingCustomers;
  final int currentlyServing;
  final int slaBreachesToday;
  final int avgWaitTimeMins;
  final int avgServiceTimeMins;
  final int completedToday;
  final int activeCounters;
  final int totalCounters;
  final String waitingTrend;
  final List<CounterStatusItemDto> counterMatrix;
  final List<TatProcessAnalyticsDto> processAnalytics;
  final List<QueueTrendPointDto> queueTrend;
  final List<RecentActivityItemDto> recentActivities;
  final List<BottleneckItemDto> bottlenecks;

  const DashboardDto({
    required this.waitingCustomers,
    required this.currentlyServing,
    required this.slaBreachesToday,
    required this.avgWaitTimeMins,
    required this.avgServiceTimeMins,
    required this.completedToday,
    required this.activeCounters,
    required this.totalCounters,
    required this.waitingTrend,
    required this.counterMatrix,
    required this.processAnalytics,
    required this.queueTrend,
    required this.recentActivities,
    required this.bottlenecks,
  });

  factory DashboardDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'] != null && json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    return DashboardDto(
      waitingCustomers: (data['waitingCustomers'] as num?)?.toInt() ?? 0,
      currentlyServing: (data['currentlyServing'] as num?)?.toInt() ?? 0,
      slaBreachesToday: (data['slaBreachesToday'] as num?)?.toInt() ?? 0,
      avgWaitTimeMins: (data['avgWaitTimeMins'] as num?)?.toInt() ?? 0,
      avgServiceTimeMins: (data['avgServiceTimeMins'] as num?)?.toInt() ?? 0,
      completedToday: (data['completedToday'] as num?)?.toInt() ?? 0,
      activeCounters: (data['activeCounters'] as num?)?.toInt() ?? 0,
      totalCounters: (data['totalCounters'] as num?)?.toInt() ?? 0,
      waitingTrend: data['waitingTrend'] as String? ?? 'Normal load',
      counterMatrix: (data['counterMatrix'] as List<dynamic>?)
              ?.map((e) => CounterStatusItemDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      processAnalytics: (data['processAnalytics'] as List<dynamic>?)
              ?.map((e) => TatProcessAnalyticsDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      queueTrend: (data['queueTrend'] as List<dynamic>?)
              ?.map((e) => QueueTrendPointDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      recentActivities: (data['recentActivities'] as List<dynamic>?)
              ?.map((e) => RecentActivityItemDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      bottlenecks: (data['bottlenecks'] as List<dynamic>?)
              ?.map((e) => BottleneckItemDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'waitingCustomers': waitingCustomers,
      'currentlyServing': currentlyServing,
      'slaBreachesToday': slaBreachesToday,
      'avgWaitTimeMins': avgWaitTimeMins,
      'avgServiceTimeMins': avgServiceTimeMins,
      'completedToday': completedToday,
      'activeCounters': activeCounters,
      'totalCounters': totalCounters,
      'waitingTrend': waitingTrend,
      'counterMatrix': counterMatrix.map((e) => e.toJson()).toList(),
      'processAnalytics': processAnalytics.map((e) => e.toJson()).toList(),
      'queueTrend': queueTrend.map((e) => e.toJson()).toList(),
      'recentActivities': recentActivities.map((e) => e.toJson()).toList(),
      'bottlenecks': bottlenecks.map((e) => e.toJson()).toList(),
    };
  }
}

class CounterStatusItemDto {
  final int counterId;
  final String counterNumber;
  final String counterName;
  final String processName;
  final String operatorName;
  final String status;
  final String? currentTokenNumber;
  final int activeSeconds;

  const CounterStatusItemDto({
    required this.counterId,
    required this.counterNumber,
    required this.counterName,
    required this.processName,
    required this.operatorName,
    required this.status,
    this.currentTokenNumber,
    required this.activeSeconds,
  });

  factory CounterStatusItemDto.fromJson(Map<String, dynamic> json) {
    return CounterStatusItemDto(
      counterId: (json['counterId'] as num?)?.toInt() ?? 0,
      counterNumber: json['counterNumber'] as String? ?? '',
      counterName: json['counterName'] as String? ?? '',
      processName: json['processName'] as String? ?? '',
      operatorName: json['operatorName'] as String? ?? '',
      status: json['status'] as String? ?? 'Idle',
      currentTokenNumber: json['currentTokenNumber'] as String?,
      activeSeconds: (json['activeSeconds'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'counterId': counterId,
      'counterNumber': counterNumber,
      'counterName': counterName,
      'processName': processName,
      'operatorName': operatorName,
      'status': status,
      'currentTokenNumber': currentTokenNumber,
      'activeSeconds': activeSeconds,
    };
  }
}

class TatProcessAnalyticsDto {
  final int processId;
  final String processCode;
  final String processName;
  final int targetSlaMins;
  final int actualAvgWaitMins;
  final int actualAvgServiceMins;
  final int totalVolume;
  final int slaBreaches;

  const TatProcessAnalyticsDto({
    required this.processId,
    required this.processCode,
    required this.processName,
    required this.targetSlaMins,
    required this.actualAvgWaitMins,
    required this.actualAvgServiceMins,
    required this.totalVolume,
    required this.slaBreaches,
  });

  factory TatProcessAnalyticsDto.fromJson(Map<String, dynamic> json) {
    return TatProcessAnalyticsDto(
      processId: (json['processId'] as num?)?.toInt() ?? 0,
      processCode: json['processCode'] as String? ?? '',
      processName: json['processName'] as String? ?? '',
      targetSlaMins: (json['targetSlaMins'] as num?)?.toInt() ?? 15,
      actualAvgWaitMins: (json['actualAvgWaitMins'] as num?)?.toInt() ?? 0,
      actualAvgServiceMins: (json['actualAvgServiceMins'] as num?)?.toInt() ?? 0,
      totalVolume: (json['totalVolume'] as num?)?.toInt() ?? 0,
      slaBreaches: (json['slaBreaches'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'processId': processId,
      'processCode': processCode,
      'processName': processName,
      'targetSlaMins': targetSlaMins,
      'actualAvgWaitMins': actualAvgWaitMins,
      'actualAvgServiceMins': actualAvgServiceMins,
      'totalVolume': totalVolume,
      'slaBreaches': slaBreaches,
    };
  }
}

class QueueTrendPointDto {
  final String hour;
  final int waitingCount;
  final int servedCount;
  final int capacityLimit;

  const QueueTrendPointDto({
    required this.hour,
    required this.waitingCount,
    required this.servedCount,
    required this.capacityLimit,
  });

  factory QueueTrendPointDto.fromJson(Map<String, dynamic> json) {
    return QueueTrendPointDto(
      hour: json['hour'] as String? ?? '',
      waitingCount: (json['waitingCount'] as num?)?.toInt() ?? 0,
      servedCount: (json['servedCount'] as num?)?.toInt() ?? 0,
      capacityLimit: (json['capacityLimit'] as num?)?.toInt() ?? 40,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hour': hour,
      'waitingCount': waitingCount,
      'servedCount': servedCount,
      'capacityLimit': capacityLimit,
    };
  }
}

class RecentActivityItemDto {
  final String activityId;
  final String timestamp;
  final String activityType;
  final String description;
  final String operatorCode;
  final String counterNumber;

  const RecentActivityItemDto({
    required this.activityId,
    required this.timestamp,
    required this.activityType,
    required this.description,
    required this.operatorCode,
    required this.counterNumber,
  });

  factory RecentActivityItemDto.fromJson(Map<String, dynamic> json) {
    return RecentActivityItemDto(
      activityId: json['activityId'] as String? ?? '',
      timestamp: json['timestamp'] as String? ?? '',
      activityType: json['activityType'] as String? ?? '',
      description: json['description'] as String? ?? '',
      operatorCode: json['operatorCode'] as String? ?? '',
      counterNumber: json['counterNumber'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activityId': activityId,
      'timestamp': timestamp,
      'activityType': activityType,
      'description': description,
      'operatorCode': operatorCode,
      'counterNumber': counterNumber,
    };
  }
}

class BottleneckItemDto {
  final String bottleneckId;
  final String title;
  final String severity;
  final String impactDescription;
  final String recommendedAction;

  const BottleneckItemDto({
    required this.bottleneckId,
    required this.title,
    required this.severity,
    required this.impactDescription,
    required this.recommendedAction,
  });

  factory BottleneckItemDto.fromJson(Map<String, dynamic> json) {
    return BottleneckItemDto(
      bottleneckId: json['bottleneckId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      severity: json['severity'] as String? ?? 'Warning',
      impactDescription: json['impactDescription'] as String? ?? '',
      recommendedAction: json['recommendedAction'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bottleneckId': bottleneckId,
      'title': title,
      'severity': severity,
      'impactDescription': impactDescription,
      'recommendedAction': recommendedAction,
    };
  }
}
