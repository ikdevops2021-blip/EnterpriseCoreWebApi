import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/customer_models.dart';
import '../../../core/network/dio_provider.dart';

/// ============================================================================
/// Stage 3 Customer & Public TV Display Board Riverpod Providers
/// ============================================================================

final displayBoardProvider =
    AsyncNotifierProvider<DisplayBoardNotifier, PublicDisplayBoardDto>(
        DisplayBoardNotifier.new);

class DisplayBoardNotifier extends AsyncNotifier<PublicDisplayBoardDto> {
  Timer? _timer;

  @override
  Future<PublicDisplayBoardDto> build() async {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      ref.invalidateSelf();
    });
    ref.onDispose(() {
      _timer?.cancel();
    });
    return _fetchDisplayBoard();
  }

  Future<PublicDisplayBoardDto> _fetchDisplayBoard() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/api/v1/public/display-board', queryParameters: {
        'organizationId': 1,
        'locationId': 1,
      });

      if (response.data != null && response.data is Map) {
        final payload = response.data['data'] ?? response.data['Data'];
        if (payload is Map) {
          return PublicDisplayBoardDto.fromJson(Map<String, dynamic>.from(payload));
        } else if (payload is List) {
          final active = payload
              .map((item) => DisplayBoardItemDto.fromJson(Map<String, dynamic>.from(item)))
              .toList();
          return PublicDisplayBoardDto(activeCalls: active, upcomingQueue: []);
        }
      }
      return PublicDisplayBoardDto.empty();
    } catch (e) {
      return PublicDisplayBoardDto.empty();
    }
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

/// Provider to fetch the next queued waiting token to advise patients to get ready
final nextWaitingTokenProvider = FutureProvider<String?>((ref) async {
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
      final waiting = data.where((item) => item['tokenStatus'] == 18001).toList();
      if (waiting.isNotEmpty) {
        return waiting.first['tokenNumber']?.toString();
      }
    }
    return null;
  } catch (_) {
    return null;
  }
});
