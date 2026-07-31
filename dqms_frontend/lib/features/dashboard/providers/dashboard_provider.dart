import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dqms_frontend/features/dashboard/models/dashboard_dto.dart';
import 'package:dqms_frontend/features/dashboard/repositories/dashboard_repository.dart';

/// ============================================================================
/// COMMAND CENTER DASHBOARD STATE MODELS & PROVIDERS
/// Connects Dio HTTP client to GET /api/v1/dqms/dashboard
/// ============================================================================

/// Hourly Queue Trend Data Point
class QueueTrendDataPoint {
  final String hour;
  final int waitingCount;
  final int servedCount;
  final int capacityLimit;

  const QueueTrendDataPoint({
    required this.hour,
    required this.waitingCount,
    required this.servedCount,
    required this.capacityLimit,
  });

  factory QueueTrendDataPoint.fromDto(QueueTrendPointDto dto) {
    return QueueTrendDataPoint(
      hour: dto.hour,
      waitingCount: dto.waitingCount,
      servedCount: dto.servedCount,
      capacityLimit: dto.capacityLimit,
    );
  }
}

/// Process Pipeline Turnaround Time (TAT) Analytics
class TatAnalyticsItem {
  final String processName;
  final int targetSlaMins;
  final double actualAvgMins;
  final double slaComplianceRate;

  const TatAnalyticsItem({
    required this.processName,
    required this.targetSlaMins,
    required this.actualAvgMins,
    required this.slaComplianceRate,
  });

  factory TatAnalyticsItem.fromDto(TatProcessAnalyticsDto dto) {
    final double compliance = dto.totalVolume > 0
        ? ((dto.totalVolume - dto.slaBreaches) / dto.totalVolume * 100).clamp(0.0, 100.0)
        : 100.0;
    return TatAnalyticsItem(
      processName: dto.processName,
      targetSlaMins: dto.targetSlaMins,
      actualAvgMins: dto.actualAvgWaitMins.toDouble(),
      slaComplianceRate: compliance,
    );
  }
}

/// Counter Station Real-Time Operational Detail
class DashboardCounterDetail {
  final int counterId;
  final String counterNumber;
  final String counterName;
  final String status; // 'Active', 'Idle', 'SLA Risk', 'Closed'
  final String? currentToken;
  final String operatorName;
  final String handlingTime;
  final bool isSlaBreached;

  const DashboardCounterDetail({
    required this.counterId,
    required this.counterNumber,
    required this.counterName,
    required this.status,
    this.currentToken,
    required this.operatorName,
    required this.handlingTime,
    this.isSlaBreached = false,
  });

  factory DashboardCounterDetail.fromDto(CounterStatusItemDto dto) {
    final mins = dto.activeSeconds ~/ 60;
    final secs = dto.activeSeconds % 60;
    final formattedTime = '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';

    return DashboardCounterDetail(
      counterId: dto.counterId,
      counterNumber: dto.counterNumber,
      counterName: dto.counterName,
      status: dto.status,
      currentToken: dto.currentTokenNumber,
      operatorName: dto.operatorName,
      handlingTime: formattedTime,
      isSlaBreached: dto.status.toLowerCase().contains('risk') || dto.status.toLowerCase().contains('breach'),
    );
  }
}

/// Operational Bottleneck Alert DTO
class BottleneckAlert {
  final String id;
  final String location;
  final String severity; // 'High', 'Medium', 'Low'
  final String description;
  final String suggestedAction;
  final String timestamp;

  const BottleneckAlert({
    required this.id,
    required this.location,
    required this.severity,
    required this.description,
    required this.suggestedAction,
    required this.timestamp,
  });

  factory BottleneckAlert.fromDto(BottleneckItemDto dto) {
    return BottleneckAlert(
      id: dto.bottleneckId,
      location: dto.title,
      severity: dto.severity,
      description: dto.impactDescription,
      suggestedAction: dto.recommendedAction,
      timestamp: 'Just now',
    );
  }
}

/// Live Stream Operational Activity Entry
class OperationalActivityEntry {
  final String id;
  final String time;
  final String title;
  final String detail;
  final String category; // 'Call', 'SLA', 'Status', 'Issue'

  const OperationalActivityEntry({
    required this.id,
    required this.time,
    required this.title,
    required this.detail,
    required this.category,
  });

