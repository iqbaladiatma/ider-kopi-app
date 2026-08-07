/// Konfigurasi dan konstanta untuk peta Mapbox & tile provider.
class MapConstants {
  MapConstants._();

  /// Token Akses Publik Mapbox.
  /// Ganti dengan Token Mapbox publik milik Anda dari https://account.mapbox.com/
  static const String mapboxAccessToken = String.fromEnvironment(
    'MAPBOX_ACCESS_TOKEN',
    defaultValue: 'pk.eyJ1IjoiaWRlcmtvcGkiLCJhIjoiY2x6c2FjcDhhMDN6eDJqcHN4dnRtd3BveCJ9.sample_token_place_holder',
  );

  /// Mapbox Style ID (opsi populer: `streets-v12`, `outdoors-v12`, `light-v11`, `dark-v11`, `satellite-streets-v12`)
  static const String mapboxStyleId = 'mapbox/streets-v12';

  /// URL template untuk Mapbox Tile Provider (256px retina tiles)
  static String get mapboxTileUrl =>
      'https://api.mapbox.com/styles/v1/$mapboxStyleId/tiles/256/{z}/{x}/{y}@2x?access_token=$mapboxAccessToken';

  /// Fallback Tile URL ke OpenStreetMap jika Token Mapbox belum diisi atau tidak valid
  static const String osmTileUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  /// User Agent untuk Tile Layer HTTP Headers
  static const String userAgentPackageName = 'com.iderkopi.absensi';
}
