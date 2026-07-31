import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:dqms_frontend/core/config/app_config.dart';

/// Centralized Client-Side Application Logger for sending logs to .NET Web API
class ClientLogger {
  ClientLogger._();

  /// Log an Info message
  static Future<void> logInfo(
    Dio dio,
    String message, {
    String loggerName = 'FlutterFrontend',
    String? url,
    String? clientInfo,
  }) async {
    await _send(dio, logLevel: 'Info', message: message, loggerName: loggerName, url: url, clientInfo: clientInfo);
  }

  /// Log a Debug message
  static Future<void> logDebug(
    Dio dio,
    String message, {
    String loggerName = 'FlutterFrontend',
    String? url,
    String? clientInfo,
  }) async {
    await _send(dio, logLevel: 'Debug', message: message, loggerName: loggerName, url: url, clientInfo: clientInfo);
  }

  /// Log a Warning message
  static Future<void> logWarning(
    Dio dio,
    String message, {
    String loggerName = 'FlutterFrontend',
    String? url,
    String? clientInfo,
  }) async {
    await _send(dio, logLevel: 'Warning', message: message, loggerName: loggerName, url: url, clientInfo: clientInfo);
  }

  /// Log an Error message with optional exception details
  static Future<void> logError(
    Dio dio,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String loggerName = 'FlutterFrontend',
    String? url,
    String? clientInfo,
  }) async {
    final exceptionStr = [
      if (error != null) error.toString(),
      if (stackTrace != null) stackTrace.toString(),
    ].join('\n');

    await _send(
      dio,
      logLevel: 'Error',
      message: message,
      loggerName: loggerName,
      exceptionDetails: exceptionStr.isNotEmpty ? exceptionStr : null,
      url: url,
      clientInfo: clientInfo,
    );
  }

  static Future<void> _send(
    Dio dio, {
    required String logLevel,
    required String message,
    required String loggerName,
    String? exceptionDetails,
    String? url,
    String? clientInfo,
  }) async {
    try {
      final payload = {
        'logLevel': logLevel,
        'message': message,
        'loggerName': loggerName,
        'exceptionDetails':? exceptionDetails,
        'url': url ?? (kIsWeb ? Uri.base.toString() : 'MobileApp'),
        'clientInfo': clientInfo ?? 'Flutter ${defaultTargetPlatform.name}',
      };

      await dio.post(
        '${AppConfig.apiBaseUrl}/api/v1/Logs',
        data: payload,
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (_) => true,
        ),
      );
    } catch (e) {
      debugPrint('ClientLogger dispatch error: $e');
    }
  }
}
