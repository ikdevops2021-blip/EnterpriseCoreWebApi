import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/enums/dqms_enums.dart';
import '../../../core/models/staff_models.dart';
import '../../../core/network/dio_provider.dart';

/// ============================================================================
/// Stage 2 Staff Operations Riverpod Providers
/// ============================================================================

final tokenQueueProvider =
    AsyncNotifierProvider<TokenQueueNotifier, List<TokenTransactionDto>>(
        TokenQueueNotifier.new);

class TokenQueueNotifier extends AsyncNotifier<List<TokenTransactionDto>> {
  @override
  Future<List<TokenTransactionDto>> build() async => _fetchQueue();

  Future<List<TokenTransactionDto>> _fetchQueue() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/api/v1/staff/queue', queryParameters: {
        'organizationId': 1,
        'locationId': 1,
        'processId': 1,
        'counterId': 1,
      });

      if (response.data != null && response.data is Map) {
        final List data = response.data['data'] ?? response.data['Data'] ?? [];
        return data.map((item) => TokenTransactionDto.fromJson(Map<String, dynamic>.from(item))).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<void> callNextToken() async {
    try {
      final dio = ref.read(dioProvider);
      await dio.post('/api/v1/staff/call-next', data: {
        'organizationId': 1,
        'locationId': 1,
        'counterId': 1,
        'processId': 1,
      });
      ref.invalidateSelf();
    } catch (e) {
      // Handle gracefully
    }
  }

  Future<void> updateTokenStatus(int tokenId, e_TokenStatus newStatus, {String? reason}) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.post('/api/v1/staff/update-status', data: {
        'tokenId': tokenId,
        'newStatus': newStatus.value,
        'reason': reason,
      });
      ref.invalidateSelf();
    } catch (e) {
      // Handle gracefully
    }
  }

  Future<void> issueToken({int priorityTier = 19001, String? name, String? phone}) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.post('/api/v1/staff/issue-token', data: {
        'organizationId': 1,
        'locationId': 1,
        'areaId': 1,
        'processId': 1,
        'priorityTier': priorityTier,
        'customerName': name,
        'customerPhone': phone,
      });
      ref.invalidateSelf();
    } catch (e) {
      // Handle gracefully
    }
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}
