import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';
import '../models/edge_node_models.dart';
import '../repositories/edge_node_repository.dart';

final edgeNodeRepositoryProvider = Provider<EdgeNodeRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return EdgeNodeRepository(dio);
});

final edgeNodesProvider =
    AsyncNotifierProvider<EdgeNodesNotifier, List<EdgeNodeRegistration>>(EdgeNodesNotifier.new);

class EdgeNodesNotifier extends AsyncNotifier<List<EdgeNodeRegistration>> {
  @override
  Future<List<EdgeNodeRegistration>> build() async {
    final repo = ref.read(edgeNodeRepositoryProvider);
    return repo.getNodes();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(edgeNodeRepositoryProvider);
      return repo.getNodes();
    });
  }

  Future<bool> registerNode(Map<String, dynamic> data) async {
    try {
      final repo = ref.read(edgeNodeRepositoryProvider);
      final ok = await repo.registerNode(data);
      if (ok) {
        await refresh();
      }
      return ok;
    } catch (_) {
      return false;
    }
  }
}

final edgeSyncLogsProvider = FutureProvider.family<List<EdgeSyncAuditLog>, String?>((ref, nodeId) async {
  final repo = ref.read(edgeNodeRepositoryProvider);
  return repo.getAuditLogs(nodeId: nodeId);
});
