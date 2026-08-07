import 'package:flutter_test/flutter_test.dart';
import 'package:iderkopi_absensi/core/database/app_database.dart';
import 'package:iderkopi_absensi/core/database/daos/outlet_dao.dart';
import 'package:iderkopi_absensi/features/outlet/data/outlet_model.dart';

import '../../../helpers/test_database_helper.dart';

void main() {
  late OutletDao dao;

  setUpAll(() {
    TestDatabaseHelper.initFfi();
  });

  setUp(() async {
    final db = await TestDatabaseHelper.createInMemory();
    AppDatabase.setTestDatabase(db);
    dao = OutletDao(AppDatabase());
  });

  tearDown(() {
    AppDatabase.clearTestDatabase();
  });

  group('OutletDao', () {
    test('upsertAll inserts outlets', () async {
      await dao.upsertAll([
        const Outlet(id: 1, nama: 'HQ', latitude: -7.7, longitude: 110.4),
        const Outlet(id: 2, nama: 'Malioboro', latitude: -7.8, longitude: 110.3),
      ]);

      final all = await dao.getAll();
      expect(all.length, 2);
    });

    test('upsertAll replaces existing (clear + insert)', () async {
      await dao.upsertAll([
        const Outlet(id: 1, nama: 'HQ', latitude: -7.7, longitude: 110.4),
        const Outlet(id: 2, nama: 'Malioboro', latitude: -7.8, longitude: 110.3),
      ]);
      // Re-upsert with different set
      await dao.upsertAll([
        const Outlet(id: 3, nama: 'Kotabaru', latitude: -7.79, longitude: 110.37),
      ]);

      final all = await dao.getAll();
      expect(all.length, 1);
      expect(all.first.nama, 'Kotabaru');
    });

    test('getAll returns only active outlets sorted by nama', () async {
      await dao.upsertAll([
        const Outlet(id: 1, nama: 'Zeta', latitude: 0, longitude: 0, isActive: false),
        const Outlet(id: 2, nama: 'Alpha', latitude: 0, longitude: 0),
        const Outlet(id: 3, nama: 'Beta', latitude: 0, longitude: 0),
      ]);

      final all = await dao.getAll();
      expect(all.length, 2); // Zeta excluded (inactive)
      expect(all.first.nama, 'Alpha');
      expect(all.last.nama, 'Beta');
    });

    test('getById returns outlet by id', () async {
      await dao.upsertAll([
        const Outlet(id: 5, nama: 'HQ', latitude: -7.7, longitude: 110.4, radiusMeters: 200),
      ]);

      final outlet = await dao.getById(5);
      expect(outlet, isNotNull);
      expect(outlet!.nama, 'HQ');
      expect(outlet.radiusMeters, 200);
    });

    test('getById returns null for non-existent id', () async {
      final outlet = await dao.getById(999);
      expect(outlet, isNull);
    });

    test('clear removes all outlets', () async {
      await dao.upsertAll([
        const Outlet(id: 1, nama: 'HQ', latitude: 0, longitude: 0),
      ]);
      await dao.clear();
      expect(await dao.getAll(), isEmpty);
    });
  });
}
