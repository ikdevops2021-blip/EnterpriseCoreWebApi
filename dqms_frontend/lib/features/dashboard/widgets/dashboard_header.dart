import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/features/dashboard/providers/dashboard_provider.dart';
import 'package:dqms_frontend/features/customer/kiosk/screens/kiosk_screen.dart';
import 'package:dqms_frontend/features/customer/mobile/screens/mobile_tracker_screen.dart';
import 'package:dqms_frontend/features/customer/appointment/screens/appointment_booking_screen.dart';
import 'package:dqms_frontend/features/customer/tv/screens/waiting_room_tv_screen.dart';

/// ============================================================================
/// COMMAND CENTER DASHBOARD HEADER
/// Top status & operational control bar with live status, clock, & area filter
/// ============================================================================
class DashboardHeader extends ConsumerStatefulWidget {
  const DashboardHeader({super.key});

  @override
  ConsumerState<DashboardHeader> createState() => _DashboardHeaderState();
}

class _DashboardHeaderState extends ConsumerState<DashboardHeader> {
  late Timer _timer;
  late DateTime _currentTime;
  String _selectedZone = 'All Areas / Main HQ';

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatTwoDigits(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final timeStr = '${_formatTwoDigits(_currentTime.hour)}:${_formatTwoDigits(_currentTime.minute)}:${_formatTwoDigits(_currentTime.second)}';
    final dateStr = '${_currentTime.year}-${_formatTwoDigits(_currentTime.month)}-${_formatTwoDigits(_currentTime.day)}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.bgHeader,
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle, width: 1)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Command Center Title Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.brandPrimary.withValues(alpha: 0.25),
                    AppColors.neonCyan.withValues(alpha: 0.15),
                  ],
                ),
                border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.dashboard_customize_rounded, color: AppColors.neonCyan, size: 14),
                  SizedBox(width: 6),
                  Text(
                    'COMMAND CENTER',
                    style: TextStyle(
                      color: AppColors.neonCyan,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),

            // Live Operational Status Indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.statusActive.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.statusActive.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.fiber_manual_record, color: AppColors.statusActive, size: 8),
                  SizedBox(width: 6),
                  Text(
                    'LIVE OPERATIONAL',
                    style: TextStyle(
                      color: AppColors.statusActive,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),

            // Zone / Branch Filter Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedZone,
                  dropdownColor: AppColors.bgSurface,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted, size: 18),
                  style: const TextStyle(color: AppColors.textMain, fontSize: 12, fontWeight: FontWeight.w600),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedZone = val;
                      });
                    }
                  },
                  items: const [
                    DropdownMenuItem(value: 'All Areas / Main HQ', child: Text('All Areas / Main HQ')),
                    DropdownMenuItem(value: 'Main Service Hall A', child: Text('Main Service Hall A')),
                    DropdownMenuItem(value: 'Priority Wing B', child: Text('Priority Wing B')),
                    DropdownMenuItem(value: 'Express Desk C', child: Text('Express Desk C')),
                    DropdownMenuItem(value: 'VIP Lounge D', child: Text('VIP Lounge D')),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 20),

            // System Time Clock
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time_filled_rounded, color: AppColors.brandAccent, size: 14),
                  const SizedBox(width: 8),
                  Text(
                    '$dateStr  |  $timeStr',
                    style: const TextStyle(
                      color: AppColors.textMain,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),

            // Refresh Button
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: AppColors.textMuted, size: 20),
              tooltip: 'Sync Real-Time Metrics',
              onPressed: () {
                ref.read(dashboardStateProvider.notifier).refreshState();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Command Center metrics refreshed.'),
                    backgroundColor: AppColors.brandPrimary,
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
            const SizedBox(width: 12),

            // Customer Experience Dropdown Menu
            PopupMenuButton<String>(
              icon: const Icon(Icons.open_in_new_rounded, color: AppColors.brandPrimary, size: 20),
              tooltip: 'Open Customer Experience Interfaces',
              color: AppColors.bgSurface,
              onSelected: (val) {
                if (val == 'kiosk') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const KioskScreen()));
                } else if (val == 'mobile') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MobileTrackerScreen()));
                } else if (val == 'appointment') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AppointmentBookingScreen()));
                } else if (val == 'tv') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const WaitingRoomTvScreen()));
                }
              },
              itemBuilder: (ctx) => const [
                PopupMenuItem(value: 'kiosk', child: Row(children: [Icon(Icons.touch_app_rounded, color: AppColors.brandPrimary, size: 16), SizedBox(width: 8), Text('Self-Service Kiosk')])),
                PopupMenuItem(value: 'mobile', child: Row(children: [Icon(Icons.phone_iphone_rounded, color: AppColors.brandAccent, size: 16), SizedBox(width: 8), Text('Mobile Ticket Tracker')])),
                PopupMenuItem(value: 'appointment', child: Row(children: [Icon(Icons.calendar_month_rounded, color: AppColors.statusActive, size: 16), SizedBox(width: 8), Text('Appointment Pre-Booking')])),
                PopupMenuItem(value: 'tv', child: Row(children: [Icon(Icons.tv_rounded, color: AppColors.statusSpecial, size: 16), SizedBox(width: 8), Text('Waiting Room 4K TV')])),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
