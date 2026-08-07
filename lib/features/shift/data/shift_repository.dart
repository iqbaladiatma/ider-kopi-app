import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/config/api_provider.dart';
import '../../../core/config/app_config.dart';
import '../../../core/network/directus_client.dart';
import 'shift_model.dart';

/// Repository untuk shift & user_shifts (v2.0).
class ShiftRepository {
  ShiftRepository._();
  static final ShiftRepository _instance = ShiftRepository._();
  factory ShiftRepository() => _instance;

  final DirectusClient _client = DirectusClient.instance;

  /// Mock shifts untuk development.
  static final List<Map<String, dynamic>> _mockShifts = [
    {
      'id': 1,
      'name': 'Pagi',
      'start_time': '07:00',
      'end_time': '15:00',
      'outlet_id': 1,
      'outlet_name': 'IderKopi - Head Office',
      'is_active': true,
    },
    {
      'id': 2,
      'name': 'Siang',
      'start_time': '13:00',
      'end_time': '21:00',
      'outlet_id': 1,
      'outlet_name': 'IderKopi - Head Office',
      'is_active': true,
    },
    {
      'id': 3,
      'name': 'Malam',
      'start_time': '19:00',
      'end_time': '03:00',
      'outlet_id': 2,
      'outlet_name': 'IderKopi - Malioboro',
      'is_active': true,
    },
  ];

  static final List<Map<String, dynamic>> _mockUserShifts = [
    {
      'id': 1,
      'user_id': 'usr-0012',
      'user_name': 'Andi (Kang Ider)',
      'shift_id': 1,
      'shift': _mockShifts[0],
      'date': DateTime.now().toIso8601String().split('T').first,
    },
    {
      'id': 2,
      'user_id': 'usr-0012',
      'user_name': 'Andi (Kang Ider)',
      'shift_id': 1,
      'shift': _mockShifts[0],
      'date': DateTime.now().add(const Duration(days: 1)).toIso8601String().split('T').first,
    },
    {
      'id': 3,
      'user_id': 'usr-0012',
      'user_name': 'Andi (Kang Ider)',
      'shift_id': 1,
      'shift': _mockShifts[0],
      'date': DateTime.now().add(const Duration(days: 2)).toIso8601String().split('T').first,
    },
  ];

  /// Ambil semua shift aktif.
  Future<List<Shift>> getShifts() async {
    if (AppConfig.useMockAuth) {
      return _mockShifts.map((e) => Shift.fromJson(e)).toList();
    }

    try {
      final isDirectus = AppConfig.apiProvider == ApiProvider.directus;
      final endpoint = isDirectus ? '/items/shifts' : '/api/v1/shifts';
      final query = isDirectus ? {'filter[is_active][_eq]': true, 'limit': 100} : null;

      final response = await _client.get(endpoint, query: query);
      final data = response.data['data'] as List;
      return data.map((e) => Shift.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      if (kDebugMode) debugPrint('ShiftRepository.getShifts error: $e');
      return _mockShifts.map((e) => Shift.fromJson(e)).toList();
    }
  }

  /// Ambil jadwal shift user untuk bulan tertentu.
  Future<List<UserShift>> getMyShifts({
    required String userId,
    required int year,
    required int month,
  }) async {
    if (AppConfig.useMockAuth) {
      // Generate mock shifts for the month
      final daysInMonth = DateTime(year, month + 1, 0).day;
      final now = DateTime.now();
      final shifts = <UserShift>[];
      for (int day = 1; day <= daysInMonth; day++) {
        final date = DateTime(year, month, day);
        if (date.isAfter(now.add(const Duration(days: 7)))) continue;
        if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
          continue;
        }
        shifts.add(UserShift(
          userId: userId,
          userName: 'Andi (Kang Ider)',
          shiftId: 1,
          shift: Shift.fromJson(_mockShifts[0]),
          date: date,
        ));
      }
      return shifts;
    }

    try {
      final startDate = '$year-${month.toString().padLeft(2, '0')}-01';
      final endDate = '$year-${month.toString().padLeft(2, '0')}-${DateTime(year, month + 1, 0).day}';
      final response = await _client.get('/items/user_shifts', query: {
        'filter[user_id][_eq]': userId,
        'filter[date][_between]': '$startDate,$endDate',
        'fields[]': ['*', 'shift.*'],
        'sort[]': 'date',
        'limit': 31,
      });
      final data = response.data['data'] as List;
      return data.map((e) => UserShift.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      if (kDebugMode) debugPrint('ShiftRepository.getMyShifts error: $e');
      return [];
    }
  }

  /// Assign shift ke user (admin only).
  Future<UserShift> assignShift({
    required String userId,
    required int shiftId,
    required DateTime date,
  }) async {
    if (AppConfig.useMockAuth) {
      final newRecord = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'user_id': userId,
        'shift_id': shiftId,
        'shift': _mockShifts.firstWhere((s) => s['id'] == shiftId,
            orElse: () => _mockShifts[0]),
        'date': '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      };
      _mockUserShifts.add(newRecord);
      return UserShift.fromJson(newRecord);
    }

    final response = await _client.post('/items/user_shifts', body: {
      'user_id': userId,
      'shift_id': shiftId,
      'date': '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
    });
    final data = response.data['data'] as Map<String, dynamic>;
    return UserShift.fromJson(data);
  }

  /// Cek apakah check-in pada [time] berada dalam jam shift user.
  /// Return null jika tidak ada shift untuk hari itu.
  Future<bool?> isCheckInOnShift({
    required String userId,
    required DateTime dateTime,
  }) async {
    final shifts = await getMyShifts(
      userId: userId,
      year: dateTime.year,
      month: dateTime.month,
    );

    final dayShift = shifts.where((s) =>
      s.date.year == dateTime.year &&
      s.date.month == dateTime.month &&
      s.date.day == dateTime.day,
    ).toList();

    if (dayShift.isEmpty) return null; // Tidak ada shift

    final shift = dayShift.first.shift;
    if (shift == null) return null;

    return shift.isWithinShift(TimeOfDay.fromDateTime(dateTime));
  }
}
