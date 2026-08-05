import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/auth_status.dart';
import '../domain/entities/user_session.dart';
import '../domain/repositories/i_session_repository.dart';

/// Riverpod State Container for reactive session state management.
class SessionState {
  final AuthStatus status;
  final UserSession? session;
  final bool isLoading;

  const SessionState({
    required this.status,
    this.session,
    this.isLoading = false,
  });

  factory SessionState.initial() => const SessionState(
        status: AuthStatus.unknown,
        isLoading: true,
      );

  SessionState copyWith({
    AuthStatus? status,
    UserSession? session,
    bool? isLoading,
  }) {
    return SessionState(
      status: status ?? this.status,
      session: session ?? this.session,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SessionState &&
        other.status == status &&
        other.session == session &&
        other.isLoading == isLoading;
  }

  @override
  int get hashCode => Object.hash(status, session, isLoading);
}

class SessionNotifier extends StateNotifier<SessionState> {
  final ISessionRepository _repository;
  late final StreamSubscription<AuthStatus> _statusSub;

  SessionNotifier(this._repository) : super(SessionState.initial()) {
    _init();
  }

  Future<void> _init() async {
    _statusSub = _repository.authStatusStream.listen((status) {
      state = state.copyWith(status: status, isLoading: false);
    });

    final currentSession = await _repository.getSession();
    if (currentSession != null) {
      state = SessionState(
        status: currentSession.isExpired ? AuthStatus.expired : AuthStatus.authenticated,
        session: currentSession,
        isLoading: false,
      );
    } else {
      state = const SessionState(
        status: AuthStatus.unauthenticated,
        session: null,
        isLoading: false,
      );
    }
  }

  Future<void> login(UserSession session) async {
    state = state.copyWith(isLoading: true);
    await _repository.saveSession(session);
    state = SessionState(
      status: AuthStatus.authenticated,
      session: session,
      isLoading: false,
    );
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await _repository.clearSession();
    state = const SessionState(
      status: AuthStatus.unauthenticated,
      session: null,
      isLoading: false,
    );
  }

  @override
  void dispose() {
    _statusSub.cancel();
    super.dispose();
  }
}
