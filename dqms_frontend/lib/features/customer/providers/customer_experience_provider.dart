import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ============================================================================
/// PHASE 6 CUSTOMER EXPERIENCE — STATE MODELS & PROVIDERS
/// Structured state management for Kiosk, Mobile Tracker, Appointment, & TV Display
/// ============================================================================

// ---------------------------------------------------------------------------
// 1. KIOSK STATE
// ---------------------------------------------------------------------------
class KioskState {
  final int activeStep; // 0: Welcome, 1: Service, 2: Category, 3: Confirm, 4: Ticket Generated
  final String? selectedService;
  final int? selectedProcessId;
  final String? selectedProcessCode;
  final String? selectedCategory;
  final String searchQuery;
  final String? customerName;
  final String? mobileNumber;
  final String generatedTokenNumber;
  final int estimatedWaitMins;
  final String qrCodeData;

  const KioskState({
    required this.activeStep,
    this.selectedService,
    this.selectedProcessId,
    this.selectedProcessCode,
    this.selectedCategory,
    this.searchQuery = '',
    this.customerName,
    this.mobileNumber,
    this.generatedTokenNumber = 'A-108',
    this.estimatedWaitMins = 8,
    this.qrCodeData = 'https://dqms.org/track/A-108',
  });

  KioskState copyWith({
    int? activeStep,
    String? selectedService,
    int? selectedProcessId,
    String? selectedProcessCode,
    String? selectedCategory,
    String? searchQuery,
    String? customerName,
    String? mobileNumber,
    String? generatedTokenNumber,
    int? estimatedWaitMins,
    String? qrCodeData,
  }) {
    return KioskState(
      activeStep: activeStep ?? this.activeStep,
      selectedService: selectedService ?? this.selectedService,
      selectedProcessId: selectedProcessId ?? this.selectedProcessId,
      selectedProcessCode: selectedProcessCode ?? this.selectedProcessCode,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      customerName: customerName ?? this.customerName,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      generatedTokenNumber: generatedTokenNumber ?? this.generatedTokenNumber,
      estimatedWaitMins: estimatedWaitMins ?? this.estimatedWaitMins,
      qrCodeData: qrCodeData ?? this.qrCodeData,
    );
  }
}

class KioskNotifier extends StateNotifier<KioskState> {
  KioskNotifier() : super(const KioskState(activeStep: 0));

  void startCheckIn() {
    state = state.copyWith(activeStep: 1, searchQuery: '');
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void selectService(String service, {int? processId, String? processCode, int? slaMins}) {
    state = state.copyWith(
      selectedService: service,
      selectedProcessId: processId,
      selectedProcessCode: processCode,
      estimatedWaitMins: slaMins ?? 10,
      activeStep: 2,
    );
  }

  void selectCategory(String category) {
    state = state.copyWith(selectedCategory: category, activeStep: 3);
  }

  void setCustomerInfo({String? name, String? mobile}) {
    state = state.copyWith(customerName: name, mobileNumber: mobile);
  }

  void goToStep(int step) {
    state = state.copyWith(activeStep: step);
  }

  void confirmAndGenerateTicket() {
    final prefix = state.selectedProcessCode != null && state.selectedProcessCode!.isNotEmpty
        ? state.selectedProcessCode!.replaceAll('PROC-', 'P-')
        : 'A';
    final tokenSeq = 100 + DateTime.now().second % 50;
    final nextTokenNum = '$prefix-$tokenSeq';
    state = state.copyWith(
      generatedTokenNumber: nextTokenNum,
      estimatedWaitMins: state.estimatedWaitMins,
      qrCodeData: 'https://dqms.org/track/$nextTokenNum',
      activeStep: 4,
    );
  }

  void reset() {
    state = const KioskState(activeStep: 0);
  }
}

final kioskStateProvider = StateNotifierProvider<KioskNotifier, KioskState>((ref) {
  return KioskNotifier();
});

// ---------------------------------------------------------------------------
// 2. MOBILE TRACKER STATE
// ---------------------------------------------------------------------------
class MobileTicketState {
  final String tokenNumber;
  final String customerName;
  final String serviceName;
  final String status; // 'Waiting', 'Calling', 'Serving', 'Completed'
  final int customersAhead;
  final int estimatedWaitMins;
  final String assignedCounter;
  final String counterName;

  const MobileTicketState({
    required this.tokenNumber,
    required this.customerName,
    required this.serviceName,
    required this.status,
    required this.customersAhead,
    required this.estimatedWaitMins,
    required this.assignedCounter,
    required this.counterName,
  });

