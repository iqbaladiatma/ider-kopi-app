class AppConfig {
  AppConfig._();

  static const String _legacyConfiguredCoreApiBaseUrl = String.fromEnvironment(
    'CUSTOM_API_BASE_URL',
    defaultValue: 'https://iderkopi.tailcbf3a3.ts.net:8443/core/api/v1',
  );

  static const String _configuredCoreApiBaseUrl = String.fromEnvironment(
    'CORE_API_BASE_URL',
    defaultValue: _legacyConfiguredCoreApiBaseUrl,
  );

  static const String _configuredAuthApiBaseUrl = String.fromEnvironment(
    'AUTH_API_BASE_URL',
    defaultValue:
        'https://iderkopi.tailcbf3a3.ts.net:8443/employee-auth/api/v1',
  );

  /// Core business API root (attendance, outlets, shifts, KPI, and employees).
  static String get coreApiBaseUrl => _normalizeApiBaseUrl(
        _configuredCoreApiBaseUrl,
      );

  /// Standalone authentication API root.
  static String get authApiBaseUrl => _normalizeApiBaseUrl(
        _configuredAuthApiBaseUrl,
      );

  /// Backwards-compatible alias for business repositories.
  static String get apiBaseUrl => coreApiBaseUrl;

  static String _normalizeApiBaseUrl(String configuredValue) {
    var value = configuredValue.trim();
    while (value.endsWith('/')) {
      value = value.substring(0, value.length - 1);
    }
    if (!value.endsWith('/api/v1')) {
      value = '$value/api/v1';
    }
    return '$value/';
  }

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const int retryCount = 3;
  static const Duration retryBackoff = Duration(seconds: 2);

  static const String appVersion = '2.0.0';

  /// Flag mode autentikasi/API:
  /// - `true`: Gunakan mock data lokal (untuk pengujian UI offline).
  /// - `false`: Panggil custom Go API. API errors are never mocked.
  static const bool useMockAuth =
      bool.fromEnvironment('USE_MOCK_AUTH', defaultValue: false);

  /// Required when `USE_MOCK_AUTH=true`; intentionally has no default.
  static const String mockAuthPassword =
      String.fromEnvironment('MOCK_AUTH_PASSWORD', defaultValue: '');

  // Mapbox Access Token untuk map preview interaktif (v2.0).
  // Set via --dart-define=MAPBOX_ACCESS_TOKEN=xxx saat build.
  static const String mapboxAccessToken =
      String.fromEnvironment('MAPBOX_ACCESS_TOKEN', defaultValue: '');

  /// True jika Mapbox Access Token sudah dikonfigurasi.
  static bool get hasMapboxToken {
    final token = mapboxAccessToken.trim();
    if (token.isEmpty) return false;
    final lower = token.toLowerCase();
    return token.startsWith('pk.') &&
        !lower.contains('placeholder') &&
        !lower.contains('sample') &&
        !lower.contains('your_') &&
        !lower.contains('changeme');
  }
}
