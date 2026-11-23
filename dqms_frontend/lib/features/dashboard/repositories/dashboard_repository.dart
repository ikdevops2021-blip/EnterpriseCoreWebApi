import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dqms_frontend/core/network/dio_provider.dart';
import 'package:dqms_frontend/features/dashboard/models/dashboard_dto.dart';
import 'package:dqms_frontend/features/dashboard/models/tat_analytics_dto.dart';

/// ============================================================================
/// DASHBOARD REPOSITORY — Calls .NET 8 Web API for Dashboard & TAT Analytics
/// ============================================================================
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return DashboardRepository(dio: dio);
});

class DashboardRepository {
  final Dio dio;

  const DashboardRepository({required this.dio});

  /// Fetches real-time Command Center Dashboard summary from Web API
  Future<DashboardDto> fetchDashboardSummary({
    int organizationId = 1,
    int locationId = 1,
    int? areaId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'organizationId': organizationId,
        'locationId': locationId,
      };
      if (areaId != null) {
        queryParams['areaId'] = areaId;
      }

      final response = await dio.get(
        '/api/v1/dqms/dashboard',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        return DashboardDto.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch dashboard data (HTTP ${response.statusCode})',
        );
      }
    } on DioException catch (_) {
      rethrow;
    } catch (e) {
      throw Exception('Unexpected error fetching dashboard data: $e');
    }
  }

  /// Fetches Turnaround Time (TAT) Variance analysis & dispersion metrics
  Future<TatVarianceReportDto> fetchTatVarianceReport({
    int organizationId = 1,
    int locationId = 1,
    int? processId,
    int? areaId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'organizationId': organizationId,
        'locationId': locationId,
      };
      if (processId != null) queryParams['processId'] = processId;
      if (areaId != null) queryParams['areaId'] = areaId;

      final response = await dio.get(
        '/api/v1/dqms/reports/tat-variance',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        final rawData = response.data;
        if (rawData is Map<String, dynamic>) {
          final payload = rawData['data'] ?? rawData;
          return TatVarianceReportDto.fromJson(payload as Map<String, dynamic>);
        }
      }
      return TatVarianceReportDto.mock();
    } catch (_) {
      return TatVarianceReportDto.mock();
    }
  }

  /// Fetches 2D matrix Bottleneck Heatmap across time and operational dimensions
  Future<BottleneckHeatmapDto> fetchBottleneckHeatmap({
    int organizationId = 1,
    int locationId = 1,
    String dimensionType = 'HourByDayOfWeek',
    int? areaId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'organizationId': organizationId,
        'locationId': locationId,
        'dimensionType': dimensionType,
      };
      if (areaId != null) queryParams['areaId'] = areaId;

      final response = await dio.get(
        '/api/v1/dqms/reports/bottleneck-heatmap',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        final rawData = response.data;
        if (rawData is Map<String, dynamic>) {
          final payload = rawData['data'] ?? rawData;
          return BottleneckHeatmapDto.fromJson(payload as Map<String, dynamic>);
        }
      }
      return BottleneckHeatmapDto.mock(dimensionType: dimensionType);
    } catch (_) {
      return BottleneckHeatmapDto.mock(dimensionType: dimensionType);
    }
  }
}
