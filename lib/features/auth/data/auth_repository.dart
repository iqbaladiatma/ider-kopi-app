import '../../../core/config/api_provider.dart';
import '../../../core/config/app_config.dart';
import '../../../core/network/directus_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/utils/mock_data.dart';
import 'auth_model.dart';

class AuthRepository {
  AuthRepository._internal();
  static final AuthRepository _instance = AuthRepository._internal();
  factory AuthRepository() => _instance;

  final DirectusClient _client = DirectusClient.instance;
  final SecureStorage _storage = SecureStorage();

  static String? _inMemoryEmail;
  static String? _inMemoryRole;

  Future<AuthTokens> login(String email, String password) async {
    _inMemoryEmail = email;
    _inMemoryRole = MockData.isAdmin(email) ? 'Admin' : 'Karyawan';

    if (AppConfig.useMockAuth) {
      return _mockLogin(email, password);
    }

    final endpoint = AppConfig.apiProvider == ApiProvider.directus
        ? '/auth/login'
        : '/api/v1/auth/login';

    try {
      final response = await _client.post(
        endpoint,
        body: {'email': email, 'password': password},
      );

      final tokens = AuthTokens.fromJson(response.data);

      await _storage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
        expiresAt: tokens.expiresAt,
      );
      await _storage.saveUserEmail(email);
      await _storage.saveUserRole(_inMemoryRole!);

      return tokens;
    } catch (e) {
      // Fallback ke mock login jika API mengembalikan error / 401
      try {
        return await _mockLogin(email, password);
      } catch (_) {
        rethrow;
      }
    }
  }

  Future<AuthTokens> _mockLogin(String email, String password) async {
    if (!MockData.validate(email, password)) {
      throw Exception('Invalid credentials');
    }

    _inMemoryEmail = email;
    _inMemoryRole = MockData.isAdmin(email) ? 'Admin' : 'Karyawan';

    final tokens = AuthTokens(
      accessToken: 'mock-access-token-${DateTime.now().millisecondsSinceEpoch}',
      refreshToken: 'mock-refresh-token',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );

    await _storage.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      expiresAt: tokens.expiresAt,
    );
    await _storage.saveUserEmail(email);
    await _storage.saveUserRole(_inMemoryRole!);

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    return tokens;
  }

  Future<UserProfile> getCurrentUser() async {
    if (AppConfig.useMockAuth) {
      return _mockGetCurrentUser();
    }

    final isDirectus = AppConfig.apiProvider == ApiProvider.directus;
    final endpoint = isDirectus ? '/users/me' : '/api/v1/auth/me';
    final query = isDirectus
        ? {'fields': 'id,email,first_name,last_name,kangider_id,kangider_nama,outlet,role.id,role.name'}
        : null;

    try {
      final response = await _client.get(endpoint, query: query);

      final data = response.data['data'] as Map<String, dynamic>;
      final profile = UserProfile.fromJson(data);

      if (profile.kangiderId != null) {
        await _storage.saveKangiderId(profile.kangiderId!);
      }
      if (profile.roleName != null) {
        _inMemoryRole = profile.roleName;
        await _storage.saveUserRole(profile.roleName!);
      }

      return profile;
    } catch (_) {
      return _mockGetCurrentUser();
    }
  }

  Future<UserProfile> _mockGetCurrentUser() async {
    final email = _inMemoryEmail ?? await _storage.getUserEmail();
    final profile = MockData.getUser(email ?? '');
    _inMemoryEmail = profile.email;
    _inMemoryRole = profile.roleName ?? (profile.isAdmin ? 'Admin' : 'Karyawan');

    if (profile.kangiderId != null) {
      await _storage.saveKangiderId(profile.kangiderId!);
    }
    if (profile.roleName != null) {
      await _storage.saveUserRole(profile.roleName!);
    }

    return profile;
  }

  Future<void> logout() async {
    _inMemoryEmail = null;
    _inMemoryRole = null;
    if (!AppConfig.useMockAuth) {
      try {
        await _client.post('/auth/logout');
      } catch (_) {
        // ignore logout API errors
      }
    }
    await _storage.clearAll();
  }

  Future<bool> isLoggedIn() async {
    if (_inMemoryEmail != null) return true;
    final token = await _storage.getAccessToken();
    final expiresAt = await _storage.getExpiresAt();
    if (token == null) return false;
    if (expiresAt != null && DateTime.now().isAfter(expiresAt)) {
      return false;
    }
    return true;
  }

  Future<String?> getKangiderId() async {
    return await _storage.getKangiderId();
  }

  Future<String?> getUserEmail() async {
    return _inMemoryEmail ?? await _storage.getUserEmail();
  }

  Future<String?> getUserRole() async {
    return _inMemoryRole ?? await _storage.getUserRole();
  }
}

