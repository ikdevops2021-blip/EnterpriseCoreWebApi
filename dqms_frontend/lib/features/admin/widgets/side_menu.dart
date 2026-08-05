import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/core/utils/icon_resolver.dart';
import 'package:dqms_frontend/features/admin/providers/navigation_menu_provider.dart';

/// ============================================================================
/// RESPONSIVE SIDE MENU / DRAWER (Abu Anwar Pattern)
/// Clean, responsive sidebar drawer navigation with categorized sections,
/// active item highlighting, brand header, and dynamic route binding.
/// ============================================================================
class SideMenu extends StatelessWidget {
  final List<NavigationMenuModel> navItems;
  final int activeIndex;
  final bool isDrawer;

  const SideMenu({
    super.key,
    required this.navItems,
    required this.activeIndex,
    this.isDrawer = false,
  });

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: AppColors.bgSurface,
        border: Border(right: BorderSide(color: AppColors.borderSubtle, width: 1)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // ----------------------------------------------------------------
            // 1. Top Brand Header (Logo + Title)
            // ----------------------------------------------------------------
            _buildBrandHeader(context),
            const Divider(color: AppColors.borderSubtle, height: 1),

            // ----------------------------------------------------------------
            // 2. Navigation Items List
            // ----------------------------------------------------------------
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: [
                  // Main Command Section
                  const _SectionHeader(title: 'MAIN COMMAND'),
                  DrawerListTile(
                    title: 'Command Center',
                    icon: Icons.dashboard_customize_rounded,
                    isActive: location == '/dashboard',
                    press: () {
                      if (isDrawer) Navigator.pop(context);
                      context.go('/dashboard');
                    },
                  ),
                  const SizedBox(height: 12),

                  // Admin Domains Section
                  const _SectionHeader(title: 'ADMINISTRATIVE DOMAINS'),
                  if (navItems.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.brandPrimary,
                          ),
                        ),
                      ),
                    )
                  else
                    ...navItems.asMap().entries.map((entry) {
                      final i = entry.key;
                      final item = entry.value;
                      final isSelected = activeIndex == i || location == item.routePath;
                      final iconData = IconResolver.resolve(item.iconName);

                      return DrawerListTile(
                        title: item.title,
                        icon: iconData,
                        isActive: isSelected,
                        press: () {
                          if (isDrawer) Navigator.pop(context);
                          context.go(item.routePath);
                        },
                      );
                    }),
                ],
              ),
            ),

            // ----------------------------------------------------------------
            // 3. Footer Section (Org & Version)
            // ----------------------------------------------------------------
            const Divider(color: AppColors.borderSubtle, height: 1),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  /// Top Brand Logo Header
  Widget _buildBrandHeader(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.brandPrimary.withValues(alpha: 0.8),
                  AppColors.brandPrimary,
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: AppColors.brandPrimary.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.shield_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'DQMS Enterprise',
                  style: TextStyle(
                    color: AppColors.textMain,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Queue Management System',
                  style: TextStyle(
                    color: AppColors.textSubtle,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Bottom Footer Widget
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.bgCanvas.withValues(alpha: 0.5),
      child: Row(
        children: [
          const Icon(Icons.business_rounded, color: AppColors.textSubtle, size: 14),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'DQMS Platform v1.0',
              style: TextStyle(
                color: AppColors.textSubtle,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.statusActive,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

/// Category Section Header
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textSubtle,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

/// Abu Anwar Pattern Drawer List Tile with Active Highlighting & Smooth Hover
class DrawerListTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isActive;
  final VoidCallback press;

  const DrawerListTile({
    super.key,
    required this.title,
    required this.icon,
    required this.isActive,
    required this.press,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: press,
          borderRadius: BorderRadius.circular(8),
          hoverColor: AppColors.brandPrimary.withValues(alpha: 0.08),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.brandPrimary.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isActive
                  ? Border.all(
                      color: AppColors.brandPrimary.withValues(alpha: 0.3),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isActive ? AppColors.brandPrimary : AppColors.textMuted,
                  size: 18,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isActive ? AppColors.textMain : AppColors.textSubtle,
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isActive)
                  Container(
                    width: 4,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.brandPrimary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
