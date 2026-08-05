import '../entities/auth_status.dart';
import '../entities/user_session.dart';

/// Abstract contract for secure session persistence and reactive status streaming.
abstract class ISessionRepository {
  /// Persists a new user session securely.
  Future<void> saveSession(UserSession session);

  /// Retrieves the active user session if present and valid.
  Future<UserSession?> getSession();

  /// Clears stored credentials and resets session state.
  Future<void> clearSession();

  /// Reactive stream broadcasting session status changes.
  Stream<AuthStatus> get authStatusStream;

  /// Alias for authStatusStream for compatibility.
  Stream<AuthStatus> get statusStream;

  /// Closes stream resources.
  void dispose();
}
