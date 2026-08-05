import 'package:dio/dio.dart';
import '../../domain/entities/user_session.dart';
import '../../domain/repositories/i_session_repository.dart';

/// Abstract refresh token handler contract.
abstract class ITokenRefresher {
  Future<UserSession?> refreshTokens(UserSession currentSession);
}

/// Dio Interceptor handling dynamic Bearer token injection and automated 401 refresh/clear logic.
class SessionInterceptor extends Interceptor {
  final ISessionRepository _sessionRepository;
  final ITokenRefresher? _tokenRefresher;

  SessionInterceptor({
    required ISessionRepository sessionRepository,
    ITokenRefresher? tokenRefresher,
  })  : _sessionRepository = sessionRepository,
        _tokenRefresher = tokenRefresher;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final session = await _sessionRepository.getSession();
    if (session != null && session.accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer ${session.accessToken}';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      final currentSession = await _sessionRepository.getSession();
      
      if (currentSession != null && _tokenRefresher != null) {
        try {
          final newSession = await _tokenRefresher!.refreshTokens(currentSession);
          if (newSession != null) {
            await _sessionRepository.saveSession(newSession);

            final requestOptions = err.requestOptions;
            requestOptions.headers['Authorization'] = 'Bearer ${newSession.accessToken}';
            
            final dio = Dio();
            final response = await dio.fetch(requestOptions);
            return handler.resolve(response);
          }
        } catch (_) {
          // Token refresh failure falls through to clear session
        }
      }

      await _sessionRepository.clearSession();
    }
    handler.next(err);
  }
}
