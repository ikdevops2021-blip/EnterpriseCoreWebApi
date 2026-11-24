import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/dqms_button.dart';
import '../../../core/widgets/dqms_text_field.dart';
import '../../../core/widgets/dqms_status_badge.dart';
import '../models/webhook_models.dart';
import '../providers/webhook_provider.dart';
import 'master_detail_layout.dart';

class WebhookManagementView extends ConsumerStatefulWidget {
  const WebhookManagementView({super.key});

  @override
  ConsumerState<WebhookManagementView> createState() => _WebhookManagementViewState();
}

class _WebhookManagementViewState extends ConsumerState<WebhookManagementView> {
  String _searchQuery = '';
  WebhookSubscription? _selectedSubscription;
  bool _isCreating = false;

  // Form Controllers
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();
  final _secretController = TextEditingController();
  int _timeoutSeconds = 10;
  int _maxRetries = 3;
  bool _isActive = true;
  final Set<String> _selectedEvents = {'token.issued', 'token.called', 'token.completed'};

  final List<String> _availableEvents = [
    'token.issued',
    'token.called',
    'token.serving',
    'token.hold',
    'token.completed',
    'token.forwarded',
    'token.canceled',
    'sla.breached',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    _secretController.dispose();
    super.dispose();
  }

  void _initForm(WebhookSubscription? sub) {
    if (sub != null) {
      _nameController.text = sub.name;
      _urlController.text = sub.endpointUrl;
      _secretController.text = sub.secretKey;
      _timeoutSeconds = sub.timeoutSeconds;
      _maxRetries = sub.maxRetryAttempts;
      _isActive = sub.isActive;
      _selectedEvents.clear();
      _selectedEvents.addAll(sub.eventList);
      _isCreating = false;
    } else {
      _nameController.clear();
      _urlController.clear();
      _secretController.text = _generateSecret();
      _timeoutSeconds = 10;
      _maxRetries = 3;
      _isActive = true;
      _selectedEvents.clear();
      _selectedEvents.addAll(['token.issued', 'token.called', 'token.completed']);
      _isCreating = true;
    }
  }

  String _generateSecret() {
    const chars = 'abcdef0123456789';
    final rand = Random.secure();
    final randomHex = List.generate(32, (_) => chars[rand.nextInt(chars.length)]).join();
    return 'whsec_$randomHex';
  }

