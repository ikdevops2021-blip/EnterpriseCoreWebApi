import 'package:dio/dio.dart';
import '../models/signage_models.dart';

class SignageRepository {
  final Dio _dio;

  SignageRepository(this._dio);

  Future<List<SignageCampaign>> getCampaigns({int organizationId = 1}) async {
    try {
      final response = await _dio.get(
        '/api/v1/dqms/signage/campaigns',
        queryParameters: {'organizationId': organizationId},
      );

      if (response.data != null && response.data['data'] != null) {
        final List raw = response.data['data'];
        return raw.map((json) => SignageCampaign.fromJson(Map<String, dynamic>.from(json))).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<bool> saveCampaign(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/api/v1/dqms/signage/campaigns', data: data);
      return response.data?['success'] ?? response.data?['Success'] ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteCampaign(int id, {int organizationId = 1}) async {
    try {
      final response = await _dio.delete(
        '/api/v1/dqms/signage/campaigns/$id',
        queryParameters: {'organizationId': organizationId},
      );
      return response.data?['success'] ?? response.data?['Success'] ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<List<SignageMediaItem>> getActivePlaylist({
    int organizationId = 1,
    int locationId = 1,
    int? areaId,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/dqms/signage/playlist',
        queryParameters: {
          'organizationId': organizationId,
          'locationId': locationId,
          if (areaId != null) 'areaId': areaId,
        },
      );

      if (response.data != null && response.data['data'] != null) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(response.data['data']);
        final List raw = data['items'] ?? data['Items'] ?? [];
        return raw.map((json) => SignageMediaItem.fromJson(Map<String, dynamic>.from(json))).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<EmergencyBroadcast?> getActiveEmergency({
    int organizationId = 1,
    int? locationId,
    int? areaId,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/dqms/emergency/active',
        queryParameters: {
          'organizationId': organizationId,
          if (locationId != null) 'locationId': locationId,
          if (areaId != null) 'areaId': areaId,
        },
      );

      if (response.data != null && response.data['data'] != null) {
        return EmergencyBroadcast.fromJson(Map<String, dynamic>.from(response.data['data']));
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> triggerEmergency(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/api/v1/dqms/emergency/trigger', data: data);
      return response.data?['success'] ?? response.data?['Success'] ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> dismissEmergency(int broadcastId, {int organizationId = 1}) async {
    try {
      final response = await _dio.post(
        '/api/v1/dqms/emergency/dismiss',
        data: {'broadcastId': broadcastId, 'organizationId': organizationId},
      );
      return response.data?['success'] ?? response.data?['Success'] ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<List<EmergencyBroadcast>> getEmergencyHistory({
    int organizationId = 1,
    int? locationId,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/dqms/emergency/history',
        queryParameters: {
          'organizationId': organizationId,
          if (locationId != null) 'locationId': locationId,
        },
      );

      if (response.data != null && response.data['data'] != null) {
        final List raw = response.data['data'];
        return raw.map((json) => EmergencyBroadcast.fromJson(Map<String, dynamic>.from(json))).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}
