import 'package:flutter/material.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import 'shift_model.dart';

class ShiftRepository {
  ShiftRepository._();
  static final ShiftRepository _instance = ShiftRepository._();
  factory ShiftRepository() => _instance;

  final ApiClient _client = ApiClient.instance;
  static const _mockShifts = <Map<String, dynamic>>[
    {
      'id': '00000000-0000-4000-8000-000000000001',
      'name': 'Pagi',
      'start_time': '07:00',
      'end_time': '15:00',
      'tolerance_minutes': 10,
    },
  ];

  Future<List<Shift>> getShifts() async {
    if (AppConfig.useMockAuth) {
      return _mockShifts.map(Shift.fromJson).toList();
    }
    final response = await _client.get('shifts');
    final data =
        (response.data as Map<String, dynamic>)['data'] as List<dynamic>;
    return data
        .map((item) => Shift.fromJson((item as Map).cast<String, dynamic>()))
        .toList();
  }

  Future<List<UserShift>> getMyShifts({
    required String userId,
    required int year,
    required int month,
  }) async {
    if (AppConfig.useMockAuth) return const [];
    final response = await _client.get('employees/me/shift');
    final data =
        (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    final shift = Shift.fromJson(data);
    final lastDay = DateTime(year, month + 1, 0).day;
    return List.generate(
      lastDay,
      (index) => UserShift(
        userId: userId,
        shiftId: shift.id ?? '',
        shift: shift,
        date: DateTime(year, month, index + 1),
      ),
    );
  }

  Future<UserShift> assignShift({
    required String userId,
    required String shiftId,
    required DateTime date,
  }) async {
    final shift = (await getShifts()).firstWhere((item) => item.id == shiftId);
    if (!AppConfig.useMockAuth) {
      await _client.put('employees/$userId', body: {'shift_id': shiftId});
    }
    return UserShift(
      userId: userId,
      shiftId: shiftId,
      shift: shift,
      date: date,
    );
  }

  Future<bool?> isCheckInOnShift({
    required String userId,
    required DateTime dateTime,
  }) async {
    final shifts = await getMyShifts(
      userId: userId,
      year: dateTime.year,
      month: dateTime.month,
    );
    for (final assignment in shifts) {
      if (assignment.date.year == dateTime.year &&
          assignment.date.month == dateTime.month &&
          assignment.date.day == dateTime.day) {
        return assignment.shift?.isWithinShift(
          TimeOfDay.fromDateTime(dateTime),
        );
      }
    }
    return null;
  }
}
