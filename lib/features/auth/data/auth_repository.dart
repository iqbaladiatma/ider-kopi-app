import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/background/sync_worker.dart';
import '../../../core/config/app_config.dart';
import '../../../core/database/app_database.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/auth_api_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/utils/mock_data.dart';
import '../../outlet/data/outlet_repository.dart';
import 'auth_model.dart';

class AuthLoginException implements Exception {
  const AuthLoginException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ChangePasswordException implements Exception {
  const ChangePasswordException(
    this.message, {
    this.sessionExpired = false,
  });

  final String message;
  final bool sessionExpired;

  @override
  String toString() => message;
}

class AuthRepository {
  AuthRepository._internal()
      : _client = AuthApiClient.instance,
        _coreClient = ApiClient.instance,
        _storage = SecureStorage();

  AuthRepository.withDependencies({
    required AuthApiClient client,
    ApiClient? coreClient,
    SecureStorage? storage,
  })  : _client = client,
        _coreClient = coreClient ?? ApiClient.instance,
        _storage = storage ?? SecureStorage();

  static final AuthRepository _instance = AuthRepository._internal();
  factory AuthRepository() => _instance;

  final AuthApiClient _client;
  final ApiClient _coreClient;
  final SecureStorage _storage;

  static String? _inMemoryEmail;
  static String? _inMemoryRole;
  static AuthRealm? _inMemoryRealm;

  Future<LoginResult> login(
    String email,
    String password, {
    bool isAdmin = false,
  }) async {
    if (AppConfig.useMockAuth) {
      return _mockLogin(email, password, isAdmin: isAdmin);
    }
    final realm = isAdmin ? AuthRealm.admin : AuthRealm.employee;
    late final LoginResult result;
    try {
      final response = realm == AuthRealm.admin
          ? await _coreClient.post(
              'auth/login',
              body: {'email': email, 'password': password},
            )
          : await _client.post(
              'auth/login',
              body: {'email': email, 'password': password},
            );
      result = LoginResult.fromJson(
        (response.data as Map).cast<String, dynamic>(),
      );
    } on DioException catch (error) {
      throw AuthLoginException(_loginErrorMessage(error));
    } on FormatException {
      throw const AuthLoginException(
        'Respons server tidak valid. Hubungi administrator.',
      );
    }
    if (isAdmin != result.user.isAdmin) {
      throw AuthLoginException(isAdmin
          ? 'Akun ini bukan akun Admin.'
          : 'Akun Admin harus masuk melalui mode Admin.');
    }
    final tokens = result.tokens;
    _inMemoryEmail = email;
    _inMemoryRole = result.user.roleName ?? 'employee';
    _inMemoryRealm = realm;
    await _storage.saveAuthRealm(realm);
    await _storage.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      expiresAt: tokens.expiresAt,
    );
    await _storage.saveUserEmail(email);
    await _storage.saveUserRole(_inMemoryRole!);
    await _storage.saveMustChangePassword(result.user.mustChangePassword);
    if (!kIsWeb &&
        realm == AuthRealm.employee &&
        !result.user.mustChangePassword) {
      await SyncWorker.init();
    }
    return result;
  }

  String _loginErrorMessage(DioException error) {
    final status = error.response?.statusCode;
    if (status == 401 || status == 403) {
      return 'Email atau password salah.';
    }
    if (status == 429) {
      return 'Terlalu banyak percobaan login. Tunggu satu menit lalu coba lagi.';
    }
    if (status != null && status >= 500) {
      return 'Server login sedang bermasalah. Coba lagi beberapa saat.';
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return 'Koneksi ke server login timeout. Periksa jaringan lalu coba lagi.';
    }
    if (error.type == DioExceptionType.connectionError) {
      return 'Server login tidak dapat dijangkau. Periksa jaringan atau VPN.';
    }
    return 'Login gagal. Coba lagi atau hubungi administrator.';
  }

  Future<LoginResult> _mockLogin(
    String email,
    String password, {
    required bool isAdmin,
  }) async {
    if (!MockData.validate(email, password)) {
      throw Exception('Invalid credentials');
    }

    _inMemoryEmail = email;
    _inMemoryRole = MockData.isAdmin(email) ? 'Admin' : 'Karyawan';
    _inMemoryRealm = isAdmin ? AuthRealm.admin : AuthRealm.employee;
    await _storage.saveAuthRealm(_inMemoryRealm!);

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
    await _storage.saveMustChangePassword(false);

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    return LoginResult(tokens: tokens, user: MockData.getUser(email));
  }

