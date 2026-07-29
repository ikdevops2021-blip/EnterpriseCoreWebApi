import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/admin_models.dart';
import '../providers/admin_providers.dart';

/// ============================================================================
/// DQMS DESIGN TOKENS — Glassmorphism + Dark Mode (OLED)
/// ============================================================================
class DqmsColors {
  static const Color background = Color(0xFF0D1117);
  static const Color surface = Color(0xFF161B22);
  static const Color surfaceLight = Color(0xFF21262D);
  static const Color accent = Color(0xFF58A6FF);
  static const Color accentGreen = Color(0xFF3FB950);
  static const Color accentRed = Color(0xFFF85149);
  static const Color accentPurple = Color(0xFFBC8CFF);
  static const Color accentOrange = Color(0xFFD29922);
  static const Color textPrimary = Color(0xFFE6EDF3);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color border = Color(0xFF30363D);
}

/// ============================================================================
/// STAGE 1: ADMIN PANEL — Main Shell with NavigationRail
/// ============================================================================
class AdminPanelScreen extends ConsumerStatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  ConsumerState<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends ConsumerState<AdminPanelScreen> {
  int _selectedIndex = 0;

  static const _tabs = [
    _TabInfo(icon: Icons.location_city_rounded, label: 'Areas / Zones'),
    _TabInfo(icon: Icons.account_tree_rounded, label: 'Process Pipelines'),
    _TabInfo(icon: Icons.tv_rounded, label: 'Display Templates'),
    _TabInfo(icon: Icons.point_of_sale_rounded, label: 'Counters'),
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 960;

    return Scaffold(
      backgroundColor: DqmsColors.background,
      appBar: AppBar(
        backgroundColor: DqmsColors.surface,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF58A6FF), Color(0xFFBC8CFF)]),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('DQMS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
            ),
            const SizedBox(width: 12),
            const Text('Admin Master Setup', style: TextStyle(color: DqmsColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 18)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: DqmsColors.accentGreen.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('Stage 1', style: TextStyle(color: DqmsColors.accentGreen, fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
      body: Row(
        children: [
          if (isWide)
            Container(
              width: 220,
              decoration: const BoxDecoration(
                color: DqmsColors.surface,
                border: Border(right: BorderSide(color: DqmsColors.border, width: 1)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  ...List.generate(_tabs.length, (i) => _buildNavItem(i)),
                ],
              ),
            ),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: const [
                AreaMasterView(),
                ProcessMasterView(),
                DisplayTemplateMasterView(),
                CounterMasterView(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isWide
          ? null
          : BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (i) => setState(() => _selectedIndex = i),
              backgroundColor: DqmsColors.surface,
              selectedItemColor: DqmsColors.accent,
              unselectedItemColor: DqmsColors.textSecondary,
              type: BottomNavigationBarType.fixed,
              items: _tabs
                  .map((t) => BottomNavigationBarItem(icon: Icon(t.icon), label: t.label))
                  .toList(),
            ),
    );
  }

  Widget _buildNavItem(int index) {
    final isSelected = _selectedIndex == index;
    final tab = _tabs[index];
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? DqmsColors.accent.withOpacity(0.1) : Colors.transparent,
          border: Border(left: BorderSide(color: isSelected ? DqmsColors.accent : Colors.transparent, width: 3)),
        ),
        child: Row(
          children: [
            Icon(tab.icon, color: isSelected ? DqmsColors.accent : DqmsColors.textSecondary, size: 20),
            const SizedBox(width: 12),
            Text(tab.label,
                style: TextStyle(
                  color: isSelected ? DqmsColors.textPrimary : DqmsColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 14,
                )),
          ],
        ),
      ),
    );
  }
}

class _TabInfo {
  final IconData icon;
  final String label;
  const _TabInfo({required this.icon, required this.label});
}

/// ============================================================================
/// AREA MASTER VIEW
/// ============================================================================
class AreaMasterView extends ConsumerWidget {
  const AreaMasterView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final areaState = ref.watch(areaListProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, ref, 'Area & Zone Masters', Icons.location_city_rounded, () => _showAreaDialog(context, ref)),
          const SizedBox(height: 20),
          Expanded(
            child: areaState.when(
              loading: () => const Center(child: CircularProgressIndicator(color: DqmsColors.accent)),
              error: (err, _) => _buildErrorState(err.toString()),
              data: (areas) => areas.isEmpty
                  ? _buildEmptyState('No areas configured yet. Create your first area to get started.')
                  : ListView.separated(
                      itemCount: areas.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) => _buildAreaCard(areas[i]),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAreaCard(AreaDto area) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DqmsColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DqmsColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [DqmsColors.accent.withOpacity(0.3), DqmsColors.accentPurple.withOpacity(0.2)]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Text(area.areaCode, style: const TextStyle(color: DqmsColors.accent, fontWeight: FontWeight.w700, fontSize: 12))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(area.areaName, style: const TextStyle(color: DqmsColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 4),
                Text(area.description ?? 'Location ID: ${area.locationId}', style: const TextStyle(color: DqmsColors.textSecondary, fontSize: 13)),
              ],
            ),
          ),
          _buildStatusChip(area.isActive),
        ],
      ),
    );
  }

  void _showAreaDialog(BuildContext context, WidgetRef ref) {
    final codeCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: DqmsColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Create Area / Zone', style: TextStyle(color: DqmsColors.textPrimary)),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(codeCtrl, 'Area Code', 'e.g. Z-01'),
              const SizedBox(height: 12),
              _buildTextField(nameCtrl, 'Area Name', 'e.g. Radiology Zone B'),
              const SizedBox(height: 12),
              _buildTextField(descCtrl, 'Description (Optional)', 'e.g. Imaging & Diagnostics'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: DqmsColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: DqmsColors.accent, foregroundColor: Colors.white),
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
            child: const Text('Save Area'),
          ),
        ],
      ),
    );
  }
}

