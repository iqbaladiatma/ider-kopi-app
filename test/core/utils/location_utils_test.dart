import 'package:flutter_test/flutter_test.dart';
import 'package:iderkopi_absensi/core/utils/location_utils.dart';

void main() {
  group('LocationUtils.distanceTo', () {
    test('returns 0 for same point', () {
      final d = LocationUtils.distanceTo(0, 0, 0, 0);
      expect(d, closeTo(0, 0.01));
    });

    test('returns ~111km for 1 degree latitude', () {
      // 1 derajat latitude ≈ 111.32 km
      final d = LocationUtils.distanceTo(0, 0, 1, 0);
      expect(d, closeTo(111320, 1000));
    });

    test('returns ~111km for 1 degree longitude at equator', () {
      final d = LocationUtils.distanceTo(0, 0, 0, 1);
      expect(d, closeTo(111320, 1000));
    });

    test('distance Yogyakarta Malioboro to Kotabaru', () {
      // Malioboro: -7.7928, 110.3658
      // Kotabaru: -7.7850, 110.3720
      final d = LocationUtils.distanceTo(-7.7928, 110.3658, -7.7850, 110.3720);
      // Sekitar 1km
      expect(d, greaterThan(800));
      expect(d, lessThan(1200));
    });
  });

  group('LocationUtils.isWithinOutletRadius', () {
    test('returns true when within radius', () {
      final within = LocationUtils.isWithinOutletRadius(
        userLat: -7.7928,
        userLng: 110.3658,
        outletLat: -7.7928,
        outletLng: 110.3658,
        radiusMeters: 100,
      );
      expect(within, isTrue);
    });

    test('returns false when outside radius', () {
      final within = LocationUtils.isWithinOutletRadius(
        userLat: -7.7928,
        userLng: 110.3658,
        outletLat: -7.7850, // ~1km away
        outletLng: 110.3720,
        radiusMeters: 100,
      );
      expect(within, isFalse);
    });

    test('returns true at edge of radius (50m away, 100m radius)', () {
      // 0.0005 derajat latitude ≈ 55m
      final within = LocationUtils.isWithinOutletRadius(
        userLat: -7.7928,
        userLng: 110.3658,
        outletLat: -7.7928 + 0.0005,
        outletLng: 110.3658,
        radiusMeters: 100,
      );
      expect(within, isTrue);
    });
  });
}
