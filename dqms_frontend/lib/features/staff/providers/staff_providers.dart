import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/enums/dqms_enums.dart';
import '../../../core/models/staff_models.dart';
import '../../../core/network/dio_provider.dart';
import 'staff_session_provider.dart';

/// ============================================================================
/// Stage 2 Staff Operations Riverpod Providers
/// Queue fetching and actions now use StaffSession for processId/counterId
/// ============================================================================

final tokenQueueProvider =
    AsyncNotifierProvider<TokenQueueNotifier, List<TokenTransactionDto>>(
        TokenQueueNotifier.new);

class TokenQueueNotifier extends AsyncNotifier<List<TokenTransactionDto>> {
  @override
  Future<List<TokenTransactionDto>> build() async => _fetchQueue();

  Future<List<TokenTransactionDto>> _fetchQueue() async {
    final session = ref.read(staffSessionProvider);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/api/v1/staff/queue', queryParameters: {
        'organizationId': 1,
        'locationId': 1,
        'processId': session.selectedProcessId ?? 1,
        'counterId': session.selectedCounterId ?? 1,
      });

      if (response.data != null && response.data is Map) {
        final List data = response.data['data'] ?? response.data['Data'] ?? [];
        return data.map((item) => TokenTransactionDto.fromJson(Map<String, dynamic>.from(item))).toList();
      }
      return [];
    } catch (e) {
      // Return empty on error — UI handles gracefully
      return [];
    }
  }

  Future<void> callNextToken() async {
    final session = ref.read(staffSessionProvider);
    try {
      final dio = ref.read(dioProvider);
      await dio.post('/api/v1/staff/call-next', data: {
        'organizationId': 1,
        'locationId': 1,
        'counterId': session.selectedCounterId ?? 1,
        'processId': session.selectedProcessId ?? 1,
        'staffUserId': session.staffUserId,
      });
      ref.invalidateSelf();
    } catch (e) {
      // Handle gracefully — may be offline/demo
    }
  }

  Future<void> updateTokenStatus(
    int tokenId,
    e_TokenStatus newStatus, {
    String? reason,
    String tokenNumber = '',
  }) async {
    final session = ref.read(staffSessionProvider);
    try {
      final dio = ref.read(dioProvider);
      await dio.post('/api/v1/staff/update-status', data: {
        'tokenId': tokenId,
        'newStatus': newStatus.value,
        'reason': reason,
        'staffUserId': session.staffUserId,
        'counterId': session.selectedCounterId ?? 1,
      });
      // Log the action for audit trail
      final actionLabel = _statusToActionLabel(newStatus);
      ref.read(staffSessionProvider.notifier).logAction(
        tokenNumber.isNotEmpty ? tokenNumber : 'TKN-$tokenId',
        actionLabel,
        notes: reason,
      );
      ref.invalidateSelf();
    } catch (e) {
      // Log audit even on API failure (offline/demo mode)
      final actionLabel = _statusToActionLabel(newStatus);
      ref.read(staffSessionProvider.notifier).logAction(
        tokenNumber.isNotEmpty ? tokenNumber : 'TKN-$tokenId',
        actionLabel,
        notes: reason,
      );
    }
  }

  Future<void> issueToken({
    int priorityTier = 19001,
    String? name,
    String? phone,
  }) async {
    final session = ref.read(staffSessionProvider);
    try {
      final dio = ref.read(dioProvider);
      await dio.post('/api/v1/staff/issue-token', data: {
        'organizationId': 1,
        'locationId': 1,
        'areaId': 1,
        'processId': session.selectedProcessId ?? 1,
        'priorityTier': priorityTier,
        'customerName': name,
        'customerPhone': phone,
        'staffUserId': session.staffUserId,
      });
      ref.read(staffSessionProvider.notifier).logAction(
        'NEW',
        'Issued',
        notes: name != null ? 'For: $name' : null,
      );
      ref.invalidateSelf();
    } catch (e) {
      ref.read(staffSessionProvider.notifier).logAction('NEW', 'Issued');
    }
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }

  String _statusToActionLabel(e_TokenStatus status) {
    switch (status) {
      case e_TokenStatus.calling:
        return 'Called';
      case e_TokenStatus.active:
        return 'Serving';
      case e_TokenStatus.hold:
        return 'On Hold';
      case e_TokenStatus.completed:
        return 'Completed';
      case e_TokenStatus.canceled:
        return 'Cancelled';
      default:
        return 'Updated';
    }
  }
}
