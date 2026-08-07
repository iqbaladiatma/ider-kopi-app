/// Pilihan backend API provider.
///
/// Opsi: `directus`, `goBackend`, `customWeb`.
/// Set via `--dart-define=API_PROVIDER=customWeb` saat build atau ganti di `app_config.dart`.
enum ApiProvider {
  directus,
  goBackend,
  customWeb,
}

/// Helper untuk parse ApiProvider dari String (dart-define).
extension ApiProviderX on ApiProvider {
  static ApiProvider fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'gobackend':
      case 'go':
        return ApiProvider.goBackend;
      case 'customweb':
      case 'custom':
      case 'web':
        return ApiProvider.customWeb;
      default:
        return ApiProvider.directus;
    }
  }

  String get label {
    switch (this) {
      case ApiProvider.directus:
        return 'Directus';
      case ApiProvider.goBackend:
        return 'Go Backend';
      case ApiProvider.customWeb:
        return 'Web Sendiri (Tailscale/Custom)';
    }
  }
}
