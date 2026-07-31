import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:dqms_frontend/core/config/app_config.dart';
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

/// SYSTEM CONFIGURATION KEYS & API GATEWAY WORKSPACE VIEW
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
              ElevatedButton.icon(
                icon: const Icon(Icons.dns_rounded, size: 16),
                label: const Text('API Gateway Endpoints', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                onPressed: () => _showApiEndpointsModal(context),
              ),
              const SizedBox(width: 10),
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

          // Active Endpoint Status Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.brandPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.brandPrimary.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.cloud_sync_rounded, size: 16, color: AppColors.brandPrimary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Active Root API Endpoint: ${AppConfig.apiBaseUrl} (Admin API: ${AppConfig.adminApiBase})',
                    style: const TextStyle(color: AppColors.textMain, fontSize: 11, fontWeight: FontWeight.w600, fontFamily: 'monospace'),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  onPressed: () => _showApiEndpointsModal(context),
                  child: const Text('Configure Endpoints', style: TextStyle(color: AppColors.brandPrimary, fontSize: 11, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

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

  /// Interactive Modal Screen to View, Test & Edit API Gateway Endpoints Live from Frontend
  void _showApiEndpointsModal(BuildContext context) {
    final hostCtrl = TextEditingController(text: AppConfig.apiBaseUrl);
    final adminCtrl = TextEditingController(text: AppConfig.adminApiBase);
    final dqmsCtrl = TextEditingController(text: AppConfig.dqmsApiBase);
    final authCtrl = TextEditingController(text: AppConfig.authApiBase);
    final reportsCtrl = TextEditingController(text: AppConfig.reportsApiBase);

    String pingResult = 'Click "Test API Connection" to verify server connectivity.';
    bool isTesting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          backgroundColor: AppColors.bgSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: AppColors.borderSubtle),
          ),
          title: Row(
            children: [
              const Icon(Icons.dns_rounded, color: AppColors.brandPrimary, size: 20),
              const SizedBox(width: 10),
              const Text('API Gateway & Subsystem Endpoints Config', style: TextStyle(color: AppColors.textMain, fontSize: 15, fontWeight: FontWeight.w700)),
            ],
          ),
          content: SizedBox(
            width: 540,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline_rounded, color: AppColors.brandPrimary, size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Modify API Gateway & microservice subsystem base URLs live without rebuilding the application binary.',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  DqmsTextField(label: 'Root API Host URL (apiBaseUrl)', controller: hostCtrl),
                  const SizedBox(height: 12),
                  DqmsTextField(label: 'Admin Subsystem Endpoint (adminApiBase)', controller: adminCtrl),
                  const SizedBox(height: 12),
                  DqmsTextField(label: 'Queue Core Subsystem Endpoint (dqmsApiBase)', controller: dqmsCtrl),
                  const SizedBox(height: 12),
                  DqmsTextField(label: 'Authentication Subsystem Endpoint (authApiBase)', controller: authCtrl),
                  const SizedBox(height: 12),
                  DqmsTextField(label: 'Reports & Analytics Subsystem Endpoint (reportsApiBase)', controller: reportsCtrl),
                  const SizedBox(height: 14),

                  // Ping & Test Result Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.bgCanvas,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('API Health Status', style: TextStyle(color: AppColors.textMain, fontSize: 11, fontWeight: FontWeight.w700)),
                            const Spacer(),
                            if (isTesting)
                              const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.brandPrimary))
                            else
                              TextButton.icon(
                                icon: const Icon(Icons.bolt_rounded, size: 14),
                                label: const Text('Test Connection', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                                onPressed: () async {
                                  setModalState(() {
                                    isTesting = true;
                                    pingResult = 'Pinging ${hostCtrl.text}...';
                                  });
                                  final stopwatch = Stopwatch()..start();
                                  try {
                                    final dio = Dio();
                                    final res = await dio.get('${hostCtrl.text}/api/v1/admin/areas', options: Options(validateStatus: (_) => true));
                                    stopwatch.stop();
                                    setModalState(() {
                                      isTesting = false;
                                      pingResult = '🟢 Server Online — HTTP ${res.statusCode} (${stopwatch.elapsedMilliseconds}ms response time)';
                                    });
                                  } catch (err) {
                                    stopwatch.stop();
                                    setModalState(() {
                                      isTesting = false;
                                      pingResult = '🔴 Connection Notice (${err.toString()})';
                                    });
                                  }
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(pingResult, style: const TextStyle(color: AppColors.brandAccent, fontSize: 11, fontFamily: 'monospace')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.save_rounded, size: 16),
              label: const Text('Apply Endpoint Changes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandPrimary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                AppConfig.updateEndpoints(
                  apiBaseUrl: hostCtrl.text,
                  adminApiBase: adminCtrl.text,
                  dqmsApiBase: dqmsCtrl.text,
                  authApiBase: authCtrl.text,
                  reportsApiBase: reportsCtrl.text,
                );

                setState(() {});
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('API Gateway Endpoints updated live! Root URL set to ${hostCtrl.text}.'),
                    backgroundColor: AppColors.statusActive,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
