import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';
import '../models/data_residency_models.dart';

final dataResidencyConfigProvider =
    FutureProvider.autoDispose.family<OrganizationDataResidency, int>((ref, organizationId) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get('/api/v1/dqms/residency/config', queryParameters: {'organizationId': organizationId});
  final data = response.data['data'] ?? response.data['Data'] ?? response.data;
  return OrganizationDataResidency.fromJson(Map<String, dynamic>.from(data));
});

final gdprAuditLogsProvider =
    FutureProvider.autoDispose.family<List<GdprAuditLog>, int>((ref, organizationId) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get('/api/v1/dqms/residency/audit', queryParameters: {'organizationId': organizationId});
  final listRaw = response.data['data'] ?? response.data['Data'] ?? response.data as List? ?? [];
  return (listRaw as List).map((i) => GdprAuditLog.fromJson(Map<String, dynamic>.from(i))).toList();
});

class DataResidencyActionsNotifier {
  final Ref _ref;

  DataResidencyActionsNotifier(this._ref);

  Future<bool> saveConfig(OrganizationDataResidency config) async {
    try {
      final dio = _ref.read(dioProvider);
      final response = await dio.post('/api/v1/dqms/residency/config', data: config.toJson());
      final ok = response.data['success'] ?? response.data['Success'] ?? false;
      if (ok) {
        _ref.invalidate(dataResidencyConfigProvider(config.organizationId));
      }
      return ok;
    } catch (_) {
      return false;
    }
  }

  Future<GdprRightToBeForgottenResult?> executeRightToBeForgotten({
    required int organizationId,
    required String phoneNumber,
    String? nationalId,
    String? reason,
  }) async {
    try {
      final dio = _ref.read(dioProvider);
      final response = await dio.post('/api/v1/dqms/gdpr/right-to-be-forgotten', data: {
        'organizationId': organizationId,
        'customerPhoneNumber': phoneNumber,
        'nationalId': nationalId,
        'reason': reason ?? 'GDPR Article 17 Erasure Request',
      });
      final data = response.data['data'] ?? response.data['Data'] ?? response.data;
      _ref.invalidate(gdprAuditLogsProvider(organizationId));
      return GdprRightToBeForgottenResult.fromJson(Map<String, dynamic>.from(data));
    } catch (_) {
      return null;
    }
  }

  Future<CustomerDataExport?> exportCustomerData({
    required int organizationId,
    required String phoneNumber,
  }) async {
    try {
      final dio = _ref.read(dioProvider);
      final response = await dio.get('/api/v1/dqms/gdpr/export', queryParameters: {
        'organizationId': organizationId,
        'customerPhoneNumber': phoneNumber,
      });
      final data = response.data['data'] ?? response.data['Data'] ?? response.data;
      return CustomerDataExport.fromJson(Map<String, dynamic>.from(data));
    } catch (_) {
      return null;
    }
  }

  Future<int?> triggerPurge(int organizationId) async {
    try {
      final dio = _ref.read(dioProvider);
      final response = await dio.post('/api/v1/dqms/residency/purge', data: {
        'organizationId': organizationId,
      });
      final data = response.data['data'] ?? response.data['Data'] ?? response.data;
      _ref.invalidate(gdprAuditLogsProvider(organizationId));
      return data['purgedRecordsCount'] ?? data['PurgedRecordsCount'] ?? 0;
    } catch (_) {
      return null;
    }
  }
}

final dataResidencyActionsProvider = Provider<DataResidencyActionsNotifier>((ref) {
  return DataResidencyActionsNotifier(ref);
});
