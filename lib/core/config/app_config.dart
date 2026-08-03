class AppConfig {
  AppConfig._();

  static const String directusApiBaseUrl = 'https://api.iderkopi.id';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const int retryCount = 3;
  static const Duration retryBackoff = Duration(seconds: 2);

  static const double officeRadiusMeters = 100.0;

  static const double officeLatitude = -6.123456;
  static const double officeLongitude = 106.789012;

  static const String appVersion = '1.0.0';

  // Flag untuk integrasi Directus (false = ambil data langsung dari Directus API)
  static const bool useMockAuth = false;
}
