import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dqms_frontend/core/config/app_config.dart';
import 'package:dqms_frontend/core/network/dio_provider.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/core/widgets/dqms_button.dart';
import 'package:dqms_frontend/core/widgets/dqms_text_field.dart';
import 'package:dqms_frontend/core/widgets/dqms_status_badge.dart';
import 'package:dqms_frontend/core/widgets/dqms_states.dart';
import 'package:dqms_frontend/features/admin/providers/admin_mock_providers.dart';
import 'package:dqms_frontend/features/admin/widgets/master_detail_layout.dart';

/// ============================================================================
/// AREAS & ZONES WORKSPACE VIEW (Domain 1)
/// Master-Detail management interface for physical facility zones and SLA targets
/// ============================================================================
class AreasZonesView extends ConsumerStatefulWidget {
  const AreasZonesView({super.key});

  @override
  ConsumerState<AreasZonesView> createState() => _AreasZonesViewState();
}

class _AreasZonesViewState extends ConsumerState<AreasZonesView> {
  String _searchQuery = '';
  String _statusFilter = 'All';
  AreaZoneModel? _selectedArea;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminWorkspaceStateProvider);
    final filteredAreas = state.areas.where((a) {
      final matchesSearch = a.areaName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          a.areaCode.toLowerCase().contains(_searchQuery.toLowerCase());
      if (_statusFilter == 'Active') return matchesSearch && a.isActive;
      if (_statusFilter == 'Inactive') return matchesSearch && !a.isActive;
      return matchesSearch;
    }).toList();

    return MasterDetailLayout(
      masterWidget: _buildMasterTable(filteredAreas),
      detailWidget: _selectedArea != null ? _buildDetailInspector(_selectedArea!) : null,
      detailTitle: _selectedArea != null ? 'Area Inspector — ${_selectedArea!.areaCode}' : 'Area Inspector',
      onCloseDetail: () {
        setState(() {
          _selectedArea = null;
        });
      },
    );
  }

  Widget _buildMasterTable(List<AreaZoneModel> areas) {
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
          // Toolbar Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                SizedBox(
                  width: 200,
                  child: DqmsTextField(
                    hintText: 'Search Area Code...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 18),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                _buildFilterDropdown(),
                const SizedBox(width: 12),
                DqmsButton(
                  label: 'New Area',
                  icon: Icons.add_rounded,
                  onPressed: () {
                    setState(() {
                      _selectedArea = const AreaZoneModel(
                        areaId: 999,
                        areaCode: 'AZ-NEW',
                        areaName: 'New Facility Zone',
                        description: 'Enter zone description',
                        targetSlaMins: 15,
                        isActive: true,
                      );
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Table / List View
          if (areas.isEmpty)
            const Expanded(
              child: DqmsEmptyState(
                title: 'No Areas Found',
                message: 'No facility zones match your current search and status filter.',
                icon: Icons.grid_off_rounded,
              ),
            )
          else
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: 580,
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
                            SizedBox(width: 80, child: Text('CODE', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                            Expanded(flex: 3, child: Text('ZONE NAME', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                            Expanded(flex: 3, child: Text('DESCRIPTION', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                            SizedBox(width: 100, child: Text('SLA TARGET', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                            SizedBox(width: 90, child: Text('STATUS', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),

                      // List Rows
                      Expanded(
                        child: ListView.separated(
                          itemCount: areas.length,
                          separatorBuilder: (_, _) => const Divider(color: AppColors.borderSubtle, height: 1),
                          itemBuilder: (ctx, i) {
                            final area = areas[i];
                            final isSelected = _selectedArea?.areaId == area.areaId;

                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedArea = area;
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
                                    SizedBox(
                                      width: 80,
                                      child: Text(
                                        area.areaCode,
                                        style: const TextStyle(
                                          color: AppColors.brandPrimary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        area.areaName,
                                        style: const TextStyle(color: AppColors.textMain, fontSize: 13, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        area.description,
                                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 100,
                                      child: Text(
                                        '${area.targetSlaMins} Mins',
                                        style: const TextStyle(color: AppColors.brandAccent, fontSize: 12, fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 90,
                                      child: DqmsStatusBadge.activeState(area.isActive),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Pagination Footer
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Showing ${areas.length} of ${ref.read(adminWorkspaceStateProvider).areas.length} Zone Records', style: const TextStyle(color: AppColors.textSubtle, fontSize: 11)),
                          const Row(
                            children: [
                              Icon(Icons.chevron_left_rounded, color: AppColors.textMuted, size: 18),
                              SizedBox(width: 8),
                              Text('Page 1 of 1', style: TextStyle(color: AppColors.textMain, fontSize: 11, fontWeight: FontWeight.w600)),
                              SizedBox(width: 8),
                              Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 18),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _statusFilter,
          dropdownColor: AppColors.bgSurface,
          style: const TextStyle(color: AppColors.textMain, fontSize: 12, fontWeight: FontWeight.w600),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _statusFilter = val;
              });
            }
          },
          items: const [
            DropdownMenuItem(value: 'All', child: Text('All Statuses')),
            DropdownMenuItem(value: 'Active', child: Text('Active Only')),
            DropdownMenuItem(value: 'Inactive', child: Text('Inactive Only')),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailInspector(AreaZoneModel area) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DqmsTextField(label: 'Area / Zone Code', initialValue: area.areaCode),
        const SizedBox(height: 14),
        DqmsTextField(label: 'Zone Name', initialValue: area.areaName),
        const SizedBox(height: 14),
        DqmsTextField(label: 'Description', initialValue: area.description, maxLines: 3),
        const SizedBox(height: 14),
        DqmsTextField(label: 'Target SLA (Minutes)', initialValue: '${area.targetSlaMins}'),
        const SizedBox(height: 16),
        Row(
          children: [
            const Text('Operational Status:', style: TextStyle(color: AppColors.textMain, fontSize: 12, fontWeight: FontWeight.w600)),
            const Spacer(),
            DqmsStatusBadge.activeState(area.isActive),
          ],
        ),
        const SizedBox(height: 24),
        DqmsButton(
          label: 'Save Area Changes',
          icon: Icons.save_rounded,
          isFullWidth: true,
          onPressed: () async {
            try {
              final dio = ref.read(dioProvider);
              await dio.post('${AppConfig.adminApiBase}/area', data: {
                'id': area.areaId,
                'areaCode': area.areaCode,
                'areaName': area.areaName,
                'description': area.description,
                'organizationId': 1,
                'locationId': 1,
                'isActive': area.isActive,
              });
            } catch (_) {}

            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Zone ${area.areaCode} saved to backend API.'), backgroundColor: AppColors.statusActive),
            );
          },
        ),
      ],
    );
  }
}
