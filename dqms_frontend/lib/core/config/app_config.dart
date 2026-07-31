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

  /// Central Organization API Key and Tenant Context
  static String get organizationApiKey => _runtimeConfig['organizationApiKey'] ?? 'ORG-KEY-8871-ACME-ENTERPRISE';
  static int get organizationId => _runtimeConfig['organizationId'] ?? 1;

  /// Returns current map of active configuration endpoints
  static Map<String, dynamic> get currentEndpoints => {
    'apiBaseUrl': apiBaseUrl,
    'apiV1Base': apiV1Base,
    'adminApiBase': adminApiBase,
    'dqmsApiBase': dqmsApiBase,
    'authApiBase': authApiBase,
    'reportsApiBase': reportsApiBase,
    'organizationApiKey': organizationApiKey,
    'organizationId': organizationId,
  };

  /// Loads runtime configuration from assets/config.json dynamically at app boot.
  static Future<void> loadRuntimeConfig() async {
    try {
      final jsonString = await rootBundle.loadString('assets/config.json');
      _runtimeConfig = json.decode(jsonString) as Map<String, dynamic>;
    } catch (_) {
      // Seamless fallback to default compile-time values if file is unreadable
    }
  }

  /// Updates runtime endpoints dynamically from the UI without rebuilding
  static void updateEndpoints({
    String? apiBaseUrl,
    String? adminApiBase,
    String? dqmsApiBase,
    String? authApiBase,
    String? reportsApiBase,
    String? organizationApiKey,
    int? organizationId,
  }) {
    if (apiBaseUrl != null && apiBaseUrl.isNotEmpty) _runtimeConfig['apiBaseUrl'] = apiBaseUrl;
    if (adminApiBase != null && adminApiBase.isNotEmpty) _runtimeConfig['adminApiBase'] = adminApiBase;
    if (dqmsApiBase != null && dqmsApiBase.isNotEmpty) _runtimeConfig['dqmsApiBase'] = dqmsApiBase;
    if (authApiBase != null && authApiBase.isNotEmpty) _runtimeConfig['authApiBase'] = authApiBase;
    if (reportsApiBase != null && reportsApiBase.isNotEmpty) _runtimeConfig['reportsApiBase'] = reportsApiBase;
    if (organizationApiKey != null && organizationApiKey.isNotEmpty) _runtimeConfig['organizationApiKey'] = organizationApiKey;
    if (organizationId != null) _runtimeConfig['organizationId'] = organizationId;
  }
}
