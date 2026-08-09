import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:html' as html show window;

class SecureStorage {
  SecureStorage._internal();
  static final SecureStorage _instance = SecureStorage._internal();
  factory SecureStorage() => _instance;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _prefix = 'iderkopi_';

  String _fullKey(String key) => '$_prefix$key';

  Future<void> _write(String key, String value) async {
    if (kIsWeb) {
      html.window.localStorage[_fullKey(key)] = value;
    } else {
      await _secureStorage.write(key: key, value: value);
    }
  }

  Future<String?> _read(String key) async {
    if (kIsWeb) {
      return html.window.localStorage[_fullKey(key)];
    } else {
      return await _secureStorage.read(key: key);
    }
  }

  Future<void> _delete(String key) async {
    if (kIsWeb) {
      html.window.localStorage.remove(_fullKey(key));
    } else {
      await _secureStorage.delete(key: key);
    }
  }

  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyExpiresAt = 'expires_at';
  static const _keyUserEmail = 'user_email';
  static const _keyKangiderId = 'kangider_id';
  static const _keyUserRole = 'user_role';

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

  Future<void> clearAll() async {
    if (kIsWeb) {
      final keys = html.window.localStorage.keys
          .where((k) => k.startsWith(_prefix))
          .toList();
      for (final key in keys) {
        html.window.localStorage.remove(key);
      }
    } else {
      await _secureStorage.deleteAll();
    }
  }
}
