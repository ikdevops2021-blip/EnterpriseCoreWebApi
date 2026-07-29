import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ============================================================================
/// Dio HTTP Client Provider — connects to .NET Core Web API
/// ============================================================================
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    // TODO: Update to production URL or read from environment config
    baseUrl: 'http://localhost:5026',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
  ));

  return dio;
});
