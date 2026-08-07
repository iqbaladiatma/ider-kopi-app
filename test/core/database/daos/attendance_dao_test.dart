import 'package:flutter_test/flutter_test.dart';
import 'package:iderkopi_absensi/core/database/app_database.dart';
import 'package:iderkopi_absensi/core/database/daos/attendance_dao.dart';
import 'package:iderkopi_absensi/features/attendance/data/attendance_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../helpers/test_database_helper.dart';

void main() {
  late AttendanceDao dao;

  setUpAll(() {
    TestDatabaseHelper.initFfi();
  });

  setUp(() async {
    final db = await TestDatabaseHelper.createInMemory();
    AppDatabase.setTestDatabase(db);
    dao = AttendanceDao(AppDatabase());
  });

  tearDown(() async {
    AppDatabase.clearTestDatabase();
  });

  group('AttendanceDao', () {
    test('upsert & getToday returns the record', () async {
      final record = AttendanceRecord(
        id: 1,
        tanggalAbsensi: '2026-08-05',
        masuk: '08:00:00',
        pulang: null,
        kangider: 'IDR-0012',
        outletId: 2,
      );

      await dao.upsert(record);

      final today = await dao.getToday('IDR-0012', '2026-08-05');
      expect(today, isNotNull);
      expect(today!.id, 1);
      expect(today.tanggalAbsensi, '2026-08-05');
      expect(today.masuk, '08:00:00');
      expect(today.kangider, 'IDR-0012');
      expect(today.outletId, 2);
    });

    test('upsert replaces existing record (same id)', () async {
      await dao.upsert(AttendanceRecord(
        id: 5,
        tanggalAbsensi: '2026-08-05',
        masuk: '08:00:00',
        kangider: 'IDR-0012',
      ));
      await dao.upsert(AttendanceRecord(
        id: 5,
        tanggalAbsensi: '2026-08-05',
        masuk: '09:30:00', // updated
        kangider: 'IDR-0012',
      ));

      final today = await dao.getToday('IDR-0012', '2026-08-05');
      expect(today?.masuk, '09:30:00');
    });

    test('getToday returns null when not found', () async {
      final today = await dao.getToday('IDR-9999', '2026-01-01');
      expect(today, isNull);
    });

    test('getHistory returns sorted desc by tanggal_absensi', () async {
      await dao.upsert(AttendanceRecord(
        id: 1,
        tanggalAbsensi: '2026-08-01',
        masuk: '08:00:00',
        kangider: 'IDR-0012',
      ));
      await dao.upsert(AttendanceRecord(
        id: 2,
        tanggalAbsensi: '2026-08-05',
        masuk: '08:00:00',
        kangider: 'IDR-0012',
      ));
      await dao.upsert(AttendanceRecord(
        id: 3,
        tanggalAbsensi: '2026-08-03',
        masuk: '08:00:00',
        kangider: 'IDR-0012',
      ));

      final history = await dao.getHistory('IDR-0012');
      expect(history.length, 3);
      // Sorted desc
      expect(history[0].tanggalAbsensi, '2026-08-05');
      expect(history[1].tanggalAbsensi, '2026-08-03');
      expect(history[2].tanggalAbsensi, '2026-08-01');
    });

    test('getHistory only returns records for the given kangider', () async {
      await dao.upsert(AttendanceRecord(
        id: 1,
        tanggalAbsensi: '2026-08-01',
        masuk: '08:00:00',
        kangider: 'IDR-0012',
      ));
      await dao.upsert(AttendanceRecord(
        id: 2,
        tanggalAbsensi: '2026-08-01',
        masuk: '08:00:00',
        kangider: 'IDR-0014',
      ));

      final history = await dao.getHistory('IDR-0012');
      expect(history.length, 1);
      expect(history.first.kangider, 'IDR-0012');
    });

    test('upsertAll bulk inserts efficiently', () async {
      final records = List.generate(5, (i) => AttendanceRecord(
        id: i + 1,
        tanggalAbsensi: '2026-08-0${i + 1}',
        masuk: '08:00:00',
        kangider: 'IDR-0012',
      ));

      await dao.upsertAll(records);

      final history = await dao.getHistory('IDR-0012');
      expect(history.length, 5);
    });

    test('getMonthlyHistory filters by date range', () async {
      await dao.upsert(AttendanceRecord(
        id: 1,
        tanggalAbsensi: '2026-07-31',
        masuk: '08:00:00',
        kangider: 'IDR-0012',
      ));
      await dao.upsert(AttendanceRecord(
        id: 2,
        tanggalAbsensi: '2026-08-01',
        masuk: '08:00:00',
        kangider: 'IDR-0012',
      ));
      await dao.upsert(AttendanceRecord(
        id: 3,
        tanggalAbsensi: '2026-08-15',
        masuk: '08:00:00',
        kangider: 'IDR-0012',
      ));
      await dao.upsert(AttendanceRecord(
        id: 4,
        tanggalAbsensi: '2026-09-01',
        masuk: '08:00:00',
        kangider: 'IDR-0012',
      ));

      final august = await dao.getMonthlyHistory('IDR-0012', '2026-08-01', '2026-08-31');
      expect(august.length, 2);
      expect(august.every((r) => r.tanggalAbsensi.startsWith('2026-08')), isTrue);
    });

    test('hasCache returns true when records exist', () async {
      expect(await dao.hasCache('IDR-0012'), isFalse);
      await dao.upsert(AttendanceRecord(
        id: 1,
        tanggalAbsensi: '2026-08-05',
        masuk: '08:00:00',
        kangider: 'IDR-0012',
      ));
      expect(await dao.hasCache('IDR-0012'), isTrue);
    });

    test('deleteByKangider removes all records for that kangider', () async {
      await dao.upsert(AttendanceRecord(
        id: 1,
        tanggalAbsensi: '2026-08-01',
        masuk: '08:00:00',
        kangider: 'IDR-0012',
      ));
      await dao.upsert(AttendanceRecord(
        id: 2,
        tanggalAbsensi: '2026-08-02',
        masuk: '08:00:00',
        kangider: 'IDR-0012',
      ));
      await dao.upsert(AttendanceRecord(
        id: 3,
        tanggalAbsensi: '2026-08-01',
        masuk: '08:00:00',
        kangider: 'IDR-0014',
      ));

      await dao.deleteByKangider('IDR-0012');

      expect(await dao.hasCache('IDR-0012'), isFalse);
      expect(await dao.hasCache('IDR-0014'), isTrue);
    });
  });
}
