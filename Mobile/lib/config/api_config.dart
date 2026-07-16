/// Backend API configuration.
class ApiConfig {
  /// Override at build or run time with:
  /// flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    // defaultValue: 'http://10.0.2.2:8000',
    // defaultValue: 'http://192.168.1.246:8000',
    defaultValue: 'https://jobmatch-backend-vb7w.onrender.com',
  );

  static const String apiPrefix = '/api/v1';

  static String get apiBaseUrl => '$baseUrl$apiPrefix';
}
