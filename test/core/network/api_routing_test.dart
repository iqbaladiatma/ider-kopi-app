import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iderkopi_absensi/core/config/app_config.dart';
import 'package:iderkopi_absensi/core/network/api_client.dart';
import 'package:iderkopi_absensi/core/network/auth_api_client.dart';
import 'package:iderkopi_absensi/core/network/auth_interceptor.dart';
import 'package:iderkopi_absensi/core/storage/secure_storage.dart';
import 'package:iderkopi_absensi/features/auth/data/auth_repository.dart';
import 'package:iderkopi_absensi/features/outlet/data/outlet_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _RecordingAdapter implements HttpClientAdapter {
  _RecordingAdapter(this.respond);

  final ResponseBody Function(RequestOptions options, int requestNumber)
      respond;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return respond(options, requests.length);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _jsonResponse(Object body, {int statusCode = 200}) {
  return ResponseBody.fromString(
    jsonEncode(body),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

Dio _dio(String baseUrl, HttpClientAdapter adapter) {
  return Dio(BaseOptions(baseUrl: baseUrl))..httpClientAdapter = adapter;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
  });

  test('failed login does not create an in-memory authenticated session',
      () async {
    final adapter = _RecordingAdapter(
      (_, __) =>
          _jsonResponse({'error': 'invalid credentials'}, statusCode: 401),
    );
    final authDio = _dio(AppConfig.authApiBaseUrl, adapter);
    final coordinator = TokenRefreshCoordinator(
      storage: SecureStorage(),
      authDio: authDio,
    );
    final repository = AuthRepository.withDependencies(
      client: AuthApiClient.forTesting(
        authDio,
        refreshCoordinator: coordinator,
      ),
    );

    await expectLater(
      repository.login('user@example.invalid', 'wrong-password'),
      throwsA(
        isA<AuthLoginException>().having(
          (error) => error.message,
          'message',
          'Email atau password salah.',
        ),
      ),
    );
    expect(await repository.isLoggedIn(), isFalse);
  });

  test('login and change-password route exclusively to auth service', () async {
    final adapter = _RecordingAdapter((options, _) {
      if (options.path.endsWith('auth/login')) {
        return _jsonResponse({
          'data': {
            'access_token': 'synthetic-access-token',
            'refresh_token': 'synthetic-refresh-token',
            'user': {
              'id': 'synthetic-user-id',
              'email': 'user@example.invalid',
              'role': 'employee',
              'must_change_password': true,
            },
          },
        });
      }
      return _jsonResponse({'data': {}});
    });
    final authDio = _dio(AppConfig.authApiBaseUrl, adapter);
    final storage = SecureStorage();
    final coordinator = TokenRefreshCoordinator(
      storage: storage,
      authDio: authDio,
    );
    authDio.interceptors.add(
      AuthInterceptor(
        storage: storage,
        requestDio: authDio,
        refreshCoordinator: coordinator,
      ),
    );
    final authClient = AuthApiClient.forTesting(
      authDio,
      refreshCoordinator: coordinator,
    );
    final repository = AuthRepository.withDependencies(client: authClient);

    final result = await repository.login(
      'user@example.invalid',
      'synthetic-password',
    );
    await repository.changePassword(
      currentPassword: 'synthetic-password',
      newPassword: 'different-synthetic-password',
    );
    await authClient.get('auth/me');
    await authClient.post('auth/logout');

    expect(result.user.mustChangePassword, isTrue);
    expect(
      adapter.requests[1].headers['Authorization'],
      'Bearer synthetic-access-token',
    );
    expect(
      adapter.requests.map((request) => request.uri.toString()),
      [
        'https://iderkopi.tailcbf3a3.ts.net:8443/employee-auth/api/v1/auth/login',
        'https://iderkopi.tailcbf3a3.ts.net:8443/employee-auth/api/v1/auth/change-password',
        'https://iderkopi.tailcbf3a3.ts.net:8443/employee-auth/api/v1/auth/me',
        'https://iderkopi.tailcbf3a3.ts.net:8443/employee-auth/api/v1/auth/logout',
      ],
    );
  });

  test('change-password distinguishes current password mismatch', () async {
    final adapter = _RecordingAdapter(
      (_, __) => _jsonResponse(
        {'error': 'current password is incorrect'},
        statusCode: 401,
      ),
    );
    final authDio = _dio(AppConfig.authApiBaseUrl, adapter);
    final coordinator = TokenRefreshCoordinator(
      storage: SecureStorage(),
      authDio: authDio,
    );
    final repository = AuthRepository.withDependencies(
      client: AuthApiClient.forTesting(
        authDio,
        refreshCoordinator: coordinator,
      ),
    );

    await expectLater(
      repository.changePassword(
        currentPassword: 'synthetic-password',
        newPassword: 'different-synthetic-password',
      ),
      throwsA(
        isA<ChangePasswordException>()
            .having((error) => error.sessionExpired, 'sessionExpired', isFalse)
            .having(
              (error) => error.message,
              'message',
              'Kata sandi saat ini tidak cocok.',
            ),
      ),
    );
  });

  test('change-password identifies an invalid login session', () async {
    final adapter = _RecordingAdapter(
      (_, __) => _jsonResponse(
        {'error': 'invalid access token'},
        statusCode: 401,
      ),
    );
    final authDio = _dio(AppConfig.authApiBaseUrl, adapter);
    final coordinator = TokenRefreshCoordinator(
      storage: SecureStorage(),
      authDio: authDio,
    );
    final repository = AuthRepository.withDependencies(
      client: AuthApiClient.forTesting(
        authDio,
        refreshCoordinator: coordinator,
      ),
    );

    await expectLater(
      repository.changePassword(
        currentPassword: 'synthetic-password',
        newPassword: 'different-synthetic-password',
      ),
      throwsA(
        isA<ChangePasswordException>()
            .having((error) => error.sessionExpired, 'sessionExpired', isTrue)
            .having(
              (error) => error.message,
              'message',
              'Sesi login sudah tidak valid. Silakan masuk kembali.',
            ),
      ),
    );
  });

  test('business request stays on core service', () async {
    final adapter = _RecordingAdapter(
      (_, __) => _jsonResponse({'data': []}),
    );
    final dio = ApiClient.instance.dio;
    final originalAdapter = dio.httpClientAdapter;
    addTearDown(() => dio.httpClientAdapter = originalAdapter);
    dio.httpClientAdapter = adapter;

    await ApiClient.instance.get('attendance');

    expect(
      adapter.requests.single.uri.toString(),
      'https://iderkopi.tailcbf3a3.ts.net:8443/core/api/v1/attendance',
    );
  });

  test('admin outlet listing keeps unconfigured outlets visible', () async {
    await SecureStorage().saveAuthRealm(AuthRealm.admin);
    final adapter = _RecordingAdapter(
      (_, __) => _jsonResponse({
        'data': [
          {
            'id': 'unconfigured-outlet',
            'name': 'IderKopi - Winarko',
            'address': 'Belum dikonfigurasi',
            'latitude': 0,
            'longitude': 0,
            'radius_meters': 200,
            'is_active': false,
          },
        ],
      }),
    );
    final dio = ApiClient.instance.dio;
    final originalAdapter = dio.httpClientAdapter;
    addTearDown(() => dio.httpClientAdapter = originalAdapter);
    dio.httpClientAdapter = adapter;

    final outlets = await OutletRepository().getOutlets(forceRefresh: true);

    expect(
      adapter.requests.single.uri.toString(),
      'https://iderkopi.tailcbf3a3.ts.net:8443/core/api/v1/admin/outlets',
    );
    expect(outlets, hasLength(1));
    expect(outlets.single.nama, 'IderKopi - Winarko');
  });

  test('employee outlet listing filters unsafe unconfigured outlets', () async {
    await SecureStorage().saveAuthRealm(AuthRealm.employee);
    final adapter = _RecordingAdapter(
      (_, __) => _jsonResponse({
        'data': [
          {
            'id': 'unsafe-outlet',
            'name': 'IderKopi - Winarko',
            'address': 'Belum dikonfigurasi',
            'latitude': 0,
            'longitude': 0,
            'radius_meters': 200,
            'is_active': false,
          },
        ],
      }),
    );
    final dio = ApiClient.instance.dio;
    final originalAdapter = dio.httpClientAdapter;
    addTearDown(() => dio.httpClientAdapter = originalAdapter);
    dio.httpClientAdapter = adapter;

    final outlets = await OutletRepository().getOutlets(forceRefresh: true);

    expect(adapter.requests.single.uri.path, '/core/api/v1/outlets');
    expect(adapter.requests.single.uri.queryParameters['active'], 'true');
    expect(outlets, isEmpty);
  });

  test('business 401 refreshes on auth service and retries once', () async {
    await SecureStorage().saveTokens(
      accessToken: 'expired-synthetic-token',
      refreshToken: 'synthetic-refresh-token',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );

    final refreshAdapter = _RecordingAdapter(
      (_, __) => _jsonResponse({
        'data': {
          'access_token': 'new-synthetic-token',
          'refresh_token': 'new-synthetic-refresh-token',
        },
      }),
    );
    final businessAdapter = _RecordingAdapter((_, requestNumber) {
      if (requestNumber == 1) {
        return _jsonResponse({'error': 'expired'}, statusCode: 401);
      }
      return _jsonResponse({'data': []});
    });
    final refreshDio = _dio(AppConfig.authApiBaseUrl, refreshAdapter);
    final businessDio = _dio(AppConfig.coreApiBaseUrl, businessAdapter);
    final coordinator = TokenRefreshCoordinator(
      storage: SecureStorage(),
      authDio: refreshDio,
    );
    businessDio.interceptors.add(
      AuthInterceptor(
        storage: SecureStorage(),
        requestDio: businessDio,
        refreshCoordinator: coordinator,
      ),
    );

    final response = await businessDio.get<dynamic>('kpi/me');

    expect(response.statusCode, 200);
    expect(businessAdapter.requests, hasLength(2));
    expect(
      businessAdapter.requests.every(
        (request) =>
            request.uri.port == 8443 && request.uri.path.startsWith('/core/'),
      ),
      isTrue,
    );
    expect(
      refreshAdapter.requests.single.uri.toString(),
      'https://iderkopi.tailcbf3a3.ts.net:8443/employee-auth/api/v1/auth/refresh',
    );
    expect(
      businessAdapter.requests.last.headers['Authorization'],
      'Bearer new-synthetic-token',
    );
  });

  test('expired admin token refreshes before parallel business requests',
      () async {
    final storage = SecureStorage();
    await storage.saveAuthRealm(AuthRealm.admin);
    await storage.saveTokens(
      accessToken: 'expired-admin-token',
      refreshToken: 'synthetic-admin-refresh-token',
      expiresAt: DateTime.fromMillisecondsSinceEpoch(0),
    );

    final employeeAdapter = _RecordingAdapter(
      (_, __) => _jsonResponse({'error': 'wrong realm'}, statusCode: 500),
    );
    final adminRefreshAdapter = _RecordingAdapter(
      (_, __) => _jsonResponse({
        'data': {
          'access_token': 'new-synthetic-admin-token',
          'refresh_token': 'new-synthetic-admin-refresh-token',
          'expires_at':
              DateTime.now().add(const Duration(minutes: 15)).toIso8601String(),
        },
      }),
    );
    final businessAdapter = _RecordingAdapter(
      (_, __) => _jsonResponse({'data': []}),
    );
    final businessDio = _dio(AppConfig.coreApiBaseUrl, businessAdapter);
    final coordinator = TokenRefreshCoordinator(
      storage: storage,
      authDio: _dio(AppConfig.authApiBaseUrl, employeeAdapter),
      adminAuthDio: _dio(AppConfig.coreApiBaseUrl, adminRefreshAdapter),
    );
    businessDio.interceptors.add(
      AuthInterceptor(
        storage: storage,
        requestDio: businessDio,
        refreshCoordinator: coordinator,
      ),
    );

    final responses = await Future.wait([
      businessDio.get<dynamic>('attendance/logs'),
      businessDio.get<dynamic>('mobile-auth/accounts'),
    ]);

    expect(responses.every((response) => response.statusCode == 200), isTrue);
    expect(employeeAdapter.requests, isEmpty);
    expect(adminRefreshAdapter.requests, hasLength(1));
    expect(businessAdapter.requests, hasLength(2));
    expect(
      businessAdapter.requests.every(
        (request) =>
            request.headers['Authorization'] ==
            'Bearer new-synthetic-admin-token',
      ),
      isTrue,
    );
  });

  test('admin login and current-user route exclusively to core service',
      () async {
    final employeeAdapter = _RecordingAdapter(
      (_, __) => _jsonResponse({'error': 'employee auth must not be called'},
          statusCode: 500),
    );
    final coreAdapter = _RecordingAdapter((options, _) {
      if (options.path.endsWith('auth/login')) {
        return _jsonResponse({
          'data': {
            'access_token': 'synthetic-admin-access-token',
            'refresh_token': 'synthetic-admin-refresh-token',
            'user': {
              'id': 'synthetic-admin-id',
              'email': 'admin@example.invalid',
              'role': 'super_admin',
            },
          },
        });
      }
      return _jsonResponse({
        'data': {
          'id': 'synthetic-admin-id',
          'email': 'admin@example.invalid',
          'role': 'super_admin',
        },
      });
    });
    final employeeDio = _dio(AppConfig.authApiBaseUrl, employeeAdapter);
    final coreDio = _dio(AppConfig.coreApiBaseUrl, coreAdapter);
    final coordinator = TokenRefreshCoordinator(
      storage: SecureStorage(),
      authDio: employeeDio,
      adminAuthDio: coreDio,
    );
    final authClient = AuthApiClient.forTesting(
      employeeDio,
      refreshCoordinator: coordinator,
    );
    final coreClient = ApiClient.forTesting(
      coreDio,
      refreshCoordinator: coordinator,
    );
    final repository = AuthRepository.withDependencies(
      client: authClient,
      coreClient: coreClient,
    );

    final result = await repository.login(
      'admin@example.invalid',
      'synthetic-password',
      isAdmin: true,
    );
    final current = await repository.getCurrentUser();

    expect(result.user.roleName, 'super_admin');
    expect(current.roleName, 'super_admin');
    expect(await SecureStorage().getAuthRealm(), AuthRealm.admin);
    await repository.logout();
    expect(employeeAdapter.requests, isEmpty);
    expect(
      coreAdapter.requests.map((request) => request.uri.toString()),
      [
        'https://iderkopi.tailcbf3a3.ts.net:8443/core/api/v1/auth/login',
        'https://iderkopi.tailcbf3a3.ts.net:8443/core/api/v1/auth/me',
        'https://iderkopi.tailcbf3a3.ts.net:8443/core/api/v1/auth/logout',
      ],
    );
  });

  test('admin session refresh routes only to core auth service', () async {
    final storage = SecureStorage();
    await storage.saveAuthRealm(AuthRealm.admin);
    await storage.saveTokens(
      accessToken: 'expired-admin-token',
      refreshToken: 'synthetic-admin-refresh-token',
      expiresAt: DateTime.fromMillisecondsSinceEpoch(0),
    );
    final employeeAdapter = _RecordingAdapter(
      (_, __) => _jsonResponse({'error': 'wrong realm'}, statusCode: 500),
    );
    final adminAdapter = _RecordingAdapter(
      (_, __) => _jsonResponse({
        'data': {'access_token': 'new-synthetic-admin-token'},
      }),
    );
    final coordinator = TokenRefreshCoordinator(
      storage: storage,
      authDio: _dio(AppConfig.authApiBaseUrl, employeeAdapter),
      adminAuthDio: _dio(AppConfig.coreApiBaseUrl, adminAdapter),
    );

    expect(await coordinator.refreshToken(), isTrue);
    expect(employeeAdapter.requests, isEmpty);
    expect(
      adminAdapter.requests.single.uri.toString(),
      'https://iderkopi.tailcbf3a3.ts.net:8443/core/api/v1/auth/refresh',
    );
  });
}
