import 'storage_backend.dart';

enum AuthRealm { employee, admin }

class SecureStorage {
  SecureStorage._internal();
  static final SecureStorage _instance = SecureStorage._internal();
  factory SecureStorage() => _instance;

  final StorageBackend _backend = createStorageBackend();

  Future<void> _write(String key, String value) async {
    await _backend.write(key, value);
  }

  Future<String?> _read(String key) async {
    return _backend.read(key);
  }

  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyExpiresAt = 'expires_at';
  static const _keyUserEmail = 'user_email';
  static const _keyKangiderId = 'kangider_id';
  static const _keyUserRole = 'user_role';
  static const _keyMustChangePassword = 'must_change_password';
  static const _keyAuthRealm = 'auth_realm';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiresAt,
  }) async {
    await _write(_keyAccessToken, accessToken);
    await _write(_keyRefreshToken, refreshToken);
    await _write(_keyExpiresAt, expiresAt.toIso8601String());
  }

  Future<String?> getAccessToken() async {
    return await _read(_keyAccessToken);
  }

  Future<String?> getRefreshToken() async {
    return await _read(_keyRefreshToken);
  }

  Future<DateTime?> getExpiresAt() async {
    final value = await _read(_keyExpiresAt);
    if (value != null) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  Future<void> saveUserEmail(String email) async {
    await _write(_keyUserEmail, email);
  }

  Future<String?> getUserEmail() async {
    return await _read(_keyUserEmail);
  }

  Future<void> saveKangiderId(String id) async {
    await _write(_keyKangiderId, id);
  }

  Future<String?> getKangiderId() async {
    return await _read(_keyKangiderId);
  }

  Future<void> saveUserRole(String role) async {
    await _write(_keyUserRole, role);
  }

  Future<String?> getUserRole() async {
    return await _read(_keyUserRole);
  }

  Future<void> saveMustChangePassword(bool value) async {
    await _write(_keyMustChangePassword, value.toString());
  }

  Future<bool> getMustChangePassword() async {
    return await _read(_keyMustChangePassword) == 'true';
  }

  Future<void> saveAuthRealm(AuthRealm realm) async {
    await _write(_keyAuthRealm, realm.name);
  }

  Future<AuthRealm> getAuthRealm() async {
    final value = await _read(_keyAuthRealm);
    return value == AuthRealm.admin.name ? AuthRealm.admin : AuthRealm.employee;
  }

  Future<void> clearAll() async {
    await _backend.deleteAll();
  }
}