  factory MobileTicketState.demo() {
    return const MobileTicketState(
      tokenNumber: 'A-108',
      customerName: 'Marcus Vance',
      serviceName: 'Patient Registration & Triage',
      status: 'Calling', // Toggle between 'Waiting' and 'Calling'
      customersAhead: 0,
      estimatedWaitMins: 0,
      assignedCounter: 'C-01',
      counterName: 'Registration Station 1',
    );
  }

  MobileTicketState copyWith({
    String? tokenNumber,
    String? customerName,
    String? serviceName,
    String? status,
    int? customersAhead,
    int? estimatedWaitMins,
    String? assignedCounter,
    String? counterName,
  }) {
    return MobileTicketState(
      tokenNumber: tokenNumber ?? this.tokenNumber,
      customerName: customerName ?? this.customerName,
      serviceName: serviceName ?? this.serviceName,
      status: status ?? this.status,
      customersAhead: customersAhead ?? this.customersAhead,
      estimatedWaitMins: estimatedWaitMins ?? this.estimatedWaitMins,
      assignedCounter: assignedCounter ?? this.assignedCounter,
      counterName: counterName ?? this.counterName,
    );
  }
}

class MobileTicketNotifier extends StateNotifier<MobileTicketState> {
  MobileTicketNotifier() : super(MobileTicketState.demo());

  void toggleCallingState() {
    if (state.status == 'Calling') {
      state = state.copyWith(
        status: 'Waiting',
        customersAhead: 3,
        estimatedWaitMins: 8,
      );
    } else {
      state = state.copyWith(
        status: 'Calling',
        customersAhead: 0,
        estimatedWaitMins: 0,
        assignedCounter: 'C-01',
      );
    }
  }
}

final mobileTicketStateProvider = StateNotifierProvider<MobileTicketNotifier, MobileTicketState>((ref) {
  return MobileTicketNotifier();
});

// ---------------------------------------------------------------------------
// 3. APPOINTMENT BOOKING STATE
// ---------------------------------------------------------------------------
class AppointmentBookingState {
  final int activeStep; // 0: Location, 1: Service, 2: DateTime, 3: CustomerDetails, 4: Confirmation
  final String? selectedLocation;
  final String? selectedService;
  final String? selectedDate;
  final String? selectedTimeSlot;
  final String fullName;
  final String email;
  final String mobile;
  final String bookingReference;
  final String qrPassCode;

  const AppointmentBookingState({
    required this.activeStep,
    this.selectedLocation,
    this.selectedService,
    this.selectedDate,
    this.selectedTimeSlot,
    this.fullName = '',
    this.email = '',
    this.mobile = '',
    this.bookingReference = 'APT-9842',
    this.qrPassCode = 'PASS-9842-DQMS',
  });

  AppointmentBookingState copyWith({
    int? activeStep,
    String? selectedLocation,
    String? selectedService,
    String? selectedDate,
    String? selectedTimeSlot,
    String? fullName,
    String? email,
    String? mobile,
    String? bookingReference,
    String? qrPassCode,
  }) {
    return AppointmentBookingState(
      activeStep: activeStep ?? this.activeStep,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      selectedService: selectedService ?? this.selectedService,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTimeSlot: selectedTimeSlot ?? this.selectedTimeSlot,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      bookingReference: bookingReference ?? this.bookingReference,
      qrPassCode: qrPassCode ?? this.qrPassCode,
    );
  }
}

class AppointmentBookingNotifier extends StateNotifier<AppointmentBookingState> {
  AppointmentBookingNotifier() : super(const AppointmentBookingState(activeStep: 0));

  void selectLocation(String location) {
    state = state.copyWith(selectedLocation: location, activeStep: 1);
  }

  void selectService(String service) {
    state = state.copyWith(selectedService: service, activeStep: 2);
  }

  void selectDateTime(String date, String timeSlot) {
    state = state.copyWith(selectedDate: date, selectedTimeSlot: timeSlot, activeStep: 3);
  }

  void submitCustomerDetails(String name, String email, String mobile) {
    state = state.copyWith(
      fullName: name,
      email: email,
      mobile: mobile,
      bookingReference: 'APT-${1000 + DateTime.now().second % 9000}',
      activeStep: 4,
    );
  }

  void reset() {
    state = const AppointmentBookingState(activeStep: 0);
  }
}

final appointmentBookingStateProvider = StateNotifierProvider<AppointmentBookingNotifier, AppointmentBookingState>((ref) {
  return AppointmentBookingNotifier();
});

// ---------------------------------------------------------------------------
// 4. WAITING ROOM TV DISPLAY STATE
// ---------------------------------------------------------------------------
class TvCallItem {
  final String tokenNumber;
  final String counterNumber;
  final String timestamp;