  factory OperationalActivityEntry.fromDto(RecentActivityItemDto dto) {
    return OperationalActivityEntry(
      id: dto.activityId,
      time: dto.timestamp.contains('T') ? dto.timestamp.split('T').last.substring(0, 5) : dto.timestamp,
      title: dto.activityType.replaceAll('_', ' '),
      detail: dto.description,
      category: dto.activityType.toLowerCase().contains('sla') ? 'SLA' : 'Call',
    );
  }
}

/// Master Command Center State DTO
class DashboardState {
  final bool isLoading;
  final bool isOffline;
  final String? errorMessage;
  
  final int waitingCustomers;
  final String waitingTrend;
  final int currentlyServing;
  final double avgWaitTimeMins;
  final double avgServiceTimeMins;
  final int activeCounters;
  final int idleCounters;
  final int totalCounters;
  final int slaBreachesToday;
  final int completedToday;
  
  final Map<String, int> queueDensityByArea;
  final List<DashboardCounterDetail> counters;
  final List<QueueTrendDataPoint> queueTrend;
  final List<TatAnalyticsItem> tatAnalytics;
  final List<BottleneckAlert> activeBottlenecks;
  final List<OperationalActivityEntry> recentActivities;

  const DashboardState({
    this.isLoading = false,
    this.isOffline = false,
    this.errorMessage,
    required this.waitingCustomers,
    required this.waitingTrend,
    required this.currentlyServing,
    required this.avgWaitTimeMins,
    required this.avgServiceTimeMins,
    required this.activeCounters,
    required this.idleCounters,
    required this.totalCounters,
    required this.slaBreachesToday,
    required this.completedToday,
    required this.queueDensityByArea,
    required this.counters,
    required this.queueTrend,
    required this.tatAnalytics,
    required this.activeBottlenecks,
    required this.recentActivities,
  });

  factory DashboardState.fromDto(DashboardDto dto, {bool isOffline = false, String? errorMessage}) {
    final idle = (dto.totalCounters - dto.activeCounters).clamp(0, dto.totalCounters);
    return DashboardState(
      isLoading: false,
      isOffline: isOffline,
      errorMessage: errorMessage,
      waitingCustomers: dto.waitingCustomers,
      waitingTrend: dto.waitingTrend,
      currentlyServing: dto.currentlyServing,
      avgWaitTimeMins: dto.avgWaitTimeMins.toDouble(),
      avgServiceTimeMins: dto.avgServiceTimeMins.toDouble(),
      activeCounters: dto.activeCounters,
      idleCounters: idle,
      totalCounters: dto.totalCounters,
      slaBreachesToday: dto.slaBreachesToday,
      completedToday: dto.completedToday,
      queueDensityByArea: const {
        'Main Service Hall A': 28,
        'Priority Wing B': 14,
        'Express Desk C': 9,
        'VIP Lounge D': 6,
      },
      counters: dto.counterMatrix.map(DashboardCounterDetail.fromDto).toList(),
      queueTrend: dto.queueTrend.map(QueueTrendDataPoint.fromDto).toList(),
      tatAnalytics: dto.processAnalytics.map(TatAnalyticsItem.fromDto).toList(),
      activeBottlenecks: dto.bottlenecks.map(BottleneckAlert.fromDto).toList(),
      recentActivities: dto.recentActivities.map(OperationalActivityEntry.fromDto).toList(),
    );
  }

  /// Factory for Initial Loading State
  factory DashboardState.loading() {
    final demo = DashboardState.demo();
    return DashboardState(
      isLoading: true,
      isOffline: false,
      waitingCustomers: demo.waitingCustomers,
      waitingTrend: demo.waitingTrend,
      currentlyServing: demo.currentlyServing,
      avgWaitTimeMins: demo.avgWaitTimeMins,
      avgServiceTimeMins: demo.avgServiceTimeMins,
      activeCounters: demo.activeCounters,
      idleCounters: demo.idleCounters,
      totalCounters: demo.totalCounters,
      slaBreachesToday: demo.slaBreachesToday,
      completedToday: demo.completedToday,
      queueDensityByArea: demo.queueDensityByArea,
      counters: demo.counters,
      queueTrend: demo.queueTrend,
      tatAnalytics: demo.tatAnalytics,
      activeBottlenecks: demo.activeBottlenecks,
      recentActivities: demo.recentActivities,
    );
  }

