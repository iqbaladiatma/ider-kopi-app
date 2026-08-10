import 'package:flutter_test/flutter_test.dart';
import 'package:iderkopi_absensi/features/holiday/data/holiday_model.dart';

void main() {
  group('Holiday', () {
    test('fromJson parses all fields', () {
      final json = {
        'id': 1,
        'tanggal': '2026-08-17',
        'nama': 'Hari Kemerdekaan RI',
        'is_nasional': true,
      };
      final h = Holiday.fromJson(json);
      expect(h.id, '1');
      expect(h.tanggal, DateTime(2026, 8, 17));
      expect(h.nama, 'Hari Kemerdekaan RI');
      expect(h.isNasional, isTrue);
    });

    test('fromJson parses string id', () {
      final h = Holiday.fromJson({
        'id': '42',
        'tanggal': '2026-01-01',
        'nama': 'Tahun Baru',
        'is_nasional': 'true',
      });
      expect(h.id, '42');
      expect(h.isNasional, isTrue);
    });

    test('fromJson parses is_nasional as int 1', () {
      final h = Holiday.fromJson({
        'id': 1,
        'tanggal': '2026-01-01',
        'nama': 'Test',
        'is_nasional': 1,
      });
      expect(h.isNasional, isTrue);
    });

    test('fromJson parses is_nasional as int 0', () {
      final h = Holiday.fromJson({
        'id': 1,
        'tanggal': '2026-01-01',
        'nama': 'Test',
        'is_nasional': 0,
      });
      expect(h.isNasional, isFalse);
    });

    test('fromJson defaults is_nasional to true when missing', () {
      final h = Holiday.fromJson({
        'id': 1,
        'tanggal': '2026-01-01',
        'nama': 'Test',
      });
      expect(h.isNasional, isTrue);
    });

    test('toJson round-trips correctly', () {
      final h = Holiday(
        id: '5',
        tanggal: DateTime(2026, 12, 25),
        nama: 'Natal',
        isNasional: false,
      );
      final json = h.toJson();
      expect(json['id'], '5');
      expect(json['tanggal'], '2026-12-25');
      expect(json['nama'], 'Natal');
      expect(json['is_nasional'], isFalse);
    });

    test('isSameDate returns true for same date', () {
      final h = Holiday(
        tanggal: DateTime(2026, 8, 17),
        nama: 'Kemerdekaan',
      );
      expect(h.isSameDate(DateTime(2026, 8, 17, 8, 30)), isTrue);
    });

    test('isSameDate returns false for different date', () {
      final h = Holiday(
        tanggal: DateTime(2026, 8, 17),
        nama: 'Kemerdekaan',
      );
      expect(h.isSameDate(DateTime(2026, 8, 18)), isFalse);
      expect(h.isSameDate(DateTime(2025, 8, 17)), isFalse);
    });

    test('toString contains nama and date', () {
      final h = Holiday(
        tanggal: DateTime(2026, 1, 1),
        nama: 'Tahun Baru',
      );
      final s = h.toString();
      expect(s.contains('Tahun Baru'), isTrue);
      expect(s.contains('2026-01-01'), isTrue);
    });
  });
}
