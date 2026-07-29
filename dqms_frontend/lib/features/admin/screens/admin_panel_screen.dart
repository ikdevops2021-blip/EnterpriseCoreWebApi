import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/admin_models.dart';
import '../../customer/screens/kiosk_ticket_screen.dart';
import '../../customer/screens/waiting_room_display_screen.dart';
import '../../staff/screens/counter_operator_screen.dart';
import '../providers/admin_providers.dart';

/// ============================================================================
/// DQMS ENTERPRISE DESIGN TOKENS (Per UI_UX_DESIGN_SPEC.md)
/// Aesthetic: Command Center | Precision | Clarity | Restrained Palette
/// ============================================================================
class DqmsTheme {
  static const Color bgCanvas = Color(0xFF090D11);
  static const Color bgSurface = Color(0xFF12171F);
  static const Color bgSurfaceHover = Color(0xFF1A212B);
  static const Color bgHeader = Color(0xFF0E131A);
  
  static const Color borderSubtle = Color(0xFF222B36);
  static const Color borderFocus = Color(0xFF2F81F7);

  static const Color brandPrimary = Color(0xFF2F81F7);
  static const Color statusActive = Color(0xFF238636);
  static const Color statusDeactive = Color(0xFFDA3633);
  static const Color statusWarning = Color(0xFFD29922);
  static const Color statusSpecial = Color(0xFF8957E5);

  static const Color textMain = Color(0xFFF0F6FC);
  static const Color textMuted = Color(0xFF8B949E);
  static const Color textSubtle = Color(0xFF6E7681);
}

/// ============================================================================
/// STAGE 1: ADMIN COMMAND CENTER PANEL
/// ============================================================================
class AdminPanelScreen extends ConsumerStatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  ConsumerState<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends ConsumerState<AdminPanelScreen> {
  int _selectedTabIndex = 0;