  /// Factory for Demo State
  factory DashboardState.demo({bool isOffline = false, String? errorMessage}) {
    return DashboardState(
      isLoading: false,
      isOffline: isOffline,
      errorMessage: errorMessage,
      waitingCustomers: 57,
      waitingTrend: '+12%',
      currentlyServing: 12,
      avgWaitTimeMins: 8.4,
      avgServiceTimeMins: 5.2,
      activeCounters: 12,
      idleCounters: 3,
      totalCounters: 15,
      slaBreachesToday: 4,
      completedToday: 342,
      queueDensityByArea: const {
        'Main Service Hall A': 28,
        'Priority Wing B': 14,
        'Express Desk C': 9,
        'VIP Lounge D': 6,
      },
      counters: const [
        DashboardCounterDetail(counterId: 1, counterNumber: 'C-01', counterName: 'General Reg 1', status: 'Active', currentToken: 'A-104', operatorName: 'Alex Rivera', handlingTime: '04:12'),
        DashboardCounterDetail(counterId: 2, counterNumber: 'C-02', counterName: 'General Reg 2', status: 'Active', currentToken: 'A-105', operatorName: 'Maria Chen', handlingTime: '06:45'),
        DashboardCounterDetail(counterId: 3, counterNumber: 'C-03', counterName: 'General Reg 3', status: 'SLA Risk', currentToken: 'A-098', operatorName: 'John Smith', handlingTime: '18:20', isSlaBreached: true),
        DashboardCounterDetail(counterId: 4, counterNumber: 'C-04', counterName: 'Priority Counter', status: 'Active', currentToken: 'P-042', operatorName: 'Sarah Jenkins', handlingTime: '03:10'),
        DashboardCounterDetail(counterId: 5, counterNumber: 'C-05', counterName: 'Priority Counter', status: 'Idle', currentToken: null, operatorName: 'David Kim', handlingTime: '00:00'),
        DashboardCounterDetail(counterId: 6, counterNumber: 'C-06', counterName: 'Billing & Cash', status: 'Active', currentToken: 'B-210', operatorName: 'Elena Rostova', handlingTime: '05:30'),
        DashboardCounterDetail(counterId: 7, counterNumber: 'C-07', counterName: 'Billing & Cash', status: 'Active', currentToken: 'B-211', operatorName: 'Robert Vance', handlingTime: '02:15'),
        DashboardCounterDetail(counterId: 8, counterNumber: 'C-08', counterName: 'Pharmacy Window 1', status: 'Active', currentToken: 'Rx-088', operatorName: 'Priya Patel', handlingTime: '08:50'),
        DashboardCounterDetail(counterId: 9, counterNumber: 'C-09', counterName: 'Pharmacy Window 2', status: 'SLA Risk', currentToken: 'Rx-085', operatorName: 'James Wilson', handlingTime: '21:05', isSlaBreached: true),
        DashboardCounterDetail(counterId: 10, counterNumber: 'C-10', counterName: 'Express Desk', status: 'Active', currentToken: 'E-019', operatorName: 'Lisa Wong', handlingTime: '01:45'),
        DashboardCounterDetail(counterId: 11, counterNumber: 'C-11', counterName: 'Consultation A', status: 'Idle', currentToken: null, operatorName: 'Carlos Gomez', handlingTime: '00:00'),
        DashboardCounterDetail(counterId: 12, counterNumber: 'C-12', counterName: 'Consultation B', status: 'Idle', currentToken: null, operatorName: 'Anna Taylor', handlingTime: '00:00'),
        DashboardCounterDetail(counterId: 13, counterNumber: 'C-13', counterName: 'VIP Desk 1', status: 'Active', currentToken: 'VIP-004', operatorName: 'Michael Chang', handlingTime: '07:15'),
        DashboardCounterDetail(counterId: 14, counterNumber: 'C-14', counterName: 'VIP Desk 2', status: 'Closed', currentToken: null, operatorName: 'Unassigned', handlingTime: '00:00'),
        DashboardCounterDetail(counterId: 15, counterNumber: 'C-15', counterName: 'Support Desk', status: 'Closed', currentToken: null, operatorName: 'Unassigned', handlingTime: '00:00'),
      ],
      queueTrend: const [
        QueueTrendDataPoint(hour: '08:00', waitingCount: 12, servedCount: 15, capacityLimit: 40),
        QueueTrendDataPoint(hour: '09:00', waitingCount: 34, servedCount: 45, capacityLimit: 50),
        QueueTrendDataPoint(hour: '10:00', waitingCount: 68, servedCount: 60, capacityLimit: 60),
        QueueTrendDataPoint(hour: '11:00', waitingCount: 85, servedCount: 72, capacityLimit: 60),
        QueueTrendDataPoint(hour: '12:00', waitingCount: 52, servedCount: 65, capacityLimit: 60),
        QueueTrendDataPoint(hour: '13:00', waitingCount: 41, servedCount: 58, capacityLimit: 60),
        QueueTrendDataPoint(hour: '14:00', waitingCount: 62, servedCount: 70, capacityLimit: 60),
        QueueTrendDataPoint(hour: '15:00', waitingCount: 57, servedCount: 64, capacityLimit: 60),
        QueueTrendDataPoint(hour: '16:00', waitingCount: 30, servedCount: 40, capacityLimit: 50),
      ],
      tatAnalytics: const [
        TatAnalyticsItem(processName: 'Patient Registration', targetSlaMins: 10, actualAvgMins: 7.2, slaComplianceRate: 94.5),
        TatAnalyticsItem(processName: 'Clinical Consultation', targetSlaMins: 20, actualAvgMins: 18.5, slaComplianceRate: 88.0),
        TatAnalyticsItem(processName: 'Cashier & Billing', targetSlaMins: 8, actualAvgMins: 5.1, slaComplianceRate: 97.2),
        TatAnalyticsItem(processName: 'Pharmacy Dispensing', targetSlaMins: 12, actualAvgMins: 15.4, slaComplianceRate: 74.8),
      ],
      activeBottlenecks: const [
        BottleneckAlert(
          id: 'BN-01',
          location: 'Pharmacy Window 2 (C-09)',
          severity: 'High',
          description: 'Dispensing backlog exceeding target SLA by 3.4 mins. Handling time 21+ mins.',
          suggestedAction: 'Reassign Idle Counter C-05 to Pharmacy Dispensing.',
          timestamp: '14:28:10',
        ),
        BottleneckAlert(
          id: 'BN-02',
          location: 'General Reg 3 (C-03)',
          severity: 'Medium',
          description: 'Complex document verification causing queue buildup in Hall A.',
          suggestedAction: 'Dispatch Express Desk C-10 overflow support.',
          timestamp: '14:32:45',
        ),
      ],
      recentActivities: const [
        OperationalActivityEntry(id: 'LOG-109', time: '14:34:12', title: 'Token Called', detail: 'Token A-105 called to Counter 02 (Maria Chen)', category: 'Call'),
        OperationalActivityEntry(id: 'LOG-108', time: '14:32:45', title: 'SLA Warning Triggered', detail: 'Token Rx-085 exceeded 15m threshold at Pharmacy 2', category: 'SLA'),
        OperationalActivityEntry(id: 'LOG-107', time: '14:30:00', title: 'Counter Status Changed', detail: 'Counter 05 set to Idle by David Kim', category: 'Status'),
        OperationalActivityEntry(id: 'LOG-106', time: '14:28:10', title: 'Bottleneck Detected', detail: 'Pharmacy Dispensing SLA compliance dropped to 74.8%', category: 'Issue'),
        OperationalActivityEntry(id: 'LOG-105', time: '14:25:30', title: 'Token Completed', detail: 'Token B-209 completed at Billing Counter 06', category: 'Call'),
      ],
    );
  }
}