  Future<UserProfile> getCurrentUser() async {
    if (AppConfig.useMockAuth) {
      return _mockGetCurrentUser();
    }

    final realm = await _authRealm();
    final response = realm == AuthRealm.admin
        ? await _coreClient.get('auth/me')
        : await _client.get('auth/me');
    final data =
        (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    final profile = UserProfile.fromJson(data);
    await _storage.saveMustChangePassword(profile.mustChangePassword);
    if (profile.kangiderId != null) {
      await _storage.saveKangiderId(profile.kangiderId!);
    }
    if (profile.roleName != null) {
      _inMemoryRole = profile.roleName;
      await _storage.saveUserRole(profile.roleName!);
    }
    return profile;
  }

  Future<UserProfile> _mockGetCurrentUser() async {
    final email = _inMemoryEmail ?? await _storage.getUserEmail();
    final profile = MockData.getUser(email ?? '');
    _inMemoryEmail = profile.email;
    _inMemoryRole =
        profile.roleName ?? (profile.isAdmin ? 'Admin' : 'Karyawan');

    if (profile.kangiderId != null) {
      await _storage.saveKangiderId(profile.kangiderId!);
    }
    if (profile.roleName != null) {
      await _storage.saveUserRole(profile.roleName!);
    }

    return profile;
  }

  Future<void> logout() async {
    final realm = await _authRealm();
    _inMemoryEmail = null;
    _inMemoryRole = null;
    _inMemoryRealm = null;
    if (!AppConfig.useMockAuth) {
      try {
        final refreshToken = await _storage.getRefreshToken();
        final options = refreshToken == null
            ? null
            : Options(headers: {'X-Refresh-Token': refreshToken});
        if (realm == AuthRealm.admin) {
          await _coreClient.post(
            'auth/logout',
            body: {'refresh_token': refreshToken},
            options: options,
          );
        } else {
          await _client.post(
            'auth/logout',
            body: {'refresh_token': refreshToken},
            options: options,
          );
        }
      } catch (_) {
        // ignore logout API errors
      }
    }
    await _storage.clearAll();
    if (realm == AuthRealm.employee) {
      await SyncWorker.cancel();
      await OutletRepository().clearCache();
      await AppDatabase().resetAll();
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (AppConfig.useMockAuth) return;
    if (await _authRealm() == AuthRealm.admin) {
      throw UnsupportedError('Admin password changes use the core dashboard');
    }
    try {
      await _client.post(
        'auth/change-password',
        body: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );
    } on DioException catch (error) {
      final responseData = error.response?.data;
      final serverError =
          responseData is Map ? responseData['error']?.toString() : null;
      final status = error.response?.statusCode;

      if (status == 401 && serverError == 'current password is incorrect') {
        throw const ChangePasswordException(
          'Kata sandi saat ini tidak cocok.',
        );
      }
      if (status == 401) {
        throw const ChangePasswordException(
          'Sesi login sudah tidak valid. Silakan masuk kembali.',
          sessionExpired: true,
        );
      }
      if (status == 400) {
        throw const ChangePasswordException(
          'Kata sandi baru tidak valid. Gunakan minimal 8 karakter dan pastikan berbeda dari kata sandi saat ini.',
        );
      }
      throw const ChangePasswordException(
        'Kata sandi tidak dapat diubah. Coba lagi beberapa saat.',
      );
    }
  }

  Future<bool> isLoggedIn() async {
    if (_inMemoryEmail != null) return true;
    final token = await _storage.getAccessToken();
    final expiresAt = await _storage.getExpiresAt();
    if (token == null) return false;
    if (expiresAt == null || DateTime.now().isAfter(expiresAt)) {
      final refreshed = await _client.refreshSession();
      if (!refreshed) {
        await _storage.clearAll();
      }
      return refreshed;
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

  Future<bool> getMustChangePassword() async {
    return _storage.getMustChangePassword();
  }

  Future<AuthRealm> _authRealm() async {
    return _inMemoryRealm ??= await _storage.getAuthRealm();
  }
}
