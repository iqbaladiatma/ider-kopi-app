/// Model Outlet IderKopi.
///
/// Setiap outlet punya koordinat GPS & radius geofencing sendiri.
/// Dipakai untuk validasi check-in/check-out di v1.1.
class Outlet {
  final String id;
  final String nama;
  final String? alamat;
  final double latitude;
  final double longitude;
  final double radiusMeters;
  final bool isActive;

  const Outlet({
    required this.id,
    required this.nama,
    this.alamat,
    required this.latitude,
    required this.longitude,
    this.radiusMeters = 100.0,
    this.isActive = true,
  });

  bool get hasValidGeofence =>
      latitude >= -90 &&
      latitude <= 90 &&
      longitude >= -180 &&
      longitude <= 180 &&
      radiusMeters > 0 &&
      !(latitude == 0 && longitude == 0);

  /// Nama singkat untuk display (tanpa prefix "IderKopi - ").
  String get shortName {
    if (nama.startsWith('IderKopi - ')) {
      return nama.substring('IderKopi - '.length);
    }
    return nama;
  }

  factory Outlet.fromJson(Map<String, dynamic> json) {
    return Outlet(
      id: json['id']?.toString() ?? '',
      nama: json['nama']?.toString() ?? json['name']?.toString() ?? 'Outlet',
      alamat: json['alamat']?.toString() ?? json['address']?.toString(),
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      radiusMeters: (json['radius_meters'] as num?)?.toDouble() ?? 100.0,
      isActive: json['is_active'] == null
          ? true
          : json['is_active'] is bool
              ? json['is_active'] as bool
              : json['is_active'].toString() == '1' ||
                  json['is_active'].toString().toLowerCase() == 'true',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nama': nama,
        'alamat': alamat,
        'latitude': latitude,
        'longitude': longitude,
        'radius_meters': radiusMeters,
        'is_active': isActive,
      };

  @override
  String toString() =>
      'Outlet($id, $nama, $latitude,$longitude, r=$radiusMeters)';
}

/// Hasil perhitungan jarak user ke sebuah outlet.
class OutletDistance {
  final Outlet outlet;
  final double distanceMeters;
  final bool isWithinRadius;

  const OutletDistance({
    required this.outlet,
    required this.distanceMeters,
    required this.isWithinRadius,
  });

  /// Format jarak untuk display: "12 m" atau "1.3 km".
  String get distanceLabel {
    if (distanceMeters < 1000) {
      return '${distanceMeters.round()} m';
    }
    return '${(distanceMeters / 1000).toStringAsFixed(1)} km';
  }
}