/// ============================================================================
/// PROCESS MASTER VIEW
/// ============================================================================
class ProcessMasterView extends ConsumerWidget {
  const ProcessMasterView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final processState = ref.watch(processListProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, ref, 'Process Pipeline & SLA TAT Masters', Icons.account_tree_rounded, null),
          const SizedBox(height: 20),
          Expanded(
            child: processState.when(
              loading: () => const Center(child: CircularProgressIndicator(color: DqmsColors.accent)),
              error: (err, _) => _buildErrorState(err.toString()),
              data: (processes) => processes.isEmpty
                  ? _buildEmptyState('No process pipelines configured yet.')
                  : ListView.separated(
                      itemCount: processes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) => _buildProcessCard(processes[i]),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessCard(ProcessDto proc) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DqmsColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DqmsColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [DqmsColors.accentPurple.withOpacity(0.3), DqmsColors.accent.withOpacity(0.2)]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Text(proc.prefix, style: const TextStyle(color: DqmsColors.accentPurple, fontWeight: FontWeight.w800, fontSize: 18))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(proc.processName, style: const TextStyle(color: DqmsColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildMetaChip(Icons.timer_outlined, '${proc.targetTATMinutes} min TAT'),
                    const SizedBox(width: 8),
                    _buildMetaChip(Icons.call_split_rounded, proc.allowSubTokens ? 'Sub-Tokens: ON' : 'Sub-Tokens: OFF'),
                  ],
                ),
              ],
            ),
          ),
          _buildStatusChip(proc.isActive),
        ],
      ),
    );
  }
}

/// ============================================================================
/// DISPLAY TEMPLATE VIEW (Placeholder)
/// ============================================================================
class DisplayTemplateMasterView extends StatelessWidget {
  const DisplayTemplateMasterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: _buildEmptyState('Display Template configuration will be available in a future update.\nTemplate types: GridView, Split-Screen Video, High-Density List, Audio-Visual Banner.'),
    );
  }
}

/// ============================================================================
/// COUNTER MASTER VIEW (Placeholder)
/// ============================================================================
class CounterMasterView extends StatelessWidget {
  const CounterMasterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: _buildEmptyState('Counter/Window assignment configuration will be available in a future update.'),
    );
  }
}

/// ============================================================================
/// SHARED UI HELPERS
/// ============================================================================
Widget _buildHeader(BuildContext context, WidgetRef ref, String title, IconData icon, VoidCallback? onAdd) {
  return Row(
    children: [
      Icon(icon, color: DqmsColors.accent, size: 24),
      const SizedBox(width: 10),
      Text(title, style: const TextStyle(color: DqmsColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
      const Spacer(),
      if (onAdd != null)
        ElevatedButton.icon(
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Add New'),
          style: ElevatedButton.styleFrom(
            backgroundColor: DqmsColors.accent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: onAdd,
        ),
    ],
  );
}

Widget _buildStatusChip(bool isActive) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: isActive ? DqmsColors.accentGreen.withOpacity(0.12) : DqmsColors.accentRed.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      isActive ? 'Active' : 'Deactive',
      style: TextStyle(color: isActive ? DqmsColors.accentGreen : DqmsColors.accentRed, fontSize: 12, fontWeight: FontWeight.w600),
    ),
  );
}

Widget _buildMetaChip(IconData icon, String label) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: DqmsColors.surfaceLight,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: DqmsColors.textSecondary, size: 14),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: DqmsColors.textSecondary, fontSize: 12)),
      ],
    ),
  );
}

Widget _buildEmptyState(String message) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.inbox_rounded, color: DqmsColors.textSecondary.withOpacity(0.4), size: 64),
        const SizedBox(height: 16),
        Text(message, textAlign: TextAlign.center, style: const TextStyle(color: DqmsColors.textSecondary, fontSize: 14)),
      ],
    ),
  );
}

Widget _buildErrorState(String error) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline_rounded, color: DqmsColors.accentRed, size: 48),
        const SizedBox(height: 16),
        Text('Error: $error', style: const TextStyle(color: DqmsColors.accentRed, fontSize: 14)),
      ],
    ),
  );
}

Widget _buildTextField(TextEditingController controller, String label, String hint) {
  return TextField(
    controller: controller,
    style: const TextStyle(color: DqmsColors.textPrimary),
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: DqmsColors.textSecondary),
      hintStyle: TextStyle(color: DqmsColors.textSecondary.withOpacity(0.5)),
      filled: true,
      fillColor: DqmsColors.surfaceLight,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: DqmsColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: DqmsColors.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: DqmsColors.accent)),
    ),
  );
}
