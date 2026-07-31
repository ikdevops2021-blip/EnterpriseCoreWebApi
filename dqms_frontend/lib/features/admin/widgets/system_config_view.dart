import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/core/widgets/dqms_button.dart';
import 'package:dqms_frontend/core/widgets/dqms_text_field.dart';
import 'package:dqms_frontend/core/widgets/dqms_status_badge.dart';
import 'package:dqms_frontend/features/admin/widgets/master_detail_layout.dart';

/// Complete SystemConfigurationKey Model matching .NET Entity (SystemConfigurationKey.cs)
class SystemConfigModel {
  final int configId; // SystemConfigurationKeyID
  final String categoryName;
  final String paramKey; // Key
  final String paramValue; // Value
  final String description;
  final String? acceptedValues;
  final int dataTypeId;
  final String valueDataType; // DataTypeCode / DataTypeName
  final bool allowEdit;
  final bool active;

  const SystemConfigModel({
    required this.configId,
    required this.categoryName,
    required this.paramKey,
    required this.paramValue,
    required this.description,
    this.acceptedValues,
    this.dataTypeId = 15001,
    required this.valueDataType,
    this.allowEdit = true,
    this.active = true,
  });
}

/// SYSTEM CONFIGURATION KEYS WORKSPACE VIEW
class SystemConfigView extends ConsumerStatefulWidget {
  const SystemConfigView({super.key});

  @override
  ConsumerState<SystemConfigView> createState() => _SystemConfigViewState();
}

class _SystemConfigViewState extends ConsumerState<SystemConfigView> {
  String _searchQuery = '';
  SystemConfigModel? _selectedConfig;

