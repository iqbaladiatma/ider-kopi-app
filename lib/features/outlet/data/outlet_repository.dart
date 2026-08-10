import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/utils/mock_data.dart';
import 'outlet_model.dart';

class OutletRepository {
  OutletRepository._();
  static final OutletRepository _instance = OutletRepository._();
  factory OutletRepository() => _instance;

  final ApiClient _client = ApiClient.instance;
  final SecureStorage _storage = SecureStorage();
  static const _cacheKey = 'cache_outlet_v2';
  static const _cacheTimestampKey = 'cache_outlet_ts_v2';
  static const _cacheTtl = Duration(hours: 24);

  Future<List<Outlet>> getOutlets({bool forceRefresh = false}) async {
    if (AppConfig.useMockAuth) {
      return MockData.mockOutlets.map(Outlet.fromJson).toList();
    }
    final realm = await _storage.getAuthRealm();
    final isAdmin = realm == AuthRealm.admin;
    final response = await _client.get(
      isAdmin ? 'admin/outlets' : 'outlets',
      query: isAdmin ? null : {'active': true},
    );
    final envelope = response.data as Map<String, dynamic>;
    final raw = (envelope['data'] as List<dynamic>?) ?? const [];
    final outlets = raw
        .map((item) => Outlet.fromJson((item as Map).cast<String, dynamic>()))
        .where((outlet) => outlet.hasValidGeofence)
        .toList();
    await _saveToCache(outlets);
    return outlets;
  }

  Future<Outlet?> getOutletById(String id) async {
    final outlets = await getOutlets();
    for (final outlet in outlets) {
      if (outlet.id == id) return outlet;
    }
    return null;
  }

  Future<void> addOutlet(Outlet outlet) async {
    if (AppConfig.useMockAuth) return;
    await _client.post('admin/outlets', body: outlet.toJson());
    await getOutlets(forceRefresh: true);
  }

  Future<void> updateOutlet(Outlet outlet) async {
    if (AppConfig.useMockAuth) return;
    await _client.put('admin/outlets/${outlet.id}', body: outlet.toJson());
    await getOutlets(forceRefresh: true);
  }

  Future<List<Outlet>?> loadCachedOutlets() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null) return null;
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((item) => Outlet.fromJson((item as Map).cast<String, dynamic>()))
        .toList();
  }

  Future<void> _saveToCache(List<Outlet> outlets) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _cacheKey,
      jsonEncode(outlets.map((outlet) => outlet.toJson()).toList()),
    );
    await prefs.setInt(
      _cacheTimestampKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<bool> isCacheStale() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_cacheTimestampKey);
    if (timestamp == null) return true;
    return DateTime.now().millisecondsSinceEpoch - timestamp >
        _cacheTtl.inMilliseconds;
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    await prefs.remove(_cacheTimestampKey);
  }
}
