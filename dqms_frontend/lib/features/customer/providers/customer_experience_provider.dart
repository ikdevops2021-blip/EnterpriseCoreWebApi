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
  final String? selectedCategory;
  final String generatedTokenNumber;
  final int estimatedWaitMins;
  final String qrCodeData;

  const KioskState({
    required this.activeStep,
    this.selectedService,
    this.selectedCategory,
    this.generatedTokenNumber = 'A-108',
    this.estimatedWaitMins = 8,
    this.qrCodeData = 'https://dqms.org/track/A-108',
  });

  KioskState copyWith({
    int? activeStep,
    String? selectedService,
    String? selectedCategory,
    String? generatedTokenNumber,
    int? estimatedWaitMins,
    String? qrCodeData,
  }) {
    return KioskState(
      activeStep: activeStep ?? this.activeStep,
      selectedService: selectedService ?? this.selectedService,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      generatedTokenNumber: generatedTokenNumber ?? this.generatedTokenNumber,
      estimatedWaitMins: estimatedWaitMins ?? this.estimatedWaitMins,
      qrCodeData: qrCodeData ?? this.qrCodeData,
    );
  }
}

class KioskNotifier extends StateNotifier<KioskState> {
  KioskNotifier() : super(const KioskState(activeStep: 0));

  void selectService(String service) {
    state = state.copyWith(selectedService: service, activeStep: 2);
  }

  void selectCategory(String category) {
    state = state.copyWith(selectedCategory: category, activeStep: 3);
  }

  void confirmAndGenerateTicket() {
    final nextTokenNum = 'A-${100 + DateTime.now().second % 50}';
    state = state.copyWith(
      generatedTokenNumber: nextTokenNum,
      estimatedWaitMins: 10,
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
