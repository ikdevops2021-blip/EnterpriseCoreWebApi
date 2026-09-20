import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/core/theme/app_decorations.dart';
import 'package:dqms_frontend/core/theme/app_typography.dart';
import 'package:dqms_frontend/core/widgets/dqms_button.dart';
import 'package:dqms_frontend/core/widgets/glass_widgets.dart';
import 'package:dqms_frontend/features/auth/providers/auth_provider.dart';
import 'package:dqms_frontend/features/customer/providers/customer_experience_provider.dart';

/// ============================================================================
/// PHASE 2 — MODERNIZED RESPONSIVE CUSTOMER PORTAL (MobileTrackerScreen)
/// Features luxury liquid glassmorphism, 4-tab architecture, real-time queue
/// tracking, appointment management, and patient profile suite.
/// ============================================================================
class MobileTrackerScreen extends ConsumerStatefulWidget {
  const MobileTrackerScreen({super.key});

  @override
  ConsumerState<MobileTrackerScreen> createState() => _MobileTrackerScreenState();
}

class _MobileTrackerScreenState extends ConsumerState<MobileTrackerScreen> {
  @override
  Widget build(BuildContext context) {
    final currentTab = ref.watch(customerPortalTabProvider);
    final ticketState = ref.watch(mobileTicketStateProvider);
    final ticketNotifier = ref.read(mobileTicketStateProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.bgCanvas,
      appBar: AppBar(
        backgroundColor: AppColors.bgHeader,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.phone_iphone_rounded, color: AppColors.brandPrimary, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'DQMS Mobile Tracker',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz_rounded, color: AppColors.brandAccent),
            tooltip: 'Simulate Called/Waiting State',
            onPressed: () => ticketNotifier.toggleCallingState(),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.textMuted),
            tooltip: 'Notifications',
            onPressed: () => _showNotificationsSheet(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Stack(
              children: [
                // Tab Content View
                IndexedStack(
                  index: currentTab,
                  children: [
                    _buildHomeTab(context, ticketState),
                    _buildLiveQueueTab(context),
                    _buildAppointmentsTab(context),
                    _buildProfileTab(context),
                  ],
                ),

                // Floating Glass Bottom Navigation Bar
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: GlassBottomNav(
                    currentIndex: currentTab,
                    onTap: (index) {
                      ref.read(customerPortalTabProvider.notifier).state = index;
                    },
                    items: const [
                      GlassNavItem(
                        icon: Icons.home_outlined,
                        activeIcon: Icons.home_rounded,
                        label: 'Home',
                      ),
                      GlassNavItem(
                        icon: Icons.format_list_numbered_rounded,
                        activeIcon: Icons.format_list_numbered_rounded,
                        label: 'Live Queue',
                      ),
                      GlassNavItem(
                        icon: Icons.calendar_today_outlined,
                        activeIcon: Icons.calendar_month_rounded,
                        label: 'Appointments',
                      ),
                      GlassNavItem(
                        icon: Icons.person_outline_rounded,
                        activeIcon: Icons.person_rounded,
                        label: 'Profile',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // TAB 0: HOME
  // ===========================================================================
  Widget _buildHomeTab(BuildContext context, MobileTicketState ticketState) {
    final authState = ref.watch(authStateProvider);
    final user = authState.currentUser;
    final userName = user?.fullName ?? 'Imdad Khan';
    final currentLocation = ref.watch(customerLocationProvider);
    final isCalling = ticketState.status == 'Calling';

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Greeting & Location Selector
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // User Avatar with Verified Status
              Stack(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.heroGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.electricBlue.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        userName.isNotEmpty ? userName.substring(0, 1).toUpperCase() : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.emeraldSuccess,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.bgCanvas, width: 2),
                      ),
                      child: const Icon(Icons.check, size: 8, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),

              // Greeting & Branch Selector
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good Morning, $userName',
                      style: AppTypography.heroGreeting.copyWith(fontSize: 17),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    GestureColorSelector(
                      currentLocation: currentLocation,
                      onChanged: (loc) => ref.read(customerLocationProvider.notifier).state = loc,
                    ),
                  ],
                ),
              ),

              // Notifications Action Button
              GlassSquircleIcon(
                icon: Icons.notifications_none_rounded,
                backgroundColor: AppColors.glassSurfaceLight,
                iconColor: AppColors.cyanGlow,
                size: 42,
                iconSize: 20,
                onTap: () => _showNotificationsSheet(context),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // High-Visibility CALL BANNER when status is 'Calling'
          if (isCalling) ...[
            _buildProceedToCounterBanner(ticketState),
            const SizedBox(height: 16),
          ],

          // 2. Hero Appointment & Token Card
          _buildHeroAppointmentCard(context, ticketState),

          const SizedBox(height: 24),

          // 3. Quick Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Quick Actions',
                  style: AppTypography.sectionTitle.copyWith(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '4 Services',
                style: TextStyle(
                  color: AppColors.textMuted.withValues(alpha: 0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildQuickActionsGrid(context),

          const SizedBox(height: 24),

          // 4. Live Facility Quick Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Queue Overview',
                  style: AppTypography.sectionTitle.copyWith(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.emeraldSuccess,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Live Updates',
                    style: TextStyle(
                      color: AppColors.emeraldSuccess,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildQuickStatsRow(),
        ],
      ),
    );
  }

  /// High-Visibility CALL BANNER (Preserves existing audio-visual call indicator)
  Widget _buildProceedToCounterBanner(MobileTicketState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.statusActive,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: [
          BoxShadow(
            color: AppColors.statusActive.withValues(alpha: 0.45),
            blurRadius: 18,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.campaign_rounded, color: Colors.white, size: 22),
              SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'YOUR NUMBER HAS BEEN CALLED!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'PROCEED TO ${state.assignedCounter}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              fontFamily: 'monospace',
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.02, 1.02),
          duration: 800.ms,
          curve: Curves.easeInOut,
        );
  }

  /// Hero Next Appointment Card with Luxury Glass Gradient
  Widget _buildHeroAppointmentCard(BuildContext context, MobileTicketState ticketState) {
    final isCalling = ticketState.status == 'Calling';

    return GlassCard(
      borderRadius: AppRadius.hero,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF1E1B4B), // Deep indigo
          const Color(0xFF0F172A).withValues(alpha: 0.9), // Slate midnight
          const Color(0xFF1E293B),
        ],
      ),
      borderColor: isCalling
          ? AppColors.statusActive.withValues(alpha: 0.6)
          : AppColors.cyanGlow.withValues(alpha: 0.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Badge & Context
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const GlassSquircleIcon(
                      icon: Icons.calendar_month_rounded,
                      backgroundColor: Color(0x3338BDF8),
                      iconColor: AppColors.cyanGlow,
                      size: 32,
                      iconSize: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your Next Appointment',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GlassPillBadge(
                label: isCalling ? 'NOW SERVING' : 'CONFIRMED',
                variant: isCalling ? GlassPillVariant.nowServing : GlassPillVariant.upcoming,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Token Display Box (Includes YOUR TOKEN NUMBER label for test & clarity)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
                width: 1.0,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'YOUR TOKEN NUMBER',
                        style: TextStyle(
                          color: AppColors.textSubtle,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          ticketState.tokenNumber,
                          style: const TextStyle(
                            color: AppColors.cyanGlow,
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'monospace',
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        isCalling ? 'NOW CALLED' : 'ETA ~${ticketState.estimatedWaitMins} MINS',
                        style: TextStyle(
                          color: isCalling ? AppColors.statusActive : AppColors.amberOrange,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isCalling ? 'Station ${ticketState.assignedCounter}' : '${ticketState.customersAhead} Ahead of you',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Service & Doctor Meta Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticketState.serviceName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Dr. Ahmed Rahman • Room 2 (10:20 AM)',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // View Details Button (Opens Glass Token Card Dialog)
              DqmsButton(
                label: 'View Details',
                icon: Icons.qr_code_2_rounded,
                variant: DqmsButtonVariant.gradientPill,
                onPressed: () => _showTokenDetailsModal(context, ticketState),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 4 Quick Action Cards with Squircle Icons
  Widget _buildQuickActionsGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 460;
        final itemWidth = isNarrow ? (constraints.maxWidth - 12) / 2 : (constraints.maxWidth - 36) / 4;

        final actions = [
          _QuickActionItem(
            title: 'Book Appointment',
            subtitle: 'Reserve time slot',
            icon: Icons.calendar_today_rounded,
            iconBg: AppColors.electricBlue.withValues(alpha: 0.16),
            iconColor: AppColors.electricBlue,
            onTap: () => context.push('/appointment'),
          ),
          _QuickActionItem(
            title: 'Check In / Scan QR',
            subtitle: 'Confirm arrival',
            icon: Icons.qr_code_scanner_rounded,
            iconBg: AppColors.cyanGlow.withValues(alpha: 0.16),
            iconColor: AppColors.cyanGlow,
            onTap: () => _showCheckInModal(context),
          ),
          _QuickActionItem(
            title: 'My Queue Status',
            subtitle: 'Live ticket ETA',
            icon: Icons.format_list_bulleted_rounded,
            iconBg: AppColors.amberOrange.withValues(alpha: 0.16),
            iconColor: AppColors.amberOrange,
            onTap: () => ref.read(customerPortalTabProvider.notifier).state = 1,
          ),
          _QuickActionItem(
            title: 'View Reports',
            subtitle: 'Lab tests & Rx',
            icon: Icons.description_outlined,
            iconBg: AppColors.violetPrimary.withValues(alpha: 0.16),
            iconColor: AppColors.violetPrimary,
            onTap: () => _showReportsModal(context),
          ),
        ];

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: actions.map((item) {
            return SizedBox(
              width: itemWidth,
              child: GlassCard(
                padding: const EdgeInsets.all(12),
                borderRadius: AppRadius.card,
                onTap: item.onTap,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GlassSquircleIcon(
                      icon: item.icon,
                      backgroundColor: item.iconBg,
                      iconColor: item.iconColor,
                      size: 38,
                      iconSize: 18,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: AppColors.textMain,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  /// Compact Glass Stat Cards
  Widget _buildQuickStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            label: 'WAITING',
            value: '12',
            icon: Icons.hourglass_top_rounded,
            color: AppColors.amberOrange,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            label: 'IN SERVICE',
            value: '8',
            icon: Icons.medical_services_rounded,
            color: AppColors.cyanGlow,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            label: 'COMPLETED',
            value: '3',
            icon: Icons.check_circle_rounded,
            color: AppColors.emeraldSuccess,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      borderRadius: AppRadius.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSubtle,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 2),
              Icon(icon, size: 13, color: color),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // TAB 1: LIVE QUEUE
  // ===========================================================================
  Widget _buildLiveQueueTab(BuildContext context) {
    final queueItems = ref.watch(liveQueueItemsProvider);
    final activeFilter = ref.watch(queueDepartmentFilterProvider);

    final filteredQueue = activeFilter == 'All'
        ? queueItems
        : queueItems.where((item) => item.department.toLowerCase() == activeFilter.toLowerCase()).toList();

    final nowServingItem = queueItems.firstWhere(
      (item) => item.status == 'Now Serving',
      orElse: () => queueItems.first,
    );

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Live Queue Monitor',
                style: AppTypography.sectionTitle.copyWith(fontSize: 18),
              ),
              GlassPillBadge(
                label: '${filteredQueue.length} Active Tickets',
                variant: GlassPillVariant.upcoming,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 1. Horizontally Scrollable Token Strip
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: queueItems.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final item = queueItems[index];
                final isServing = item.status == 'Now Serving';

                return GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  borderRadius: AppRadius.pill,
                  borderColor: isServing
                      ? AppColors.emeraldSuccess.withValues(alpha: 0.6)
                      : AppColors.glassBorderLight,
                  color: isServing
                      ? AppColors.emeraldSuccess.withValues(alpha: 0.18)
                      : AppColors.glassSurfaceLight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isServing ? AppColors.emeraldSuccess : AppColors.cyanGlow,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.tokenNumber,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isServing ? '• Now' : '• Next',
                        style: TextStyle(
                          color: isServing ? AppColors.emeraldSuccess : AppColors.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 18),

          // 2. Department Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildDepartmentFilterChip(context, 'All'),
                const SizedBox(width: 8),
                _buildDepartmentFilterChip(context, 'Consultation'),
                const SizedBox(width: 8),
                _buildDepartmentFilterChip(context, 'Lab'),
                const SizedBox(width: 8),
                _buildDepartmentFilterChip(context, 'Pharmacy'),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // 3. Now Serving Hero Card
          GlassCard(
            borderRadius: AppRadius.hero,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF064E3B).withValues(alpha: 0.8), // Emerald dark
                const Color(0xFF0F172A),
                const Color(0xFF0F172A),
              ],
            ),
            borderColor: AppColors.emeraldSuccess.withValues(alpha: 0.4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const GlassPillBadge(
                      label: 'NOW SERVING',
                      variant: GlassPillVariant.nowServing,
                    ),
                    Text(
                      'Started ${nowServingItem.timeSlot ?? '10:20 AM'}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.emeraldSuccess.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        border: Border.all(
                          color: AppColors.emeraldSuccess.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        nowServingItem.tokenNumber,
                        style: const TextStyle(
                          color: AppColors.emeraldSuccess,
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nowServingItem.doctorOrStaff ?? 'Dr. Ahmed Rahman',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            nowServingItem.serviceName,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Text(
                              nowServingItem.roomOrCounter,
                              style: const TextStyle(
                                color: AppColors.cyanGlow,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
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

          const SizedBox(height: 22),

          // 4. Waiting Queue List
          Text(
            'Upcoming In Line',
            style: AppTypography.sectionTitle.copyWith(fontSize: 15),
          ),
          const SizedBox(height: 10),

          if (filteredQueue.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'No tokens currently waiting in this department.',
                  style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.8)),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredQueue.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = filteredQueue[index];
                final isNow = item.status == 'Now Serving';
                if (isNow) return const SizedBox.shrink(); // Already highlighted above

                return GlassCard(
                  padding: const EdgeInsets.all(14),
                  borderRadius: AppRadius.card,
                  child: Row(
                    children: [
                      // Token ID Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.glassSurfaceLight,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: AppColors.glassBorderLight),
                        ),
                        child: Text(
                          item.tokenNumber,
                          style: const TextStyle(
                            color: AppColors.cyanGlow,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Service and Doctor Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.serviceName,
                              style: const TextStyle(
                                color: AppColors.textMain,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${item.doctorOrStaff ?? "Assigned Counter"} • ${item.roomOrCounter}',
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ETA & Position
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '~${item.estimatedWaitMinutes} min',
                            style: const TextStyle(
                              color: AppColors.amberOrange,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '#${index + 1} in queue',
                            style: TextStyle(
                              color: AppColors.textSubtle.withValues(alpha: 0.8),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDepartmentFilterChip(BuildContext context, String department) {
    final activeFilter = ref.watch(queueDepartmentFilterProvider);
    final isSelected = activeFilter.toLowerCase() == department.toLowerCase();

    return InkWell(
      onTap: () => ref.read(queueDepartmentFilterProvider.notifier).state = department,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: AnimatedContainer(
        duration: AppMotion.fast,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.electricBlue : AppColors.glassSurfaceLight,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: isSelected ? AppColors.electricBlue : AppColors.glassBorderLight,
          ),
        ),
        child: Text(
          department,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textMuted,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // TAB 2: APPOINTMENTS
  // ===========================================================================
  Widget _buildAppointmentsTab(BuildContext context) {
    final activeSegment = ref.watch(appointmentSegmentProvider);
    final appointments = ref.watch(scheduledAppointmentsProvider);

    final filteredAppointments = activeSegment == 0
        ? appointments.where((apt) => apt.status != 'Completed').toList()
        : appointments.where((apt) => apt.status == 'Completed').toList();

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & New Appointment Action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Appointments',
                style: AppTypography.sectionTitle.copyWith(fontSize: 18),
              ),
              DqmsButton(
                label: 'Book New',
                icon: Icons.add_rounded,
                variant: DqmsButtonVariant.primary,
                onPressed: () => context.push('/appointment'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Glass Segmented Control (Upcoming | Past)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.glassSurfaceDark,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: AppColors.glassBorderLight),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildSegmentOption(
                    label: 'Upcoming (${appointments.where((a) => a.status != 'Completed').length})',
                    index: 0,
                    selectedIndex: activeSegment,
                  ),
                ),
                Expanded(
                  child: _buildSegmentOption(
                    label: 'Past (${appointments.where((a) => a.status == 'Completed').length})',
                    index: 1,
                    selectedIndex: activeSegment,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Appointment Cards List
          if (filteredAppointments.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Column(
                  children: [
                    const Icon(Icons.event_busy_rounded, size: 48, color: AppColors.textSubtle),
                    const SizedBox(height: 12),
                    Text(
                      activeSegment == 0 ? 'No upcoming appointments' : 'No past appointments found',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredAppointments.length,
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final apt = filteredAppointments[index];
                final isCompleted = apt.status == 'Completed';

                return GlassCard(
                  borderRadius: AppRadius.card,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Card Top Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                GlassSquircleIcon(
                                  icon: isCompleted ? Icons.check_circle_outline : Icons.event_available_rounded,
                                  backgroundColor: isCompleted
                                      ? AppColors.emeraldSuccess.withValues(alpha: 0.15)
                                      : AppColors.electricBlue.withValues(alpha: 0.15),
                                  iconColor: isCompleted ? AppColors.emeraldSuccess : AppColors.cyanGlow,
                                  size: 36,
                                  iconSize: 18,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        apt.serviceName,
                                        style: const TextStyle(
                                          color: AppColors.textMain,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        apt.locationName,
                                        style: const TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 11,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          GlassPillBadge(
                            label: apt.status.toUpperCase(),
                            variant: isCompleted ? GlassPillVariant.completed : GlassPillVariant.nowServing,
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Schedule & Meta Grid
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.glassSurfaceLight,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: AppColors.glassBorderLight),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.access_time_rounded, size: 16, color: AppColors.cyanGlow),
                                const SizedBox(width: 6),
                                Text(
                                  apt.timeSlot,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'ID: ${apt.appointmentId}',
                              style: const TextStyle(
                                color: AppColors.textSubtle,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Bottom Row: Details / QR Pass Action
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Patient: ${apt.visitorName}',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => _showAppointmentQrPass(context, apt),
                            icon: const Icon(Icons.qr_code_2_rounded, size: 16, color: AppColors.cyanGlow),
                            label: const Text(
                              'View Pass',
                              style: TextStyle(
                                color: AppColors.cyanGlow,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSegmentOption({
    required String label,
    required int index,
    required int selectedIndex,
  }) {
    final isSelected = index == selectedIndex;

    return InkWell(
      onTap: () => ref.read(appointmentSegmentProvider.notifier).state = index,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: AnimatedContainer(
        duration: AppMotion.fast,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.electricBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textMuted,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // TAB 3: PROFILE
  // ===========================================================================
  Widget _buildProfileTab(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.currentUser;
    final userName = user?.fullName ?? 'Imdad Khan';
    final userEmail = user?.email ?? 'imdad.khan@dqms.org';

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
      child: Column(
        children: [
          // 1. Curved Fluid Gradient Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.circular(AppRadius.hero),
              boxShadow: [
                BoxShadow(
                  color: AppColors.electricBlue.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                // Avatar with Verified Badge
                Stack(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: const [
                          BoxShadow(color: Color(0x33000000), blurRadius: 12, offset: Offset(0, 4)),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          userName.isNotEmpty ? userName.substring(0, 1).toUpperCase() : 'U',
                          style: const TextStyle(
                            color: AppColors.electricBlue,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: AppColors.emeraldSuccess,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.verified, size: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  userEmail,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),

                const GlassPillBadge(
                  label: 'Verified Patient',
                  variant: GlassPillVariant.verified,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 2. Statistics Row
          GlassCard(
            borderRadius: AppRadius.card,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildProfileStatColumn('12', 'Appointments'),
                Container(width: 1, height: 28, color: AppColors.glassBorderLight),
                _buildProfileStatColumn('5', 'Visited'),
                Container(width: 1, height: 28, color: AppColors.glassBorderLight),
                _buildProfileStatColumn('3', 'Upcoming'),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 3. Menu Rows with Squircle Icons
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            borderRadius: AppRadius.card,
            child: Column(
              children: [
                _buildProfileMenuRow(
                  icon: Icons.person_outline_rounded,
                  iconBg: AppColors.electricBlue.withValues(alpha: 0.16),
                  iconColor: AppColors.electricBlue,
                  title: 'Personal Information',
                  onTap: () => _showPersonalInformationModal(context, user),
                ),
                const Divider(height: 1, color: AppColors.borderSubtle),
                _buildProfileMenuRow(
                  icon: Icons.calendar_today_rounded,
                  iconBg: AppColors.cyanGlow.withValues(alpha: 0.16),
                  iconColor: AppColors.cyanGlow,
                  title: 'My Appointments',
                  onTap: () => ref.read(customerPortalTabProvider.notifier).state = 2,
                ),
                const Divider(height: 1, color: AppColors.borderSubtle),
                _buildProfileMenuRow(
                  icon: Icons.history_rounded,
                  iconBg: AppColors.amberOrange.withValues(alpha: 0.16),
                  iconColor: AppColors.amberOrange,
                  title: 'Queue History',
                  onTap: () => _showQueueHistoryModal(context),
                ),
                const Divider(height: 1, color: AppColors.borderSubtle),
                _buildProfileMenuRow(
                  icon: Icons.notifications_none_rounded,
                  iconBg: AppColors.violetPrimary.withValues(alpha: 0.16),
                  iconColor: AppColors.violetPrimary,
                  title: 'Notifications',
                  onTap: () => _showNotificationsSheet(context),
                ),
                const Divider(height: 1, color: AppColors.borderSubtle),
                _buildProfileMenuRow(
                  icon: Icons.language_rounded,
                  iconBg: const Color(0x2610B981),
                  iconColor: AppColors.emeraldSuccess,
                  title: 'Language',
                  trailing: 'English (US)',
                  onTap: () => _showLanguageModal(context),
                ),
                const Divider(height: 1, color: AppColors.borderSubtle),
                _buildProfileMenuRow(
                  icon: Icons.help_outline_rounded,
                  iconBg: const Color(0x26F43F5E),
                  iconColor: const Color(0xFFF43F5E),
                  title: 'Help & Support',
                  onTap: () => _showHelpSupportModal(context),
                ),
                const Divider(height: 1, color: AppColors.borderSubtle),
                _buildProfileMenuRow(
                  icon: Icons.logout_rounded,
                  iconBg: AppColors.statusError.withValues(alpha: 0.16),
                  iconColor: AppColors.statusError,
                  title: 'Sign Out',
                  titleColor: AppColors.statusError,
                  onTap: () {
                    ref.read(authStateProvider.notifier).logout();
                    context.go('/login');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStatColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileMenuRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    Color? titleColor,
    String? trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: [
            GlassSquircleIcon(
              icon: icon,
              backgroundColor: iconBg,
              iconColor: iconColor,
              size: 36,
              iconSize: 18,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: titleColor ?? AppColors.textMain,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (trailing != null) ...[
              Text(
                trailing,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 6),
            ],
            const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textSubtle),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // INTERACTIVE MODALS & BOTTOM SHEETS
  // ===========================================================================

  /// Show Full Glass Token Card Modal
  void _showTokenDetailsModal(BuildContext context, MobileTicketState ticketState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 24,
            left: 16,
            right: 16,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: GlassTokenCard(
                tokenNumber: ticketState.tokenNumber,
                status: ticketState.status == 'Calling' ? 'Now Serving' : 'Waiting',
                serviceName: ticketState.serviceName,
                doctorName: 'Dr. Ahmed Rahman',
                roomInfo: ticketState.assignedCounter,
                timeInfo: '10:20 AM',
                queuePosition: ticketState.customersAhead + 1,
                estimatedWaitMinutes: ticketState.estimatedWaitMins,
                onShare: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Digital Token ${ticketState.tokenNumber} Pass link copied!'),
                      backgroundColor: AppColors.brandPrimary,
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  /// Show Appointment QR Pass Dialog
  void _showAppointmentQrPass(BuildContext context, ScheduledAppointmentModel apt) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: GlassTokenCard(
              tokenNumber: apt.appointmentId,
              status: apt.status,
              serviceName: apt.serviceName,
              doctorName: 'Specialist Clinic',
              roomInfo: apt.locationName,
              timeInfo: apt.timeSlot,
              onShare: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Appointment ${apt.appointmentId} pass saved!'),
                    backgroundColor: AppColors.brandPrimary,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  /// Check-In / Scan QR Simulation Sheet
  void _showCheckInModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
            border: Border.all(color: AppColors.glassBorderLight),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.borderSubtle, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 18),
              const Text('Kiosk QR Check-In', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              const Text('Scan the QR code displayed on the waiting hall kiosk or enter token code', style: TextStyle(color: AppColors.textMuted, fontSize: 12), textAlign: TextAlign.center),
              const SizedBox(height: 20),

              // Mock Viewfinder
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: AppColors.cyanGlow, width: 2),
                ),
                child: const Center(
                  child: Icon(Icons.qr_code_scanner_rounded, size: 72, color: AppColors.cyanGlow),
                ),
              ),
              const SizedBox(height: 24),

              DqmsButton(
                label: 'CONFIRM CHECK-IN',
                icon: Icons.check_circle_rounded,
                isFullWidth: true,
                variant: DqmsButtonVariant.gradientPill,
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Check-in confirmed! You are now queued at Green Valley Medical Center.'),
                      backgroundColor: AppColors.emeraldSuccess,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// View Reports Modal Sheet
  void _showReportsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
            border: Border.all(color: AppColors.glassBorderLight),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.borderSubtle, borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 18),
              const Text('Diagnostic & Lab Reports', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              const Text('Available medical documents for Imdad Khan', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              const SizedBox(height: 18),

              _buildReportItem(title: 'Comprehensive Blood Panel', date: 'Sep 15, 2026', doctor: 'Dr. Farzana Akter', status: 'Verified'),
              const SizedBox(height: 10),
              _buildReportItem(title: 'Electrocardiogram (ECG) Report', date: 'Sep 02, 2026', doctor: 'Dr. Sarah Jenkins', status: 'Normal'),
              const SizedBox(height: 10),
              _buildReportItem(title: 'General Consultation Summary', date: 'Aug 18, 2026', doctor: 'Dr. Ahmed Rahman', status: 'Archived'),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReportItem({
    required String title,
    required String date,
    required String doctor,
    required String status,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      borderRadius: AppRadius.card,
      child: Row(
        children: [
          const GlassSquircleIcon(
            icon: Icons.picture_as_pdf_rounded,
            backgroundColor: Color(0x26F43F5E),
            iconColor: Color(0xFFF43F5E),
            size: 38,
            iconSize: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.textMain, fontSize: 13, fontWeight: FontWeight.w700)),
                Text('$date • $doctor', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
              ],
            ),
          ),
          GlassPillBadge(label: status, variant: GlassPillVariant.completed),
        ],
      ),
    );
  }

  /// Notifications Sheet
  void _showNotificationsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final notifs = ref.watch(customerNotificationsProvider);

            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
                border: Border.all(color: AppColors.glassBorderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.borderSubtle, borderRadius: BorderRadius.circular(2))),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Notifications', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                      GlassPillBadge(label: '${notifs.length} Total', variant: GlassPillVariant.upcoming),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Expanded(
                    child: ListView.separated(
                      itemCount: notifs.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final n = notifs[index];
                        return GlassCard(
                          padding: const EdgeInsets.all(12),
                          borderRadius: AppRadius.card,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GlassSquircleIcon(
                                icon: n.category == 'queue'
                                    ? Icons.campaign_rounded
                                    : n.category == 'reminder'
                                        ? Icons.alarm_rounded
                                        : Icons.notifications_rounded,
                                backgroundColor: AppColors.cyanGlow.withValues(alpha: 0.15),
                                iconColor: AppColors.cyanGlow,
                                size: 34,
                                iconSize: 16,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(n.title, style: const TextStyle(color: AppColors.textMain, fontSize: 13, fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 2),
                                    Text(n.message, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                                    const SizedBox(height: 4),
                                    Text(n.timestamp, style: const TextStyle(color: AppColors.textSubtle, fontSize: 10)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Personal Information Sheet
  void _showPersonalInformationModal(BuildContext context, dynamic user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
            border: Border.all(color: AppColors.glassBorderLight),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.borderSubtle, borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 18),
              const Text('Personal Information', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              _buildInfoRow('Full Name', user?.fullName ?? 'Imdad Khan'),
              _buildInfoRow('Email Address', user?.email ?? 'imdad.khan@dqms.org'),
              _buildInfoRow('Contact Phone', '+1 (555) 234-5678'),
              _buildInfoRow('Date of Birth', '14 March 1988'),
              _buildInfoRow('Blood Group', 'O Positive (O+)'),
              _buildInfoRow('Residential Address', '742 Evergreen Terrace, Sector 4'),
              const SizedBox(height: 20),
              DqmsButton(
                label: 'EDIT PROFILE',
                icon: Icons.edit_rounded,
                isFullWidth: true,
                variant: DqmsButtonVariant.secondary,
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile edit mode enabled.')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  /// Queue History Modal
  void _showQueueHistoryModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.bgSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
          title: const Text('Queue History', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHistoryTile('A011', 'General Consultation', 'Completed in 14 min', 'Sep 18, 2026'),
              const SizedBox(height: 8),
              _buildHistoryTile('B003', 'Pharmacy Dispensing', 'Completed in 6 min', 'Sep 10, 2026'),
              const SizedBox(height: 8),
              _buildHistoryTile('L004', 'Blood Sample Collection', 'Completed in 8 min', 'Aug 24, 2026'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: AppColors.cyanGlow)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHistoryTile(String token, String service, String time, String date) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.glassSurfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.glassBorderLight),
      ),
      child: Row(
        children: [
          Text(token, style: const TextStyle(color: AppColors.cyanGlow, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                Text('$time • $date', style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
              ],
            ),
          ),
          const Icon(Icons.check_circle, size: 16, color: AppColors.emeraldSuccess),
        ],
      ),
    );
  }

  /// Language Selector Modal
  void _showLanguageModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
            border: Border.all(color: AppColors.glassBorderLight),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select Language', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              _buildLangOption('English (US)', true),
              _buildLangOption('Español (Spanish)', false),
              _buildLangOption('Français (French)', false),
              _buildLangOption('বাংলা (Bengali)', false),
              _buildLangOption('العربية (Arabic)', false),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLangOption(String language, bool isSelected) {
    return ListTile(
      title: Text(language, style: TextStyle(color: isSelected ? AppColors.cyanGlow : Colors.white, fontSize: 13, fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500)),
      trailing: isSelected ? const Icon(Icons.check, color: AppColors.cyanGlow, size: 18) : null,
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Language set to $language')));
      },
    );
  }

  /// Help & Support Modal
  void _showHelpSupportModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.bgSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
          title: const Text('Help & Support', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Need assistance with your queue ticket or appointment?', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              const SizedBox(height: 14),
              _buildContactRow(Icons.call_rounded, 'Emergency Hotline: +1 (800) 555-DQMS'),
              const SizedBox(height: 8),
              _buildContactRow(Icons.email_outlined, 'Support: support@dqms.org'),
              const SizedBox(height: 8),
              _buildContactRow(Icons.chat_bubble_outline_rounded, 'Live Chat: Available 24/7 in app'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: AppColors.cyanGlow)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.cyanGlow),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12))),
      ],
    );
  }
}

/// Helper model for Quick Actions
class _QuickActionItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.onTap,
  });
}

/// Location Selector Pill with Modal Sheet
class GestureColorSelector extends StatelessWidget {
  final String currentLocation;
  final ValueChanged<String> onChanged;

  const GestureColorSelector({
    super.key,
    required this.currentLocation,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (context) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
                border: Border.all(color: AppColors.glassBorderLight),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select Medical Facility', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 14),
                  _buildLocationTile(context, 'Green Valley Medical Center', 'Main Campus • 12 Counters Active'),
                  _buildLocationTile(context, 'HQ Main Medical Center', 'Downtown • 18 Counters Active'),
                  _buildLocationTile(context, 'Downtown Diagnostic Clinic', 'West Wing • 6 Counters Active'),
                ],
              ),
            );
          },
        );
      },
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.glassSurfaceLight,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: AppColors.glassBorderLight),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_on_outlined, size: 12, color: AppColors.cyanGlow),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                currentLocation,
                style: const TextStyle(
                  color: AppColors.cyanGlow,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: AppColors.cyanGlow),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationTile(BuildContext context, String name, String subtitle) {
    final isSelected = name == currentLocation;

    return ListTile(
      title: Text(name, style: TextStyle(color: isSelected ? AppColors.cyanGlow : Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
      trailing: isSelected ? const Icon(Icons.check, color: AppColors.cyanGlow, size: 18) : null,
      onTap: () {
        onChanged(name);
        Navigator.pop(context);
      },
    );
  }
}
