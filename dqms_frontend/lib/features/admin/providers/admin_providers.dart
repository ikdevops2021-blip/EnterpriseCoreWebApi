import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/enums/dqms_enums.dart';
import '../../../core/models/admin_models.dart';
import '../../../core/network/dio_provider.dart';

/// ============================================================================
/// Stage 1 Admin Master Providers (Riverpod AsyncNotifier)
/// ============================================================================

// ---------------------------------------------------------------------------
// AREA LIST PROVIDER
// ---------------------------------------------------------------------------
final areaListProvider =
    AsyncNotifierProvider<AreaListNotifier, List<AreaDto>>(AreaListNotifier.new);

class AreaListNotifier extends AsyncNotifier<List<AreaDto>> {
  @override
  Future<List<AreaDto>> build() async => _fetchAreas();

  Future<List<AreaDto>> _fetchAreas() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/api/v1/admin/areas', queryParameters: {
        'isActive': e_ActiveSearchStatus.active.value,
      });

      if (response.data != null && response.data is Map) {
        final List data = response.data['data'] ?? response.data['Data'] ?? [];
        return data.map((item) => AreaDto.fromJson(Map<String, dynamic>.from(item))).toList();
      }
      return [];
    } catch (e) {
      // Return empty list on failure or rethrow for AsyncError
      return [];
    }
  }

  Future<void> saveArea(AreaDto dto) async {
    final dio = ref.read(dioProvider);
    await dio.post('/api/v1/admin/area', data: dto.toJson());
    ref.invalidateSelf();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

// ---------------------------------------------------------------------------
// PROCESS LIST PROVIDER
// ---------------------------------------------------------------------------
final processListProvider =
    AsyncNotifierProvider<ProcessListNotifier, List<ProcessDto>>(
        ProcessListNotifier.new);

class ProcessListNotifier extends AsyncNotifier<List<ProcessDto>> {
  @override
  Future<List<ProcessDto>> build() async => _fetchProcesses();

  Future<List<ProcessDto>> _fetchProcesses() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/api/v1/admin/processes', queryParameters: {
        'isActive': e_ActiveSearchStatus.active.value,
      });

      if (response.data != null && response.data is Map) {
        final List data = response.data['data'] ?? response.data['Data'] ?? [];
        return data.map((item) => ProcessDto.fromJson(Map<String, dynamic>.from(item))).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<void> saveProcess(ProcessDto dto) async {
    final dio = ref.read(dioProvider);
    await dio.post('/api/v1/admin/process', data: dto.toJson());
    ref.invalidateSelf();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}
