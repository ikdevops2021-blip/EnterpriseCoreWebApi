// ignore_for_file: dangling_library_doc_comments

/// ============================================================================
/// TAT & BOTTLENECK HEATMAP ANALYTICS MODELS
/// Data Transfer Objects for Turnaround Time variance & 2D congestion matrix
/// ============================================================================

class TatVarianceReportDto {
  final DateTime generatedAt;
  final DateTime periodStart;
  final DateTime periodEnd;
  final TatVarianceSummaryDto summary;
  final List<ProcessTatVarianceDto> processBreakdown;

  const TatVarianceReportDto({
    required this.generatedAt,
    required this.periodStart,
    required this.periodEnd,
    required this.summary,
    required this.processBreakdown,
  });

  factory TatVarianceReportDto.fromJson(Map<String, dynamic> json) {
    return TatVarianceReportDto(
      generatedAt: DateTime.tryParse(json['generatedAt']?.toString() ?? '') ?? DateTime.now(),
      periodStart: DateTime.tryParse(json['periodStart']?.toString() ?? '') ?? DateTime.now(),
      periodEnd: DateTime.tryParse(json['periodEnd']?.toString() ?? '') ?? DateTime.now(),
      summary: json['summary'] != null
          ? TatVarianceSummaryDto.fromJson(json['summary'] as Map<String, dynamic>)
          : TatVarianceSummaryDto.empty(),
      processBreakdown: (json['processBreakdown'] as List<dynamic>?)
              ?.map((e) => ProcessTatVarianceDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  factory TatVarianceReportDto.mock() {
    return TatVarianceReportDto(
      generatedAt: DateTime.now(),
      periodStart: DateTime.now().subtract(const Duration(days: 7)),
      periodEnd: DateTime.now(),
      summary: TatVarianceSummaryDto.mock(),
      processBreakdown: [
        const ProcessTatVarianceDto(
          processId: 1,
          processName: 'General Inquiries',
          processCode: 'GEN',
          targetTATMinutes: 15,
          totalTokens: 520,
          completedTokens: 505,
          avgWaitMinutes: 6.2,
          avgServiceMinutes: 4.8,
          actualTatMinutes: 11.0,
          variancePercentage: -26.67,
          stdDevMinutes: 2.4,
          slaPassRate: 98.2,
          statusTier: 'OPTIMAL',
        ),
        const ProcessTatVarianceDto(
          processId: 2,
          processName: 'Account Services',
          processCode: 'ACC',
          targetTATMinutes: 15,
          totalTokens: 380,
          completedTokens: 362,
          avgWaitMinutes: 9.1,
          avgServiceMinutes: 8.5,
          actualTatMinutes: 17.6,
          variancePercentage: 17.33,
          stdDevMinutes: 4.1,
          slaPassRate: 89.5,
          statusTier: 'ACCEPTABLE',
        ),
        const ProcessTatVarianceDto(
          processId: 3,
          processName: 'Cashier & Payments',
          processCode: 'CSH',
          targetTATMinutes: 10,
          totalTokens: 420,
          completedTokens: 401,
          avgWaitMinutes: 7.8,
          avgServiceMinutes: 5.1,
          actualTatMinutes: 12.9,
          variancePercentage: 29.0,
          stdDevMinutes: 3.8,
          slaPassRate: 81.4,
          statusTier: 'CONGESTED',
        ),
        const ProcessTatVarianceDto(
          processId: 4,
          processName: 'VIP Express Desk',
          processCode: 'VIP',
          targetTATMinutes: 8,
          totalTokens: 100,
          completedTokens: 98,
          avgWaitMinutes: 2.4,
          avgServiceMinutes: 3.9,
          actualTatMinutes: 6.3,
          variancePercentage: -21.25,
          stdDevMinutes: 1.2,
          slaPassRate: 99.8,
          statusTier: 'OPTIMAL',
        ),
      ],
    );
  }
}

class TatVarianceSummaryDto {
  final int totalTokens;
  final int completedTokens;
  final double averageWaitMinutes;
  final double averageServiceMinutes;
  final double averageTatMinutes;
  final double targetTatMinutes;
  final double variancePercentage;
  final double stdDevMinutes;
  final double coefficientOfVariation;
  final double p95TatMinutes;
  final double slaPassPercentage;
  final String statusTier;

  const TatVarianceSummaryDto({
    required this.totalTokens,
    required this.completedTokens,
    required this.averageWaitMinutes,
    required this.averageServiceMinutes,
    required this.averageTatMinutes,
    required this.targetTatMinutes,
    required this.variancePercentage,
    required this.stdDevMinutes,
    required this.coefficientOfVariation,
    required this.p95TatMinutes,
    required this.slaPassPercentage,
    required this.statusTier,
  });

  factory TatVarianceSummaryDto.fromJson(Map<String, dynamic> json) {
    return TatVarianceSummaryDto(
      totalTokens: (json['totalTokens'] as num?)?.toInt() ?? 0,
      completedTokens: (json['completedTokens'] as num?)?.toInt() ?? 0,
      averageWaitMinutes: (json['averageWaitMinutes'] as num?)?.toDouble() ?? 0.0,
      averageServiceMinutes: (json['averageServiceMinutes'] as num?)?.toDouble() ?? 0.0,
      averageTatMinutes: (json['averageTatMinutes'] as num?)?.toDouble() ?? 0.0,
      targetTatMinutes: (json['targetTatMinutes'] as num?)?.toDouble() ?? 15.0,
      variancePercentage: (json['variancePercentage'] as num?)?.toDouble() ?? 0.0,
      stdDevMinutes: (json['stdDevMinutes'] as num?)?.toDouble() ?? 0.0,
      coefficientOfVariation: (json['coefficientOfVariation'] as num?)?.toDouble() ?? 0.0,
      p95TatMinutes: (json['p95TatMinutes'] as num?)?.toDouble() ?? 0.0,
      slaPassPercentage: (json['slaPassPercentage'] as num?)?.toDouble() ?? 0.0,
      statusTier: json['statusTier']?.toString() ?? 'OPTIMAL',
    );
  }

  factory TatVarianceSummaryDto.empty() {
    return const TatVarianceSummaryDto(
      totalTokens: 0,
      completedTokens: 0,
      averageWaitMinutes: 0.0,
      averageServiceMinutes: 0.0,
      averageTatMinutes: 0.0,
      targetTatMinutes: 15.0,
      variancePercentage: 0.0,
      stdDevMinutes: 0.0,
      coefficientOfVariation: 0.0,
      p95TatMinutes: 0.0,
      slaPassPercentage: 100.0,
      statusTier: 'OPTIMAL',
    );
  }

  factory TatVarianceSummaryDto.mock() {
    return const TatVarianceSummaryDto(
      totalTokens: 1420,
      completedTokens: 1366,
      averageWaitMinutes: 6.8,
      averageServiceMinutes: 5.4,
      averageTatMinutes: 12.2,
      targetTatMinutes: 12.0,
      variancePercentage: 1.67,
      stdDevMinutes: 3.2,
      coefficientOfVariation: 0.262,
      p95TatMinutes: 17.5,
      slaPassPercentage: 92.2,
      statusTier: 'ACCEPTABLE',
    );
  }
}

class ProcessTatVarianceDto {
  final int processId;
  final String processName;
  final String processCode;
  final int targetTATMinutes;
  final int totalTokens;
  final int completedTokens;
  final double avgWaitMinutes;
  final double avgServiceMinutes;
  final double actualTatMinutes;
  final double variancePercentage;
  final double stdDevMinutes;
  final double slaPassRate;
  final String statusTier;

  const ProcessTatVarianceDto({
    required this.processId,
    required this.processName,
    required this.processCode,
    required this.targetTATMinutes,
    required this.totalTokens,
    required this.completedTokens,
    required this.avgWaitMinutes,
    required this.avgServiceMinutes,
    required this.actualTatMinutes,
    required this.variancePercentage,
    required this.stdDevMinutes,
    required this.slaPassRate,
    required this.statusTier,
  });

  factory ProcessTatVarianceDto.fromJson(Map<String, dynamic> json) {
    return ProcessTatVarianceDto(
      processId: (json['processId'] as num?)?.toInt() ?? 0,
      processName: json['processName']?.toString() ?? '',
      processCode: json['processCode']?.toString() ?? '',
      targetTATMinutes: (json['targetTATMinutes'] as num?)?.toInt() ?? 15,
      totalTokens: (json['totalTokens'] as num?)?.toInt() ?? 0,
      completedTokens: (json['completedTokens'] as num?)?.toInt() ?? 0,
      avgWaitMinutes: (json['avgWaitMinutes'] as num?)?.toDouble() ?? 0.0,
      avgServiceMinutes: (json['avgServiceMinutes'] as num?)?.toDouble() ?? 0.0,
      actualTatMinutes: (json['actualTatMinutes'] as num?)?.toDouble() ?? 0.0,
      variancePercentage: (json['variancePercentage'] as num?)?.toDouble() ?? 0.0,
      stdDevMinutes: (json['stdDevMinutes'] as num?)?.toDouble() ?? 0.0,
      slaPassRate: (json['slaPassRate'] as num?)?.toDouble() ?? 100.0,
      statusTier: json['statusTier']?.toString() ?? 'OPTIMAL',
    );
  }
}

class BottleneckHeatmapDto {
  final DateTime generatedAt;
  final DateTime periodStart;
  final DateTime periodEnd;
  final String dimensionType;
  final List<HeatmapCellDto> cells;
  final int peakCongestionHour;
  final int peakCongestionScore;
  final String peakCongestionLabel;

  const BottleneckHeatmapDto({
    required this.generatedAt,
    required this.periodStart,
    required this.periodEnd,
    required this.dimensionType,
    required this.cells,
    required this.peakCongestionHour,
    required this.peakCongestionScore,
    required this.peakCongestionLabel,
  });

  factory BottleneckHeatmapDto.fromJson(Map<String, dynamic> json) {
    return BottleneckHeatmapDto(
      generatedAt: DateTime.tryParse(json['generatedAt']?.toString() ?? '') ?? DateTime.now(),
      periodStart: DateTime.tryParse(json['periodStart']?.toString() ?? '') ?? DateTime.now(),
      periodEnd: DateTime.tryParse(json['periodEnd']?.toString() ?? '') ?? DateTime.now(),
      dimensionType: json['dimensionType']?.toString() ?? 'HourByDayOfWeek',
      cells: (json['cells'] as List<dynamic>?)
              ?.map((e) => HeatmapCellDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      peakCongestionHour: (json['peakCongestionHour'] as num?)?.toInt() ?? 12,
      peakCongestionScore: (json['peakCongestionScore'] as num?)?.toInt() ?? 80,
      peakCongestionLabel: json['peakCongestionLabel']?.toString() ?? 'Peak @ 12:00',
    );
  }

  factory BottleneckHeatmapDto.mock({String dimensionType = 'HourByDayOfWeek'}) {
    final cells = <HeatmapCellDto>[];
    final labels = dimensionType == 'HourByDayOfWeek'
        ? ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
        : (dimensionType == 'HourByProcess'
            ? ['General Inquiries', 'Account Services', 'Cashier & Payments', 'VIP Express Desk']
            : ['C-01', 'C-02', 'C-03', 'C-04', 'C-05']);

    for (int y = 0; y < labels.length; y++) {
      for (int h = 8; h <= 18; h++) {
        final isLunch = (h >= 12 && h <= 14);
        final isMid = (h == 11 || h == 15);
        final isWeekend = dimensionType == 'HourByDayOfWeek' && (y == 5 || y == 6);

        final tokenCount = isWeekend ? 6 : (isLunch ? 42 : (isMid ? 26 : 14));
        final avgWait = isWeekend ? 3.0 : (isLunch ? 19.5 : (isMid ? 11.2 : 5.8));
        final avgService = 4.8;
        final target = 15.0;
        final actualTat = avgWait + avgService;
        final variance = ((actualTat - target) / target) * 100.0;
        final score = (avgWait * 3.8 + tokenCount * 1.1).clamp(0, 100).toInt();
        final level = score >= 75 ? 'CRITICAL' : (score >= 50 ? 'HIGH' : (score >= 25 ? 'MODERATE' : 'LOW'));

        cells.add(HeatmapCellDto(
          hourOfDay: h,
          dimensionKey: y + 1,
          dimensionLabel: labels[y],
          tokenCount: tokenCount,
          avgWaitMinutes: avgWait,
          avgServiceMinutes: avgService,
          avgTatMinutes: actualTat,
          variancePercentage: variance,
          congestionScore: score,
          congestionLevel: level,
        ));
      }
    }

    return BottleneckHeatmapDto(
      generatedAt: DateTime.now(),
      periodStart: DateTime.now().subtract(const Duration(days: 7)),
      periodEnd: DateTime.now(),
      dimensionType: dimensionType,
      cells: cells,
      peakCongestionHour: 13,
      peakCongestionScore: 92,
      peakCongestionLabel: 'Wednesday @ 13:00',
    );
  }
}

class HeatmapCellDto {
  final int hourOfDay;
  final int dimensionKey;
  final String dimensionLabel;
  final int tokenCount;
  final double avgWaitMinutes;
  final double avgServiceMinutes;
  final double avgTatMinutes;
  final double variancePercentage;
  final int congestionScore;
  final String congestionLevel;

  const HeatmapCellDto({
    required this.hourOfDay,
    required this.dimensionKey,
    required this.dimensionLabel,
    required this.tokenCount,
    required this.avgWaitMinutes,
    required this.avgServiceMinutes,
    required this.avgTatMinutes,
    required this.variancePercentage,
    required this.congestionScore,
    required this.congestionLevel,
  });

  factory HeatmapCellDto.fromJson(Map<String, dynamic> json) {
    return HeatmapCellDto(
      hourOfDay: (json['hourOfDay'] as num?)?.toInt() ?? 0,
      dimensionKey: (json['dimensionKey'] as num?)?.toInt() ?? 0,
      dimensionLabel: json['dimensionLabel']?.toString() ?? '',
      tokenCount: (json['tokenCount'] as num?)?.toInt() ?? 0,
      avgWaitMinutes: (json['avgWaitMinutes'] as num?)?.toDouble() ?? 0.0,
      avgServiceMinutes: (json['avgServiceMinutes'] as num?)?.toDouble() ?? 0.0,
      avgTatMinutes: (json['avgTatMinutes'] as num?)?.toDouble() ?? 0.0,
      variancePercentage: (json['variancePercentage'] as num?)?.toDouble() ?? 0.0,
      congestionScore: (json['congestionScore'] as num?)?.toInt() ?? 0,
      congestionLevel: json['congestionLevel']?.toString() ?? 'LOW',
    );
  }
}
