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

  Future<AuthTokens> login(String email, String password) async {
    if (AppConfig.useMockAuth) {
      return _mockLogin(email, password);
    }

    final response = await _client.post(
      '/auth/login',
      body: {'email': email, 'password': password},
    );

    final tokens = AuthTokens.fromJson(response.data);

    await _storage.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      expiresAt: tokens.expiresAt,
    );
    await _storage.saveUserEmail(email);

    return tokens;
  }

  Future<AuthTokens> _mockLogin(String email, String password) async {
    if (!MockData.validate(email, password)) {
      throw Exception('Invalid credentials');
    }

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

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    return tokens;
  }

  Future<UserProfile> getCurrentUser() async {
    if (AppConfig.useMockAuth) {
      return _mockGetCurrentUser();
    }

    final response = await _client.get('/users/me', query: {
      'fields': 'id,email,first_name,last_name,kangider_id,kangider_nama,outlet,role.id,role.name',
    });

    final data = response.data['data'] as Map<String, dynamic>;
    final profile = UserProfile.fromJson(data);

    if (profile.kangiderId != null) {
      await _storage.saveKangiderId(profile.kangiderId!);
    }
    if (profile.roleName != null) {
      await _storage.saveUserRole(profile.roleName!);
    }

    return profile;
  }

  Future<UserProfile> _mockGetCurrentUser() async {
    final email = await _storage.getUserEmail();
    final profile = MockData.getUser(email ?? '');

    if (profile.kangiderId != null) {
      await _storage.saveKangiderId(profile.kangiderId!);
    }
    if (profile.roleName != null) {
      await _storage.saveUserRole(profile.roleName!);
    }

    return profile;
  }

  Future<void> logout() async {
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
    return await _storage.getUserEmail();
  }

  Future<String?> getUserRole() async {
    return await _storage.getUserRole();
  }
}
