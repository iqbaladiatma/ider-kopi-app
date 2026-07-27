enum AttendanceStatus { tepatWaktu, terlambat, alpha, belumAbsen }

class AttendanceRecord {
  final int? id;
  final String tanggalAbsensi;
  final String? masuk;
  final String? pulang;
  final String? kangider;
  final String? keterangan;
  final double? latitude;
  final double? longitude;
  final String? selfieFileId;
  final String? checkInSource;
  final double? latitudePulang;
  final double? longitudePulang;
  final String? selfiePulangFileId;

  AttendanceRecord({
    this.id,
    required this.tanggalAbsensi,
    this.masuk,
    this.pulang,
    this.kangider,
    this.keterangan,
    this.latitude,
    this.longitude,
    this.selfieFileId,
    this.checkInSource,
    this.latitudePulang,
    this.longitudePulang,
    this.selfiePulangFileId,
  });

  bool get hasCheckedIn => masuk != null && masuk!.isNotEmpty;
  bool get hasCheckedOut => pulang != null && pulang!.isNotEmpty;

  AttendanceStatus get status {
    if (!hasCheckedIn) return AttendanceStatus.alpha;
    if (_isLate(masuk!)) return AttendanceStatus.terlambat;
    return AttendanceStatus.tepatWaktu;
  }

  bool _isLate(String time) {
    final parts = time.split(':');
    if (parts.length < 2) return false;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    return hour > 8 || (hour == 8 && minute > 0);
  }

  String get statusLabel {
    switch (status) {
      case AttendanceStatus.tepatWaktu:
        return 'Tepat Waktu';
      case AttendanceStatus.terlambat:
        return 'Terlambat';
      case AttendanceStatus.alpha:
        return 'Alpha';
      case AttendanceStatus.belumAbsen:
        return 'Belum Absen';
    }
  }

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      tanggalAbsensi: json['tanggal_absensi'] ?? '',
      masuk: json['masuk'],
      pulang: json['pulang'],
      kangider: json['kangider']?.toString(),
      keterangan: json['keterangan'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      selfieFileId: json['selfie_file_id'],
      checkInSource: json['check_in_source'],
      latitudePulang: (json['latitude_pulang'] as num?)?.toDouble(),
      longitudePulang: (json['longitude_pulang'] as num?)?.toDouble(),
      selfiePulangFileId: json['selfie_pulang_file_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tanggal_absensi': tanggalAbsensi,
      'masuk': masuk,
      'pulang': pulang,
      'kangider': kangider,
      'keterangan': keterangan,
      'latitude': latitude,
      'longitude': longitude,
      'selfie_file_id': selfieFileId,
      'check_in_source': checkInSource ?? 'app',
      'latitude_pulang': latitudePulang,
      'longitude_pulang': longitudePulang,
      'selfie_pulang_file_id': selfiePulangFileId,
    };
  }
}

class CheckInRequest {
  final String tanggalAbsensi;
  final String masuk;
  final String kangider;
  final double latitude;
  final double longitude;
  final String selfieFileId;
  final String? keterangan;

  CheckInRequest({
    required this.tanggalAbsensi,
    required this.masuk,
    required this.kangider,
    required this.latitude,
    required this.longitude,
    required this.selfieFileId,
    this.keterangan,
  });

  Map<String, dynamic> toJson() => {
        'tanggal_absensi': tanggalAbsensi,
        'masuk': masuk,
        'kangider': kangider,
        'latitude': latitude,
        'longitude': longitude,
        'selfie_file_id': selfieFileId,
        'check_in_source': 'app',
        'keterangan': keterangan,
      };
}

class CheckOutRequest {
  final String pulang;
  final double? latitudePulang;
  final double? longitudePulang;
  final String? selfiePulangFileId;
  final String? keterangan;

  CheckOutRequest({
    required this.pulang,
    this.latitudePulang,
    this.longitudePulang,
    this.selfiePulangFileId,
    this.keterangan,
  });

  Map<String, dynamic> toJson() => {
        'pulang': pulang,
        if (latitudePulang != null) 'latitude_pulang': latitudePulang,
        if (longitudePulang != null) 'longitude_pulang': longitudePulang,
        if (selfiePulangFileId != null)
          'selfie_pulang_file_id': selfiePulangFileId,
        if (keterangan != null) 'keterangan': keterangan,
      };
}
