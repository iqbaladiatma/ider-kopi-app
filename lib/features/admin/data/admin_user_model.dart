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
  final DateTime? lastLoginAt;
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
    this.lastLoginAt,
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
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.tryParse(json['last_login_at'].toString())
          : null,
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
    DateTime? lastLoginAt,
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
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
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

class CoreEmployee {
  const CoreEmployee({
    required this.id,
    required this.employeeCode,
    required this.fullName,
    required this.brand,
    required this.joinDate,
    required this.isActive,
    this.email,
    this.phone,
    this.departmentId,
    this.departmentName,
    this.positionId,
    this.positionName,
    this.shiftId,
    this.shiftName,
    this.outletId,
    this.outletName,
  });

  final String id;
  final String employeeCode;
  final String fullName;
  final String brand;
  final DateTime? joinDate;
  final bool isActive;
  final String? email;
  final String? phone;
  final String? departmentId;
  final String? departmentName;
  final String? positionId;
  final String? positionName;
  final String? shiftId;
  final String? shiftName;
  final String? outletId;
  final String? outletName;

  factory CoreEmployee.fromJson(Map<String, dynamic> json) {
    String? relationName(String key) {
      final relation = json[key];
      if (relation is Map) return relation['name']?.toString();
      return null;
    }

    return CoreEmployee(
      id: json['id']?.toString() ?? '',
      employeeCode: json['employee_code']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      brand: json['brand']?.toString() ?? '',
      departmentId: json['department_id']?.toString(),
      departmentName: relationName('department'),
      positionId: json['position_id']?.toString(),
      positionName: relationName('position'),
      shiftId: json['shift_id']?.toString(),
      shiftName: relationName('shift'),
      outletId: json['outlet_id']?.toString(),
      outletName: json['outlet_name']?.toString(),
      joinDate: json['join_date'] == null
          ? null
          : DateTime.tryParse(json['join_date'].toString()),
      isActive: json['is_active'] == true,
    );
  }
}
