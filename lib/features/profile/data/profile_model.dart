class ProfileInfo {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? kangiderId;
  final String? kangiderNama;
  final String? outlet;
  final String? phone;

  ProfileInfo({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.kangiderId,
    this.kangiderNama,
    this.outlet,
    this.phone,
  });

  String get fullName {
    final parts = [firstName, lastName].where((p) => p != null && p.isNotEmpty);
    return parts.isNotEmpty ? parts.join(' ') : email;
  }

  factory ProfileInfo.fromJson(Map<String, dynamic> json) {
    return ProfileInfo(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'],
      lastName: json['last_name'],
      kangiderId: json['kangider_id']?.toString(),
      kangiderNama: json['kangider_nama'],
      outlet: json['outlet'],
      phone: json['phone'],
    );
  }
}

class AttendanceStats {
  final int hadir;
  final int terlambat;
  final int alpha;

  AttendanceStats({
    required this.hadir,
    required this.terlambat,
    required this.alpha,
  });
}
