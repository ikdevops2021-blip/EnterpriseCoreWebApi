import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dqms_frontend/core/config/app_config.dart';
import 'package:dqms_frontend/features/auth/providers/auth_provider.dart';

/// ============================================================================
/// Dio HTTP Client Provider — connects to .NET Core Web API with Auth Interceptor
/// ============================================================================
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: AppConfig.apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    validateStatus: (status) => status != null && status < 600, // Handle responses gracefully without raw crashes
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Api-Key': AppConfig.organizationApiKey,
      'X-Organization-Id': '${AppConfig.organizationId}',
    },
  ));

  // Request Interceptor to dynamically inject Bearer tokens & Tenant headers
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final authState = ref.read(authStateProvider);
        options.headers['X-Api-Key'] = AppConfig.organizationApiKey;
        options.headers['X-Organization-Id'] = '${authState.currentUser?.organizationId ?? AppConfig.organizationId}';
        options.headers['X-User-Id'] = '${authState.currentUser?.userId ?? 1}';

        if (authState.currentUser?.token != null && authState.currentUser!.token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer ${authState.currentUser!.token}';
        }
        return handler.next(options);
      },
    ),
  );

  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
  ));

  return dio;
});
