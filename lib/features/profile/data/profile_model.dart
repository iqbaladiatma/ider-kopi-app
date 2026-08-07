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
    // Go backend: full_name, email, department.name, external_kangider_id
    // Directus:   first_name, last_name, kangider_id, kangider_nama, outlet
    final dept = json['department'] is Map<String, dynamic>
        ? json['department'] as Map<String, dynamic>
        : null;

    return ProfileInfo(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? json['full_name'],
      lastName: json['last_name'],
      kangiderId: json['kangider_id']?.toString() ?? json['external_kangider_id']?.toString(),
      kangiderNama: json['kangider_nama'] ?? json['full_name'],
      outlet: json['outlet'] ?? dept?['name'],
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
