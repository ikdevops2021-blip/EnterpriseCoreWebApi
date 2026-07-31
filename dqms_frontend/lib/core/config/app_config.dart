/// Central Enterprise Environment & API Endpoint Configuration
class AppConfig {
  /// Base API Host URL (overridable via --dart-define=API_BASE_URL=http://your-server:5026)
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5026',
  );

  /// Root API V1 Prefix
  static String get apiV1Base => '$apiBaseUrl/api/v1';

  /// Specific Subsystem Endpoint Roots
  static String get adminApiBase => '$apiV1Base/admin';
  static String get dqmsApiBase => '$apiV1Base/dqms';
  static String get authApiBase => '$apiV1Base/auth';
  static String get reportsApiBase => '$apiV1Base/reports';
}
