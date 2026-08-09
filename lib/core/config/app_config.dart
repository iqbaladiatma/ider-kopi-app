import 'api_provider.dart';

class AppConfig {
  AppConfig._();

  static const String directusApiBaseUrl = 'https://api.iderkopi.id';

  /// Base URL untuk Go backend (v2.0).
  /// Set via --dart-define=GO_API_BASE_URL=xxx saat build.
  static const String goApiBaseUrl =
      String.fromEnvironment('GO_API_BASE_URL', defaultValue: 'http://localhost:8080');

  /// Base URL untuk Web / Backend Server sendiri via Tailscale.
  /// Default: `http://100.90.46.31:9000` (dapat di-override via --dart-define=CUSTOM_WEB_URL=http://xxx).
  static const String customWebBaseUrl =
      String.fromEnvironment('CUSTOM_WEB_URL', defaultValue: 'http://100.90.46.31:9000');

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const int retryCount = 3;
  static const Duration retryBackoff = Duration(seconds: 2);

  static const double officeRadiusMeters = 100.0;

  static const double officeLatitude = -6.123456;
  static const double officeLongitude = 106.789012;

  static const String appVersion = '2.0.0';

  /// Flag mode autentikasi/API:
  /// - `true`: Gunakan mock data lokal (untuk pengujian UI offline).
  /// - `false`: Panggil API server asli secara riil (Directus / Server Tailscale Anda).
  static const bool useMockAuth = bool.fromEnvironment('USE_MOCK_AUTH', defaultValue: false);

  // Mapbox Access Token untuk map preview interaktif (v2.0).
  // Set via --dart-define=MAPBOX_ACCESS_TOKEN=xxx saat build.
  static const String mapboxAccessToken =
      String.fromEnvironment('MAPBOX_ACCESS_TOKEN', defaultValue: '');

  /// True jika Mapbox Access Token sudah dikonfigurasi.
  static bool get hasMapboxToken => mapboxAccessToken.isNotEmpty;

  /// API provider aktif.
  /// Set via --dart-define=API_PROVIDER=directus|gobackend|customweb
  static const String _apiProviderStr =
      String.fromEnvironment('API_PROVIDER', defaultValue: 'directus');

  static const ApiProvider apiProvider =
      _apiProviderStr == 'gobackend' || _apiProviderStr == 'go'
          ? ApiProvider.goBackend
          : _apiProviderStr == 'customweb' || _apiProviderStr == 'customWeb' || _apiProviderStr == 'custom' || _apiProviderStr == 'web'
              ? ApiProvider.customWeb
              : ApiProvider.directus;

  /// Base URL untuk provider aktif.
  static String get apiBaseUrl {
    switch (apiProvider) {
      case ApiProvider.directus:
        return directusApiBaseUrl;
      case ApiProvider.goBackend:
        return goApiBaseUrl;
      case ApiProvider.customWeb:
        return customWebBaseUrl;
    }
  }
}
