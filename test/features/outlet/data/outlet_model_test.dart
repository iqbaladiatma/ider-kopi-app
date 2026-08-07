import 'package:flutter_test/flutter_test.dart';
import 'package:iderkopi_absensi/features/outlet/data/outlet_model.dart';

void main() {
  group('Outlet', () {
    test('fromJson parses all fields correctly', () {
      final json = {
        'id': 2,
        'nama': 'IderKopi - Malioboro',
        'alamat': 'Jl. Malioboro No. 52',
        'latitude': -7.7928,
        'longitude': 110.3658,
        'radius_meters': 100.0,
        'is_active': true,
      };

      final outlet = Outlet.fromJson(json);

      expect(outlet.id, 2);
      expect(outlet.nama, 'IderKopi - Malioboro');
      expect(outlet.alamat, 'Jl. Malioboro No. 52');
      expect(outlet.latitude, -7.7928);
      expect(outlet.longitude, 110.3658);
      expect(outlet.radiusMeters, 100.0);
      expect(outlet.isActive, isTrue);
    });

    test('fromJson handles string id and missing fields', () {
      final json = {
        'id': '5',
        'name': 'Outlet Tanpa Alamat',
        // alamat, radius_meters, is_active hilang
        'latitude': 0,
        'longitude': 0,
      };

      final outlet = Outlet.fromJson(json);

      expect(outlet.id, 5);
      expect(outlet.nama, 'Outlet Tanpa Alamat');
      expect(outlet.alamat, isNull);
      expect(outlet.radiusMeters, 100.0); // default
      expect(outlet.isActive, isTrue); // default
    });

    test('fromJson parses is_active as string "1"', () {
      final json = {
        'id': 1,
        'nama': 'X',
        'latitude': 1.0,
        'longitude': 1.0,
        'is_active': '1',
      };
      expect(Outlet.fromJson(json).isActive, isTrue);
    });

    test('fromJson parses is_active as string "true"', () {
      final json = {
        'id': 1,
        'nama': 'X',
        'latitude': 1.0,
        'longitude': 1.0,
        'is_active': 'true',
      };
      expect(Outlet.fromJson(json).isActive, isTrue);
    });

    test('fromJson parses is_active=false', () {
      final json = {
        'id': 1,
        'nama': 'X',
        'latitude': 1.0,
        'longitude': 1.0,
        'is_active': false,
      };
      expect(Outlet.fromJson(json).isActive, isFalse);
    });

    test('shortName strips "IderKopi - " prefix', () {
      const outlet = Outlet(
        id: 1,
        nama: 'IderKopi - Malioboro',
        latitude: 0,
        longitude: 0,
      );
      expect(outlet.shortName, 'Malioboro');
    });

    test('shortName returns full nama when no prefix', () {
      const outlet = Outlet(
        id: 1,
        nama: 'Malioboro',
        latitude: 0,
        longitude: 0,
      );
      expect(outlet.shortName, 'Malioboro');
    });

    test('toJson round-trips correctly', () {
      const outlet = Outlet(
        id: 3,
        nama: 'IderKopi - Kotabaru',
        alamat: 'Jl. Simanjuntak',
        latitude: -7.785,
        longitude: 110.372,
        radiusMeters: 120,
        isActive: true,
      );
      final json = outlet.toJson();
      expect(json['id'], 3);
      expect(json['nama'], 'IderKopi - Kotabaru');
      expect(json['latitude'], -7.785);
      expect(json['longitude'], 110.372);
      expect(json['radius_meters'], 120);
      expect(json['is_active'], isTrue);

      final rebuilt = Outlet.fromJson(json);
      expect(rebuilt.id, outlet.id);
      expect(rebuilt.nama, outlet.nama);
      expect(rebuilt.latitude, outlet.latitude);
      expect(rebuilt.longitude, outlet.longitude);
      expect(rebuilt.radiusMeters, outlet.radiusMeters);
    });
  });

  group('OutletDistance', () {
    test('distanceLabel formats meters correctly', () {
      const d = OutletDistance(
        outlet: Outlet(id: 1, nama: 'X', latitude: 0, longitude: 0),
        distanceMeters: 12.4,
        isWithinRadius: true,
      );
      expect(d.distanceLabel, '12 m');
    });

    test('distanceLabel formats kilometers correctly', () {
      const d = OutletDistance(
        outlet: Outlet(id: 1, nama: 'X', latitude: 0, longitude: 0),
        distanceMeters: 1350.0,
        isWithinRadius: false,
      );
      expect(d.distanceLabel, '1.4 km');
    });

    test('distanceLabel rounds 999.4m to "999 m"', () {
      const d = OutletDistance(
        outlet: Outlet(id: 1, nama: 'X', latitude: 0, longitude: 0),
        distanceMeters: 999.4,
        isWithinRadius: false,
      );
      expect(d.distanceLabel, '999 m');
    });
  });
}
