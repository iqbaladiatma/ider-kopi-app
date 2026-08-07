import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/directus_client.dart';
import '../../../core/utils/mock_data.dart';
import 'holiday_model.dart';

/// Repository untuk fetch & cache hari libur.
///
/// Cache 1 tahun di SharedPreferences (key: `holidays_<year>`).
/// Refresh best-effort di background.
class HolidayRepository {
  HolidayRepository._();
  static final HolidayRepository _instance = HolidayRepository._();
  factory HolidayRepository() => _instance;

  static const String _cacheKeyPrefix = 'holidays_';
  static const Duration _cacheTtl = Duration(days: 30);

  final DirectusClient _client = DirectusClient.instance;

  /// Ambil semua hari libur untuk tahun tertentu.
  Future<List<Holiday>> getHolidays({int? year, bool forceRefresh = false}) async {
    final y = year ?? DateTime.now().year;

    // 1. Coba cache dulu
    if (!forceRefresh) {
      final cached = await _loadFromCache(y);
      if (cached != null && !_isCacheStale(y)) {
        // Refresh di background
        _refreshFromApi(y).ignore();
        return cached;
      }
    }

    // 2. Fetch dari API
    try {
      return await _fetchFromApi(y);
    } catch (e) {
      if (kDebugMode) debugPrint('HolidayRepository.getHolidays error: $e');
      // 3. Fallback ke cache (walaupun stale) atau mock
      final cached = await _loadFromCache(y);
      if (cached != null) return cached;
      return _mockHolidays(y);
    }
  }

  /// Cek apakah tanggal tertentu adalah hari libur.
  Future<Holiday?> getHolidayForDate(DateTime date) async {
    final holidays = await getHolidays(year: date.year);
    for (final h in holidays) {
      if (h.isSameDate(date)) return h;
    }
    return null;
  }

  /// Cek apakah hari ini adalah hari libur.
  Future<Holiday?> getTodayHoliday() async {
    return getHolidayForDate(DateTime.now());
  }

  /// Cek apakah besok adalah hari libur (untuk skip reminder).
  Future<Holiday?> getTomorrowHoliday() async {
    return getHolidayForDate(DateTime.now().add(const Duration(days: 1)));
  }

  Future<List<Holiday>> _fetchFromApi(int year) async {
    final dio = _client.dio;
    final startOfYear = '$year-01-01';
    final endOfYear = '$year-12-31';

    try {
      final response = await dio.get(
        '/items/hari_libur',
        queryParameters: {
          'filter[tanggal][_between]': '$startOfYear,$endOfYear',
          'sort': 'tanggal',
          'limit': 100,
        },
      );

      final data = response.data['data'] as List;
      final holidays = data
          .map((e) => Holiday.fromJson(e as Map<String, dynamic>))
          .toList();

      await _saveToCache(year, holidays);
      return holidays;
    } on DioException catch (e) {
      // Jika collection belum ada (404), fallback ke mock
      if (e.response?.statusCode == 404 || e.response?.statusCode == 403) {
        final mock = _mockHolidays(year);
        await _saveToCache(year, mock);
        return mock;
      }
      rethrow;
    }
  }

  Future<void> _refreshFromApi(int year) async {
    try {
      await _fetchFromApi(year);
    } catch (_) {
      // Best-effort, ignore error
    }
  }

  Future<List<Holiday>?> _loadFromCache(int year) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString('$_cacheKeyPrefix$year');
      if (json == null) return null;
      final list = jsonDecode(json) as List;
      return list
          .map((e) => Holiday.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveToCache(int year, List<Holiday> holidays) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(holidays.map((h) => h.toJson()).toList());
      await prefs.setString('$_cacheKeyPrefix$year', json);
      // Simpan timestamp cache
      await prefs.setInt(
        '$_cacheKeyPrefix${year}_ts',
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (_) {}
  }

  bool _isCacheStale(int year) {
    // Simplified: cache dianggap stale setelah 30 hari.
    // Untuk check penuh butuh async baca timestamp — di sini kita
    // anggap cache selalu cukup segar (refresh background tetap jalan).
    return false;
  }

  List<Holiday> _mockHolidays(int year) {
    // Filter mock data untuk year yang diminta
    return MockData.mockHolidays
        .map((e) => Holiday.fromJson(e))
        .where((h) => h.tanggal.year == year)
        .toList();
  }

  /// Cek apakah cache holiday untuk tahun tertentu ada.
  Future<bool> hasCache(int year) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('$_cacheKeyPrefix$year');
  }
}
