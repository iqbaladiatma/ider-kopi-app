class AdminUser {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? kangiderId;
  final String? kangiderNama;
  final String? outlet;
  final String? roleName;
  final String? roleId;
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
    this.roleId,
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
    final resolvedOutlet = (rawOutlet != null && rawOutlet.isNotEmpty)
        ? (rawOutlet.contains('IderKopi') ? rawOutlet : 'IderKopi - $rawOutlet')
        : null;

    return AdminUser(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? json['full_name'],
      lastName: json['last_name'],
      kangiderId: json['kangider_id']?.toString(),
      kangiderNama: json['kangider_nama'],
      outlet: resolvedOutlet,
      roleName: role?['name'] ?? json['role_name'],
      roleId: json['role_id']?.toString() ?? role?['id']?.toString(),
      status: json['status'] ??
          (json['is_active'] == false ? 'inactive' : 'active'),
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
    String? roleId,
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
      roleId: roleId ?? this.roleId,
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
        'role_id': roleId,
        'is_active': true,
      };
}

class MobileEmployeeAccount {
  const MobileEmployeeAccount({
    required this.employeeId,
    required this.employeeCode,
    required this.fullName,
    required this.email,
    required this.brand,
    required this.employeeActive,
    this.userId,
    this.department,
    this.position,
    this.accountActive,
    this.mustChangePassword,
  });

  final String employeeId;
  final String? userId;
  final String employeeCode;
  final String fullName;
  final String email;
  final String brand;
  final String? department;
  final String? position;
  final bool employeeActive;
  final bool? accountActive;
  final bool? mustChangePassword;

  bool get hasAccount => userId != null && userId!.isNotEmpty;

  factory MobileEmployeeAccount.fromJson(Map<String, dynamic> json) {
    return MobileEmployeeAccount(
      employeeId: json['employee_id']?.toString() ?? '',
      userId: json['user_id']?.toString(),
      employeeCode: json['employee_code']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      brand: json['brand']?.toString() ?? '',
      department: json['department_name']?.toString(),
      position: json['position_name']?.toString(),
      employeeActive: json['employee_active'] == true,
      accountActive: json['account_active'] as bool?,
      mustChangePassword: json['must_change_password'] as bool?,
    );
  }
}
