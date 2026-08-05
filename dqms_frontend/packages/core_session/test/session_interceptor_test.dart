import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:core_session/domain/entities/user_session.dart';
import 'package:core_session/domain/repositories/i_session_repository.dart';
import 'package:core_session/infrastructure/network/session_interceptor.dart';

class MockSessionRepository extends Mock implements ISessionRepository {}
class MockRequestInterceptorHandler extends Mock implements RequestInterceptorHandler {}
class MockErrorInterceptorHandler extends Mock implements ErrorInterceptorHandler {}
class MockTokenRefresher extends Mock implements ITokenRefresher {}

void main() {
  late MockSessionRepository mockRepository;
  late MockRequestInterceptorHandler mockRequestHandler;
  late MockErrorInterceptorHandler mockErrorHandler;
  late MockTokenRefresher mockRefresher;
  late SessionInterceptor interceptor;

  final tSession = UserSession(
    userId: 'usr_1001',
    accessToken: 'test_bearer_token_xyz',
  );

  setUp(() {
    mockRepository = MockSessionRepository();
    mockRequestHandler = MockRequestInterceptorHandler();
    mockErrorHandler = MockErrorInterceptorHandler();
    mockRefresher = MockTokenRefresher();
    interceptor = SessionInterceptor(
      sessionRepository: mockRepository,
      tokenRefresher: mockRefresher,
    );
  });

  group('SessionInterceptor QA Tests', () {
    test('[TC-I01] onRequest attaches Authorization Bearer token header when session exists', () async {
      when(() => mockRepository.getSession()).thenAnswer((_) async => tSession);
      final options = RequestOptions(path: '/api/v1/resource');

      await interceptor.onRequest(options, mockRequestHandler);

      expect(options.headers['Authorization'], equals('Bearer test_bearer_token_xyz'));
      verify(() => mockRequestHandler.next(options)).called(1);
    });

    test('[TC-I02] onError triggers clearSession when HTTP 401 occurs without token refresher', () async {
      final interceptorNoRefresher = SessionInterceptor(sessionRepository: mockRepository);
      final err = DioException(
        requestOptions: RequestOptions(path: '/api/v1/protected'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/protected'),
          statusCode: 401,
        ),
      );

      when(() => mockRepository.getSession()).thenAnswer((_) async => tSession);
      when(() => mockRepository.clearSession()).thenAnswer((_) async {});

      await interceptorNoRefresher.onError(err, mockErrorHandler);

      verify(() => mockRepository.clearSession()).called(1);
      verify(() => mockErrorHandler.next(err)).called(1);
    });
  });
}
