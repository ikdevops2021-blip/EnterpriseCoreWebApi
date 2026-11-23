import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dqms_frontend/core/network/dio_provider.dart';
import 'package:dqms_frontend/features/staff/models/staff_dto.dart';

/// ============================================================================
/// STAFF REPOSITORY — Calls .NET 8 Web API /api/v1/staff/* endpoints
/// ============================================================================
final staffRepositoryProvider = Provider<StaffRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return StaffRepository(dio: dio);
});

class StaffRepository {
  final Dio dio;

  const StaffRepository({required this.dio});

  /// Operator Calls Next Token in Queue (Hotkey Space / F1)
  Future<Map<String, dynamic>> callNextToken(CallNextTokenRequestDto dto) async {
    try {
      final response = await dio.post(
        '/api/v1/staff/call-next',
        data: dto.toJson(),
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Call next token failed (HTTP ${response.statusCode})');
    } catch (e) {
      rethrow;
    }
  }

  /// Updates Token Status (Active 18004, Hold 18005, Canceled 18006, Completed 18007)
  Future<bool> updateTokenStatus(UpdateTokenStatusRequestDto dto) async {
    try {
      final response = await dio.post(
        '/api/v1/staff/update-status',
        data: dto.toJson(),
      );
      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  /// Issues a new Token (Kiosk / Reception Desk)
  Future<Map<String, dynamic>> issueToken(IssueTokenRequestDto dto) async {
    try {
      final response = await dio.post(
        '/api/v1/staff/issue-token',
        data: dto.toJson(),
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Issue token failed (HTTP ${response.statusCode})');
    } catch (e) {
      rethrow;
    }
  }

  /// Gets current Token Queue for Counter Station
  Future<Map<String, dynamic>> fetchTokenQueue({
    int organizationId = 1,
    int locationId = 1,
    int processId = 1,
    int counterId = 1,
  }) async {
    try {
      final response = await dio.get(
        '/api/v1/staff/queue',
        queryParameters: {
          'organizationId': organizationId,
          'locationId': locationId,
          'processId': processId,
          'counterId': counterId,
        },
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Fetch queue failed (HTTP ${response.statusCode})');
    } catch (e) {
      rethrow;
    }
  }

  /// Forwards a token along the N-level pipeline (Step N -> Step N+1 or sub-token branch)
  Future<Map<String, dynamic>> forwardToken(ForwardTokenRequestDto dto) async {
    try {
      final response = await dio.post(
        '/api/v1/staff/forward-token',
        data: dto.toJson(),
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Forward token failed (HTTP ${response.statusCode})');
    } catch (e) {
      rethrow;
    }
  }

  /// Fetches complete workflow journey history for a token
  Future<TokenWorkflowHistoryDto?> fetchTokenWorkflow(int tokenId, {String? tokenNumber}) async {
    try {
      final response = await dio.get(
        '/api/v1/staff/token/$tokenId/workflow',
        queryParameters: tokenNumber != null ? {'tokenNumber': tokenNumber} : null,
      );
      if (response.statusCode == 200 && response.data != null && response.data['data'] != null) {
        return TokenWorkflowHistoryDto.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Fetches sequential step catalog for a process
  Future<List<ProcessStepDto>> fetchProcessSteps({int? processId}) async {
    try {
      final response = await dio.get(
        '/api/v1/staff/steps',
        queryParameters: processId != null ? {'processId': processId} : null,
      );
      if (response.statusCode == 200 && response.data != null && response.data['data'] != null) {
        final list = response.data['data'] as List;
        return list.map((item) => ProcessStepDto.fromJson(item as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }
}