  @override
  Widget build(BuildContext context) {
    final subsAsync = ref.watch(webhookSubscriptionsProvider);

    return subsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.brandPrimary)),
      error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
      data: (subscriptions) {
        final filteredSubs = subscriptions.where((s) {
          return s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              s.endpointUrl.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();

        return MasterDetailLayout(
          masterWidget: _buildMasterTable(filteredSubs),
          detailWidget: (_selectedSubscription != null || _isCreating) ? _buildDetailEditor() : null,
          detailTitle: _isCreating
              ? 'New Webhook Registration'
              : (_selectedSubscription != null ? 'Webhook Inspector — ${_selectedSubscription!.name}' : 'Webhook Inspector'),
          onCloseDetail: () {
            setState(() {
              _selectedSubscription = null;
              _isCreating = false;
            });
          },
        );
      },
    );
  }

  Widget _buildMasterTable(List<WebhookSubscription> subscriptions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Webhook Integrations & Real-Time Sync',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Event-driven outbound HTTP dispatches with HMAC-SHA256 payload signatures',
                    style: TextStyle(fontSize: 13, color: Colors.white70),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  tooltip: 'Refresh',
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
                  onPressed: () => ref.read(webhookSubscriptionsProvider.notifier).refresh(),
                ),
                const SizedBox(width: 8),
                DqmsButton(
                  label: '+ Register Webhook',
                  icon: Icons.add_link_rounded,
                  onPressed: () {
                    setState(() {
                      _selectedSubscription = null;
                      _initForm(null);
                    });
                  },
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Search Field
        SizedBox(
          width: 340,
          child: DqmsTextField(
            hintText: 'Search endpoints by name or URL...',
            prefixIcon: const Icon(Icons.search_rounded, size: 16, color: AppColors.textSubtle),
            onChanged: (val) => setState(() => _searchQuery = val),
          ),
        ),
        const SizedBox(height: 16),

        // Table
        Expanded(
          child: subscriptions.isEmpty
              ? _buildEmptyState()
              : Container(
                  decoration: BoxDecoration(
                    color: AppColors.bgSurface.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: ListView.separated(
                    itemCount: subscriptions.length,
                    separatorBuilder: (_, __) => Divider(color: Colors.white.withOpacity(0.06), height: 1),
                    itemBuilder: (context, index) {
                      final sub = subscriptions[index];
                      final isSelected = _selectedSubscription?.id == sub.id;

                      return Material(
                        color: Colors.transparent,
                        child: ListTile(
                          selected: isSelected,
                          selectedTileColor: AppColors.brandPrimary.withOpacity(0.12),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: sub.isActive ? AppColors.brandPrimary.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                            child: Icon(
                              Icons.webhook_rounded,
                              color: sub.isActive ? AppColors.brandPrimary : Colors.grey,
                              size: 20,
                            ),
                          ),
                        title: Row(
                          children: [
                            Text(
                              sub.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                            ),
                            const SizedBox(width: 8),
                            _buildHealthBadge(sub),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              sub.endpointUrl,
                              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12, fontFamily: 'monospace'),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: sub.eventList.map((e) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.blueGrey.withOpacity(0.25),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: Colors.blueGrey.withOpacity(0.4), width: 0.8),
                                  ),
                                  child: Text(e, style: const TextStyle(fontSize: 10, color: Colors.white70)),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.bolt_rounded, color: Colors.amber, size: 20),
                              tooltip: 'Test Ping',
                              onPressed: () => _executeTestPing(sub),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_rounded, color: Colors.white70, size: 20),
                              tooltip: 'Edit Webhook',
                              onPressed: () {
                                setState(() {
                                  _selectedSubscription = sub;
                                  _initForm(sub);
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                              tooltip: 'Delete',
                              onPressed: () => _confirmDelete(sub),
                            ),
                          ],
                        ),
                        onTap: () {
                          setState(() {
                            _selectedSubscription = sub;
                            _initForm(sub);
                          });
                        },
                      ),
                    );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildHealthBadge(WebhookSubscription sub) {
    if (!sub.isActive) {
      return const DqmsStatusBadge(label: 'INACTIVE', color: Colors.grey);
    }
    if (sub.circuitBreakerUntil != null && sub.circuitBreakerUntil!.isAfter(DateTime.now())) {
      return const DqmsStatusBadge(label: 'CIRCUIT TRIPPED', color: Colors.orange);
    }
    if (sub.lastResponseStatusCode == 200) {
      return const DqmsStatusBadge(label: '200 OK', color: Colors.green);
    }
    if (sub.lastResponseStatusCode != null && sub.lastResponseStatusCode! > 0) {
      return DqmsStatusBadge(label: 'HTTP ${sub.lastResponseStatusCode}', color: Colors.redAccent);
    }
    return const DqmsStatusBadge(label: 'ACTIVE', color: Colors.blue);
  }

  Widget _buildDetailEditor() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name Field
          const Text('Subscription Name', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
          const SizedBox(height: 6),
          DqmsTextField(
            controller: _nameController,
            hintText: 'e.g. Hospital HIS Intake Webhook',
          ),
          const SizedBox(height: 14),

          // URL Field
          const Text('Destination Endpoint URL (HTTPS)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
          const SizedBox(height: 6),
          DqmsTextField(
            controller: _urlController,
            hintText: 'https://his.hospital.org/api/webhooks',
          ),
          const SizedBox(height: 14),

          // Secret Key Card
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('HMAC-SHA256 Signing Secret', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
              TextButton.icon(
                icon: const Icon(Icons.refresh_rounded, size: 14, color: AppColors.brandPrimary),
                label: const Text('Generate New', style: TextStyle(fontSize: 12, color: AppColors.brandPrimary)),
                onPressed: () => setState(() => _secretController.text = _generateSecret()),
              ),
            ],
          ),
          const SizedBox(height: 4),
          DqmsTextField(
            controller: _secretController,
            hintText: 'whsec_...',
          ),
          const SizedBox(height: 14),

          // Subscribed Events
          const Text('Subscribed Queue Events', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _availableEvents.map((ev) {
              final isChecked = _selectedEvents.contains(ev);
              return FilterChip(
                label: Text(ev, style: TextStyle(fontSize: 12, color: isChecked ? Colors.white : Colors.white70)),
                selected: isChecked,
                selectedColor: AppColors.brandPrimary.withOpacity(0.5),
                backgroundColor: AppColors.bgSurface,
                checkmarkColor: Colors.white,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedEvents.add(ev);
                    } else {
                      if (_selectedEvents.length > 1) {
                        _selectedEvents.remove(ev);
                      }
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Switches
          Row(
            children: [
              Switch(
                value: _isActive,
                activeColor: AppColors.brandPrimary,
                onChanged: (val) => setState(() => _isActive = val),
              ),
              const SizedBox(width: 8),
              const Text('Active (Accept Dispatches)', style: TextStyle(color: Colors.white)),
            ],
          ),
          const SizedBox(height: 20),

          // Actions
          Row(
            children: [
              Expanded(
                child: DqmsButton(
                  label: _isCreating ? 'Save Webhook' : 'Update Webhook',
                  icon: Icons.check_rounded,
                  onPressed: _saveWebhook,
                ),
              ),
              if (!_isCreating && _selectedSubscription != null) ...[
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.bolt_rounded, color: Colors.amber),
                  label: const Text('Test Ping', style: TextStyle(color: Colors.amber)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.amber),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  onPressed: () => _executeTestPing(_selectedSubscription!),
                ),
              ],
            ],
          ),

          if (!_isCreating && _selectedSubscription != null) ...[
            const SizedBox(height: 24),
            const Divider(color: Colors.white24),
            const SizedBox(height: 12),
            _buildAuditLogsSection(_selectedSubscription!.id),
          ],
        ],
      ),
    );
  }

  Widget _buildAuditLogsSection(int subId) {
    final logsAsync = ref.watch(webhookDeliveryLogsProvider(subId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Delivery History',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 8),
        logsAsync.when(
          loading: () => const LinearProgressIndicator(),
          error: (err, _) => Text('Failed to load logs: $err', style: const TextStyle(color: Colors.redAccent)),
          data: (logs) {
            if (logs.isEmpty) {
              return Text('No dispatches recorded yet.', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12));
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: logs.length > 5 ? 5 : logs.length,
              itemBuilder: (context, idx) {
                final log = logs[idx];
                final isOk = log.deliveryStatus == 'Success';
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(isOk ? Icons.check_circle_rounded : Icons.error_rounded,
                              color: isOk ? Colors.green : Colors.redAccent, size: 16),
                          const SizedBox(width: 6),
                          Text(log.eventCode, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                      Text('HTTP ${log.responseStatusCode ?? 0} (${log.durationMs}ms)',
                          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.webhook_rounded, size: 48, color: Colors.white.withOpacity(0.3)),
          const SizedBox(height: 12),
          const Text('No Webhooks Configured', style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text('Register your first external endpoint to begin receiving real-time queue events.',
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
          const SizedBox(height: 16),
          DqmsButton(
            label: '+ Register Webhook',
            onPressed: () {
              setState(() {
                _selectedSubscription = null;
                _initForm(null);
              });
            },
          ),
        ],
      ),
    );
  }

  Future<void> _saveWebhook() async {
    final name = _nameController.text.trim();
    final url = _urlController.text.trim();
    if (name.isEmpty || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both Name and Target URL.')),
      );
      return;
    }

    final data = {
      'id': _isCreating ? 0 : (_selectedSubscription?.id ?? 0),
      'organizationId': 1,
      'name': name,
      'endpointUrl': url,
      'secretKey': _secretController.text.trim(),
      'subscribedEvents': _selectedEvents.join(','),
      'isActive': _isActive,
      'timeoutSeconds': _timeoutSeconds,
      'maxRetryAttempts': _maxRetries,
    };

    final ok = await ref.read(webhookSubscriptionsProvider.notifier).saveSubscription(data);
    if (ok) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Webhook saved successfully.')),
        );
        setState(() {
          _selectedSubscription = null;
          _isCreating = false;
        });
      }
    }
  }

  Future<void> _executeTestPing(WebhookSubscription sub) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.brandPrimary)),
    );

    final repo = ref.read(webhookRepositoryProvider);
    final result = await repo.testWebhook(
      subscriptionId: sub.id,
      endpointUrl: sub.endpointUrl,
      secretKey: sub.secretKey,
    );

    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop(); // dismiss loading

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.bgSurface,
          title: Row(
            children: [
              Icon(result.isSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
                  color: result.isSuccess ? Colors.green : Colors.redAccent),
              const SizedBox(width: 8),
              Text(result.isSuccess ? 'Ping Succeeded' : 'Ping Failed', style: const TextStyle(color: Colors.white)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('HTTP Status: ${result.statusCode}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Latency: ${result.latencyMs}ms', style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              Text(result.message, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
              if (result.computedSignature != null) ...[
                const SizedBox(height: 10),
                const Text('Computed X-DQMS-Signature:', style: TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold)),
                Text(result.computedSignature!, style: const TextStyle(color: Colors.white60, fontSize: 10, fontFamily: 'monospace')),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _confirmDelete(WebhookSubscription sub) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgSurface,
        title: const Text('Confirm Deletion', style: TextStyle(color: Colors.white)),
        content: Text('Are you sure you want to delete "${sub.name}"? Outbound queue events will no longer be dispatched to this URL.',
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final ok = await ref.read(webhookSubscriptionsProvider.notifier).deleteSubscription(sub.id);
      if (ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Webhook deleted.')));
        setState(() {
          _selectedSubscription = null;
        });
      }
    }
  }
}
