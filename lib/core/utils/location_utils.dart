import 'package:geolocator/geolocator.dart';

class LocationUtils {
  LocationUtils._();

  static Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('GPS tidak aktif. Aktifkan GPS di pengaturan perangkat.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Izin lokasi ditolak.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Izin lokasi ditolak permanen. Buka pengaturan untuk mengaktifkan.');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 15),
    );
  }

  static double distanceToOffice(double lat, double lng) {
    return Geolocator.distanceBetween(
      lat,
      lng,
      -6.123456,
      106.789012,
    );
  }

  static bool isWithinOfficeRadius(double lat, double lng,
      {double radiusMeters = 100.0}) {
    return distanceToOffice(lat, lng) <= radiusMeters;
  }
}
