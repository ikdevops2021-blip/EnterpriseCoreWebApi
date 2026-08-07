import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/features/customer/providers/customer_experience_provider.dart';

/// ============================================================================
/// SCHEDULED APPOINTMENTS CALENDAR SCREEN (`table_calendar`)
/// Multi-tenant, domain-agnostic interactive calendar for managing pre-booked appointments.
/// ============================================================================
class AppointmentsCalendarScreen extends ConsumerStatefulWidget {
  const AppointmentsCalendarScreen({super.key});

  @override
  ConsumerState<AppointmentsCalendarScreen> createState() => _AppointmentsCalendarScreenState();
}

class _AppointmentsCalendarScreenState extends ConsumerState<AppointmentsCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  String _filterLocation = 'All Locations';
  final String _filterStatus = 'All Statuses';

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<ScheduledAppointmentModel> _getEventsForDay(
    DateTime day,
    List<ScheduledAppointmentModel> appointments,
  ) {
    return appointments.where((apt) {
      final isSameDate = _isSameDay(apt.scheduledDateTime, day);
      final matchesLocation = _filterLocation == 'All Locations' || apt.locationName == _filterLocation;
      final matchesStatus = _filterStatus == 'All Statuses' || apt.status == _filterStatus;
      return isSameDate && matchesLocation && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final appointments = ref.watch(scheduledAppointmentsProvider);
    final selectedDayAppointments = _getEventsForDay(_selectedDay ?? DateTime.now(), appointments);

    final totalScheduled = appointments.length;
    final checkedInToday = appointments.where((a) => a.status == 'Checked-In').length;
    final pendingCount = appointments.where((a) => a.status == 'Pending').length;
    final completedCount = appointments.where((a) => a.status == 'Completed').length;

    return Scaffold(
      backgroundColor: AppColors.bgCanvas,
      body: SafeArea(
        child: Column(
          children: [
            // ----------------------------------------------------------------
            // 1. Top Header & KPI Telemetry Row
            // ----------------------------------------------------------------
            _buildTopHeader(context),
            _buildTelemetryBar(
              totalScheduled: totalScheduled,
              checkedInToday: checkedInToday,
              pendingCount: pendingCount,
              completedCount: completedCount,
            ),
            const Divider(color: AppColors.borderSubtle, height: 1),

            // ----------------------------------------------------------------
            // 2. Main Calendar & Details Grid
            // ----------------------------------------------------------------
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 900;
                  return isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left Pane: Table Calendar
                            Expanded(
                              flex: 3,
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.all(16),
                                child: _buildCalendarCard(appointments),
                              ),
                            ),
                            // Right Pane: Selected Day Details Side Panel
                            Expanded(
                              flex: 2,
                              child: Container(
                                decoration: const BoxDecoration(
                                  border: Border(left: BorderSide(color: AppColors.borderSubtle)),
                                ),
                                child: _buildDetailsSidePanel(selectedDayAppointments),
                              ),
                            ),
                          ],
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _buildCalendarCard(appointments),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 500,
                                child: _buildDetailsSidePanel(selectedDayAppointments),
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
    );
  }

  /// Top Operational Header
  Widget _buildTopHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: AppColors.bgHeader,
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.brandPrimary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.brandPrimary.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.calendar_month_rounded, color: AppColors.brandPrimary, size: 22),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Scheduled Appointments Calendar',
                  style: TextStyle(
                    color: AppColors.textMain,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Multi-tenant appointment management & pre-booking schedule matrix',
                  style: TextStyle(color: AppColors.textSubtle, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// KPI Telemetry Bar
  Widget _buildTelemetryBar({
    required int totalScheduled,
    required int checkedInToday,
    required int pendingCount,
    required int completedCount,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: AppColors.bgSurface,
      child: Wrap(
        spacing: 16,
        runSpacing: 10,
        alignment: WrapAlignment.spaceBetween,
        children: [
          _buildKpiChip('TOTAL SCHEDULED', '$totalScheduled', Icons.bookmark_added_rounded, AppColors.brandPrimary),
          _buildKpiChip('CHECKED-IN TODAY', '$checkedInToday', Icons.how_to_reg_rounded, AppColors.statusActive),
          _buildKpiChip('PENDING CONFIRMATION', '$pendingCount', Icons.pending_actions_rounded, AppColors.statusWarning),
          _buildKpiChip('COMPLETED', '$completedCount', Icons.task_alt_rounded, AppColors.brandAccent),
        ],
      ),
    );
  }

  Widget _buildKpiChip(String label, String value, IconData icon, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Text('$label: ', style: const TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w600)),
        Text(value, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w800)),
      ],
    );
  }

  /// Table Calendar Card View
  Widget _buildCalendarCard(List<ScheduledAppointmentModel> appointments) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Filter & Format Switchers Header
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                const Icon(Icons.filter_list_rounded, color: AppColors.textMuted, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _filterLocation,
                      dropdownColor: AppColors.bgSurface,
                      style: const TextStyle(color: AppColors.textMain, fontSize: 12, fontWeight: FontWeight.w600),
                      items: ['All Locations', 'HQ Main Medical Center', 'West Wing Regional Center']
                          .map((loc) => DropdownMenuItem(value: loc, child: Text(loc)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _filterLocation = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SegmentedButton<CalendarFormat>(
                  segments: const [
                    ButtonSegment(value: CalendarFormat.month, label: Text('Month', style: TextStyle(fontSize: 11))),
                    ButtonSegment(value: CalendarFormat.twoWeeks, label: Text('2-Wk', style: TextStyle(fontSize: 11))),
                    ButtonSegment(value: CalendarFormat.week, label: Text('Week', style: TextStyle(fontSize: 11))),
                  ],
                  selected: {_calendarFormat},
                  onSelectionChanged: (set) => setState(() => _calendarFormat = set.first),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.borderSubtle, height: 1),

          // TableCalendar Widget
          TableCalendar<ScheduledAppointmentModel>(
            firstDay: DateTime.utc(2025, 1, 1),
            lastDay: DateTime.utc(2027, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => _isSameDay(_selectedDay, day),
            eventLoader: (day) => _getEventsForDay(day, appointments),
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(color: AppColors.textMain, fontSize: 15, fontWeight: FontWeight.w800),
              leftChevronIcon: Icon(Icons.chevron_left_rounded, color: AppColors.textMain),
              rightChevronIcon: Icon(Icons.chevron_right_rounded, color: AppColors.textMain),
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(color: AppColors.textSubtle, fontSize: 12, fontWeight: FontWeight.w700),
              weekendStyle: TextStyle(color: AppColors.brandAccent, fontSize: 12, fontWeight: FontWeight.w700),
            ),
            calendarStyle: CalendarStyle(
              defaultTextStyle: const TextStyle(color: AppColors.textMain, fontSize: 13),
              weekendTextStyle: const TextStyle(color: AppColors.brandAccent, fontSize: 13),
              outsideTextStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
              todayDecoration: BoxDecoration(
                color: AppColors.brandPrimary.withValues(alpha: 0.25),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.brandPrimary, width: 1.5),
              ),
              todayTextStyle: const TextStyle(color: AppColors.brandPrimary, fontWeight: FontWeight.w800),
              selectedDecoration: const BoxDecoration(
                color: AppColors.brandPrimary,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isEmpty) return const SizedBox.shrink();
                return Positioned(
                  bottom: 4,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: events.take(3).map((event) {
                      Color color = AppColors.brandPrimary;
                      if (event.status == 'Checked-In') color = AppColors.statusActive;
                      if (event.status == 'Pending') color = AppColors.statusWarning;
                      if (event.status == 'Completed') color = AppColors.brandAccent;

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() => _calendarFormat = format);
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  /// Details Side Panel for Selected Day
  Widget _buildDetailsSidePanel(List<ScheduledAppointmentModel> dayAppointments) {
    final selectedDateStr = DateFormat.yMMMMEEEEd().format(_selectedDay ?? DateTime.now());

    return Container(
      color: AppColors.bgSurface,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.event_note_rounded, color: AppColors.brandPrimary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  selectedDateStr,
                  style: const TextStyle(
                    color: AppColors.textMain,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${dayAppointments.length} appointment(s) scheduled',
            style: const TextStyle(color: AppColors.textSubtle, fontSize: 11),
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.borderSubtle, height: 1),

          // Appointment List
          Expanded(
            child: dayAppointments.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.event_available_rounded, color: AppColors.textMuted, size: 40),
                        SizedBox(height: 12),
                        Text(
                          'No Appointments Scheduled',
                          style: TextStyle(color: AppColors.textSubtle, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Select a marked date on the calendar to view bookings.',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: dayAppointments.length,
                    itemBuilder: (context, index) {
                      final apt = dayAppointments[index];
                      return _buildAppointmentCard(apt);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Individual Appointment Card Tile
  Widget _buildAppointmentCard(ScheduledAppointmentModel apt) {
    Color badgeColor = AppColors.brandPrimary;
    if (apt.status == 'Checked-In') badgeColor = AppColors.statusActive;
    if (apt.status == 'Pending') badgeColor = AppColors.statusWarning;
    if (apt.status == 'Completed') badgeColor = AppColors.brandAccent;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCanvas,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time Slot & Status Pill Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.access_time_rounded, color: AppColors.brandPrimary, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    apt.timeSlot,
                    style: const TextStyle(
                      color: AppColors.brandPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  apt.status.toUpperCase(),
                  style: TextStyle(
                    color: badgeColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Visitor / Person Name (Domain-Agnostic)
          Text(
            apt.visitorName,
            style: const TextStyle(
              color: AppColors.textMain,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),

          // Service & Location Info
          Row(
            children: [
              const Icon(Icons.business_center_rounded, color: AppColors.textSubtle, size: 13),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  apt.serviceName,
                  style: const TextStyle(color: AppColors.textSubtle, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              const Icon(Icons.location_on_rounded, color: AppColors.textSubtle, size: 13),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  apt.locationName,
                  style: const TextStyle(color: AppColors.textSubtle, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Action Buttons Row
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (apt.status == 'Confirmed' || apt.status == 'Pending')
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.statusActive,
                    side: const BorderSide(color: AppColors.statusActive),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  ),
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 14),
                  label: const Text('Check In', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                  onPressed: () {
                    ref.read(scheduledAppointmentsProvider.notifier).updateStatus(apt.appointmentId, 'Checked-In');
                  },
                ),
              const SizedBox(width: 8),
              if (apt.status == 'Checked-In')
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  ),
                  icon: const Icon(Icons.task_alt_rounded, color: Colors.white, size: 14),
                  label: const Text('Complete', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                  onPressed: () {
                    ref.read(scheduledAppointmentsProvider.notifier).updateStatus(apt.appointmentId, 'Completed');
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}
