import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../storage/secure_storage.dart';
import 'auth_interceptor.dart';

/// HTTP client dedicated to the standalone authentication service.
class AuthApiClient {
  AuthApiClient._(
    this._dio,
    this.refreshCoordinator,
  );

  static AuthApiClient? _instance;

  final Dio _dio;
  final TokenRefreshCoordinator refreshCoordinator;

  static AuthApiClient get instance => _instance ??= _create();

  static AuthApiClient _create() {
    final storage = SecureStorage();
    final refreshDio = _newDio(AppConfig.authApiBaseUrl);
    final adminRefreshDio = _newDio(AppConfig.coreApiBaseUrl);
    final requestDio = _newDio(AppConfig.authApiBaseUrl);
    final coordinator = TokenRefreshCoordinator(
      storage: storage,
      authDio: refreshDio,
      adminAuthDio: adminRefreshDio,
    );
    requestDio.interceptors.add(
      AuthInterceptor(
        storage: storage,
        requestDio: requestDio,
        refreshCoordinator: coordinator,
      ),
    );
    _addDebugLogging(requestDio);
    return AuthApiClient._(requestDio, coordinator);
  }

  @visibleForTesting
  factory AuthApiClient.forTesting(
    Dio dio, {
    required TokenRefreshCoordinator refreshCoordinator,
  }) {
    return AuthApiClient._(dio, refreshCoordinator);
  }

  static Dio _newDio(String baseUrl) => Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: AppConfig.connectTimeout,
          receiveTimeout: AppConfig.receiveTimeout,
          headers: const {'Content-Type': 'application/json'},
        ),
      );

  static void _addDebugLogging(Dio dio) {
    if (!kDebugMode) return;
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: false,
        requestBody: false,
        responseHeader: false,
        responseBody: false,
        error: true,
      ),
    );
  }

  String _path(String path) {
    var normalized = path.trim();
    if (normalized.startsWith('/api/v1/')) {
      normalized = normalized.substring('/api/v1/'.length);
    }
    while (normalized.startsWith('/')) {
      normalized = normalized.substring(1);
    }
    return normalized;
  }

  Future<Response<dynamic>> get(String path) => _dio.get(_path(path));

  Future<Response<dynamic>> post(
    String path, {
    dynamic body,
    Options? options,
  }) =>
      _dio.post(_path(path), data: body, options: options);

  Future<bool> refreshSession() => refreshCoordinator.refreshToken();

  Dio get dio => _dio;
}
