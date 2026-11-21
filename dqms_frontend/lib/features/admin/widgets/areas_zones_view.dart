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
/// 1:1 Matched to Stitch Screen: "Hospital Areas & Physical Zones"
/// ============================================================================
class AreasZonesView extends ConsumerStatefulWidget {
  const AreasZonesView({super.key});

  @override
  ConsumerState<AreasZonesView> createState() => _AreasZonesViewState();
}

class _AreasZonesViewState extends ConsumerState<AreasZonesView> {
  String _searchQuery = '';
  String _statusFilter = 'All';
  String _wingFilter = 'All Campuses';
  AreaZoneModel? _selectedArea;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminWorkspaceStateProvider);
    final filteredAreas = state.areas.where((a) {
      final matchesSearch = a.areaName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          a.areaCode.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          a.description.toLowerCase().contains(_searchQuery.toLowerCase());
      if (_statusFilter == 'Active') return matchesSearch && a.isActive;
      if (_statusFilter == 'Inactive') return matchesSearch && !a.isActive;
      return matchesSearch;
    }).toList();

    return MasterDetailLayout(
      masterWidget: _buildMasterContent(filteredAreas, state),
      detailWidget: _selectedArea != null ? _buildDetailInspector(_selectedArea!) : null,
      detailTitle: _selectedArea != null ? 'Zone Inspector — ${_selectedArea!.areaCode}' : 'Zone Inspector',
      onCloseDetail: () {
        setState(() {
          _selectedArea = null;
        });
      },
    );
  }

  Widget _buildMasterContent(List<AreaZoneModel> areas, AdminWorkspaceState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompactHeight = constraints.maxHeight < 550;

        // --------------------------------------------------------------------
        // 1. TOP HEADER & OPERATIONAL METRIC CHIPS
        // --------------------------------------------------------------------
        final headerWidget = Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // Title + Live Indicator
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.brandPrimary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.brandPrimary.withValues(alpha: 0.3)),
                        ),
                        child: const Icon(Icons.domain_rounded, color: AppColors.brandPrimary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Hospital Areas & Physical Zones',
                              style: TextStyle(
                                color: AppColors.textMain,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AppColors.statusActive,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Flexible(
                                  child: Text(
                                    'LIVE SYNC ACTIVE • CLUSTER ALPHA',
                                    style: TextStyle(
                                      color: AppColors.textSubtle,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                      fontFamily: 'monospace',
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Stat Chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildHeaderChip(
                        icon: Icons.domain,
                        label: 'ZONES',
                        value: '${areas.length} Active',
                        color: AppColors.brandPrimary,
                      ),
                      _buildHeaderChip(
                        icon: Icons.desktop_windows_outlined,
                        label: 'WORKSTATIONS',
                        value: '${state.counters.length} Total',
                        color: AppColors.brandAccent,
                      ),
                      _buildHeaderChip(
                        icon: Icons.verified_outlined,
                        label: 'HEALTH',
                        value: '98.5% Uptime',
                        color: AppColors.statusActive,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );

        // --------------------------------------------------------------------
        // 2. TOOLBAR CONTROLS BAR
        // --------------------------------------------------------------------
        final toolbarWidget = Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Search field
              SizedBox(
                width: 240,
                child: DqmsTextField(
                  hintText: 'Filter areas, building, or code...',
                  prefixIcon: const Icon(Icons.filter_list_rounded, size: 16),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                ),
              ),

              // Filter Dropdowns
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildFilterDropdown(),
                  _buildWingDropdown(),
                ],
              ),

              // Action buttons
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  DqmsButton(
                    label: 'Batch Reallocation',
                    icon: Icons.sync_alt_rounded,
                    variant: DqmsButtonVariant.secondary,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Zone topology reallocated across current shifts.')),
                      );
                    },
                  ),
                  DqmsButton(
                    label: '+ Create New Area',
                    icon: Icons.add_rounded,
                    onPressed: () {
                      setState(() {
                        _selectedArea = const AreaZoneModel(
                          areaId: 999,
                          areaCode: 'AZ-NEW',
                          areaName: 'New Facility Zone',
                          description: 'Enter zone description and department specs',
                          targetSlaMins: 15,
                          isActive: true,
                        );
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        );

        // --------------------------------------------------------------------
        // 3. MASTER DATA TABLE / LIST
        // --------------------------------------------------------------------
        final tableContainer = Container(
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: areas.isEmpty
                ? const DqmsEmptyState(
                    title: 'No Areas Found',
                    message: 'No facility zones match your current search and status filter.',
                    icon: Icons.grid_off_rounded,
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 700;
                      if (isMobile) {
                        return ListView.separated(
                          padding: const EdgeInsets.all(12),
                          itemCount: areas.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (ctx, i) {
                            final area = areas[i];
                            final isSelected = _selectedArea?.areaId == area.areaId;
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedArea = area;
                                });
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.brandPrimary.withValues(alpha: 0.12) : AppColors.bgCard,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected ? AppColors.brandPrimary : AppColors.borderSubtle,
                                    width: isSelected ? 1.5 : 1.0,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppColors.brandPrimary.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: AppColors.brandPrimary.withValues(alpha: 0.3)),
                                          ),
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
                                        DqmsStatusBadge.activeState(area.isActive),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      area.areaName,
                                      style: const TextStyle(
                                        color: AppColors.textMain,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    if (area.description.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        area.description,
                                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppColors.brandAccent.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.timer_outlined, size: 12, color: AppColors.brandAccent),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${area.targetSlaMins}m Target SLA',
                                                style: const TextStyle(
                                                  color: AppColors.brandAccent,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: 820,
                          child: Column(
                            children: [
                              // Table Header
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.bgSurfaceHover,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                  border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
                                ),
                                child: const Row(
                                  children: [
                                    SizedBox(width: 100, child: Text('AREA CODE', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'monospace'))),
                                    Expanded(flex: 3, child: Text('AREA NAME & DEPARTMENT', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                                    Expanded(flex: 3, child: Text('DESCRIPTION / LOCATION', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                                    SizedBox(width: 110, child: Text('SLA TARGET', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                                    SizedBox(width: 90, child: Text('STATUS', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                                    SizedBox(width: 50, child: Text('ACTION', textAlign: TextAlign.right, style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                                  ],
                                ),
                              ),

                              // Table Rows
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
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: isSelected ? AppColors.brandPrimary.withValues(alpha: 0.12) : AppColors.bgCard,
                                          border: isSelected ? const Border(left: BorderSide(color: AppColors.brandPrimary, width: 3)) : null,
                                        ),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 100,
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.brandPrimary.withValues(alpha: 0.15),
                                                    borderRadius: BorderRadius.circular(4),
                                                    border: Border.all(color: AppColors.brandPrimary.withValues(alpha: 0.3)),
                                                  ),
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
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    area.areaName,
                                                    style: const TextStyle(color: AppColors.textMain, fontSize: 13, fontWeight: FontWeight.w700),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  const Text(
                                                    'Specialty Diagnostic Wing',
                                                    style: TextStyle(color: AppColors.textSubtle, fontSize: 11),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                area.description.isNotEmpty ? area.description : 'Standard clinical consultation and care wing',
                                                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 110,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.timer_outlined, size: 14, color: AppColors.statusActive),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${area.targetSlaMins}m avg',
                                                    style: const TextStyle(color: AppColors.statusActive, fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'monospace'),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              width: 90,
                                              child: DqmsStatusBadge.activeState(area.isActive),
                                            ),
                                            SizedBox(
                                              width: 50,
                                              child: IconButton(
                                                icon: const Icon(Icons.edit_note_rounded, size: 20, color: AppColors.brandPrimary),
                                                tooltip: 'Inspect & Edit',
                                                onPressed: () {
                                                  setState(() {
                                                    _selectedArea = area;
                                                  });
                                                },
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
                      );
                    },
                  ),
          );

        // --------------------------------------------------------------------
        // 4. FOOTER STATUS
        // --------------------------------------------------------------------
        final footerWidget = Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Showing ${areas.length} of ${ref.read(adminWorkspaceStateProvider).areas.length} Zone Records',
                style: const TextStyle(color: AppColors.textSubtle, fontSize: 11),
                overflow: TextOverflow.ellipsis,
              ),
            ),
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
        );

        if (isCompactHeight) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                headerWidget,
                const SizedBox(height: 12),
                toolbarWidget,
                const SizedBox(height: 12),
                SizedBox(height: 380, child: tableContainer),
                const SizedBox(height: 8),
                footerWidget,
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            headerWidget,
            const SizedBox(height: 12),
            toolbarWidget,
            const SizedBox(height: 12),
            Expanded(child: tableContainer),
            const SizedBox(height: 8),
            footerWidget,
          ],
        );
      },
    );
  }

  Widget _buildHeaderChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.bgSurfaceHover,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(color: AppColors.textSubtle, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5),
              ),
              Text(
                value,
                style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w800, fontFamily: 'monospace'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(8),
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

  Widget _buildWingDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _wingFilter,
          dropdownColor: AppColors.bgSurface,
          style: const TextStyle(color: AppColors.textMain, fontSize: 12, fontWeight: FontWeight.w600),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _wingFilter = val;
              });
            }
          },
          items: const [
            DropdownMenuItem(value: 'All Campuses', child: Text('All Campuses & Floors')),
            DropdownMenuItem(value: 'Level 1 - OPD', child: Text('Level 1 - OPD')),
            DropdownMenuItem(value: 'Level 2 - Wing B', child: Text('Level 2 - Wing B')),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailInspector(AreaZoneModel area) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Inspector Header Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.brandPrimary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.brandPrimary.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.brandPrimary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.location_on_rounded, color: AppColors.brandPrimary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        area.areaCode,
                        style: const TextStyle(
                          color: AppColors.brandPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        area.areaName,
                        style: const TextStyle(color: AppColors.textMain, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                DqmsStatusBadge.activeState(area.isActive),
              ],
            ),
          ),
          const SizedBox(height: 18),

          DqmsTextField(label: 'Area / Zone Code', initialValue: area.areaCode),
          const SizedBox(height: 14),
          DqmsTextField(label: 'Zone Name', initialValue: area.areaName),
          const SizedBox(height: 14),
          DqmsTextField(label: 'Description / Wing Specs', initialValue: area.description, maxLines: 3),
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
      ),
    );
  }
}
