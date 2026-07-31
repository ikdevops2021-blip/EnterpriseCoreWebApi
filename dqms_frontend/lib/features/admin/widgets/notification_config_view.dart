import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/core/widgets/dqms_button.dart';
import 'package:dqms_frontend/core/widgets/dqms_text_field.dart';
import 'package:dqms_frontend/core/widgets/dqms_status_badge.dart';
import 'package:dqms_frontend/core/widgets/dqms_states.dart';
import 'package:dqms_frontend/features/admin/providers/admin_mock_providers.dart';
import 'package:dqms_frontend/features/admin/widgets/master_detail_layout.dart';

/// ============================================================================
/// NOTIFICATION CONFIGURATION WORKSPACE VIEW (Domain 7)
/// Master-Detail management interface for SMS, Audio Voice, WebHooks, & Push
/// ============================================================================
class NotificationConfigView extends ConsumerStatefulWidget {
  const NotificationConfigView({super.key});

  @override
  ConsumerState<NotificationConfigView> createState() => _NotificationConfigViewState();
}

class _NotificationConfigViewState extends ConsumerState<NotificationConfigView> {
  String _searchQuery = '';
  NotificationConfigModel? _selectedConfig;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminWorkspaceStateProvider);
    final filteredConfigs = state.notificationConfigs.where((n) {
      return n.channelName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          n.providerName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return MasterDetailLayout(
      masterWidget: _buildMasterTable(filteredConfigs),
      detailWidget: _selectedConfig != null ? _buildDetailInspector(_selectedConfig!) : null,
      detailTitle: _selectedConfig != null ? 'Notification Channel — ${_selectedConfig!.channelName}' : 'Notification Channel',
      onCloseDetail: () {
        setState(() {
          _selectedConfig = null;
        });
      },
    );
  }

  Widget _buildMasterTable(List<NotificationConfigModel> configs) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Toolbar
          Row(
            children: [
              Expanded(
                child: DqmsTextField(
                  hintText: 'Search Notification Channel or Provider...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 18),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              DqmsButton(
                label: 'Add Channel',
                icon: Icons.add_rounded,
                onPressed: () {
                  setState(() {
                    _selectedConfig = const NotificationConfigModel(
                      channelId: 999,
                      channelName: 'Custom Dispatch Channel',
                      providerName: 'Custom Service Provider',
                      isEnabled: true,
                      retryLimit: 3,
                      configDetails: 'Endpoint: https://api.dqms.org/custom-notify',
                    );
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Content
          if (configs.isEmpty)
            const Expanded(
              child: DqmsEmptyState(
                title: 'No Notification Channels Found',
                message: 'No dispatch channels match your search query.',
                icon: Icons.notifications_off_rounded,
              ),
            )
          else
            Expanded(
              child: Column(
                children: [
                  // Table Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.bgHeader,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: const Row(
                      children: [
                        Expanded(flex: 3, child: Text('CHANNEL NAME', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                        Expanded(flex: 3, child: Text('PROVIDER ENGINE', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                        SizedBox(width: 100, child: Text('RETRY LIMIT', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                        SizedBox(width: 90, child: Text('STATUS', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Rows
                  Expanded(
                    child: ListView.separated(
                      itemCount: configs.length,
                      separatorBuilder: (_, _) => const Divider(color: AppColors.borderSubtle, height: 1),
                      itemBuilder: (ctx, i) {
                        final notif = configs[i];
                        final isSelected = _selectedConfig?.channelId == notif.channelId;

                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedConfig = notif;
                            });
                          },
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.brandPrimary.withValues(alpha: 0.12) : AppColors.bgCard,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    notif.channelName,
                                    style: const TextStyle(color: AppColors.textMain, fontSize: 13, fontWeight: FontWeight.w700),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    notif.providerName,
                                    style: const TextStyle(color: AppColors.brandAccent, fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    '${notif.retryLimit} Retries',
                                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                                  ),
                                ),
                                SizedBox(
                                  width: 90,
                                  child: DqmsStatusBadge.activeState(notif.isEnabled),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailInspector(NotificationConfigModel notif) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DqmsTextField(label: 'Channel Name', initialValue: notif.channelName),
        const SizedBox(height: 14),
        DqmsTextField(label: 'Provider Name / Engine', initialValue: notif.providerName),
        const SizedBox(height: 14),
        DqmsTextField(label: 'Retry Threshold', initialValue: '${notif.retryLimit}'),
        const SizedBox(height: 14),
        DqmsTextField(label: 'Channel Configuration Details', initialValue: notif.configDetails, maxLines: 3),
        const SizedBox(height: 16),
        Row(
          children: [
            const Text('Channel Enabled Status:', style: TextStyle(color: AppColors.textMain, fontSize: 12, fontWeight: FontWeight.w600)),
            const Spacer(),
            DqmsStatusBadge.activeState(notif.isEnabled),
          ],
        ),
        const SizedBox(height: 24),
        DqmsButton(
          label: 'Save Channel Settings',
          icon: Icons.save_rounded,
          isFullWidth: true,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Channel ${notif.channelName} updated.'), backgroundColor: AppColors.statusActive),
            );
          },
        ),
      ],
    );
  }
}
