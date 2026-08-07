import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/api_provider.dart';
import '../config/app_config.dart';
import '../storage/secure_storage.dart';
import 'auth_interceptor.dart';

class DirectusClient {
  DirectusClient._internal(this._dio);
  static DirectusClient? _instance;

  final Dio _dio;

  static DirectusClient get instance {
    if (_instance == null) {
      final storage = SecureStorage();
      final dio = Dio(BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
        },
      ));

      dio.interceptors.add(AuthInterceptor(storage: storage, dio: dio));

      if (kDebugMode) {
        dio.interceptors.add(LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
        ));
      }

      _instance = DirectusClient._internal(dio);
    }
    return _instance!;
  }

  Future<Response> get(String path, {Map<String, dynamic>? query}) {
    return _dio.get(path, queryParameters: query);
  }

  Future<Response> post(String path, {dynamic body, FormData? formData}) {
    if (formData != null) {
      return _dio.post(path, data: formData);
    }
    return _dio.post(path, data: body);
  }

  Future<Response> patch(String path, {dynamic body}) {
    return _dio.patch(path, data: body);
  }

  Future<Response> delete(String path) {
    return _dio.delete(path);
  }

  Dio get dio => _dio;

  /// Cek koneksi ke API server (best-effort, timeout 3 detik).
  /// Dipakai untuk menampilkan banner offline di UI.
  static Future<bool> isOnline() async {
    try {
      final dio = instance._dio;
      // Go backend punya /health; Directus pakai endpoint ringan sebagai fallback
      final healthPath = AppConfig.apiProvider == ApiProvider.directus
          ? '/items/outlet_ider'
          : '/health';
      await dio.get(healthPath, queryParameters: AppConfig.apiProvider == ApiProvider.directus ? {'limit': '1'} : null).timeout(
        const Duration(seconds: 3),
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
