import 'package:dio/dio.dart';
import '../models/webhook_models.dart';

class WebhookRepository {
  final Dio _dio;

  WebhookRepository(this._dio);

  Future<List<WebhookSubscription>> getSubscriptions({int organizationId = 1, int? locationId}) async {
    try {
      final response = await _dio.get(
        '/api/v1/dqms/webhooks',
        queryParameters: {
          'organizationId': organizationId,
          if (locationId != null) 'locationId': locationId,
        },
      );

      if (response.data != null && response.data['data'] != null) {
        final List raw = response.data['data'];
        return raw.map((json) => WebhookSubscription.fromJson(Map<String, dynamic>.from(json))).toList();
      }
      return [];
    } catch (e) {
      // Graceful fallback to empty list
      return [];
    }
  }

  Future<WebhookSubscription?> saveSubscription(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        '/api/v1/dqms/webhooks',
        data: data,
      );

      if (response.data != null && response.data['data'] != null) {
        return WebhookSubscription.fromJson(Map<String, dynamic>.from(response.data['data']));
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteSubscription(int id) async {
    try {
      final response = await _dio.delete('/api/v1/dqms/webhooks/$id');
      return response.data?['data'] == true || response.data?['success'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<WebhookTestResult> testWebhook({
    int? subscriptionId,
    String? endpointUrl,
    String? secretKey,
    String eventCode = 'token.called',
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/dqms/webhooks/test',
        data: {
          if (subscriptionId != null) 'subscriptionId': subscriptionId,
          if (endpointUrl != null) 'endpointUrl': endpointUrl,
          if (secretKey != null) 'secretKey': secretKey,
          'eventCode': eventCode,
        },
      );

      if (response.data != null && response.data['data'] != null) {
        return WebhookTestResult.fromJson(Map<String, dynamic>.from(response.data['data']));
      }
      return WebhookTestResult(
        isSuccess: false,
        statusCode: 0,
        latencyMs: 0,
        message: 'No response data received from test ping.',
      );
    } on DioException catch (dioErr) {
      return WebhookTestResult(
        isSuccess: false,
        statusCode: dioErr.response?.statusCode ?? 0,
        latencyMs: 0,
        message: dioErr.message ?? 'HTTP connection error during test ping.',
        responseBody: dioErr.response?.data?.toString(),
      );
    } catch (e) {
      return WebhookTestResult(
        isSuccess: false,
        statusCode: 0,
        latencyMs: 0,
        message: e.toString(),
      );
    }
  }

  Future<List<WebhookDeliveryLog>> getDeliveryLogs({
    int subscriptionId = -1,
    int organizationId = -1,
    String? status,
    int pageNumber = 1,
    int pageSize = 50,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/dqms/webhooks/logs',
        queryParameters: {
          'subscriptionId': subscriptionId,
          'organizationId': organizationId,
          if (status != null) 'status': status,
          'pageNumber': pageNumber,
          'pageSize': pageSize,
        },
      );

      if (response.data != null && response.data['data'] != null) {
        final List raw = response.data['data'];
        return raw.map((json) => WebhookDeliveryLog.fromJson(Map<String, dynamic>.from(json))).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
