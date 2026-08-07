import 'package:flutter_test/flutter_test.dart';
import 'package:iderkopi_absensi/core/database/app_database.dart';
import 'package:iderkopi_absensi/core/database/daos/sync_log_dao.dart';
import 'package:iderkopi_absensi/features/sync/data/conflict_resolver.dart';

import '../../../helpers/test_database_helper.dart';

void main() {
  late SyncLogDao syncLogDao;

  setUpAll(() {
    TestDatabaseHelper.initFfi();
  });

  setUp(() async {
    final db = await TestDatabaseHelper.createInMemory();
    AppDatabase.setTestDatabase(db);
    syncLogDao = SyncLogDao(AppDatabase());
  });

  tearDown(() {
    AppDatabase.clearTestDatabase();
  });

  group('ConflictResolver', () {
    test('resolveDuplicateCheckIn logs conflict with server_wins', () async {
      await ConflictResolver.resolveDuplicateCheckIn(
        syncLogDao: syncLogDao,
        localId: 42,
        localState: {'masuk': '08:00:00', 'tanggal_absensi': '2026-08-05'},
        serverState: {'id': 99, 'masuk': '07:55:00'},
      );

      final logs = await syncLogDao.getAll();
      expect(logs.length, 1);
      expect(logs.first.localId, 42);
      expect(logs.first.operation, 'check_in');
      expect(logs.first.conflictType, 'duplicate_check_in');
      expect(logs.first.resolution, 'server_wins');
      expect(logs.first.localState?['masuk'], '08:00:00');
      expect(logs.first.serverState?['id'], 99);
    });

    test('resolveAlreadyCheckedOut logs conflict with server_wins', () async {
      await ConflictResolver.resolveAlreadyCheckedOut(
        syncLogDao: syncLogDao,
        localId: 7,
        localState: {'pulang': '17:00:00'},
        serverState: {'id': 99, 'pulang': '16:55:00'},
      );

      final logs = await syncLogDao.getAll();
      expect(logs.length, 1);
      expect(logs.first.operation, 'check_out');
      expect(logs.first.conflictType, 'already_checked_out');
      expect(logs.first.resolution, 'server_wins');
    });

    test('logGenericConflict uses provided resolution', () async {
      await ConflictResolver.logGenericConflict(
        syncLogDao: syncLogDao,
        localId: 1,
        operation: 'check_in',
        conflictType: 'server_error',
        localState: {'foo': 'bar'},
        resolution: 'skipped',
      );

      final logs = await syncLogDao.getAll();
      expect(logs.first.conflictType, 'server_error');
      expect(logs.first.resolution, 'skipped');
      expect(logs.first.serverState, isNull);
    });

    test('multiple conflicts logged independently', () async {
      await ConflictResolver.resolveDuplicateCheckIn(
        syncLogDao: syncLogDao,
        localId: 1,
        localState: {},
        serverState: {},
      );
      await ConflictResolver.resolveAlreadyCheckedOut(
        syncLogDao: syncLogDao,
        localId: 2,
        localState: {},
        serverState: {},
      );

      final logs = await syncLogDao.getAll();
      expect(logs.length, 2);
    });
  });
}
