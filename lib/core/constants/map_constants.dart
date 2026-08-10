import '../config/app_config.dart';

/// Konfigurasi dan konstanta untuk peta Mapbox & tile provider.
class MapConstants {
  MapConstants._();

  /// Token Akses Publik Mapbox.
  /// Ganti dengan Token Mapbox publik milik Anda dari https://account.mapbox.com/
  /// Mapbox Style ID (opsi populer: `streets-v12`, `outdoors-v12`, `light-v11`, `dark-v11`, `satellite-streets-v12`)
  static const String mapboxStyleId = 'mapbox/streets-v12';

  /// URL template untuk Tile Provider (menggunakan OSM fallback jika token masih sample/invalid)
  static String get mapboxTileUrl {
    if (!AppConfig.hasMapboxToken) {
      return osmTileUrl;
    }
    return 'https://api.mapbox.com/styles/v1/$mapboxStyleId/tiles/256/{z}/{x}/{y}@2x?access_token=${AppConfig.mapboxAccessToken}';
  }

  /// Fallback Tile URL ke OpenStreetMap
  static const String osmTileUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  /// User Agent untuk Tile Layer HTTP Headers
  static const String userAgentPackageName = 'com.iderkopi.absensi';
}
