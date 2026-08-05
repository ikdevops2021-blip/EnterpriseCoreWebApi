import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/core/utils/icon_resolver.dart';
import 'package:dqms_frontend/features/admin/providers/navigation_menu_provider.dart';

/// ============================================================================
/// Navigation Menu Manager View
/// Allows administrators to manage the plug-and-play sidebar navigation menu.
/// Menu items are stored in the database and fetched dynamically at runtime.
/// ============================================================================
class NavigationMenuView extends ConsumerStatefulWidget {
  const NavigationMenuView({super.key});

  @override
  ConsumerState<NavigationMenuView> createState() => _NavigationMenuViewState();
}

class _NavigationMenuViewState extends ConsumerState<NavigationMenuView> {
  bool _showInactive = false;

  @override
  Widget build(BuildContext context) {
    final menuAsync = ref.watch(navigationMenuProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ----------------------------------------------------------------
        // Section Header
        // ----------------------------------------------------------------
        _buildSectionHeader(context),
        const SizedBox(height: 16),

        // ----------------------------------------------------------------
        // Info Banner
        // ----------------------------------------------------------------
        _buildInfoBanner(),
        const SizedBox(height: 16),

        // ----------------------------------------------------------------
        // Menu Table
        // ----------------------------------------------------------------
        Expanded(
          child: menuAsync.when(
            loading: () => const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.brandPrimary),
                  SizedBox(height: 16),
                  Text('Loading navigation menus from database...',
                      style: TextStyle(color: AppColors.textSubtle, fontSize: 13)),
                ],
              ),
            ),
            error: (err, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, color: AppColors.statusDeactive, size: 40),
                  const SizedBox(height: 12),
                  Text('Failed to load menus: $err',
                      style: const TextStyle(color: AppColors.statusDeactive, fontSize: 13)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => ref.invalidate(navigationMenuProvider),
                    icon: const Icon(Icons.refresh_rounded, size: 14),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.brandPrimary),
                  ),
                ],
              ),
            ),
            data: (menus) {
              final filtered = _showInactive
                  ? menus
                  : menus.where((m) => m.isActive).toList();

              return Column(
                children: [
                  // Toolbar
                  _buildToolbar(context, menus.length, filtered.length),
                  const SizedBox(height: 12),

                  // Table
                  Expanded(
                    child: _buildMenuTable(context, filtered),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  // ========================================================================
  // Section Header with Add button
  // ========================================================================
  Widget _buildSectionHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.brandPrimary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.menu_rounded, color: AppColors.brandPrimary, size: 20),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Navigation Menu Manager',
                style: TextStyle(
                    color: AppColors.textMain,
                    fontSize: 18,
                    fontWeight: FontWeight.w800)),
            Text('Plug-and-play sidebar module configuration',
                style: TextStyle(
                    color: AppColors.textSubtle,
                    fontSize: 12)),
          ],
        ),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: () => _showMenuEditor(context, null),
          icon: const Icon(Icons.add_rounded, size: 16),
          label: const Text('Add Menu Item', style: TextStyle(fontWeight: FontWeight.w700)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.brandPrimary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        ),
      ],
    );
  }

  // ========================================================================
  // Info Banner explaining the plug-and-play concept
  // ========================================================================
  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.brandPrimary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.brandPrimary.withValues(alpha: 0.25)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.brandPrimary, size: 16),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Menu items are stored in the database and loaded dynamically. '
              'Add, enable, disable, or reorder modules here — no code deployment required. '
              'The sidebar refreshes on the next login or manual refresh.',
              style: TextStyle(
                  color: AppColors.textSubtle,
                  fontSize: 12,
                  height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  // ========================================================================
  // Toolbar: counts + filter toggle + refresh
  // ========================================================================
  Widget _buildToolbar(BuildContext context, int total, int showing) {
    return Row(
      children: [
        // Stats badges
        _statBadge('$total Total', AppColors.textSubtle),
        const SizedBox(width: 8),
        _statBadge('$showing Showing', AppColors.brandPrimary),
        const Spacer(),

        // Show inactive toggle
        Row(
          children: [
            const Text('Show Inactive', style: TextStyle(color: AppColors.textSubtle, fontSize: 12)),
            const SizedBox(width: 6),
            Switch.adaptive(
              value: _showInactive,
              onChanged: (val) => setState(() => _showInactive = val),
              activeTrackColor: AppColors.brandPrimary,
              activeThumbColor: Colors.white,
            ),
          ],
        ),
        const SizedBox(width: 16),

        // Refresh
        OutlinedButton.icon(
          onPressed: () => ref.invalidate(navigationMenuProvider),
          icon: const Icon(Icons.refresh_rounded, size: 14),
          label: const Text('Refresh', style: TextStyle(fontSize: 12)),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textMain,
            side: const BorderSide(color: AppColors.borderSubtle),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _statBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }

  // ========================================================================
  // Main menu table
  // ========================================================================
  Widget _buildMenuTable(BuildContext context, List<NavigationMenuModel> menus) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.bgHeader,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
            ),
            child: const Row(
              children: [
                SizedBox(width: 42, child: Text('#', style: _headerStyle)),
                SizedBox(width: 48, child: Text('Icon', style: _headerStyle)),
                Expanded(flex: 3, child: Text('Title', style: _headerStyle)),
                Expanded(flex: 4, child: Text('Route Path', style: _headerStyle)),
                SizedBox(width: 70, child: Text('Order', style: _headerStyle)),
                SizedBox(width: 80, child: Text('Status', style: _headerStyle)),
                SizedBox(width: 100, child: Text('Actions', style: _headerStyle)),
              ],
            ),
          ),

          // Table Rows
          Expanded(
            child: menus.isEmpty
                ? const Center(
                    child: Text('No menu items found.',
                        style: TextStyle(color: AppColors.textSubtle, fontSize: 13)))
                : ListView.separated(
                    itemCount: menus.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 1, color: AppColors.borderSubtle),
                    itemBuilder: (ctx, i) => _buildMenuRow(ctx, menus[i], i),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuRow(BuildContext context, NavigationMenuModel item, int index) {
    final icon = IconResolver.resolve(item.iconName);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: index.isEven
          ? Colors.transparent
          : AppColors.bgCanvas.withValues(alpha: 0.4),
      child: Row(
        children: [
          // ID
          SizedBox(
            width: 42,
            child: Text('${item.id}',
                style: const TextStyle(
                    color: AppColors.textSubtle, fontSize: 12, fontWeight: FontWeight.w600)),
          ),

          // Icon Preview
          SizedBox(
            width: 48,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.brandPrimary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: AppColors.brandPrimary, size: 16),
            ),
          ),

          // Title
          Expanded(
            flex: 3,
            child: Text(
              item.title,
              style: TextStyle(
                color: item.isActive ? AppColors.textMain : AppColors.textSubtle,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Route Path
          Expanded(
            flex: 4,
            child: Text(
              item.routePath,
              style: const TextStyle(
                  color: AppColors.brandAccent,
                  fontSize: 12,
                  fontFamily: 'monospace'),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Sort Order
          SizedBox(
            width: 70,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.bgCanvas,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Text('${item.sortOrder}',
                    style: const TextStyle(
                        color: AppColors.textMain,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ),
            ),
          ),

          // Status Badge
          SizedBox(
            width: 80,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: item.isActive
                      ? AppColors.statusActive.withValues(alpha: 0.12)
                      : AppColors.statusDeactive.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    color: item.isActive ? AppColors.statusActive : AppColors.statusDeactive,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),

          // Actions
          SizedBox(
            width: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Edit
                IconButton(
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  color: AppColors.brandPrimary,
                  tooltip: 'Edit Menu Item',
                  onPressed: () => _showMenuEditor(context, item),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
                // Toggle Active
                IconButton(
                  icon: Icon(
                    item.isActive ? Icons.toggle_on_rounded : Icons.toggle_off_rounded,
                    size: 20,
                  ),
                  color: item.isActive ? AppColors.statusActive : AppColors.textMuted,
                  tooltip: item.isActive ? 'Deactivate' : 'Activate',
                  onPressed: () => _toggleActive(context, item),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
                // Delete
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 16),
                  color: AppColors.statusDeactive,
                  tooltip: 'Remove from Navigation',
                  onPressed: () => _confirmDelete(context, item),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========================================================================
  // Menu Item Editor Dialog
  // ========================================================================
  void _showMenuEditor(BuildContext context, NavigationMenuModel? existing) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _MenuEditorDialog(
        existing: existing,
        onSave: (model) async {
          final ok = await ref.read(navigationMenuProvider.notifier).saveMenu(model);
          if (!ctx.mounted) return;
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(ok
                ? (existing == null ? '✅ Menu item created!' : '✅ Menu item updated!')
                : '❌ Failed to save. Check API connection.'),
            backgroundColor: ok ? AppColors.statusActive : AppColors.statusDeactive,
          ));
        },
      ),
    );
  }

  // ========================================================================
  // Toggle Active
  // ========================================================================
  Future<void> _toggleActive(BuildContext context, NavigationMenuModel item) async {
    final updated = item.copyWith(isActive: !item.isActive);
    final ok = await ref.read(navigationMenuProvider.notifier).saveMenu(updated);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok
          ? '${item.isActive ? "Deactivated" : "Activated"}: ${item.title}'
          : '❌ Failed to update status.'),
      backgroundColor: ok ? AppColors.brandPrimary : AppColors.statusDeactive,
      duration: const Duration(seconds: 2),
    ));
  }

  // ========================================================================
  // Confirm Delete Dialog
  // ========================================================================
  Future<void> _confirmDelete(BuildContext context, NavigationMenuModel item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.borderSubtle),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.statusDeactive, size: 20),
            SizedBox(width: 8),
            Text('Remove Menu Item', style: TextStyle(color: AppColors.textMain, fontSize: 16)),
          ],
        ),
        content: Text(
          'Are you sure you want to remove "${item.title}" from the navigation?\n\n'
          'This will hide it from the sidebar immediately.',
          style: const TextStyle(color: AppColors.textSubtle, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusDeactive),
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final ok = await ref.read(navigationMenuProvider.notifier).deleteMenu(item.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? '✅ "${item.title}" removed.' : '❌ Failed to remove.'),
        backgroundColor: ok ? AppColors.statusActive : AppColors.statusDeactive,
      ));
    }
  }

  static const TextStyle _headerStyle = TextStyle(
    color: AppColors.textSubtle,
    fontSize: 11,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.5,
  );
}

