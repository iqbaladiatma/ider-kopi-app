import 'package:flutter_test/flutter_test.dart';
import 'package:iderkopi_absensi/core/database/app_database.dart';
import 'package:iderkopi_absensi/core/database/daos/sync_log_dao.dart';

import '../../../helpers/test_database_helper.dart';

void main() {
  late SyncLogDao dao;

  setUpAll(() {
    TestDatabaseHelper.initFfi();
  });

  setUp(() async {
    final db = await TestDatabaseHelper.createInMemory();
    AppDatabase.setTestDatabase(db);
    dao = SyncLogDao(AppDatabase());
  });

  tearDown(() {
    AppDatabase.clearTestDatabase();
  });

  group('SyncLogDao', () {
    test('insert & getAll returns entries sorted by created_at DESC', () async {
      final base = DateTime(2026, 8, 5).millisecondsSinceEpoch;
      await dao.insert(SyncLogEntry(
        localId: 1,
        operation: 'check_in',
        conflictType: 'duplicate_check_in',
        localState: {'masuk': '08:00'},
        serverState: {'id': 99, 'masuk': '07:55'},
        resolution: 'server_wins',
        createdAt: base,
      ));
      await dao.insert(SyncLogEntry(
        localId: 2,
        operation: 'check_out',
        conflictType: 'already_checked_out',
        localState: {'pulang': '17:00'},
        serverState: {'id': 99, 'pulang': '16:55'},
        resolution: 'server_wins',
        createdAt: base + 1000,
      ));

      final all = await dao.getAll();
      expect(all.length, 2);
      // Sorted DESC → entry kedua (created_at lebih besar) dulu
      expect(all.first.localId, 2);
      expect(all.last.localId, 1);
    });

    test('getAll respects limit', () async {
      final base = DateTime(2026, 8, 5).millisecondsSinceEpoch;
      for (int i = 0; i < 5; i++) {
        await dao.insert(SyncLogEntry(
          localId: i,
          operation: 'check_in',
          conflictType: 'duplicate_check_in',
          localState: {},
          resolution: 'server_wins',
          createdAt: base + i,
        ));
      }

      final all = await dao.getAll(limit: 3);
      expect(all.length, 3);
    });

    test('count returns total entries', () async {
      expect(await dao.count(), 0);
      await dao.insert(SyncLogEntry(
        operation: 'check_in',
        conflictType: 'duplicate_check_in',
        resolution: 'server_wins',
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ));
      expect(await dao.count(), 1);
    });

    test('clear removes all entries', () async {
      await dao.insert(SyncLogEntry(
        operation: 'check_in',
        conflictType: 'duplicate_check_in',
        resolution: 'server_wins',
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ));
      await dao.clear();
      expect(await dao.count(), 0);
    });

    test('fromRow parses server_state & local_state JSON', () async {
      await dao.insert(SyncLogEntry(
        localId: 42,
        operation: 'check_in',
        conflictType: 'duplicate_check_in',
        localState: {'masuk': '08:00:00', 'kangider': 'IDR-0012'},
        serverState: {'id': 99, 'masuk': '07:55:00'},
        resolution: 'server_wins',
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ));

      final all = await dao.getAll();
      expect(all.first.localId, 42);
      expect(all.first.localState?['masuk'], '08:00:00');
      expect(all.first.serverState?['id'], 99);
    });
  });
}
