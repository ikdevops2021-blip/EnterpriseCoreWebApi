import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:core_session/domain/entities/auth_status.dart';
import 'package:core_session/domain/entities/user_session.dart';
import 'package:core_session/infrastructure/storage/secure_session_repository.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockFlutterSecureStorage mockStorage;
  late SecureSessionRepository repository;

  final tSession = UserSession(
    userId: 'usr_1001',
    accessToken: 'valid_access_token_xyz',
    refreshToken: 'valid_refresh_token_123',
    expiresAt: DateTime.now().add(const Duration(hours: 2)),
    metadata: const {'role': 'SuperAdmin'},
  );

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    repository = SecureSessionRepository(storage: mockStorage);
  });

  tearDown(() {
    repository.dispose();
  });

  group('SecureSessionRepository QA Tests', () {
    test('[TC-S01] saveSession writes encrypted JSON payload to secure storage and emits authenticated', () async {
      when(() => mockStorage.write(key: any(named: 'key'), value: any(named: 'value')))
          .thenAnswer((_) async {});

      expectLater(repository.authStatusStream, emits(AuthStatus.authenticated));

      await repository.saveSession(tSession);

      verify(() => mockStorage.write(
            key: 'core_session_secure_payload',
            value: any(named: 'value'),
          )).called(1);
    });

    test('[TC-S02] getSession returns valid UserSession when storage payload exists', () async {
      final jsonPayload = jsonEncode(tSession.toJson());
      when(() => mockStorage.read(key: any(named: 'key')))
          .thenAnswer((_) async => jsonPayload);

      final result = await repository.getSession();

      expect(result?.userId, equals(tSession.userId));
      expect(result?.accessToken, equals(tSession.accessToken));
    });

    test('[TC-S03] getSession emits unauthenticated when storage is empty', () async {
      when(() => mockStorage.read(key: any(named: 'key')))
          .thenAnswer((_) async => null);

      expectLater(repository.statusStream, emits(AuthStatus.unauthenticated));

      final result = await repository.getSession();

      expect(result, isNull);
    });

    test('[TC-S04] clearSession deletes key from storage and emits unauthenticated state', () async {
      when(() => mockStorage.delete(key: any(named: 'key')))
          .thenAnswer((_) async {});

      expectLater(repository.statusStream, emits(AuthStatus.unauthenticated));

      await repository.clearSession();

      verify(() => mockStorage.delete(key: 'core_session_secure_payload')).called(1);
    });

    test('[TC-S05] getSession handles corrupted JSON payload gracefully by clearing session', () async {
      when(() => mockStorage.read(key: any(named: 'key')))
          .thenAnswer((_) async => 'CORRUPTED_NON_JSON_DATA');
      when(() => mockStorage.delete(key: any(named: 'key')))
          .thenAnswer((_) async {});

      final result = await repository.getSession();

      expect(result, isNull);
      verify(() => mockStorage.delete(key: 'core_session_secure_payload')).called(1);
    });
  });
}
