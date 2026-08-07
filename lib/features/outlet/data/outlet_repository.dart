import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/api_provider.dart';
import '../../../core/config/app_config.dart';
import '../../../core/network/directus_client.dart';
import '../../../core/utils/mock_data.dart';
import 'outlet_model.dart';

/// Repository untuk fetch & cache list outlet IderKopi.
///
/// Strategi: cache-first (SharedPreferences, TTL 24 jam) lalu refresh dari API.
/// Saat offline atau API gagal, gunakan cache. Jika cache kosong, fallback mock.
class OutletRepository {
  OutletRepository._internal();
  static final OutletRepository _instance = OutletRepository._internal();
  factory OutletRepository() => _instance;

  final DirectusClient _client = DirectusClient.instance;

  static const String _cacheKey = 'cache_outlet_v1';
  static const String _cacheTimestampKey = 'cache_outlet_ts_v1';
  static const Duration _cacheTtl = Duration(hours: 24);

  /// Ambil semua outlet aktif.
  /// Cache-first: jika cache masih fresh, langsung return.
  /// Selalu coba refresh dari API di background (best-effort).
  Future<List<Outlet>> getOutlets({bool forceRefresh = false}) async {
    // 1. Coba cache dulu jika tidak dipaksa refresh
    if (!forceRefresh) {
      final cached = await _loadFromCache();
      if (cached != null && _isCacheFresh()) {
        // Refresh di background (best-effort, tidak menunggu)
        _refreshFromApi().ignore();
        return cached;
      }
    }

    // 2. Coba fetch dari API
    try {
      final outlets = await _refreshFromApi();
      return outlets;
    } catch (e) {
      // 3. Fallback: cache (meskipun stale) atau mock
      final cached = await _loadFromCache();
      if (cached != null && cached.isNotEmpty) return cached;

      if (kDebugMode) {
        debugPrint('OutletRepository: API gagal, fallback ke mock. Error: $e');
      }
      return _mockOutlets();
    }
  }

  /// Ambil outlet berdasarkan id.
  Future<Outlet?> getOutletById(int id) async {
    final outlets = await getOutlets();
    try {
      return outlets.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Fetch langsung dari API (Directus atau Go backend) atau mock jika useMockAuth.
  /// Tidak membaca cache. Hasil disimpan ke cache.
  Future<List<Outlet>> _refreshFromApi() async {
    List<Map<String, dynamic>> raw;

    if (AppConfig.useMockAuth) {
      raw = MockData.mockOutlets;
    } else if (AppConfig.apiProvider == ApiProvider.directus) {
      final response = await _client.get('/items/outlet_ider', query: {
        'filter[is_active][_eq]': 'true',
        'sort': 'nama',
        'limit': '50',
      });
      final data = response.data['data'] as List;
      raw = data.cast<Map<String, dynamic>>();
    } else {
      // Go backend: gunakan endpoint departments sebagai sumber "outlet"
      // Field: id, name, description
      final response = await _client.get('/api/v1/departments');
      final data = response.data['data'] as List;
      raw = (data.cast<Map<String, dynamic>>()).map((d) => {
        'id': d['id'],
        'nama': d['name'],
        'alamat': d['description'],
        // Go backend belum punya koordinat outlet — pakai default Surabaya
        'latitude': -7.2575,
        'longitude': 112.7521,
        'radius_meters': 100.0,
        'is_active': true,
      }).toList();
    }

    final outlets = raw.map((e) => Outlet.fromJson(e)).toList();
    await _saveToCache(outlets);
    return outlets;
  }

  List<Outlet> _mockOutlets() {
    return MockData.mockOutlets.map((e) => Outlet.fromJson(e)).toList();
  }

  // --- Cache helpers (SharedPreferences) ---

  Future<List<Outlet>?> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw == null) return null;
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => Outlet.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveToCache(List<Outlet> outlets) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(outlets.map((o) => o.toJson()).toList());
      await prefs.setString(_cacheKey, raw);
      await prefs.setInt(_cacheTimestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (_) {
      // Cache failure is non-fatal
    }
  }

  bool _isCacheFresh() {
    // Best-effort check; cache dianggap cukup segar untuk ditampilkan
    // selama ada (TTL penuh dicek via isCacheStale() untuk UI banner).
    // Refresh background tetap jalan untuk update data terbaru.
    return true;
  }

  /// Cek apakah cache sudah kedaluwarsa (untuk UI banner offline).
  Future<bool> isCacheStale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ts = prefs.getInt(_cacheTimestampKey);
      if (ts == null) return true;
      final age = DateTime.now().millisecondsSinceEpoch - ts;
      return age > _cacheTtl.inMilliseconds;
    } catch (_) {
      return true;
    }
  }

  /// Bersihkan cache (dipakai saat logout atau force-refresh manual).
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      await prefs.remove(_cacheTimestampKey);
    } catch (_) {}
  }
}
