import 'package:dio/dio.dart';
import '../models/edge_node_models.dart';

class EdgeNodeRepository {
  final Dio _dio;

  EdgeNodeRepository(this._dio);

  Future<List<EdgeNodeRegistration>> getNodes({int organizationId = 1, int locationId = -1, String? nodeId}) async {
    try {
      final response = await _dio.get(
        '/api/v1/dqms/edge/nodes',
        queryParameters: {
          'organizationId': organizationId,
          if (locationId != -1) 'locationId': locationId,
          if (nodeId != null) 'nodeId': nodeId,
        },
      );

      if (response.data != null && response.data['data'] != null) {
        final List raw = response.data['data'];
        return raw.map((json) => EdgeNodeRegistration.fromJson(Map<String, dynamic>.from(json))).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<bool> registerNode(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/api/v1/dqms/edge/register', data: data);
      return response.data?['success'] ?? response.data?['Success'] ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<EdgeSyncResult?> triggerSyncBatch(Map<String, dynamic> batchData) async {
    try {
      final response = await _dio.post('/api/v1/dqms/edge/sync', data: batchData);
      if (response.data != null && response.data['data'] != null) {
        return EdgeSyncResult.fromJson(Map<String, dynamic>.from(response.data['data']));
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<List<EdgeSyncAuditLog>> getAuditLogs({int organizationId = 1, String? nodeId, int limit = 50}) async {
    try {
      final response = await _dio.get(
        '/api/v1/dqms/edge/logs',
        queryParameters: {
          'organizationId': organizationId,
          if (nodeId != null) 'nodeId': nodeId,
          'limit': limit,
        },
      );

      if (response.data != null && response.data['data'] != null) {
        final List raw = response.data['data'];
        return raw.map((json) => EdgeSyncAuditLog.fromJson(Map<String, dynamic>.from(json))).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}
