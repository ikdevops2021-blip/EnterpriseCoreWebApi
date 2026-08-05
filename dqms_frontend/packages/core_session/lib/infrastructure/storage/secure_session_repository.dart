import 'dart:async';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/entities/auth_status.dart';
import '../../domain/entities/user_session.dart';
import '../../domain/repositories/i_session_repository.dart';

/// Enterprise secure storage implementation using iOS Keychain and Android EncryptedSharedPreferences.
class SecureSessionRepository implements ISessionRepository {
  static const String _sessionStorageKey = 'core_session_secure_payload';

  final FlutterSecureStorage _storage;
  final StreamController<AuthStatus> _statusController = StreamController<AuthStatus>.broadcast();

  SecureSessionRepository({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
              webOptions: WebOptions(dbName: 'core_session_secure_db', publicKey: 'core_session_key'),
              mOptions: MacOsOptions(accessibility: KeychainAccessibility.first_unlock),
            );

  @override
  Stream<AuthStatus> get authStatusStream => _statusController.stream;

  @override
  Stream<AuthStatus> get statusStream => _statusController.stream;

  @override
  Future<void> saveSession(UserSession session) async {
    final payload = jsonEncode(session.toJson());
    await _storage.write(key: _sessionStorageKey, value: payload);
    
    if (session.isExpired) {
      _statusController.add(AuthStatus.expired);
    } else {
      _statusController.add(AuthStatus.authenticated);
    }
  }

  @override
  Future<UserSession?> getSession() async {
    try {
      final rawJson = await _storage.read(key: _sessionStorageKey);
      if (rawJson == null || rawJson.isEmpty) {
        _statusController.add(AuthStatus.unauthenticated);
        return null;
      }

      final sessionMap = jsonDecode(rawJson) as Map<String, dynamic>;
      final session = UserSession.fromJson(sessionMap);

      if (session.isExpired) {
        _statusController.add(AuthStatus.expired);
      } else {
        _statusController.add(AuthStatus.authenticated);
      }

      return session;
    } catch (_) {
      await clearSession();
      return null;
    }
  }

  @override
  Future<void> clearSession() async {
    await _storage.delete(key: _sessionStorageKey);
    _statusController.add(AuthStatus.unauthenticated);
  }

  @override
  void dispose() {
    _statusController.close();
  }
}
