import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ============================================================================
/// STAFF SESSION PROVIDER
/// Tracks the active staff session: selected process, counter, and audit trail
/// ============================================================================

/// Audit entry — one record per token action performed by this staff member
class TokenAuditEntry {
  final String tokenNumber;
  final String action; // 'Called', 'Recalled', 'Serving', 'On Hold', 'Completed', 'Cancelled', 'Issued'
  final DateTime timestamp;
  final int staffUserId;
  final String staffName;
  final String counterName;
  final String processName;
  final String? notes;
  final int? durationMins; // set when action == 'Completed'

  const TokenAuditEntry({
    required this.tokenNumber,
    required this.action,
    required this.timestamp,
    required this.staffUserId,
    required this.staffName,
    required this.counterName,
    required this.processName,
    this.notes,
    this.durationMins,
  });

  String get formattedTime {
    final h = timestamp.hour.toString().padLeft(2, '0');
    final m = timestamp.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

/// Staff Session State
class StaffSessionState {
  final int? selectedProcessId;
  final String selectedProcessName;
  final String selectedProcessCode;
  final int? selectedCounterId;
  final String selectedCounterName;
  final String selectedCounterNumber;
  final int staffUserId;
  final String staffName;
  final bool sessionActive;
  final List<TokenAuditEntry> auditLog;

  const StaffSessionState({
    this.selectedProcessId,
    this.selectedProcessName = '',
    this.selectedProcessCode = '',
    this.selectedCounterId,
    this.selectedCounterName = '',
    this.selectedCounterNumber = '',
    this.staffUserId = 0,
    this.staffName = '',
    this.sessionActive = false,
    this.auditLog = const [],
  });

  StaffSessionState copyWith({
    int? selectedProcessId,
    String? selectedProcessName,
    String? selectedProcessCode,
    int? selectedCounterId,
    String? selectedCounterName,
    String? selectedCounterNumber,
    int? staffUserId,
    String? staffName,
    bool? sessionActive,
    List<TokenAuditEntry>? auditLog,
  }) {
    return StaffSessionState(
      selectedProcessId: selectedProcessId ?? this.selectedProcessId,
      selectedProcessName: selectedProcessName ?? this.selectedProcessName,
      selectedProcessCode: selectedProcessCode ?? this.selectedProcessCode,
      selectedCounterId: selectedCounterId ?? this.selectedCounterId,
      selectedCounterName: selectedCounterName ?? this.selectedCounterName,
      selectedCounterNumber: selectedCounterNumber ?? this.selectedCounterNumber,
      staffUserId: staffUserId ?? this.staffUserId,
      staffName: staffName ?? this.staffName,
      sessionActive: sessionActive ?? this.sessionActive,
      auditLog: auditLog ?? this.auditLog,
    );
  }

  /// Today's audit log sorted newest first
  List<TokenAuditEntry> get todayLog {
    final today = DateTime.now();
    return auditLog
        .where((e) =>
            e.timestamp.year == today.year &&
            e.timestamp.month == today.month &&
            e.timestamp.day == today.day)
        .toList()
        .reversed
        .toList();
  }

  int get tokensCompleted => auditLog.where((e) => e.action == 'Completed').length;
  int get tokensCancelled => auditLog.where((e) => e.action == 'Cancelled').length;
  int get totalCalled => auditLog.where((e) => e.action == 'Called').length;
}

/// Staff Session Notifier
class StaffSessionNotifier extends StateNotifier<StaffSessionState> {
  StaffSessionNotifier() : super(const StaffSessionState());

  /// Called from LoginScreen after successful login
  void initStaff(int userId, String name) {
    state = state.copyWith(staffUserId: userId, staffName: name);
  }

  /// Step 1 of lobby: select a process
  void selectProcess(int processId, String name, String code) {
    state = state.copyWith(
      selectedProcessId: processId,
      selectedProcessName: name,
      selectedProcessCode: code,
      // Reset counter selection when process changes
      selectedCounterId: null,
      selectedCounterName: '',
      selectedCounterNumber: '',
      sessionActive: false,
    );
  }

  /// Step 2 of lobby: select a counter
  void selectCounter(int counterId, String name, String number) {
    state = state.copyWith(
      selectedCounterId: counterId,
      selectedCounterName: name,
      selectedCounterNumber: number,
    );
  }

  /// Activate the session — staff clicks "OPEN STATION"
  void openStation() {
    if (state.selectedProcessId != null && state.selectedCounterId != null) {
      state = state.copyWith(sessionActive: true);
    }
  }

  /// Log a token action for audit trail
  void logAction(
    String tokenNumber,
    String action, {
    String? notes,
    int? durationMins,
  }) {
    final entry = TokenAuditEntry(
      tokenNumber: tokenNumber,
      action: action,
      timestamp: DateTime.now(),
      staffUserId: state.staffUserId,
      staffName: state.staffName,
      counterName: state.selectedCounterName,
      processName: state.selectedProcessName,
      notes: notes,
      durationMins: durationMins,
    );
    state = state.copyWith(auditLog: [...state.auditLog, entry]);
  }

  /// End session — returns to lobby
  void endSession() {
    state = state.copyWith(
      sessionActive: false,
      selectedProcessId: null,
      selectedProcessName: '',
      selectedProcessCode: '',
      selectedCounterId: null,
      selectedCounterName: '',
      selectedCounterNumber: '',
    );
  }

  /// Full reset on logout
  void reset() {
    state = const StaffSessionState();
  }
}

final staffSessionProvider =
    StateNotifierProvider<StaffSessionNotifier, StaffSessionState>((ref) {
  return StaffSessionNotifier();
});
