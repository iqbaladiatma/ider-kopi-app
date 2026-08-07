import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/api_provider.dart';
import '../config/app_config.dart';
import '../storage/secure_storage.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.storage, required this.dio});

  final SecureStorage storage;
  final Dio dio;

  bool _isRefreshing = false;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await storage.getAccessToken();
    if (token != null && !_isAuthEndpoint(options.path)) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isAuthEndpoint(err.requestOptions.path)) {
      final refreshed = await _refreshToken();
      if (refreshed) {
        try {
          final newToken = await storage.getAccessToken();
          final clonedRequest = err.requestOptions
            ..headers['Authorization'] = 'Bearer $newToken';
          final response = await dio.fetch(clonedRequest);
          handler.resolve(response);
          return;
        } catch (e) {
          // fall through to reject
        }
      } else {
        await storage.clearAll();
      }
    }
    handler.next(err);
  }

  Future<bool> _refreshToken() async {
    if (_isRefreshing) return false;
    _isRefreshing = true;
    try {
      final refreshToken = await storage.getRefreshToken();
      if (refreshToken == null) return false;

      // Pilih endpoint refresh sesuai provider aktif
      final refreshEndpoint = AppConfig.apiProvider == ApiProvider.directus
          ? '/auth/refresh'
          : '/api/v1/auth/refresh';

      final response = await dio.post(
        refreshEndpoint,
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final rawData = response.data;
        // Directus: { data: { access_token, refresh_token, expires } }
        // Go backend: { success: true, data: { access_token } }
        final data = rawData['data'] ?? rawData;
        final newAccessToken = data['access_token'];
        final newRefreshToken = data['refresh_token'] ?? refreshToken;
        final expires = data['expires'];

        if (newAccessToken != null) {
          await storage.saveTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
            expiresAt: DateTime.now().add(
              Duration(seconds: expires is int ? expires : 900),
            ),
          );
          return true;
        }
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Token refresh failed: $e');
      }
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  bool _isAuthEndpoint(String path) {
    return path.contains('/auth/login') || path.contains('/auth/refresh');
  }
}
