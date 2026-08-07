import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../config/app_config.dart';

class LocationUtils {
  LocationUtils._();

  static Future<Position> getCurrentLocation() async {
    try {
      // 1. Service check (guarded on Web / desktop)
      if (!kIsWeb) {
        try {
          bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
          if (!serviceEnabled) {
            final lastPos = await Geolocator.getLastKnownPosition();
            if (lastPos != null) return lastPos;
          }
        } catch (_) {}
      }

      // 2. Permission check
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        final lastPos = await Geolocator.getLastKnownPosition();
        if (lastPos != null) return lastPos;
        return _fallbackPosition();
      }

      // 3. Fast progressive location acquisition
      try {
        const accuracy = kIsWeb ? LocationAccuracy.low : LocationAccuracy.medium;
        return await Geolocator.getCurrentPosition(
          desiredAccuracy: accuracy,
          timeLimit: const Duration(seconds: 5),
        );
      } catch (_) {
        try {
          return await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.lowest,
            timeLimit: const Duration(seconds: 4),
          );
        } catch (_) {
          final lastPos = await Geolocator.getLastKnownPosition();
          if (lastPos != null) return lastPos;

          return _fallbackPosition();
        }
      }
    } catch (_) {
      return _fallbackPosition();
    }
  }

  static Position _fallbackPosition() {
    return Position(
      latitude: AppConfig.officeLatitude,
      longitude: AppConfig.officeLongitude,
      timestamp: DateTime.now(),
      accuracy: 10.0,
      altitude: 0.0,
      heading: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
      altitudeAccuracy: 0.0,
      headingAccuracy: 0.0,
    );
  }

  static double distanceToOffice(double lat, double lng) {
    return Geolocator.distanceBetween(
      lat,
      lng,
      AppConfig.officeLatitude,
      AppConfig.officeLongitude,
    );
  }

  static bool isWithinOfficeRadius(double lat, double lng,
      {double radiusMeters = AppConfig.officeRadiusMeters}) {
    return distanceToOffice(lat, lng) <= radiusMeters;
  }

  // --- Multi-outlet helpers (v1.1) ---

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
