import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:core_session/domain/entities/auth_status.dart';
import 'package:core_session/domain/entities/user_session.dart';
import 'package:core_session/domain/repositories/i_session_repository.dart';
import 'package:core_session/application/session_notifier.dart';

class MockSessionRepository extends Mock implements ISessionRepository {}

void main() {
  late MockSessionRepository mockRepository;
  late StreamController<AuthStatus> statusController;

  final tSession = UserSession(
    userId: 'usr_1001',
    accessToken: 'valid_access_token_xyz',
  );

  setUp(() {
    mockRepository = MockSessionRepository();
    statusController = StreamController<AuthStatus>.broadcast();
    when(() => mockRepository.authStatusStream).thenAnswer((_) => statusController.stream);
    when(() => mockRepository.statusStream).thenAnswer((_) => statusController.stream);
  });

  tearDown(() {
    statusController.close();
  });

  group('SessionNotifier QA Tests', () {
    test('[TC-N01] SessionNotifier initializes with unauthenticated state when storage empty', () async {
      when(() => mockRepository.getSession()).thenAnswer((_) async => null);

      final notifier = SessionNotifier(mockRepository);
      await Future.delayed(Duration.zero);

      expect(notifier.state.status, equals(AuthStatus.unauthenticated));
      expect(notifier.state.session, isNull);
      expect(notifier.state.isLoading, isFalse);
    });

    test('[TC-N02] login saves session and updates state to authenticated', () async {
      when(() => mockRepository.getSession()).thenAnswer((_) async => null);
      when(() => mockRepository.saveSession(tSession)).thenAnswer((_) async {});

      final notifier = SessionNotifier(mockRepository);
      await notifier.login(tSession);

      expect(notifier.state.status, equals(AuthStatus.authenticated));
      expect(notifier.state.session, equals(tSession));
      verify(() => mockRepository.saveSession(tSession)).called(1);
    });

    test('[TC-N03] logout clears session and updates state to unauthenticated', () async {
      when(() => mockRepository.getSession()).thenAnswer((_) async => tSession);
      when(() => mockRepository.clearSession()).thenAnswer((_) async {});

      final notifier = SessionNotifier(mockRepository);
      await notifier.logout();

      expect(notifier.state.status, equals(AuthStatus.unauthenticated));
      expect(notifier.state.session, isNull);
      verify(() => mockRepository.clearSession()).called(1);
    });
  });
}