// ============================================================================
// Menu Editor Dialog — Create / Update
// ============================================================================
class _MenuEditorDialog extends StatefulWidget {
  final NavigationMenuModel? existing;
  final Future<void> Function(NavigationMenuModel) onSave;

  const _MenuEditorDialog({this.existing, required this.onSave});

  @override
  State<_MenuEditorDialog> createState() => _MenuEditorDialogState();
}

class _MenuEditorDialogState extends State<_MenuEditorDialog> {
  final _formKey  = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _routeCtrl;
  late TextEditingController _sortCtrl;
  late TextEditingController _permCtrl;
  String _selectedIcon = 'widgets_rounded';
  bool   _isActive     = true;
  bool   _saving       = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _routeCtrl = TextEditingController(text: e?.routePath ?? '/admin/');
    _sortCtrl  = TextEditingController(text: '${e?.sortOrder ?? 99}');
    _permCtrl  = TextEditingController(text: e?.requiredPermission ?? '');
    _selectedIcon = e?.iconName ?? 'widgets_rounded';
    _isActive     = e?.isActive ?? true;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _routeCtrl.dispose();
    _sortCtrl.dispose();
    _permCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.bgSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.borderSubtle),
      ),
      child: SizedBox(
        width: 580,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Row(
                  children: [
                    const Icon(Icons.menu_rounded, color: AppColors.brandPrimary, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      widget.existing == null ? 'Add Navigation Menu Item' : 'Edit: ${widget.existing!.title}',
                      style: const TextStyle(
                          color: AppColors.textMain,
                          fontSize: 16,
                          fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Title + Route
                Row(
                  children: [
                    Expanded(child: _field('Title / Label', _titleCtrl, required: true)),
                    const SizedBox(width: 12),
                    Expanded(child: _field('Route Path', _routeCtrl, required: true,
                        hint: '/admin/my-module')),
                  ],
                ),
                const SizedBox(height: 14),

                // Sort Order + Permission
                Row(
                  children: [
                    SizedBox(width: 100, child: _field('Sort Order', _sortCtrl, isNumber: true)),
                    const SizedBox(width: 12),
                    Expanded(child: _field('Required Permission', _permCtrl,
                        hint: 'e.g. module.read (optional)')),
                  ],
                ),
                const SizedBox(height: 16),

                // Icon Picker
                _buildIconPicker(),
                const SizedBox(height: 16),

                // Active toggle
                Row(
                  children: [
                    const Text('Active:', style: TextStyle(color: AppColors.textSubtle, fontSize: 13)),
                    const SizedBox(width: 10),
                    Switch.adaptive(
                      value: _isActive,
                      onChanged: (v) => setState(() => _isActive = v),
                      activeTrackColor: AppColors.brandPrimary,
                      activeThumbColor: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(_isActive ? 'Visible in sidebar' : 'Hidden from sidebar',
                        style: TextStyle(
                            color: _isActive ? AppColors.statusActive : AppColors.textMuted,
                            fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 20),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _saving ? null : () => Navigator.pop(context),
                      child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _saving ? null : _handleSave,
                      icon: _saving
                          ? const SizedBox(
                              width: 12, height: 12,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.save_rounded, size: 14),
                      label: Text(widget.existing == null ? 'Create' : 'Update',
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandPrimary,
                          foregroundColor: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl,
      {bool required = false, bool isNumber = false, String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        TextFormField(
          controller: ctrl,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: const TextStyle(color: AppColors.textMain, fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            filled: true,
            fillColor: AppColors.bgCanvas,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: AppColors.borderSubtle),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: AppColors.borderSubtle),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: AppColors.brandPrimary),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          ),
          validator: required
              ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
              : null,
        ),
      ],
    );
  }

  Widget _buildIconPicker() {
    final allIcons = IconResolver.allEntries;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Icon',
            style: TextStyle(
                color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.bgCanvas,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selected preview
              Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.brandPrimary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(IconResolver.resolve(_selectedIcon),
                        color: AppColors.brandPrimary, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(_selectedIcon,
                        style: const TextStyle(
                            color: AppColors.textMain, fontSize: 12,
                            fontFamily: 'monospace')),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Icon Grid
              SizedBox(
                height: 130,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 12,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                  ),
                  itemCount: allIcons.length,
                  itemBuilder: (ctx, i) {
                    final entry = allIcons[i];
                    final isSelected = entry.key == _selectedIcon;
                    return InkWell(
                      onTap: () => setState(() => _selectedIcon = entry.key),
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.brandPrimary.withValues(alpha: 0.25)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.brandPrimary
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Tooltip(
                          message: entry.key,
                          child: Icon(entry.value,
                              color: isSelected
                                  ? AppColors.brandPrimary
                                  : AppColors.textMuted,
                              size: 16),
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
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final model = NavigationMenuModel(
      id:                 widget.existing?.id ?? 0,
      title:              _titleCtrl.text.trim(),
      iconName:           _selectedIcon,
      routePath:          _routeCtrl.text.trim(),
      sortOrder:          int.tryParse(_sortCtrl.text.trim()) ?? 99,
      requiredPermission: _permCtrl.text.trim().isEmpty ? null : _permCtrl.text.trim(),
      isActive:           _isActive,
    );

    await widget.onSave(model);
    if (mounted) setState(() => _saving = false);
  }
}
