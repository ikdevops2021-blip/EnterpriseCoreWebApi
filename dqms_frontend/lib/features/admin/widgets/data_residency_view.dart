import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../models/data_residency_models.dart';
import '../providers/data_residency_provider.dart';

/// ============================================================================
/// DATA RESIDENCY, SHARDING & GDPR COMPLIANCE CONSOLE
/// Comprehensive management console for geographic data residency zones,
/// AES-256 field-level envelope encryption, Article 17 Right-To-Be-Forgotten
/// erasure tool, and Article 20 Data Portability customer export packages.
/// ============================================================================
class DataResidencyView extends ConsumerStatefulWidget {
  const DataResidencyView({super.key});

  @override
  ConsumerState<DataResidencyView> createState() => _DataResidencyViewState();
}

class _DataResidencyViewState extends ConsumerState<DataResidencyView> with SingleTickerProviderStateMixin {
  int _selectedOrgId = 1;
  late TabController _tabController;

  // GDPR Tool State
  final _phoneController = TextEditingController();
  final _reasonController = TextEditingController(text: 'Customer GDPR Article 17 Erasure Request');
  bool _isActionInProgress = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _phoneController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final configAsync = ref.watch(dataResidencyConfigProvider(_selectedOrgId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _buildHeaderBar(context),
          TabBar(
            controller: _tabController,
            labelColor: AppColors.brandPrimary,
            unselectedLabelColor: AppColors.textSubtle,
            indicatorColor: AppColors.brandPrimary,
            tabs: const [
              Tab(icon: Icon(Icons.public_rounded), text: 'Data Sovereignty & Retention'),
              Tab(icon: Icon(Icons.privacy_tip_rounded), text: 'GDPR Article 17 & 20 Tools'),
              Tab(icon: Icon(Icons.history_rounded), text: 'Sovereign Audit Trail'),
            ],
          ),
          const Divider(height: 1, color: AppColors.borderSubtle),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSovereigntyTab(configAsync),
                _buildGdprToolsTab(),
                _buildAuditTrailTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.brandPrimary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.security_rounded, color: AppColors.brandPrimary, size: 26),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Data Residency & GDPR Privacy Engine',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Multi-Region Sharding, AES-256-GCM Envelope Encryption, and Article 17/20 Compliance',
                  style: TextStyle(color: AppColors.textSubtle, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Organization Selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.bgSurfaceHover,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedOrgId,
                dropdownColor: AppColors.bgCard,
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Org 1: Central Medical HQ')),
                  DropdownMenuItem(value: 101, child: Text('Org 101: EU Berlin Clinic (GDPR)')),
                  DropdownMenuItem(value: 201, child: Text('Org 201: UAE Dubai Branch (NESA)')),
                  DropdownMenuItem(value: 301, child: Text('Org 301: Saudi Riyadh Health (PDPL)')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedOrgId = val);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSovereigntyTab(AsyncValue<OrganizationDataResidency> configAsync) {
    return configAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error loading residency config: $err', style: const TextStyle(color: Colors.red))),
      data: (config) => _SovereigntyForm(config: config, orgId: _selectedOrgId),
    );
  }

  Widget _buildGdprToolsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Article 17 Erasure Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.delete_forever_rounded, color: Colors.red, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GDPR Article 17: Right-To-Be-Forgotten (Cryptographic Erasure)',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Irreversibly scrubs customer phone, name, and notes while preserving queue wait metrics for analytics',
                          style: TextStyle(color: AppColors.textSubtle, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Customer Phone Number (e.g. +971501234567 or +49170123456)',
                    prefixIcon: Icon(Icons.phone_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Erasure Request Audit Reason',
                    prefixIcon: Icon(Icons.description_rounded),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _isActionInProgress ? null : _confirmExecuteErasure,
                  icon: const Icon(Icons.warning_amber_rounded),
                  label: Text(_isActionInProgress ? 'Sanitizing Records...' : 'Execute Article 17 Erasure'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Article 20 Portability Export Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.brandPrimary.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.brandPrimary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.download_rounded, color: AppColors.brandPrimary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GDPR Article 20: Right to Data Portability Export',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Generate machine-readable JSON package of all visits and interactions for the customer',
                          style: TextStyle(color: AppColors.textSubtle, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _isActionInProgress ? null : _handleDataExport,
                  icon: const Icon(Icons.file_download_outlined),
                  label: const Text('Export Customer Visit History (JSON)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Retention Purge Trigger Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_delete_rounded, color: Colors.orange, size: 28),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Scheduled Data Retention Purge Daemon',
                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Background worker automatically purges expired tokens past retention window every 12 hours.',
                        style: TextStyle(color: AppColors.textSubtle, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: _isActionInProgress ? null : _triggerManualPurge,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade800),
                  child: const Text('Run Purge Now'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditTrailTab() {
    final auditAsync = ref.watch(gdprAuditLogsProvider(_selectedOrgId));

    return auditAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
      data: (logs) {
        if (logs.isEmpty) {
          return const Center(
            child: Text('No GDPR or retention audit logs recorded for this organization.', style: TextStyle(color: AppColors.textSubtle)),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: logs.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final log = logs[index];
            final isErasure = log.actionType.contains('Article17');

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                children: [
                  Icon(
                    isErasure ? Icons.fingerprint_rounded : Icons.auto_delete_rounded,
                    color: isErasure ? Colors.red : Colors.orange,
                    size: 28,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          log.actionType,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          log.auditReason ?? 'N/A',
                          style: const TextStyle(color: AppColors.textSubtle, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${log.recordsAffected} records affected',
                          style: const TextStyle(color: Colors.blue, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        log.executionTime.toLocal().toString().split('.').first,
                        style: const TextStyle(color: AppColors.textSubtle, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _confirmExecuteErasure() {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a customer phone number.')));
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        title: const Text('Confirm GDPR Article 17 Erasure', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to scrub all PII for $phone in Organization $_selectedOrgId?\n\nThis action is irreversible.',
          style: const TextStyle(color: AppColors.textSubtle),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isActionInProgress = true);
              final notifier = ref.read(dataResidencyActionsProvider);
              final result = await notifier.executeRightToBeForgotten(
                organizationId: _selectedOrgId,
                phoneNumber: phone,
                reason: _reasonController.text.trim(),
              );
              setState(() => _isActionInProgress = false);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: result != null && result.success ? Colors.green : Colors.red,
                    content: Text(result?.message ?? 'Failed to execute erasure.'),
                  ),
                );
              }
            },
            child: const Text('Confirm Erasure', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDataExport() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a customer phone number.')));
      return;
    }

    setState(() => _isActionInProgress = true);
    final notifier = ref.read(dataResidencyActionsProvider);
    final export = await notifier.exportCustomerData(organizationId: _selectedOrgId, phoneNumber: phone);
    setState(() => _isActionInProgress = false);

    if (export != null && mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.bgCard,
          title: Text('Customer Data Export: $phone', style: const TextStyle(color: Colors.white)),
          content: SizedBox(
            width: 600,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Visits Found: ${export.visits.length}', style: const TextStyle(color: AppColors.brandPrimary, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Container(
                  height: 250,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.bgSurfaceHover,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      const JsonEncoder.withIndent('  ').convert({
                        'organizationId': export.organizationId,
                        'customerPhone': export.customerPhoneNumber,
                        'generatedAt': export.exportGeneratedAt.toIso8601String(),
                        'visitsCount': export.visits.length,
                        'visitRecords': export.visits.map((v) => {
                          'tokenId': v.tokenId,
                          'tokenNumber': v.tokenNumber,
                          'process': v.processName,
                          'counter': v.counterName,
                          'waitSeconds': v.waitDurationSeconds,
                          'serviceSeconds': v.serviceDurationSeconds,
                        }).toList(),
                      }),
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: Colors.white70),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          ],
        ),
      );
    }
  }

  Future<void> _triggerManualPurge() async {
    setState(() => _isActionInProgress = true);
    final notifier = ref.read(dataResidencyActionsProvider);
    final purged = await notifier.triggerPurge(_selectedOrgId);
    setState(() => _isActionInProgress = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Retention purge complete. $purged records sanitized.')),
      );
    }
  }
}

class _SovereigntyForm extends ConsumerStatefulWidget {
  final OrganizationDataResidency config;
  final int orgId;

  const _SovereigntyForm({required this.config, required this.orgId});

  @override
  ConsumerState<_SovereigntyForm> createState() => _SovereigntyFormState();
}

class _SovereigntyFormState extends ConsumerState<_SovereigntyForm> {
  late String _region;
  late String _jurisdiction;
  late double _retentionDays;
  late bool _autoAnonymize;
  late bool _enableBlindIndex;
  late bool _crossBorderDiagnostics;
  late TextEditingController _kmsController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _region = widget.config.dataRegion;
    _jurisdiction = widget.config.jurisdiction;
    _retentionDays = widget.config.dataRetentionDays.toDouble();
    _autoAnonymize = widget.config.autoAnonymizeOnComplete;
    _enableBlindIndex = widget.config.enableBlindIndexing;
    _crossBorderDiagnostics = widget.config.allowCrossBorderDiagnostics;
    _kmsController = TextEditingController(text: widget.config.kmsKeyArn ?? '');
  }

  @override
  void dispose() {
    _kmsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Regional Sovereignty Flag Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.brandPrimary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.brandPrimary.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                _buildRegionBadge(_region),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Active Sovereignty Zone: ${_getRegionLabel(_region)}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        'Governed by $_jurisdiction statutory data sovereignty frameworks. Strict database isolation enforced.',
                        style: const TextStyle(color: AppColors.textSubtle, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Configuration Card
          Material(
            color: AppColors.bgCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.borderSubtle),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Geographic Data Region', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _region,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  dropdownColor: AppColors.bgCard,
                  items: const [
                    DropdownMenuItem(value: 'eu-central-1', child: Text('🇪🇺 Europe (Frankfurt) - eu-central-1 [GDPR]')),
                    DropdownMenuItem(value: 'me-central-1', child: Text('🇦🇪 Middle East (UAE Dubai) - me-central-1 [NESA]')),
                    DropdownMenuItem(value: 'me-south-1', child: Text('🇸🇦 Middle East (Riyadh) - me-south-1 [PDPL]')),
                    DropdownMenuItem(value: 'us-east-1', child: Text('🇺🇸 US East (N. Virginia) - us-east-1 [HIPAA]')),
                    DropdownMenuItem(value: 'ap-south-1', child: Text('🇮🇳 Asia Pacific (Mumbai) - ap-south-1 [DPDP]')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _region = val;
                        if (val.contains('eu')) {
                          _jurisdiction = 'GDPR';
                        } else if (val.contains('me-central')) {
                          _jurisdiction = 'NESA';
                        } else if (val.contains('me-south')) {
                          _jurisdiction = 'PDPL';
                        } else if (val.contains('us')) {
                          _jurisdiction = 'HIPAA';
                        } else if (val.contains('ap')) {
                          _jurisdiction = 'DPDP';
                        }
                      });
                    }
                  },
                ),
                const SizedBox(height: 20),

                Text('Data Retention Period: ${_retentionDays.toInt()} Days', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Slider(
                  value: _retentionDays,
                  min: 30,
                  max: 365,
                  divisions: 11,
                  activeColor: AppColors.brandPrimary,
                  label: '${_retentionDays.toInt()} Days',
                  onChanged: (val) => setState(() => _retentionDays = val),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: _kmsController,
                  decoration: const InputDecoration(
                    labelText: 'Tenant KMS Key ARN / Reference (Optional)',
                    prefixIcon: Icon(Icons.vpn_key_rounded),
                  ),
                ),
                const SizedBox(height: 16),

                SwitchListTile(
                  title: const Text('Deterministic HMAC-SHA256 Blind Indexing', style: TextStyle(color: Colors.white)),
                  subtitle: const Text('Enables O(1) indexed phone/ID searches without decrypting tables', style: TextStyle(color: AppColors.textSubtle, fontSize: 12)),
                  value: _enableBlindIndex,
                  onChanged: (val) => setState(() => _enableBlindIndex = val),
                ),
                SwitchListTile(
                  title: const Text('Auto-Anonymize Customer PII on Service Completion', style: TextStyle(color: Colors.white)),
                  subtitle: const Text('Immediately scrubs PII when token status moves to Completed', style: TextStyle(color: AppColors.textSubtle, fontSize: 12)),
                  value: _autoAnonymize,
                  onChanged: (val) => setState(() => _autoAnonymize = val),
                ),
                SwitchListTile(
                  title: const Text('Allow Cross-Border Diagnostic Telemetry', style: TextStyle(color: Colors.white)),
                  subtitle: const Text('Permits sending non-PII performance metrics outside sovereign region', style: TextStyle(color: AppColors.textSubtle, fontSize: 12)),
                  value: _crossBorderDiagnostics,
                  onChanged: (val) => setState(() => _crossBorderDiagnostics = val),
                ),
                const SizedBox(height: 20),

                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveConfiguration,
                  icon: const Icon(Icons.save_rounded),
                  label: Text(_isSaving ? 'Saving...' : 'Save Sovereignty Settings'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
  }

  Widget _buildRegionBadge(String region) {
    String flag = '🇪🇺';
    if (region.contains('me-central')) flag = '🇦🇪';
    if (region.contains('me-south')) flag = '🇸🇦';
    if (region.contains('us')) flag = '🇺🇸';
    if (region.contains('ap')) flag = '🇮🇳';

    return Text(flag, style: const TextStyle(fontSize: 32));
  }

  String _getRegionLabel(String region) {
    switch (region) {
      case 'eu-central-1': return 'Frankfurt, Germany (EU GDPR)';
      case 'me-central-1': return 'Dubai, UAE (NESA)';
      case 'me-south-1': return 'Riyadh, Saudi Arabia (PDPL)';
      case 'us-east-1': return 'N. Virginia, USA (HIPAA)';
      case 'ap-south-1': return 'Mumbai, India (DPDP)';
      default: return region;
    }
  }

  Future<void> _saveConfiguration() async {
    setState(() => _isSaving = true);
    final updated = OrganizationDataResidency(
      id: widget.config.id,
      organizationId: widget.orgId,
      dataRegion: _region,
      jurisdiction: _jurisdiction,
      kmsKeyArn: _kmsController.text.trim().isEmpty ? null : _kmsController.text.trim(),
      dataRetentionDays: _retentionDays.toInt(),
      autoAnonymizeOnComplete: _autoAnonymize,
      enableBlindIndexing: _enableBlindIndex,
      allowCrossBorderDiagnostics: _crossBorderDiagnostics,
    );

    final ok = await ref.read(dataResidencyActionsProvider).saveConfig(updated);
    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: ok ? Colors.green : Colors.red,
          content: Text(ok ? 'Data residency settings saved.' : 'Failed to save residency settings.'),
        ),
      );
    }
  }
}
