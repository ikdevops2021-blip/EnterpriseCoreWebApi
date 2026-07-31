import 'dart:convert';
import 'package:flutter/services.dart';

/// Central Enterprise Environment & API Endpoint Configuration
class AppConfig {
  static const String _defaultApiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5026',
  );

  static Map<String, dynamic> _runtimeConfig = {};

  /// Root API Host URL
  static String get apiBaseUrl => _runtimeConfig['apiBaseUrl'] ?? _defaultApiBaseUrl;

  /// Root API V1 Prefix
  static String get apiV1Base => _runtimeConfig['apiV1Base'] ?? '$apiBaseUrl/api/v1';

  /// Specific Subsystem Endpoint Roots (Dynamically loaded without rebuilding)
  static String get adminApiBase => _runtimeConfig['adminApiBase'] ?? '$apiV1Base/admin';
  static String get dqmsApiBase => _runtimeConfig['dqmsApiBase'] ?? '$apiV1Base/dqms';
  static String get authApiBase => _runtimeConfig['authApiBase'] ?? '$apiV1Base/auth';
  static String get reportsApiBase => _runtimeConfig['reportsApiBase'] ?? '$apiV1Base/reports';

  /// Loads runtime configuration from assets/config.json dynamically at app boot.
  /// Modifying config.json on deployment updates endpoints without app re-compilation.
  static Future<void> loadRuntimeConfig() async {
    try {
      final jsonString = await rootBundle.loadString('assets/config.json');
      _runtimeConfig = json.decode(jsonString) as Map<String, dynamic>;
    } catch (_) {
      // Seamless fallback to default compile-time values if file is unreadable
    }
  }
}
