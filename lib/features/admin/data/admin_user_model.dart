class AdminUser {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? kangiderId;
  final String? kangiderNama;
  final String? outlet;
  final String? roleName;
  final String? status;
  final DateTime? createdAt;

  AdminUser({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.kangiderId,
    this.kangiderNama,
    this.outlet,
    this.roleName,
    this.status,
    this.createdAt,
  });

  String get fullName {
    final parts = [firstName, lastName].where((p) => p != null && p.isNotEmpty);
    return parts.isNotEmpty ? parts.join(' ') : email;
  }

  bool get isActive => status?.toLowerCase() != 'inactive';

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    final role = json['role'] as Map<String, dynamic>?;
    final rawOutlet = json['outlet']?.toString();
    // Data dari Directus / Kangider otomatis masuk ke outlet IderKopi
    final resolvedOutlet = (rawOutlet != null && rawOutlet.isNotEmpty)
        ? (rawOutlet.contains('IderKopi') ? rawOutlet : 'IderKopi - $rawOutlet')
        : 'IderKopi';

    return AdminUser(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'],
      lastName: json['last_name'],
      kangiderId: json['kangider_id']?.toString(),
      kangiderNama: json['kangider_nama'],
      outlet: resolvedOutlet,
      roleName: role?['name'],
      status: json['status'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'first_name': firstName,
        'last_name': lastName,
        'kangider_id': kangiderId,
        'kangider_nama': kangiderNama,
        'outlet': outlet,
      };

  AdminUser copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? kangiderId,
    String? kangiderNama,
    String? outlet,
    String? roleName,
    String? status,
    DateTime? createdAt,
  }) {
    return AdminUser(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      kangiderId: kangiderId ?? this.kangiderId,
      kangiderNama: kangiderNama ?? this.kangiderNama,
      outlet: outlet ?? this.outlet,
      roleName: roleName ?? this.roleName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}


class CreateUserData {
  final String email;
  final String password;
  final String? firstName;
  final String? lastName;
  final String? kangiderNama;
  final String? outlet;
  final String roleId;

  CreateUserData({
    required this.email,
    required this.password,
    this.firstName,
    this.lastName,
    this.kangiderNama,
    this.outlet,
    required this.roleId,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        'kangider_nama': kangiderNama,
        'outlet': outlet ?? 'IderKopi',
        'role': roleId,
      };
}
