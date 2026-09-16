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
    String location = '/admin/areas-zones';
    try {
      location = GoRouterState.of(context).uri.path;
    } catch (_) {}

    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: AppColors.bgSurface.withValues(alpha: 0.88),
        border: const Border(right: BorderSide(color: AppColors.borderSubtle, width: 1)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 12,
            offset: Offset(4, 0),
          ),
        ],
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
                    iconName: 'dashboard_rounded',
                    isActive: location == '/dashboard',
                    press: () {
                      final router = GoRouter.of(context);
                      if (isDrawer) Navigator.of(context).pop();
                      router.go('/dashboard');
                    },
                  ),
                  DrawerListTile(
                    title: 'Appointments Calendar',
                    iconName: 'schedule_rounded',
                    isActive: location == '/appointments-calendar',
                    press: () {
                      final router = GoRouter.of(context);
                      if (isDrawer) Navigator.of(context).pop();
                      router.go('/appointments-calendar');
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

                      return DrawerListTile(
                        title: item.title,
                        iconName: item.iconName,
                        isActive: isSelected,
                        press: () {
                          final router = GoRouter.of(context);
                          if (isDrawer) {
                            Navigator.of(context).pop();
                          }
                          router.go(item.routePath);
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

/// 3D Compact Animated Drawer List Tile with Hover Nudge & Neon Glow
class DrawerListTile extends StatefulWidget {
  final String title;
  final String? iconName;
  final bool isActive;
  final VoidCallback press;

  const DrawerListTile({
    super.key,
    required this.title,
    required this.isActive,
    required this.press,
    this.iconName,
  });

  @override
  State<DrawerListTile> createState() => _DrawerListTileState();
}

class _DrawerListTileState extends State<DrawerListTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final iconColor = widget.isActive
        ? AppColors.brandPrimary
        : (_isHovered ? AppColors.textMain : AppColors.textMuted);
    final iconWidget = IconResolver.resolve(widget.iconName).build(size: 16, color: iconColor);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1.5),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(_isHovered ? 3.0 : 0.0, 0.0, 0.0),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            child: InkWell(
              onTap: widget.press,
              borderRadius: BorderRadius.circular(6),
              hoverColor: AppColors.brandPrimary.withValues(alpha: 0.06),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7.5),
                decoration: BoxDecoration(
                  color: widget.isActive
                      ? AppColors.brandPrimary.withValues(alpha: 0.16)
                      : (_isHovered
                          ? AppColors.bgSurfaceHover.withValues(alpha: 0.6)
                          : Colors.transparent),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: widget.isActive
                        ? AppColors.brandPrimary.withValues(alpha: 0.45)
                        : (_isHovered
                            ? AppColors.borderSubtle
                            : Colors.transparent),
                    width: 1,
                  ),
                  boxShadow: widget.isActive
                      ? [
                          const BoxShadow(
                            color: Color(0x1AFFFFFF),
                            offset: Offset(-0.5, -0.5),
                            blurRadius: 0.5,
                          ),
                          BoxShadow(
                            color: AppColors.brandPrimary.withValues(alpha: 0.25),
                            blurRadius: 8,
                            spreadRadius: 0.5,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    SizedBox(width: 18, child: Center(child: iconWidget)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: TextStyle(
                          color: widget.isActive
                              ? AppColors.textMain
                              : (_isHovered ? AppColors.textMain : AppColors.textSubtle),
                          fontSize: 12.5,
                          fontWeight: widget.isActive ? FontWeight.w700 : FontWeight.w500,
                          letterSpacing: 0.1,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.isActive)
                      Container(
                        width: 3.5,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.brandPrimary,
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.brandPrimary.withValues(alpha: 0.7),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
