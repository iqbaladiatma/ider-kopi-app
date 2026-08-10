import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iderkopi_absensi/features/shift/data/shift_model.dart';

void main() {
  group('Shift', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 1,
        'name': 'Pagi',
        'start_time': '07:00',
        'end_time': '15:00',
        'outlet_id': 1,
        'outlet_name': 'IderKopi - Head Office',
        'is_active': true,
      };
      final shift = Shift.fromJson(json);
      expect(shift.id, '1');
      expect(shift.name, 'Pagi');
      expect(shift.startTime, const TimeOfDay(hour: 7, minute: 0));
      expect(shift.endTime, const TimeOfDay(hour: 15, minute: 0));
      expect(shift.outletId, '1');
      expect(shift.outletName, 'IderKopi - Head Office');
      expect(shift.isActive, isTrue);
    });

    test('durationHours calculates correctly for day shift', () {
      const shift = Shift(
        name: 'Pagi',
        startTime: TimeOfDay(hour: 7, minute: 0),
        endTime: TimeOfDay(hour: 15, minute: 0),
      );
      expect(shift.durationHours, 8.0);
    });

    test('durationHours calculates correctly for night shift', () {
      const shift = Shift(
        name: 'Malam',
        startTime: TimeOfDay(hour: 19, minute: 0),
        endTime: TimeOfDay(hour: 3, minute: 0),
      );
      // 19:00 to 03:00 next day = 8 hours
      expect(shift.durationHours, 8.0);
    });

    test('isWithinShift returns true for time in range', () {
      const shift = Shift(
        name: 'Pagi',
        startTime: TimeOfDay(hour: 7, minute: 0),
        endTime: TimeOfDay(hour: 15, minute: 0),
      );
      expect(shift.isWithinShift(const TimeOfDay(hour: 8, minute: 30)), isTrue);
      expect(
          shift.isWithinShift(const TimeOfDay(hour: 14, minute: 59)), isTrue);
    });

    test('isWithinShift returns false for time out of range', () {
      const shift = Shift(
        name: 'Pagi',
        startTime: TimeOfDay(hour: 7, minute: 0),
        endTime: TimeOfDay(hour: 15, minute: 0),
      );
      expect(
          shift.isWithinShift(const TimeOfDay(hour: 6, minute: 59)), isFalse);
      expect(
          shift.isWithinShift(const TimeOfDay(hour: 15, minute: 1)), isFalse);
    });

    test('isWithinShift handles night shift crossing midnight', () {
      const shift = Shift(
        name: 'Malam',
        startTime: TimeOfDay(hour: 19, minute: 0),
        endTime: TimeOfDay(hour: 3, minute: 0),
      );
      expect(shift.isWithinShift(const TimeOfDay(hour: 22, minute: 0)), isTrue);
      expect(shift.isWithinShift(const TimeOfDay(hour: 2, minute: 0)), isTrue);
      expect(
          shift.isWithinShift(const TimeOfDay(hour: 12, minute: 0)), isFalse);
    });

    test('toJson round-trips', () {
      const shift = Shift(
        id: '5',
        name: 'Siang',
        startTime: TimeOfDay(hour: 13, minute: 0),
        endTime: TimeOfDay(hour: 21, minute: 0),
        outletId: '2',
      );
      final json = shift.toJson();
      expect(json['id'], '5');
      expect(json['name'], 'Siang');
      expect(json['start_time'], '13:00');
      expect(json['end_time'], '21:00');
      expect(json['outlet_id'], '2');
    });

    test('copyWith updates only specified fields', () {
      const original = Shift(
        name: 'Pagi',
        startTime: TimeOfDay(hour: 7, minute: 0),
        endTime: TimeOfDay(hour: 15, minute: 0),
      );
      final updated = original.copyWith(name: 'Pagi Awal');
      expect(updated.name, 'Pagi Awal');
      expect(updated.startTime, const TimeOfDay(hour: 7, minute: 0));
    });
  });

  group('UserShift', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 1,
        'user_id': 'usr-0012',
        'user_name': 'Andi',
        'shift_id': 1,
        'shift': {
          'id': 1,
          'name': 'Pagi',
          'start_time': '07:00',
          'end_time': '15:00',
        },
        'date': '2026-08-15',
      };
      final userShift = UserShift.fromJson(json);
      expect(userShift.id, '1');
      expect(userShift.userId, 'usr-0012');
      expect(userShift.userName, 'Andi');
      expect(userShift.shiftId, '1');
      expect(userShift.shift?.name, 'Pagi');
      expect(userShift.date, DateTime(2026, 8, 15));
    });

    test('toJson produces correct date format', () {
      final userShift = UserShift(
        userId: 'usr-0012',
        shiftId: '1',
        date: DateTime(2026, 8, 15),
      );
      final json = userShift.toJson();
      expect(json['user_id'], 'usr-0012');
      expect(json['shift_id'], '1');
      expect(json['date'], '2026-08-15');
    });
  });
}
