import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/customer_models.dart';
import '../../../core/network/dio_provider.dart';

/// ============================================================================
/// Stage 3 Customer & Public TV Display Board Riverpod Providers
/// ============================================================================

final displayBoardProvider =
    AsyncNotifierProvider<DisplayBoardNotifier, List<DisplayBoardItemDto>>(
        DisplayBoardNotifier.new);

class DisplayBoardNotifier extends AsyncNotifier<List<DisplayBoardItemDto>> {
  @override
  Future<List<DisplayBoardItemDto>> build() async => _fetchDisplayBoard();

  Future<List<DisplayBoardItemDto>> _fetchDisplayBoard() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/api/v1/public/display-board', queryParameters: {
        'organizationId': 1,
        'locationId': 1,
      });

      if (response.data != null && response.data is Map) {
        final List data = response.data['data'] ?? response.data['Data'] ?? [];
        return data.map((item) => DisplayBoardItemDto.fromJson(Map<String, dynamic>.from(item))).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}
