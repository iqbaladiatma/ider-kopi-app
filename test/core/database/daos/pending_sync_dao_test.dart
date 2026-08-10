import 'package:flutter_test/flutter_test.dart';
import 'package:iderkopi_absensi/core/database/app_database.dart';
import 'package:iderkopi_absensi/core/database/daos/pending_sync_dao.dart';

import '../../../helpers/test_database_helper.dart';

void main() {
  late PendingSyncDao dao;

  setUpAll(() {
    TestDatabaseHelper.initFfi();
  });

  setUp(() async {
    final db = await TestDatabaseHelper.createInMemory();
    AppDatabase.setTestDatabase(db);
    dao = PendingSyncDao(AppDatabase());
  });

  tearDown(() {
    AppDatabase.clearTestDatabase();
  });

  group('PendingSyncDao', () {
    test('enqueue inserts entry with pending status', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final id = await dao.enqueue(PendingSyncEntry(
        operation: PendingOperation.checkIn,
        payload: {'tanggal_absensi': '2026-08-05', 'masuk': '08:00:00'},
        createdAt: now,
        updatedAt: now,
      ));

      expect(id, greaterThan(0));

      final pending = await dao.getPending();
      expect(pending.length, 1);
      expect(pending.first.operation, PendingOperation.checkIn);
      expect(pending.first.status, PendingStatus.pending);
      expect(pending.first.payload['masuk'], '08:00:00');
    });

    test('getPending returns entries sorted by created_at ASC', () async {
      final base = DateTime(2026, 8, 5, 8).millisecondsSinceEpoch;
      await dao.enqueue(PendingSyncEntry(
        operation: PendingOperation.checkIn,
        payload: {'a': 'second'},
        createdAt: base + 2000,
        updatedAt: base + 2000,
      ));
      await dao.enqueue(PendingSyncEntry(
        operation: PendingOperation.checkIn,
        payload: {'a': 'first'},
        createdAt: base + 1000,
        updatedAt: base + 1000,
      ));

      final pending = await dao.getPending();
      expect(pending.length, 2);
      expect(pending.first.payload['a'], 'first');
    });

    test('countPending counts pending/failed/syncing entries', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await dao.enqueue(PendingSyncEntry(
        operation: PendingOperation.checkIn,
        payload: {},
        createdAt: now,
        updatedAt: now,
      ));
      await dao.enqueue(PendingSyncEntry(
        operation: PendingOperation.checkOut,
        payload: {},
        createdAt: now,
        updatedAt: now,
      ));

      expect(await dao.countPending(), 2);
    });

    test('updateStatus changes status to synced', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final id = await dao.enqueue(PendingSyncEntry(
        operation: PendingOperation.checkIn,
        payload: {},
        createdAt: now,
        updatedAt: now,
      ));

      await dao.updateStatus(id, status: PendingStatus.synced);

      final entry = await dao.getById(id);
      expect(entry?.status, PendingStatus.synced);
    });

    test('updateStatus with incrementAttempts increments attempts', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final id = await dao.enqueue(PendingSyncEntry(
        operation: PendingOperation.checkIn,
        payload: {},
        createdAt: now,
        updatedAt: now,
      ));

      await dao.updateStatus(id,
          status: PendingStatus.failed,
          error: 'network error',
          incrementAttempts: true);
      await dao.updateStatus(id,
          status: PendingStatus.failed,
          error: 'network error 2',
          incrementAttempts: true);

      final entry = await dao.getById(id);
      expect(entry?.status, PendingStatus.failed);
      expect(entry?.attempts, 2);
      expect(entry?.lastError, 'network error 2');
    });

    test('deleteSynced removes only synced entries', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final id1 = await dao.enqueue(PendingSyncEntry(
        operation: PendingOperation.checkIn,
        payload: {},
        createdAt: now,
        updatedAt: now,
      ));
      await dao.enqueue(PendingSyncEntry(
        operation: PendingOperation.checkIn,
        payload: {},
        createdAt: now,
        updatedAt: now,
      ));

      await dao.updateStatus(id1, status: PendingStatus.synced);
      final deleted = await dao.deleteSynced();

      expect(deleted, 1);
      expect(await dao.countPending(), 1); // id2 still pending
    });

    test('getPending excludes synced entries', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final id1 = await dao.enqueue(PendingSyncEntry(
        operation: PendingOperation.checkIn,
        payload: {},
        createdAt: now,
        updatedAt: now,
      ));
      await dao.enqueue(PendingSyncEntry(
        operation: PendingOperation.checkIn,
        payload: {},
        createdAt: now,
        updatedAt: now,
      ));

      await dao.updateStatus(id1, status: PendingStatus.synced);

      final pending = await dao.getPending();
      expect(pending.length, 1);
      expect(pending.first.localId, isNot(id1));
    });

    test('getById returns null for non-existent id', () async {
      final entry = await dao.getById(99999);
      expect(entry, isNull);
    });
  });
}