  const TvCallItem({
    required this.tokenNumber,
    required this.counterNumber,
    required this.timestamp,
  });
}

class WaitingRoomTvState {
  final String nowCallingToken;
  final String nowCallingCounter;
  final String nowCallingService;
  final List<TvCallItem> recentCalls;
  final String tickerText;

  const WaitingRoomTvState({
    required this.nowCallingToken,
    required this.nowCallingCounter,
    required this.nowCallingService,
    required this.recentCalls,
    required this.tickerText,
  });

  factory WaitingRoomTvState.demo() {
    return const WaitingRoomTvState(
      nowCallingToken: 'A-108',
      nowCallingCounter: 'COUNTER C-01',
      nowCallingService: 'Main Service Hall A • Registration',
      recentCalls: [
        TvCallItem(tokenNumber: 'A-107', counterNumber: 'C-02', timestamp: '14:28'),
        TvCallItem(tokenNumber: 'B-204', counterNumber: 'C-04', timestamp: '14:26'),
        TvCallItem(tokenNumber: 'C-301', counterNumber: 'C-06', timestamp: '14:25'),
        TvCallItem(tokenNumber: 'A-106', counterNumber: 'C-03', timestamp: '14:22'),
        TvCallItem(tokenNumber: 'E-501', counterNumber: 'C-08', timestamp: '14:20'),
      ],
      tickerText: 'Welcome to DQMS Medical Center. Please keep your ticket until your number is announced on screen.',
    );
  }
}

final waitingRoomTvStateProvider = StateProvider<WaitingRoomTvState>((ref) {
  return WaitingRoomTvState.demo();
});

// ---------------------------------------------------------------------------
// 5. SCHEDULED APPOINTMENTS CALENDAR DOMAIN-AGNOSTIC STATE
// ---------------------------------------------------------------------------
class ScheduledAppointmentModel {
  final String appointmentId;
  final String visitorName;
  final String contactPhone;
  final String email;
  final String serviceName;
  final String locationName;
  final DateTime scheduledDateTime;
  final String timeSlot;
  final String status; // 'Confirmed', 'Checked-In', 'Completed', 'Canceled', 'Pending'
  final String qrPassCode;

  const ScheduledAppointmentModel({
    required this.appointmentId,
    required this.visitorName,
    required this.contactPhone,
    required this.email,
    required this.serviceName,
    required this.locationName,
    required this.scheduledDateTime,
    required this.timeSlot,
    required this.status,
    required this.qrPassCode,
  });

  ScheduledAppointmentModel copyWith({
    String? appointmentId,
    String? visitorName,
    String? contactPhone,
    String? email,
    String? serviceName,
    String? locationName,
    DateTime? scheduledDateTime,
    String? timeSlot,
    String? status,
    String? qrPassCode,
  }) {
    return ScheduledAppointmentModel(
      appointmentId: appointmentId ?? this.appointmentId,
      visitorName: visitorName ?? this.visitorName,
      contactPhone: contactPhone ?? this.contactPhone,
      email: email ?? this.email,
      serviceName: serviceName ?? this.serviceName,
      locationName: locationName ?? this.locationName,
      scheduledDateTime: scheduledDateTime ?? this.scheduledDateTime,
      timeSlot: timeSlot ?? this.timeSlot,
      status: status ?? this.status,
      qrPassCode: qrPassCode ?? this.qrPassCode,
    );
  }
}

class ScheduledAppointmentsNotifier extends StateNotifier<List<ScheduledAppointmentModel>> {
  ScheduledAppointmentsNotifier() : super(_generateDemoAppointments());

