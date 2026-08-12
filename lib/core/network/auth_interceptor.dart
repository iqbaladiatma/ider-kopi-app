import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../storage/secure_storage.dart';

const _retriedAfterRefreshKey = 'retriedAfterTokenRefresh';
const _refreshBeforeExpiry = Duration(seconds: 30);

/// Refreshes access tokens through the issuer stored for the active realm.
/// A single coordinator is shared by auth and business clients so concurrent
/// 401 responses result in one refresh request without crossing issuers.
class TokenRefreshCoordinator {
  TokenRefreshCoordinator({
    required this.storage,
    required this.authDio,
    this.adminAuthDio,
  });

  final SecureStorage storage;
  final Dio authDio;
  final Dio? adminAuthDio;
  Future<bool>? _refreshFuture;

  Future<bool> refreshToken() {
    return _refreshFuture ??= _performRefresh().whenComplete(() {
      _refreshFuture = null;
    });
  }

  Future<bool> _performRefresh() async {
    try {
      final refreshToken = await storage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) return false;

      final realm = await storage.getAuthRealm();
      final refreshClient =
          realm == AuthRealm.admin ? (adminAuthDio ?? authDio) : authDio;

      final response = await refreshClient.post<dynamic>(
        'auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      final responseData = response.data;
      if (response.statusCode != 200 || responseData is! Map) return false;

      final rawData = responseData.cast<String, dynamic>();
      final nestedData = rawData['data'];
      final data =
          nestedData is Map ? nestedData.cast<String, dynamic>() : rawData;
      final newAccessToken = data['access_token'] as String?;
      final newRefreshToken =
          (data['refresh_token'] as String?) ?? refreshToken;
      if (newAccessToken == null || newAccessToken.isEmpty) return false;

      await storage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
        expiresAt: _responseExpiry(data),
      );
      return true;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Token refresh failed: $error');
      }
      return false;
    }
  }

  DateTime _responseExpiry(Map<String, dynamic> data) {
    return DateTime.tryParse(data['expires_at']?.toString() ?? '') ??
        DateTime.now().add(const Duration(minutes: 15));
  }
}

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.storage,
    required this.requestDio,
    required this.refreshCoordinator,
  });

  final SecureStorage storage;
  final Dio requestDio;
  final TokenRefreshCoordinator refreshCoordinator;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final isBootstrap = _isAuthenticationBootstrapEndpoint(options.path);
    if (!isBootstrap) {
      final expiresAt = await storage.getExpiresAt();
      final shouldRefresh = expiresAt != null &&
          !expiresAt.isAfter(DateTime.now().add(_refreshBeforeExpiry));
      if (shouldRefresh) {
        await refreshCoordinator.refreshToken();
      }
    }

    final token = await storage.getAccessToken();
    if (token != null && token.isNotEmpty && !isBootstrap) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final request = err.requestOptions;
    final shouldRefresh = err.response?.statusCode == 401 &&
        !_isAuthenticationBootstrapEndpoint(request.path) &&
        request.extra[_retriedAfterRefreshKey] != true;

    if (!shouldRefresh) {
      handler.next(err);
      return;
    }

    final refreshed = await refreshCoordinator.refreshToken();
    if (!refreshed) {
      await storage.clearAll();
      handler.next(err);
      return;
    }

    try {
      final newToken = await storage.getAccessToken();
      final retryOptions = request.copyWith(
        headers: <String, dynamic>{
          ...request.headers,
          'Authorization': 'Bearer $newToken',
        },
        extra: <String, dynamic>{
          ...request.extra,
          _retriedAfterRefreshKey: true,
        },
      );
      final response = await requestDio.fetch<dynamic>(retryOptions);
      handler.resolve(response);
    } catch (_) {
      handler.next(err);
    }
  }

  bool _isAuthenticationBootstrapEndpoint(String path) {
    final normalized = Uri.tryParse(path)?.path ?? path;
    return normalized.endsWith('/auth/login') ||
        normalized.endsWith('/auth/refresh') ||
        normalized == 'auth/login' ||
        normalized == 'auth/refresh';
  }
}
