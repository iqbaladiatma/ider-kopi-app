import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../storage/secure_storage.dart';
import 'auth_api_client.dart';
import 'auth_interceptor.dart';

/// HTTP client for core business and employee data only.
class ApiClient {
  ApiClient._(this._dio, this.authInterceptor);

  static ApiClient? _instance;
  final Dio _dio;
  final AuthInterceptor authInterceptor;

  static ApiClient get instance => _instance ??= _create();

  @visibleForTesting
  factory ApiClient.forTesting(
    Dio dio, {
    required TokenRefreshCoordinator refreshCoordinator,
    SecureStorage? storage,
  }) {
    final interceptor = AuthInterceptor(
      storage: storage ?? SecureStorage(),
      requestDio: dio,
      refreshCoordinator: refreshCoordinator,
    );
    dio.interceptors.add(interceptor);
    return ApiClient._(dio, interceptor);
  }

  static ApiClient _create() {
    final storage = SecureStorage();
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.coreApiBaseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: const {'Content-Type': 'application/json'},
      ),
    );
    final interceptor = AuthInterceptor(
      storage: storage,
      requestDio: dio,
      refreshCoordinator: AuthApiClient.instance.refreshCoordinator,
    );
    dio.interceptors.add(interceptor);
    if (kDebugMode) {
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
    return ApiClient._(dio, interceptor);
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

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
  }) =>
      _dio.get(_path(path), queryParameters: query);

  Future<Response<dynamic>> post(
    String path, {
    dynamic body,
    FormData? formData,
    Options? options,
  }) =>
      _dio.post(_path(path), data: formData ?? body, options: options);

  Future<Response<dynamic>> put(
    String path, {
    dynamic body,
  }) =>
      _dio.put(_path(path), data: body);

  Future<Response<dynamic>> patch(
    String path, {
    dynamic body,
  }) =>
      _dio.patch(_path(path), data: body);

  Future<Response<dynamic>> delete(String path) => _dio.delete(_path(path));

  Future<bool> refreshSession() =>
      AuthApiClient.instance.refreshCoordinator.refreshToken();

  Future<bool> isOnline() async {
    try {
      await get('outlets').timeout(const Duration(seconds: 4));
      return true;
    } on DioException catch (error) {
      return error.response != null;
    } catch (_) {
      return false;
    }
  }

  Dio get dio => _dio;
}
