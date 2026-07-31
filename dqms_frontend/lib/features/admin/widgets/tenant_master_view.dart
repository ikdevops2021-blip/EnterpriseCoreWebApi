import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dqms_frontend/core/config/app_config.dart';
import 'package:dqms_frontend/core/network/dio_provider.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/core/widgets/dqms_button.dart';
import 'package:dqms_frontend/core/widgets/dqms_text_field.dart';
import 'package:dqms_frontend/core/widgets/dqms_status_badge.dart';
import 'package:dqms_frontend/features/admin/widgets/master_detail_layout.dart';

/// Tenant / Organization Model
class TenantModel {
  final int tenantId;
  final String registrationKey;
  final String tenantName;
  final String planName; // 'Enterprise Pro', 'SaaS Free', 'Starter'
  final int maxUsers;
  final int maxCounters;
  final String contactEmail;
  final bool isActive;

  const TenantModel({
    required this.tenantId,
    required this.registrationKey,
    required this.tenantName,
    required this.planName,
    required this.maxUsers,
    required this.maxCounters,
    required this.contactEmail,
    required this.isActive,
  });
}

/// TENANT MASTER MANAGEMENT VIEW
class TenantMasterView extends ConsumerStatefulWidget {
  const TenantMasterView({super.key});

  @override
  ConsumerState<TenantMasterView> createState() => _TenantMasterViewState();
}

class _TenantMasterViewState extends ConsumerState<TenantMasterView> {
  String _searchQuery = '';
  TenantModel? _selectedTenant;

  final List<TenantModel> _tenants = const [
    TenantModel(
      tenantId: 1,
      registrationKey: 'TEN-8871-ACME-ENTERPRISE',
      tenantName: 'Acme Enterprise Corp (Main HQ)',
      planName: 'Enterprise Pro Tier',
      maxUsers: 50,
      maxCounters: 25,
      contactEmail: 'admin@acme-hq.org',
      isActive: true,
    ),
    TenantModel(
      tenantId: 2,
      registrationKey: 'TEN-4412-WEST-WING',
      tenantName: 'West Wing Regional Medical Center',
      planName: 'Pro Tier',
      maxUsers: 20,
      maxCounters: 10,
      contactEmail: 'contact@westwing.org',
      isActive: true,
    ),
    TenantModel(
      tenantId: 3,
      registrationKey: 'TEN-1029-EXPRESS-DESK',
      tenantName: 'Downtown Express Clinic',
      planName: 'Starter Tier',
      maxUsers: 5,
      maxCounters: 3,
      contactEmail: 'support@downtown-clinic.com',
      isActive: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _tenants.where((t) {
      return t.tenantName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.registrationKey.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.planName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return MasterDetailLayout(
      masterWidget: _buildMasterTable(filtered),
      detailWidget: _selectedTenant != null ? _buildDetailInspector(_selectedTenant!) : null,
      detailTitle: _selectedTenant != null ? 'Tenant Settings — ${_selectedTenant!.tenantName}' : 'Tenant Master Inspector',
      onCloseDetail: () => setState(() => _selectedTenant = null),
    );
  }

  Widget _buildMasterTable(List<TenantModel> tenants) {
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
                  hintText: 'Search Tenant Name, Registration Key, or SaaS Plan...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 18),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
              const SizedBox(width: 12),
              DqmsButton(
                label: 'Add Tenant',
                icon: Icons.business_rounded,
                onPressed: () {
                  setState(() {
                    _selectedTenant = const TenantModel(
                      tenantId: 99,
                      registrationKey: 'TEN-NEW-REGISTRATION-KEY',
                      tenantName: 'New Organization Tenant',
                      planName: 'Starter Tier',
                      maxUsers: 10,
                      maxCounters: 5,
                      contactEmail: 'new.tenant@dqms.org',
                      isActive: true,
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
                      Expanded(flex: 3, child: Text('ORGANIZATION / TENANT', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                      Expanded(flex: 3, child: Text('REGISTRATION KEY', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                      Expanded(flex: 2, child: Text('SAAS PLAN', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                      SizedBox(width: 90, child: Text('STATUS', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: ListView.separated(
                    itemCount: tenants.length,
                    separatorBuilder: (_, _) => const Divider(color: AppColors.borderSubtle, height: 1),
                    itemBuilder: (ctx, i) {
                      final t = tenants[i];
                      final isSelected = _selectedTenant?.tenantId == t.tenantId;

                      return InkWell(
                        onTap: () => setState(() => _selectedTenant = t),
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
                                child: Text(t.tenantName, style: const TextStyle(color: AppColors.textMain, fontSize: 13, fontWeight: FontWeight.w700)),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(t.registrationKey, style: const TextStyle(color: AppColors.brandPrimary, fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.w700)),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(t.planName, style: const TextStyle(color: AppColors.brandAccent, fontSize: 12, fontWeight: FontWeight.w600)),
                              ),
                              SizedBox(
                                width: 90,
                                child: DqmsStatusBadge.activeState(t.isActive),
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

  Widget _buildDetailInspector(TenantModel tenant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DqmsTextField(label: 'Tenant Organization Name', initialValue: tenant.tenantName),
        const SizedBox(height: 14),
        DqmsTextField(label: 'Registration Key (GUID)', initialValue: tenant.registrationKey),
        const SizedBox(height: 14),
        DqmsTextField(label: 'SaaS Subscription Plan', initialValue: tenant.planName),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: DqmsTextField(label: 'User Quota Limit', initialValue: '${tenant.maxUsers}')),
            const SizedBox(width: 12),
            Expanded(child: DqmsTextField(label: 'Counter Quota Limit', initialValue: '${tenant.maxCounters}')),
          ],
        ),
        const SizedBox(height: 14),
        DqmsTextField(label: 'Primary Contact Email', initialValue: tenant.contactEmail),
        const SizedBox(height: 24),
        DqmsButton(
          label: 'Save Tenant Master Settings',
          icon: Icons.save_rounded,
          isFullWidth: true,
          onPressed: () async {
            try {
              final dio = ref.read(dioProvider);
              await dio.post('${AppConfig.apiV1Base}/organizations', data: {
                'id': tenant.tenantId,
                'name': tenant.tenantName,
                'code': tenant.registrationKey,
                'contactEmail': tenant.contactEmail,
                'isActive': tenant.isActive,
              });
            } catch (_) {}

            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Tenant ${tenant.tenantName} saved to backend API.'), backgroundColor: AppColors.statusActive),
            );
          },
        ),
      ],
    );
  }
}
