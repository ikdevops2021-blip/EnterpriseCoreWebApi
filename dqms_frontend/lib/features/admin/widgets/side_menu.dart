import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/core/utils/icon_resolver.dart';
import 'package:dqms_frontend/features/admin/providers/navigation_menu_provider.dart';

/// ============================================================================
/// RESPONSIVE COLLAPSIBLE SIDE MENU / DRAWER (Clinical Glassmorphic Design)
/// Seamlessly transitions between full-width (256px) and compact icon-rail (72px).
/// Features active cyan glow indicator, categorized sections, brand header,
/// and instant GoRouter route binding.
/// ============================================================================
class SideMenu extends StatelessWidget {
  final List<NavigationMenuModel> navItems;
  final int activeIndex;
  final bool isDrawer;
  final bool isCollapsed;
  final VoidCallback? onToggleCollapse;

  const SideMenu({
    super.key,
    required this.navItems,
    required this.activeIndex,
    this.isDrawer = false,
    this.isCollapsed = false,
    this.onToggleCollapse,
  });

  @override
  Widget build(BuildContext context) {
    String location = '/admin/areas-zones';
    try {
      location = GoRouterState.of(context).uri.path;
    } catch (_) {}

    final effectiveWidth = isDrawer ? 256.0 : (isCollapsed ? 72.0 : 256.0);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOutCubic,
      width: effectiveWidth,
      decoration: BoxDecoration(
        color: AppColors.bgSurface.withValues(alpha: 0.96),
        border: const Border(
          right: BorderSide(color: AppColors.glassBorderLight, width: 1),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 16,
            offset: Offset(4, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // ----------------------------------------------------------------
            // 1. Top Brand Header (Logo + Title + Collapse Toggle)
            // ----------------------------------------------------------------
            _buildBrandHeader(context),
            const Divider(color: AppColors.borderSubtle, height: 1),

            // ----------------------------------------------------------------
            // 2. Navigation Items List
            // ----------------------------------------------------------------
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 10),
                children: [
                  // Main Command Section
                  if (!isCollapsed)
                    const _SectionHeader(title: 'MAIN COMMAND')
                  else
                    const _CollapsedSectionDivider(),

                  DrawerListTile(
                    title: 'Command Center',
                    iconName: 'dashboard_rounded',
                    isActive: location == '/dashboard',
                    isCollapsed: isCollapsed && !isDrawer,
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
                    isCollapsed: isCollapsed && !isDrawer,
                    press: () {
                      final router = GoRouter.of(context);
                      if (isDrawer) Navigator.of(context).pop();
                      router.go('/appointments-calendar');
                    },
                  ),
                  const SizedBox(height: 8),

                  // Admin Domains Section
                  if (!isCollapsed)
                    const _SectionHeader(title: 'ADMINISTRATIVE DOMAINS')
                  else
                    const _CollapsedSectionDivider(),

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
                        isCollapsed: isCollapsed && !isDrawer,
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
            // 3. Footer Section (Org & Version & Collapse Controls)
            // ----------------------------------------------------------------
            const Divider(color: AppColors.borderSubtle, height: 1),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  /// Top Brand Logo Header with Expand / Collapse Toggle (Stitch DQMS Command)
  Widget _buildBrandHeader(BuildContext context) {
    if (isCollapsed && !isDrawer) {
      return Container(
        height: 64,
        alignment: Alignment.center,
        child: Tooltip(
          message: 'Expand Navigation Menu',
          waitDuration: const Duration(milliseconds: 150),
          child: InkWell(
            onTap: onToggleCollapse,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3198DC), Color(0xFF262A2F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF93CCFF).withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF93CCFF).withValues(alpha: 0.2),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: const Icon(
                Icons.local_hospital_rounded,
                color: Color(0xFF93CCFF),
                size: 22,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3198DC), Color(0xFF262A2F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF93CCFF).withValues(alpha: 0.35)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF93CCFF).withValues(alpha: 0.25),
                  blurRadius: 12,
                ),
              ],
            ),
            child: const Icon(
              Icons.local_hospital_rounded,
              color: Color(0xFF93CCFF),
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'DQMS Command',
                  style: TextStyle(
                    color: Color(0xFFE0E3E8),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Clinical Admin v4.2',
                  style: TextStyle(
                    color: Color(0xFF89929B),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (!isDrawer && onToggleCollapse != null)
            IconButton(
              icon: const Icon(Icons.menu_open_rounded, color: AppColors.textMuted, size: 20),
              tooltip: 'Collapse Sidebar (Rail Mode)',
              onPressed: onToggleCollapse,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
        ],
      ),
    );
  }

  /// Bottom Footer Section (Emergency Triage Button + Host Node Status from Stitch)
  Widget _buildFooter() {
    if (isCollapsed && !isDrawer) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        color: const Color(0xFF101418),
        child: Column(
          children: [
            Tooltip(
              message: 'Emergency Triage',
              child: IconButton(
                icon: const Icon(Icons.emergency_rounded, color: Color(0xFFFFB4AB), size: 20),
                onPressed: () {},
              ),
            ),
            const SizedBox(height: 4),
            Tooltip(
              message: 'Expand Sidebar',
              waitDuration: const Duration(milliseconds: 150),
              child: IconButton(
                icon: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.cyanGlow,
                  size: 20,
                ),
                onPressed: onToggleCollapse,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: const Color(0xFF101418),
      child: Column(
        children: [
          // Vibrant Red "Emergency Triage" Action Button (from Stitch Design)
          Material(
            color: const Color(0xFF93000A),
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFFB4AB).withValues(alpha: 0.3)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.emergency_rounded, color: Color(0xFFFFDAD6), size: 15),
                    SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Emergency Triage',
                        style: TextStyle(
                          color: Color(0xFFFFDAD6),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // System Security & Documentation Links (from Stitch Design)
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(4),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.security_rounded, size: 13, color: Color(0xFF89929B)),
                        SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Security',
                            style: TextStyle(color: Color(0xFF89929B), fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(4),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.help_outline_rounded, size: 13, color: Color(0xFF89929B)),
                        SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Docs',
                            style: TextStyle(color: Color(0xFF89929B), fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Host Node Status Pill (from Stitch Design: NODE: ALPHA-HOST v4.8.2-PROD)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF181C20),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF3F4850).withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4EDEA3),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4EDEA3).withValues(alpha: 0.8),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 7),
                const Expanded(
                  child: Text(
                    'NODE: ALPHA-HOST',
                    style: TextStyle(
                      color: Color(0xFFE0E3E8),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00311F),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: const Text(
                    'v4.8.2-PROD',
                    style: TextStyle(
                      color: Color(0xFF4EDEA3),
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Category Section Header (Expanded Mode)
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
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

/// Subtle Divider between Sections in Collapsed Rail Mode
class _CollapsedSectionDivider extends StatelessWidget {
  const _CollapsedSectionDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      height: 1,
      color: AppColors.borderSubtle.withValues(alpha: 0.6),
    );
  }
}

/// 3D Compact Animated Drawer List Tile (Supports Collapsed Rail & Expanded Mode)
class DrawerListTile extends StatefulWidget {
  final String title;
  final String? iconName;
  final bool isActive;
  final bool isCollapsed;
  final VoidCallback press;

  const DrawerListTile({
    super.key,
    required this.title,
    required this.isActive,
    required this.press,
    this.iconName,
    this.isCollapsed = false,
  });

  @override
  State<DrawerListTile> createState() => _DrawerListTileState();
}

class _DrawerListTileState extends State<DrawerListTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final iconColor = widget.isActive
        ? AppColors.cyanGlow
        : (_isHovered ? AppColors.textMain : AppColors.textMuted);
    final iconWidget = IconResolver.resolve(widget.iconName).build(
      size: widget.isCollapsed ? 19 : 16,
      color: iconColor,
    );

    // ── COLLAPSED RAIL TILE ──
    if (widget.isCollapsed) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Tooltip(
          message: widget.title,
          waitDuration: const Duration(milliseconds: 150),
          preferBelow: false,
          textStyle: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.brandPrimary.withValues(alpha: 0.4)),
            boxShadow: const [
              BoxShadow(color: Color(0x66000000), blurRadius: 10, offset: Offset(0, 4)),
            ],
          ),
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: widget.press,
                borderRadius: BorderRadius.circular(8),
                hoverColor: AppColors.brandPrimary.withValues(alpha: 0.1),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: widget.isActive
                        ? AppColors.brandPrimary.withValues(alpha: 0.2)
                        : (_isHovered
                            ? AppColors.bgSurfaceHover.withValues(alpha: 0.7)
                            : Colors.transparent),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: widget.isActive
                          ? AppColors.cyanGlow.withValues(alpha: 0.6)
                          : (_isHovered ? AppColors.borderSubtle : Colors.transparent),
                      width: 1,
                    ),
                    boxShadow: widget.isActive
                        ? [
                            BoxShadow(
                              color: AppColors.brandPrimary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Center(child: iconWidget),
                      if (widget.isActive)
                        Positioned(
                          left: 0,
                          top: 10,
                          bottom: 10,
                          child: Container(
                            width: 3.5,
                            decoration: BoxDecoration(
                              color: AppColors.cyanGlow,
                              borderRadius: const BorderRadius.horizontal(right: Radius.circular(3)),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.cyanGlow.withValues(alpha: 0.8),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
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

    // ── EXPANDED FULL-WIDTH TILE ──
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
              hoverColor: AppColors.brandPrimary.withValues(alpha: 0.08),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7.5),
                decoration: BoxDecoration(
                  color: widget.isActive
                      ? AppColors.brandPrimary.withValues(alpha: 0.18)
                      : (_isHovered
                          ? AppColors.bgSurfaceHover.withValues(alpha: 0.6)
                          : Colors.transparent),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: widget.isActive
                        ? AppColors.brandPrimary.withValues(alpha: 0.5)
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
                          color: AppColors.cyanGlow,
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.cyanGlow.withValues(alpha: 0.7),
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