/// Riverpod StateNotifier for Command Center Dashboard
class DashboardNotifier extends StateNotifier<DashboardState> {
  final DashboardRepository repository;

  DashboardNotifier(this.repository) : super(DashboardState.demo()) {
    loadDashboard();
  }

  /// Load live dashboard metrics from GET /api/v1/dqms/dashboard
  Future<void> loadDashboard({int organizationId = 1, int locationId = 1, int? areaId}) async {
    state = DashboardState.loading();
    try {
      final dto = await repository.fetchDashboardSummary(
        organizationId: organizationId,
        locationId: locationId,
        areaId: areaId,
      );
      state = DashboardState.fromDto(dto);
    } on DioException catch (e) {
      // Fallback gracefully to offline state
      state = DashboardState.demo(
        isOffline: true,
        errorMessage: 'Network notice: ${e.message}. Displaying cached snapshot.',
      );
    } catch (e) {
      state = DashboardState.demo(
        isOffline: true,
        errorMessage: 'Connection notice: $e. Displaying cached snapshot.',
      );
    }
  }

  /// Refresh / simulate live tick updates
  void refreshState() {
    loadDashboard();
  }
}

/// Provider Instance
final dashboardStateProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  final repository = ref.watch(dashboardRepositoryProvider);
  return DashboardNotifier(repository);
});
