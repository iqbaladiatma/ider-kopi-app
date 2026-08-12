class AuthTokens {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;

  AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    final serverExpiry = DateTime.tryParse(
      data['expires_at']?.toString() ?? '',
    );

    return AuthTokens(
      accessToken: data['access_token'] as String,
      refreshToken: (data['refresh_token'] as String?) ?? '',
      expiresAt:
          serverExpiry ?? DateTime.now().add(const Duration(minutes: 15)),
    );
  }
}

class LoginResult {
  final AuthTokens tokens;
  final UserProfile user;

  LoginResult({required this.tokens, required this.user});

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    final user = data['user'];
    if (user is! Map) {
      throw const FormatException('Login response does not contain a user');
    }

    return LoginResult(
      tokens: AuthTokens.fromJson(data),
      user: UserProfile.fromJson(user.cast<String, dynamic>()),
    );
  }
}

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}

class UserProfile {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? kangiderId;
  final String? kangiderNama;
  final String? outlet;
  final String? roleId;
  final String? roleName;
  final bool mustChangePassword;

  UserProfile({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.kangiderId,
    this.kangiderNama,
    this.outlet,
    this.roleId,
    this.roleName,
    this.mustChangePassword = false,
  });

  String get fullName {
    final parts = [firstName, lastName].where((p) => p != null && p.isNotEmpty);
    return parts.isNotEmpty ? parts.join(' ') : email;
  }

  bool get isAdmin => const {
        'super_admin',
        'hr_admin',
        'manager',
        'admin_kpi_kang_ider',
      }.contains(roleName?.toLowerCase());

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final employee = json['employee'] is Map<String, dynamic>
        ? json['employee'] as Map<String, dynamic>
        : null;
    final roleObj = json['role'] is Map<String, dynamic>
        ? json['role'] as Map<String, dynamic>
        : null;
    final roleStr =
        json['role'] is String ? json['role'] as String : roleObj?['name'];

    final rawName = (json['first_name'] != null || json['last_name'] != null)
        ? null
        : (json['full_name'] as String? ?? employee?['full_name'] as String?);

    final rawOutlet =
        json['outlet']?.toString() ?? json['department_name']?.toString();
    final resolvedOutlet = (rawOutlet != null && rawOutlet.isNotEmpty)
        ? (rawOutlet.contains('IderKopi') ? rawOutlet : 'IderKopi - $rawOutlet')
        : 'IderKopi';

    return UserProfile(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? rawName,
      lastName: json['last_name'],
      kangiderId: json['kangider_id']?.toString() ??
          json['external_kangider_id']?.toString() ??
          json['employee_id']?.toString() ??
          employee?['id']?.toString(),
      kangiderNama:
          json['kangider_nama'] ?? json['full_name'] ?? employee?['full_name'],
      outlet: resolvedOutlet,
      roleId: roleObj?['id']?.toString(),
      roleName: roleStr,
      mustChangePassword: json['must_change_password'] == true,
    );
  }
}
