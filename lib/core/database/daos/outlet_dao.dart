import 'package:sqflite/sqflite.dart';

import '../../../features/outlet/data/outlet_model.dart';
import '../app_database.dart';

/// Data Access Object untuk tabel `outlet_cache`.
///
/// Mirror dari cache SharedPreferences di OutletRepository,
/// tapi lebih queryable (bisa filter by id, by radius area, dst).
class OutletDao {
  final AppDatabase _db;
  OutletDao(this._db);

  static const String _table = 'outlet_cache';

  Future<Database> get _database => _db.database;

  Future<void> upsertAll(List<Outlet> outlets) async {
    final db = await _database;
    final batch = db.batch();
    // Clear dulu untuk replace semua (sederhana & aman untuk data kecil)
    batch.delete(_table);
    for (final o in outlets) {
      batch.insert(_table, _toRow(o));
    }
    await batch.commit(noResult: true);
  }

  Future<List<Outlet>> getAll() async {
    final db = await _database;
    final rows = await db.query(
      _table,
      where: 'is_active = 1',
      orderBy: 'nama ASC',
    );
    return rows.map(_fromRow).toList();
  }

  Future<Outlet?> getById(int id) async {
    final db = await _database;
    final rows = await db.query(
      _table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  Future<void> clear() async {
    final db = await _database;
    await db.delete(_table);
  }

  Map<String, dynamic> _toRow(Outlet o) {
    return {
      'id': o.id,
      'nama': o.nama,
      'alamat': o.alamat,
      'latitude': o.latitude,
      'longitude': o.longitude,
      'radius_meters': o.radiusMeters,
      'is_active': o.isActive ? 1 : 0,
      'cached_at': DateTime.now().millisecondsSinceEpoch,
    };
  }

  Outlet _fromRow(Map<String, dynamic> row) {
    return Outlet(
      id: (row['id'] as num).toInt(),
      nama: row['nama'].toString(),
      alamat: row['alamat']?.toString(),
      latitude: (row['latitude'] as num).toDouble(),
      longitude: (row['longitude'] as num).toDouble(),
      radiusMeters: (row['radius_meters'] as num?)?.toDouble() ?? 100.0,
      isActive: (row['is_active'] as int?) == 1,
    );
  }
}
