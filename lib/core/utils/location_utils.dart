import 'package:geolocator/geolocator.dart';

class LocationUtils {
  LocationUtils._();

  static Future<Position> getCurrentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw StateError('Layanan lokasi tidak aktif');
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw StateError('Izin lokasi diperlukan untuk absensi');
    }
    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 15),
    );
  }

  /// Jarak (meter) antara 2 titik koordinat.
  static double distanceTo(
    double fromLat,
    double fromLng,
    double toLat,
    double toLng,
  ) {
    return Geolocator.distanceBetween(fromLat, fromLng, toLat, toLng);
  }

  /// Cek apakah posisi user dalam radius sebuah outlet.
  static bool isWithinOutletRadius({
    required double userLat,
    required double userLng,
    required double outletLat,
    required double outletLng,
    required double radiusMeters,
  }) {
    return distanceTo(userLat, userLng, outletLat, outletLng) <= radiusMeters;
  }
}