  final List<SystemConfigModel> _configs = const [
    SystemConfigModel(
      configId: 1,
      categoryName: 'General',
      paramKey: 'App.Name',
      paramValue: 'DNAQMS Enterprise',
      description: 'Main application brand title',
      acceptedValues: 'Any String',
      dataTypeId: 15001,
      valueDataType: 'STRING (15001)',
      allowEdit: true,
      active: true,
    ),
    SystemConfigModel(
      configId: 2,
      categoryName: 'QueueThresholds',
      paramKey: 'Queue.MaxWaitSlaMinutes',
      paramValue: '15',
      description: 'Global SLA Warning Alert Threshold in Minutes',
      acceptedValues: '5..120',
      dataTypeId: 15002,
      valueDataType: 'INT (15002)',
      allowEdit: true,
      active: true,
    ),
    SystemConfigModel(
      configId: 3,
      categoryName: 'QueueThresholds',
      paramKey: 'Queue.RecallMaxAttempts',
      paramValue: '3',
      description: 'Maximum Token Recall Attempts Before No-Show Auto-Cancel',
      acceptedValues: '1..10',
      dataTypeId: 15002,
      valueDataType: 'INT (15002)',
      allowEdit: true,
      active: true,
    ),
    SystemConfigModel(
      configId: 4,
      categoryName: 'DisplayEngine',
      paramKey: 'Tv.AutoRefreshIntervalSeconds',
      paramValue: '5',
      description: 'TV Display WebSocket Polling Fallback Interval',
      acceptedValues: '1..60',
      dataTypeId: 15002,
      valueDataType: 'INT (15002)',
      allowEdit: true,
      active: true,
    ),
    SystemConfigModel(
      configId: 5,
      categoryName: 'Security',
      paramKey: 'Security.RequireOrganizationHeader',
      paramValue: 'true',
      description: 'Enforces X-Organization-Id header validation',
      acceptedValues: 'true, false',
      dataTypeId: 15004,
      valueDataType: 'BOOL (15004)',
      allowEdit: false,
      active: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _configs.where((c) {
      return c.paramKey.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.categoryName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.description.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return MasterDetailLayout(
      masterWidget: _buildMasterTable(filtered),
      detailWidget: _selectedConfig != null ? _buildDetailInspector(_selectedConfig!) : null,
      detailTitle: _selectedConfig != null ? 'System Key Inspector — ${_selectedConfig!.paramKey}' : 'Key Inspector',
      onCloseDetail: () => setState(() => _selectedConfig = null),
    );
  }

  Widget _buildMasterTable(List<SystemConfigModel> configs) {
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
          Row(
            children: [
              Expanded(
                child: DqmsTextField(
                  hintText: 'Search Key Name, Category, or Description...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 18),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
              const SizedBox(width: 12),
              DqmsButton(
                label: 'Add System Key',
                icon: Icons.add_rounded,
                onPressed: () {
                  setState(() {
                    _selectedConfig = const SystemConfigModel(
                      configId: 999,
                      categoryName: 'CustomKeyCategory',
                      paramKey: 'New.SystemConfigKey',
                      paramValue: 'DefaultValue',
                      description: 'Enter description for new key',
                      acceptedValues: 'Any String',
                      dataTypeId: 15001,
                      valueDataType: 'STRING (15001)',
                      allowEdit: true,
                      active: true,
                    );
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.bgHeader,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: const Row(
                    children: [
                      Expanded(flex: 2, child: Text('CATEGORY', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                      Expanded(flex: 3, child: Text('SYSTEM CONFIG KEY', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                      Expanded(flex: 3, child: Text('KEY VALUE', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                      SizedBox(width: 110, child: Text('DATA TYPE', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: ListView.separated(
                    itemCount: configs.length,
                    separatorBuilder: (_, _) => const Divider(color: AppColors.borderSubtle, height: 1),
                    itemBuilder: (ctx, i) {
                      final cfg = configs[i];
                      final isSelected = _selectedConfig?.configId == cfg.configId;

                      return InkWell(
                        onTap: () => setState(() => _selectedConfig = cfg),
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
                                flex: 2,
                                child: Text(cfg.categoryName, style: const TextStyle(color: AppColors.textSubtle, fontSize: 12, fontWeight: FontWeight.w600)),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(cfg.paramKey, style: const TextStyle(color: AppColors.brandPrimary, fontSize: 13, fontWeight: FontWeight.w800, fontFamily: 'monospace')),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(cfg.paramValue, style: const TextStyle(color: AppColors.textMain, fontSize: 12, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                              ),
                              SizedBox(
                                width: 110,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: AppColors.bgSubtle, borderRadius: BorderRadius.circular(4)),
                                  child: Text(cfg.valueDataType, style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w700)),
                                ),
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

  Widget _buildDetailInspector(SystemConfigModel cfg) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DqmsTextField(label: 'Key Category', initialValue: cfg.categoryName),
        const SizedBox(height: 14),
        DqmsTextField(label: 'System Configuration Key (Key)', initialValue: cfg.paramKey),
        const SizedBox(height: 14),
        DqmsTextField(label: 'Configuration Value (Value)', initialValue: cfg.paramValue),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: DqmsTextField(label: 'Data Type Code / ID', initialValue: cfg.valueDataType)),
            const SizedBox(width: 12),
            Expanded(child: DqmsTextField(label: 'Accepted Values Rule', initialValue: cfg.acceptedValues ?? 'Any')),
          ],
        ),
        const SizedBox(height: 14),
        DqmsTextField(label: 'Description', initialValue: cfg.description, maxLines: 3),
        const SizedBox(height: 16),
        Row(
          children: [
            Text('Allow Edit Flag: ${cfg.allowEdit ? "EDITABLE" : "READ ONLY (Locked)"}', style: const TextStyle(color: AppColors.textMain, fontSize: 12, fontWeight: FontWeight.w600)),
            const Spacer(),
            DqmsStatusBadge.activeState(cfg.active),
          ],
        ),
        const SizedBox(height: 24),
        DqmsButton(
          label: 'Save SystemConfigurationKey Entity',
          icon: Icons.save_rounded,
          isFullWidth: true,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Key ${cfg.paramKey} saved matching SystemConfigurationKey.cs entity.'), backgroundColor: AppColors.statusActive),
            );
          },
        ),
      ],
    );
  }
}
