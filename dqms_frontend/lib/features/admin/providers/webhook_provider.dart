import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';
import '../models/webhook_models.dart';
import '../repositories/webhook_repository.dart';

final webhookRepositoryProvider = Provider<WebhookRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return WebhookRepository(dio);
});

final webhookSubscriptionsProvider =
    AsyncNotifierProvider<WebhookSubscriptionsNotifier, List<WebhookSubscription>>(
        WebhookSubscriptionsNotifier.new);

class WebhookSubscriptionsNotifier extends AsyncNotifier<List<WebhookSubscription>> {
  @override
  Future<List<WebhookSubscription>> build() async {
    final repo = ref.read(webhookRepositoryProvider);
    return repo.getSubscriptions();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(webhookRepositoryProvider);
      return repo.getSubscriptions();
    });
  }

  Future<bool> saveSubscription(Map<String, dynamic> data) async {
    try {
      final repo = ref.read(webhookRepositoryProvider);
      final result = await repo.saveSubscription(data);
      if (result != null) {
        await refresh();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteSubscription(int id) async {
    try {
      final repo = ref.read(webhookRepositoryProvider);
      final ok = await repo.deleteSubscription(id);
      if (ok) {
        await refresh();
      }
      return ok;
    } catch (_) {
      return false;
    }
  }
}

final webhookDeliveryLogsProvider =
    FutureProvider.family<List<WebhookDeliveryLog>, int>((ref, subscriptionId) async {
  final repo = ref.watch(webhookRepositoryProvider);
  return repo.getDeliveryLogs(subscriptionId: subscriptionId);
});

final isTestingWebhookProvider = StateProvider<bool>((ref) => false);
final lastTestResultProvider = StateProvider<WebhookTestResult?>((ref) => null);
