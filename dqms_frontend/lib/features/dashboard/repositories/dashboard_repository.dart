import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dqms_frontend/core/network/dio_provider.dart';
import 'package:dqms_frontend/features/dashboard/models/dashboard_dto.dart';

/// ============================================================================
/// DASHBOARD REPOSITORY — Calls .NET 8 Web API GET /api/v1/dqms/dashboard
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
}
