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
    // Directus: { data: { access_token, refresh_token, expires } }
    // Go backend: { success: true, data: { access_token, refresh_token, user: {...} } }
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    return AuthTokens(
      accessToken: data['access_token'] as String,
      refreshToken: (data['refresh_token'] as String?) ?? '',
      expiresAt: DateTime.now().add(
        Duration(seconds: (data['expires'] as int?) ?? 900),
      ),
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
  });

  String get fullName {
    final parts = [firstName, lastName].where((p) => p != null && p.isNotEmpty);
    return parts.isNotEmpty ? parts.join(' ') : email;
  }

  bool get isAdmin => roleName?.toLowerCase() == 'admin';

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final roleObj = json['role'] is Map<String, dynamic> ? json['role'] as Map<String, dynamic> : null;
    final roleStr = json['role'] is String ? json['role'] as String : roleObj?['name'];

    final rawName = (json['first_name'] != null || json['last_name'] != null)
        ? null
        : (json['full_name'] as String?);

    final rawOutlet = json['outlet']?.toString() ?? json['department_name']?.toString();
    final resolvedOutlet = (rawOutlet != null && rawOutlet.isNotEmpty)
        ? (rawOutlet.contains('IderKopi') ? rawOutlet : 'IderKopi - $rawOutlet')
        : 'IderKopi';

    return UserProfile(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? rawName,
      lastName: json['last_name'],
      kangiderId: json['kangider_id']?.toString() ?? json['external_kangider_id']?.toString(),
      kangiderNama: json['kangider_nama'] ?? json['full_name'],
      outlet: resolvedOutlet,
      roleId: roleObj?['id']?.toString(),
      roleName: roleStr,
    );
  }
}