  static List<ScheduledAppointmentModel> _generateDemoAppointments() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return [
      ScheduledAppointmentModel(
        appointmentId: 'APT-9011',
        visitorName: 'Marcus Vance',
        contactPhone: '+1 (555) 234-5678',
        email: 'marcus.vance@dqms.org',
        serviceName: 'Patient Registration & Check-in',
        locationName: 'HQ Main Medical Center',
        scheduledDateTime: today.add(const Duration(hours: 9, minutes: 30)),
        timeSlot: '09:30 AM - 10:00 AM',
        status: 'Checked-In',
        qrPassCode: 'PASS-9011-DQMS',
      ),
      ScheduledAppointmentModel(
        appointmentId: 'APT-9012',
        visitorName: 'Elena Rostova',
        contactPhone: '+1 (555) 876-5432',
        email: 'elena.rostova@dqms.org',
        serviceName: 'Fast-Track Billing & Cashier',
        locationName: 'HQ Main Medical Center',
        scheduledDateTime: today.add(const Duration(hours: 10, minutes: 15)),
        timeSlot: '10:15 AM - 10:45 AM',
        status: 'Confirmed',
        qrPassCode: 'PASS-9012-DQMS',
      ),
      ScheduledAppointmentModel(
        appointmentId: 'APT-9013',
        visitorName: 'Johnathan Smith',
        contactPhone: '+1 (555) 432-1098',
        email: 'john.smith@enterprise.org',
        serviceName: 'Executive VIP Consultation',
        locationName: 'West Wing Regional Center',
        scheduledDateTime: today.add(const Duration(hours: 11, minutes: 0)),
        timeSlot: '11:00 AM - 11:30 AM',
        status: 'Confirmed',
        qrPassCode: 'PASS-9013-DQMS',
      ),
      ScheduledAppointmentModel(
        appointmentId: 'APT-9014',
        visitorName: 'Sarah Jenkins',
        contactPhone: '+1 (555) 654-3210',
        email: 'sarah.j@dqms.org',
        serviceName: 'Priority Screening & Advisory',
        locationName: 'HQ Main Medical Center',
        scheduledDateTime: today.add(const Duration(hours: 14, minutes: 0)),
        timeSlot: '02:00 PM - 02:30 PM',
        status: 'Pending',
        qrPassCode: 'PASS-9014-DQMS',
      ),
      ScheduledAppointmentModel(
        appointmentId: 'APT-9015',
        visitorName: 'David Kim',
        contactPhone: '+1 (555) 987-6543',
        email: 'david.kim@dqms.org',
        serviceName: 'Prescription Dispensing',
        locationName: 'HQ Main Medical Center',
        scheduledDateTime: today.add(const Duration(hours: 15, minutes: 30)),
        timeSlot: '03:30 PM - 04:00 PM',
        status: 'Confirmed',
        qrPassCode: 'PASS-9015-DQMS',
      ),
      // Future Day Appointments
      ScheduledAppointmentModel(
        appointmentId: 'APT-9021',
        visitorName: 'Maria Chen',
        contactPhone: '+1 (555) 345-6789',
        email: 'maria.chen@dqms.org',
        serviceName: 'Patient Registration & Check-in',
        locationName: 'HQ Main Medical Center',
        scheduledDateTime: today.add(const Duration(days: 1, hours: 10, minutes: 0)),
        timeSlot: '10:00 AM - 10:30 AM',
        status: 'Confirmed',
        qrPassCode: 'PASS-9021-DQMS',
      ),
      ScheduledAppointmentModel(
        appointmentId: 'APT-9022',
        visitorName: 'Alex Rivera',
        contactPhone: '+1 (555) 567-8901',
        email: 'alex.rivera@dqms.org',
        serviceName: 'Fast-Track Billing & Cashier',
        locationName: 'West Wing Regional Center',
        scheduledDateTime: today.add(const Duration(days: 2, hours: 11, minutes: 30)),
        timeSlot: '11:30 AM - 12:00 PM',
        status: 'Confirmed',
        qrPassCode: 'PASS-9022-DQMS',
      ),
      ScheduledAppointmentModel(
        appointmentId: 'APT-9023',
        visitorName: 'Priya Patel',
        contactPhone: '+1 (555) 789-0123',
        email: 'priya.patel@dqms.org',
        serviceName: 'Prescription Dispensing',
        locationName: 'HQ Main Medical Center',
        scheduledDateTime: today.add(const Duration(days: 3, hours: 14, minutes: 30)),
        timeSlot: '02:30 PM - 03:00 PM',
        status: 'Pending',
        qrPassCode: 'PASS-9023-DQMS',
      ),
      ScheduledAppointmentModel(
        appointmentId: 'APT-9024',
        visitorName: 'Robert Vance',
        contactPhone: '+1 (555) 901-2345',
        email: 'robert.vance@dqms.org',
        serviceName: 'Executive VIP Consultation',
        locationName: 'HQ Main Medical Center',
        scheduledDateTime: today.subtract(const Duration(days: 1, hours: 9, minutes: 0)),
        timeSlot: '09:00 AM - 09:30 AM',
        status: 'Completed',
        qrPassCode: 'PASS-9024-DQMS',
      ),
    ];
  }

  void updateStatus(String appointmentId, String newStatus) {
    state = [
      for (final item in state)
        if (item.appointmentId == appointmentId)
          item.copyWith(status: newStatus)
        else
          item,
    ];
  }

  void addAppointment(ScheduledAppointmentModel appointment) {
    state = [...state, appointment];
  }
}

final scheduledAppointmentsProvider =
    StateNotifierProvider<ScheduledAppointmentsNotifier, List<ScheduledAppointmentModel>>((ref) {
  return ScheduledAppointmentsNotifier();
});