  static const _navItems = [
    _NavItem(icon: Icons.grid_view_rounded, label: 'Areas & Zones', count: '12'),
    _NavItem(icon: Icons.account_tree_outlined, label: 'Process Pipelines', count: '8'),
    _NavItem(icon: Icons.tv_rounded, label: 'Display Templates', count: '4'),
    _NavItem(icon: Icons.desk_rounded, label: 'Counter Stations', count: '16'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      backgroundColor: DqmsTheme.bgCanvas,
      body: Column(
        children: [
          _buildTopCommandHeader(context),
          Expanded(
            child: Row(
              children: [
                if (isDesktop) _buildSidebarNav(),
                Expanded(
                  child: Container(
                    color: DqmsTheme.bgCanvas,
                    child: IndexedStack(
                      index: _selectedTabIndex,
                      children: const [
                        AreaMasterTableView(),
                        ProcessMasterTableView(),
                        DisplayTemplateView(),
                        CounterStationView(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isDesktop
          ? null
          : BottomNavigationBar(
              currentIndex: _selectedTabIndex,
              onTap: (i) => setState(() => _selectedTabIndex = i),
              backgroundColor: DqmsTheme.bgSurface,
              selectedItemColor: DqmsTheme.brandPrimary,
              unselectedItemColor: DqmsTheme.textMuted,
              type: BottomNavigationBarType.fixed,
              items: _navItems
                  .map((t) => BottomNavigationBarItem(icon: Icon(t.icon), label: t.label))
                  .toList(),
            ),
    );
  }

  /// Top Operational Header Bar
  Widget _buildTopCommandHeader(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: DqmsTheme.bgHeader,
        border: Border(bottom: BorderSide(color: DqmsTheme.borderSubtle, width: 1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: DqmsTheme.brandPrimary.withValues(alpha: 0.15),
              border: Border.all(color: DqmsTheme.brandPrimary.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text('DQMS ENTERPRISE', style: TextStyle(color: DqmsTheme.brandPrimary, fontWeight: FontWeight.w700, fontSize: 11, letterSpacing: 1.2)),
          ),
          const SizedBox(width: 16),
          const Icon(Icons.chevron_right_rounded, color: DqmsTheme.textSubtle, size: 18),
          const SizedBox(width: 8),
          const Text('Admin Master Configuration', style: TextStyle(color: DqmsTheme.textMain, fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: DqmsTheme.statusActive.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: DqmsTheme.statusActive.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.fiber_manual_record, color: DqmsTheme.statusActive, size: 8),
                SizedBox(width: 5),
                Text('LIVE SYNC • Stage 1', style: TextStyle(color: DqmsTheme.statusActive, fontSize: 10, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: DqmsTheme.textMuted, size: 18),
            onPressed: () {
              ref.read(areaListProvider.notifier).refresh();
              ref.read(processListProvider.notifier).refresh();
              ref.read(counterListProvider.notifier).refresh();
              ref.read(templateListProvider.notifier).refresh();
            },
            tooltip: 'Refresh Masters',
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.desk_rounded, size: 14),
            label: const Text('Stage 2 Operator', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
            style: OutlinedButton.styleFrom(
              foregroundColor: DqmsTheme.brandPrimary,
              side: const BorderSide(color: DqmsTheme.brandPrimary),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CounterOperatorScreen()));
            },
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.tv_rounded, size: 14),
            label: const Text('Stage 3 TV Display', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
            style: OutlinedButton.styleFrom(
              foregroundColor: DqmsTheme.statusSpecial,
              side: const BorderSide(color: DqmsTheme.statusSpecial),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const WaitingRoomDisplayScreen()));
            },
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.touch_app_rounded, size: 14),
            label: const Text('Stage 3 Kiosk', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
            style: OutlinedButton.styleFrom(
              foregroundColor: DqmsTheme.statusActive,
              side: const BorderSide(color: DqmsTheme.statusActive),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const KioskTicketScreen()));
            },
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: DqmsTheme.bgSurface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: DqmsTheme.borderSubtle),
            ),
            child: const Row(
              children: [
                Icon(Icons.business_rounded, color: DqmsTheme.textMuted, size: 14),
                SizedBox(width: 6),
                Text('Main Headquarters', style: TextStyle(color: DqmsTheme.textMuted, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Lightweight Professional Sidebar
  Widget _buildSidebarNav() {
    return Container(
      width: 240,
      decoration: const BoxDecoration(
        color: DqmsTheme.bgSurface,
        border: Border(right: BorderSide(color: DqmsTheme.borderSubtle, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Text('SETUP MASTERS', style: TextStyle(color: DqmsTheme.textSubtle, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.0)),
          ),
          ...List.generate(_navItems.length, (i) {
            final isSelected = _selectedTabIndex == i;
            final item = _navItems[i];
            return InkWell(
              onTap: () => setState(() => _selectedTabIndex = i),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                decoration: BoxDecoration(
                  color: isSelected ? DqmsTheme.brandPrimary.withValues(alpha: 0.12) : Colors.transparent,
                  border: Border(left: BorderSide(color: isSelected ? DqmsTheme.brandPrimary : Colors.transparent, width: 3)),
                ),
                child: Row(
                  children: [
                    Icon(item.icon, color: isSelected ? DqmsTheme.brandPrimary : DqmsTheme.textMuted, size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.label,
                        style: TextStyle(
                          color: isSelected ? DqmsTheme.textMain : DqmsTheme.textMuted,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String count;
  const _NavItem({required this.icon, required this.label, required this.count});
}

/// ============================================================================
/// 1. AREA MASTER TABLE VIEW (Data Table Style per UI_UX_DESIGN_SPEC.md)
/// ============================================================================
class AreaMasterTableView extends ConsumerWidget {
  const AreaMasterTableView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final areaState = ref.watch(areaListProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Metric Summary Bar
          _buildKpiSummaryBar([
            _KpiItem(title: 'Total Areas', value: areaState.asData?.value.length.toString() ?? '0', icon: Icons.grid_view_rounded),
            _KpiItem(title: 'Active Zones', value: areaState.asData?.value.where((a) => a.isActive).length.toString() ?? '0', icon: Icons.check_circle_outline_rounded),
            const _KpiItem(title: 'Operational SLA', value: '99.8%', icon: Icons.speed_rounded),
          ]),
          const SizedBox(height: 20),

          // Action Toolbar Bar
          Row(
            children: [
              const Text('Areas & Zones Directory', style: TextStyle(color: DqmsTheme.textMain, fontSize: 18, fontWeight: FontWeight.w700)),
              const Spacer(),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Create Area'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DqmsTheme.brandPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                onPressed: () => _showCreateAreaModal(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Structured Data Table Container
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: DqmsTheme.bgSurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: DqmsTheme.borderSubtle),
              ),
              child: areaState.when(
                loading: () => const Center(child: CircularProgressIndicator(color: DqmsTheme.brandPrimary)),
                error: (err, _) => Center(child: Text('Error loading areas: $err', style: const TextStyle(color: DqmsTheme.statusDeactive))),
                data: (areas) => areas.isEmpty
                    ? _buildEmptyState('No areas configured in database. Click "Create Area" to add your first zone.')
                    : Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: const BoxDecoration(
                              color: DqmsTheme.bgHeader,
                              border: Border(bottom: BorderSide(color: DqmsTheme.borderSubtle)),
                            ),
                            child: const Row(
                              children: [
                                SizedBox(width: 80, child: Text('CODE', style: TextStyle(color: DqmsTheme.textSubtle, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8))),
                                Expanded(flex: 3, child: Text('AREA / ZONE NAME', style: TextStyle(color: DqmsTheme.textSubtle, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8))),
                                Expanded(flex: 2, child: Text('DESCRIPTION', style: TextStyle(color: DqmsTheme.textSubtle, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8))),
                                SizedBox(width: 100, child: Text('STATUS', style: TextStyle(color: DqmsTheme.textSubtle, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8))),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.separated(
                              itemCount: areas.length,
                              separatorBuilder: (_, __) => const Divider(color: DqmsTheme.borderSubtle, height: 1),
                              itemBuilder: (ctx, i) {
                                final area = areas[i];
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                  color: DqmsTheme.bgSurface,
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 80,
                                        child: Text(area.areaCode, style: const TextStyle(color: DqmsTheme.brandPrimary, fontWeight: FontWeight.w700, fontSize: 13)),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(area.areaName, style: const TextStyle(color: DqmsTheme.textMain, fontWeight: FontWeight.w600, fontSize: 14)),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(area.description ?? 'Location ID: ${area.locationId}', style: const TextStyle(color: DqmsTheme.textMuted, fontSize: 13)),
                                      ),
                                      SizedBox(
                                        width: 100,
                                        child: _buildStatusPill(area.isActive),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
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

  void _showCreateAreaModal(BuildContext context, WidgetRef ref) {
    final codeCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: DqmsTheme.bgSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: DqmsTheme.borderSubtle)),
        title: const Text('Create Area / Zone Master', style: TextStyle(color: DqmsTheme.textMain, fontWeight: FontWeight.w700, fontSize: 16)),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInputField(codeCtrl, 'Area Code', 'e.g. Z-01'),
              const SizedBox(height: 12),
              _buildInputField(nameCtrl, 'Area Name', 'e.g. Radiology Zone B'),
              const SizedBox(height: 12),
              _buildInputField(descCtrl, 'Description', 'e.g. Diagnostic & Imaging Wing'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: DqmsTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: DqmsTheme.brandPrimary, foregroundColor: Colors.white),
            onPressed: () {
              ref.read(areaListProvider.notifier).saveArea(AreaDto(
                    id: 0,
                    areaCode: codeCtrl.text,
                    organizationId: 1,
                    locationId: 1,
                    areaName: nameCtrl.text,
                    description: descCtrl.text.isEmpty ? null : descCtrl.text,
                    isActive: true,
                  ));
              Navigator.pop(ctx);
            },
            child: const Text('Save Master'),
          ),
        ],
      ),
    );
  }
}

/// ============================================================================
/// 2. PROCESS MASTER TABLE VIEW
/// ============================================================================
class ProcessMasterTableView extends ConsumerWidget {
  const ProcessMasterTableView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final processState = ref.watch(processListProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildKpiSummaryBar([
            _KpiItem(title: 'Active Processes', value: processState.asData?.value.length.toString() ?? '0', icon: Icons.account_tree_outlined),
            const _KpiItem(title: 'Avg Target SLA TAT', value: '15 Mins', icon: Icons.timer_outlined),
            const _KpiItem(title: 'Sub-Tokens Allowed', value: 'Enabled', icon: Icons.call_split_rounded),
          ]),
          const SizedBox(height: 20),

          Row(
            children: [
              const Text('Process Pipelines & SLA Target Masters', style: TextStyle(color: DqmsTheme.textMain, fontSize: 18, fontWeight: FontWeight.w700)),
              const Spacer(),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Create Process'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DqmsTheme.brandPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                onPressed: () => _showCreateProcessModal(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: DqmsTheme.bgSurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: DqmsTheme.borderSubtle),
              ),
              child: processState.when(
                loading: () => const Center(child: CircularProgressIndicator(color: DqmsTheme.brandPrimary)),
                error: (err, _) => Center(child: Text('Error loading processes: $err', style: const TextStyle(color: DqmsTheme.statusDeactive))),
                data: (processes) => processes.isEmpty
                    ? _buildEmptyState('No process pipelines configured yet.')
                    : Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: const BoxDecoration(
                              color: DqmsTheme.bgHeader,
                              border: Border(bottom: BorderSide(color: DqmsTheme.borderSubtle)),
                            ),
                            child: const Row(
                              children: [
                                SizedBox(width: 70, child: Text('PREFIX', style: TextStyle(color: DqmsTheme.textSubtle, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8))),
                                Expanded(flex: 3, child: Text('PROCESS NAME', style: TextStyle(color: DqmsTheme.textSubtle, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8))),
                                Expanded(flex: 2, child: Text('TARGET TAT (SLA)', style: TextStyle(color: DqmsTheme.textSubtle, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8))),
                                SizedBox(width: 100, child: Text('STATUS', style: TextStyle(color: DqmsTheme.textSubtle, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8))),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.separated(
                              itemCount: processes.length,
                              separatorBuilder: (_, __) => const Divider(color: DqmsTheme.borderSubtle, height: 1),
                              itemBuilder: (ctx, i) {
                                final proc = processes[i];
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                  color: DqmsTheme.bgSurface,
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 70,
                                        child: Text(proc.prefix, style: const TextStyle(color: DqmsTheme.statusSpecial, fontWeight: FontWeight.w800, fontSize: 16)),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(proc.processName, style: const TextStyle(color: DqmsTheme.textMain, fontWeight: FontWeight.w600, fontSize: 14)),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text('${proc.targetTATMinutes} Minutes SLA', style: const TextStyle(color: DqmsTheme.statusWarning, fontSize: 13, fontWeight: FontWeight.w500)),
                                      ),
                                      SizedBox(
                                        width: 100,
                                        child: _buildStatusPill(proc.isActive),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
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

  void _showCreateProcessModal(BuildContext context, WidgetRef ref) {
    final codeCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final prefixCtrl = TextEditingController(text: 'A');
    final tatCtrl = TextEditingController(text: '15');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: DqmsTheme.bgSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: DqmsTheme.borderSubtle)),
        title: const Text('Create Process Pipeline', style: TextStyle(color: DqmsTheme.textMain, fontWeight: FontWeight.w700, fontSize: 16)),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInputField(codeCtrl, 'Process Code', 'e.g. PROC-01'),
              const SizedBox(height: 12),
              _buildInputField(nameCtrl, 'Process Name', 'e.g. Consultation Pipeline'),
              const SizedBox(height: 12),
              _buildInputField(prefixCtrl, 'Token Prefix', 'e.g. A, B, C'),
              const SizedBox(height: 12),
              _buildInputField(tatCtrl, 'Target TAT (Minutes)', '15'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: DqmsTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: DqmsTheme.brandPrimary, foregroundColor: Colors.white),
            onPressed: () {
              ref.read(processListProvider.notifier).saveProcess(ProcessDto(
                    id: 0,
                    processCode: codeCtrl.text,
                    organizationId: 1,
                    processName: nameCtrl.text,
                    prefix: prefixCtrl.text.toUpperCase(),
                    targetTATMinutes: int.tryParse(tatCtrl.text) ?? 15,
                    allowSubTokens: true,
                    isActive: true,
                  ));
              Navigator.pop(ctx);
            },
            child: const Text('Save Process'),
          ),
        ],
      ),
    );
  }
}

/// ============================================================================
/// 3. DISPLAY TEMPLATE VIEW
/// ============================================================================
class DisplayTemplateView extends ConsumerWidget {
  const DisplayTemplateView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templateState = ref.watch(templateListProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildKpiSummaryBar([
            _KpiItem(title: 'Configured Layouts', value: templateState.asData?.value.length.toString() ?? '0', icon: Icons.tv_rounded),
            const _KpiItem(title: 'Primary Layout Type', value: 'GridView (21001)', icon: Icons.view_comfy_rounded),
            const _KpiItem(title: 'Audio Visual Alert', value: 'Enabled', icon: Icons.volume_up_rounded),
          ]),
          const SizedBox(height: 20),

          Row(
            children: [
              const Text('Display Templates & Waiting Room TV Layouts', style: TextStyle(color: DqmsTheme.textMain, fontSize: 18, fontWeight: FontWeight.w700)),
              const Spacer(),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Create Template'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DqmsTheme.brandPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                onPressed: () => _showCreateTemplateModal(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: DqmsTheme.bgSurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: DqmsTheme.borderSubtle),
              ),
              child: templateState.when(
                loading: () => const Center(child: CircularProgressIndicator(color: DqmsTheme.brandPrimary)),
                error: (err, _) => Center(child: Text('Error loading templates: $err', style: const TextStyle(color: DqmsTheme.statusDeactive))),
                data: (templates) => templates.isEmpty
                    ? _buildEmptyState('No display templates configured. Click "Create Template" to define a TV screen layout.')
                    : Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: const BoxDecoration(
                              color: DqmsTheme.bgHeader,
                              border: Border(bottom: BorderSide(color: DqmsTheme.borderSubtle)),
                            ),
                            child: const Row(
                              children: [
                                SizedBox(width: 80, child: Text('ID', style: TextStyle(color: DqmsTheme.textSubtle, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8))),
                                Expanded(flex: 3, child: Text('TEMPLATE NAME', style: TextStyle(color: DqmsTheme.textSubtle, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8))),
                                Expanded(flex: 2, child: Text('TYPE (CONFIG PARAMETER)', style: TextStyle(color: DqmsTheme.textSubtle, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8))),
                                SizedBox(width: 100, child: Text('STATUS', style: TextStyle(color: DqmsTheme.textSubtle, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8))),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.separated(
                              itemCount: templates.length,
                              separatorBuilder: (_, __) => const Divider(color: DqmsTheme.borderSubtle, height: 1),
                              itemBuilder: (ctx, i) {
                                final tmpl = templates[i];
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                  color: DqmsTheme.bgSurface,
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 80,
                                        child: Text('#${tmpl.id}', style: const TextStyle(color: DqmsTheme.brandPrimary, fontWeight: FontWeight.w700, fontSize: 13)),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(tmpl.templateName, style: const TextStyle(color: DqmsTheme.textMain, fontWeight: FontWeight.w600, fontSize: 14)),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text('Type Code: ${tmpl.templateType}', style: const TextStyle(color: DqmsTheme.textMuted, fontSize: 13)),
                                      ),
                                      SizedBox(
                                        width: 100,
                                        child: _buildStatusPill(tmpl.isActive),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
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

  void _showCreateTemplateModal(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: DqmsTheme.bgSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: DqmsTheme.borderSubtle)),
        title: const Text('Create Display Template', style: TextStyle(color: DqmsTheme.textMain, fontWeight: FontWeight.w700, fontSize: 16)),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInputField(nameCtrl, 'Template Name', 'e.g. Main Lobby 4K Display'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: DqmsTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: DqmsTheme.brandPrimary, foregroundColor: Colors.white),
            onPressed: () {
              ref.read(templateListProvider.notifier).saveTemplate(DisplayTemplateDto(
                    id: 0,
                    organizationId: 1,
                    templateName: nameCtrl.text,
                    templateType: 21001,
                    isDefault: true,
                    isActive: true,
                  ));
              Navigator.pop(ctx);
            },
            child: const Text('Save Template'),
          ),
        ],
      ),
    );
  }
}

/// ============================================================================
/// 4. COUNTER STATION VIEW
/// ============================================================================
class CounterStationView extends ConsumerWidget {
  const CounterStationView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counterState = ref.watch(counterListProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildKpiSummaryBar([
            _KpiItem(title: 'Configured Counters', value: counterState.asData?.value.length.toString() ?? '0', icon: Icons.desk_rounded),
            const _KpiItem(title: 'Default Status', value: 'Idle (20001)', icon: Icons.hourglass_empty_rounded),
            const _KpiItem(title: 'Operator Hotkeys', value: 'Space / F1-F5', icon: Icons.keyboard_rounded),
          ]),
          const SizedBox(height: 20),

          Row(
            children: [
              const Text('Counter & Window Stations Directory', style: TextStyle(color: DqmsTheme.textMain, fontSize: 18, fontWeight: FontWeight.w700)),
              const Spacer(),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Create Counter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DqmsTheme.brandPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                onPressed: () => _showCreateCounterModal(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: DqmsTheme.bgSurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: DqmsTheme.borderSubtle),
              ),
              child: counterState.when(
                loading: () => const Center(child: CircularProgressIndicator(color: DqmsTheme.brandPrimary)),
                error: (err, _) => Center(child: Text('Error loading counters: $err', style: const TextStyle(color: DqmsTheme.statusDeactive))),
                data: (counters) => counters.isEmpty
                    ? _buildEmptyState('No counter stations configured yet. Click "Create Counter" to assign service windows.')
                    : Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: const BoxDecoration(
                              color: DqmsTheme.bgHeader,
                              border: Border(bottom: BorderSide(color: DqmsTheme.borderSubtle)),
                            ),
                            child: const Row(
                              children: [
                                SizedBox(width: 80, child: Text('NUMBER', style: TextStyle(color: DqmsTheme.textSubtle, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8))),
                                Expanded(flex: 3, child: Text('COUNTER / WINDOW NAME', style: TextStyle(color: DqmsTheme.textSubtle, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8))),
                                Expanded(flex: 2, child: Text('CURRENT STATUS (CONFIGPARAM)', style: TextStyle(color: DqmsTheme.textSubtle, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8))),
                                SizedBox(width: 100, child: Text('STATUS', style: TextStyle(color: DqmsTheme.textSubtle, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8))),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.separated(
                              itemCount: counters.length,
                              separatorBuilder: (_, __) => const Divider(color: DqmsTheme.borderSubtle, height: 1),
                              itemBuilder: (ctx, i) {
                                final ctr = counters[i];
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                  color: DqmsTheme.bgSurface,
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 80,
                                        child: Text('C-${ctr.counterNumber}', style: const TextStyle(color: DqmsTheme.brandPrimary, fontWeight: FontWeight.w800, fontSize: 14)),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(ctr.counterName, style: const TextStyle(color: DqmsTheme.textMain, fontWeight: FontWeight.w600, fontSize: 14)),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text('Status Code: ${ctr.currentStatus}', style: const TextStyle(color: DqmsTheme.textMuted, fontSize: 13)),
                                      ),
                                      SizedBox(
                                        width: 100,
                                        child: _buildStatusPill(ctr.isActive),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
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

  void _showCreateCounterModal(BuildContext context, WidgetRef ref) {
    final numCtrl = TextEditingController();
    final nameCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: DqmsTheme.bgSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: DqmsTheme.borderSubtle)),
        title: const Text('Create Counter Station', style: TextStyle(color: DqmsTheme.textMain, fontWeight: FontWeight.w700, fontSize: 16)),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInputField(numCtrl, 'Counter Number', 'e.g. 01'),
              const SizedBox(height: 12),
              _buildInputField(nameCtrl, 'Counter Name', 'e.g. Window 1 - General Registration'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: DqmsTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: DqmsTheme.brandPrimary, foregroundColor: Colors.white),
            onPressed: () {
              ref.read(counterListProvider.notifier).saveCounter(CounterDto(
                    id: 0,
                    counterCode: 'CTR-${numCtrl.text}',
                    organizationId: 1,
                    locationId: 1,
                    areaId: 1,
                    counterNumber: numCtrl.text,
                    counterName: nameCtrl.text,
                    currentStatus: 20001,
                    isActive: true,
                  ));
              Navigator.pop(ctx);
            },
            child: const Text('Save Counter'),
          ),
        ],
      ),
    );
  }
}

/// ============================================================================
/// REFINED ENTERPRISE UI COMPONENTS (Per UI_UX_DESIGN_SPEC.md)
/// ============================================================================
Widget _buildKpiSummaryBar(List<_KpiItem> items) {
  return Row(
    children: items.map((item) {
      return Expanded(
        child: Container(
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: DqmsTheme.bgSurface,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: DqmsTheme.borderSubtle),
          ),
          child: Row(
            children: [
              Icon(item.icon, color: DqmsTheme.brandPrimary, size: 22),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: const TextStyle(color: DqmsTheme.textSubtle, fontSize: 11, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(item.value, style: const TextStyle(color: DqmsTheme.textMain, fontSize: 18, fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
        ),
      );
    }).toList(),
  );
}

class _KpiItem {
  final String title;
  final String value;
  final IconData icon;
  const _KpiItem({required this.title, required this.value, required this.icon});
}

Widget _buildStatusPill(bool isActive) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: isActive ? DqmsTheme.statusActive.withValues(alpha: 0.15) : DqmsTheme.statusDeactive.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: isActive ? DqmsTheme.statusActive.withValues(alpha: 0.3) : DqmsTheme.statusDeactive.withValues(alpha: 0.3)),
    ),
    child: Text(
      isActive ? 'Active' : 'Deactive',
      textAlign: TextAlign.center,
      style: TextStyle(color: isActive ? DqmsTheme.statusActive : DqmsTheme.statusDeactive, fontSize: 11, fontWeight: FontWeight.w600),
    ),
  );
}

Widget _buildEmptyState(String message) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.inbox_outlined, color: DqmsTheme.textSubtle, size: 48),
        const SizedBox(height: 12),
        Text(message, textAlign: TextAlign.center, style: const TextStyle(color: DqmsTheme.textMuted, fontSize: 13)),
      ],
    ),
  );
}

Widget _buildInputField(TextEditingController controller, String label, String hint) {
  return TextField(
    controller: controller,
    style: const TextStyle(color: DqmsTheme.textMain, fontSize: 13),
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: DqmsTheme.textMuted, fontSize: 12),
      hintStyle: const TextStyle(color: DqmsTheme.textSubtle, fontSize: 12),
      filled: true,
      fillColor: DqmsTheme.bgCanvas,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: DqmsTheme.borderSubtle)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: DqmsTheme.borderSubtle)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: DqmsTheme.brandPrimary)),
    ),
  );
}
