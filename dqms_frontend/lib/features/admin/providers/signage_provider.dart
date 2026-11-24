import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';
import '../models/signage_models.dart';
import '../repositories/signage_repository.dart';

final signageRepositoryProvider = Provider<SignageRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return SignageRepository(dio);
});

// --- Signage Campaigns Provider ---
final signageCampaignsProvider =
    AsyncNotifierProvider<SignageCampaignsNotifier, List<SignageCampaign>>(SignageCampaignsNotifier.new);

class SignageCampaignsNotifier extends AsyncNotifier<List<SignageCampaign>> {
  @override
  Future<List<SignageCampaign>> build() async {
    final repo = ref.read(signageRepositoryProvider);
    return repo.getCampaigns();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(signageRepositoryProvider);
      return repo.getCampaigns();
    });
  }

  Future<bool> saveCampaign(Map<String, dynamic> data) async {
    try {
      final repo = ref.read(signageRepositoryProvider);
      final ok = await repo.saveCampaign(data);
      if (ok) {
        await refresh();
      }
      return ok;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteCampaign(int id) async {
    try {
      final repo = ref.read(signageRepositoryProvider);
      final ok = await repo.deleteCampaign(id);
      if (ok) {
        await refresh();
      }
      return ok;
    } catch (_) {
      return false;
    }
  }
}

// --- Active Playlist Provider for TV Displays ---
final activePlaylistProvider =
    FutureProvider.autoDispose.family<List<SignageMediaItem>, int>((ref, locationId) async {
  final repo = ref.read(signageRepositoryProvider);
  return repo.getActivePlaylist(locationId: locationId);
});

// --- Active Emergency Broadcast Provider ---
final activeEmergencyProvider =
    AsyncNotifierProvider.family<EmergencyBroadcastNotifier, EmergencyBroadcast?, int>(
  EmergencyBroadcastNotifier.new,
);

class EmergencyBroadcastNotifier extends FamilyAsyncNotifier<EmergencyBroadcast?, int> {
  @override
  Future<EmergencyBroadcast?> build(int arg) async {
    final repo = ref.read(signageRepositoryProvider);
    return repo.getActiveEmergency(locationId: arg == -1 ? null : arg);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(signageRepositoryProvider);
      return repo.getActiveEmergency(locationId: arg == -1 ? null : arg);
    });
  }

  Future<bool> triggerEmergency(Map<String, dynamic> data) async {
    try {
      final repo = ref.read(signageRepositoryProvider);
      final ok = await repo.triggerEmergency(data);
      if (ok) {
        await refresh();
      }
      return ok;
    } catch (_) {
      return false;
    }
  }

  Future<bool> dismissEmergency(int broadcastId) async {
    try {
      final repo = ref.read(signageRepositoryProvider);
      final ok = await repo.dismissEmergency(broadcastId);
      if (ok) {
        await refresh();
      }
      return ok;
    } catch (_) {
      return false;
    }
  }
}
