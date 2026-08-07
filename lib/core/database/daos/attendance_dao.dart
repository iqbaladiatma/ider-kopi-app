import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../../features/attendance/data/attendance_model.dart';
import '../app_database.dart';

/// Data Access Object untuk tabel `attendance_cache`.
///
/// Dipakai untuk cache-first rendering di history page:
/// tampilkan data lokal dulu, lalu refresh dari API.
class AttendanceDao {
  final AppDatabase _db;
  AttendanceDao(this._db);

  static const String _table = 'attendance_cache';

  Future<Database> get _database => _db.database;

  /// Insert atau replace record (upsert by id).
  Future<void> upsert(AttendanceRecord record) async {
    final db = await _database;
    await db.insert(
      _table,
      _toRow(record),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Bulk upsert (lebih efisien untuk batch refresh).
  Future<void> upsertAll(List<AttendanceRecord> records) async {
    final db = await _database;
    final batch = db.batch();
    for (final r in records) {
      batch.insert(
        _table,
        _toRow(r),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  /// Ambil record hari ini untuk kangider tertentu.
  Future<AttendanceRecord?> getToday(String kangiderId, String todayDate) async {
    final db = await _database;
    final rows = await db.query(
      _table,
      where: 'kangider = ? AND tanggal_absensi = ?',
      whereArgs: [kangiderId, todayDate],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  /// Ambil riwayat absensi (sorted desc, limit 30 default).
  Future<List<AttendanceRecord>> getHistory(String kangiderId,
      {int limit = 30}) async {
    final db = await _database;
    final rows = await db.query(
      _table,
      where: 'kangider = ?',
      whereArgs: [kangiderId],
      orderBy: 'tanggal_absensi DESC, masuk DESC',
      limit: limit,
    );
    return rows.map(_fromRow).toList();
  }

  /// Ambil riwayat bulanan.
  Future<List<AttendanceRecord>> getMonthlyHistory(
    String kangiderId,
    String startDate,
    String endDate,
  ) async {
    final db = await _database;
    final rows = await db.query(
      _table,
      where: 'kangider = ? AND tanggal_absensi BETWEEN ? AND ?',
      whereArgs: [kangiderId, startDate, endDate],
      orderBy: 'tanggal_absensi DESC, masuk DESC',
      limit: 31,
    );
    return rows.map(_fromRow).toList();
  }

  /// Hapus semua record milik kangider tertentu (sebelum refresh penuh).
  Future<void> deleteByKangider(String kangiderId) async {
    final db = await _database;
    await db.delete(_table, where: 'kangider = ?', whereArgs: [kangiderId]);
  }

  /// Cek apakah cache masih ada untuk kangider.
  Future<bool> hasCache(String kangiderId) async {
    final db = await _database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM $_table WHERE kangider = ?',
        [kangiderId],
      ),
    );
    return (count ?? 0) > 0;
  }

  // --- Mapping helpers ---

  Map<String, dynamic> _toRow(AttendanceRecord r) {
    return {
      'id': r.id,
      'tanggal_absensi': r.tanggalAbsensi,
      'masuk': r.masuk,
      'pulang': r.pulang,
      'kangider': r.kangider,
      'keterangan': r.keterangan,
      'latitude': r.latitude,
      'longitude': r.longitude,
      'selfie_file_id': r.selfieFileId,
      'check_in_source': r.checkInSource,
      'latitude_pulang': r.latitudePulang,
      'longitude_pulang': r.longitudePulang,
      'selfie_pulang_file_id': r.selfiePulangFileId,
      'kangider_nama': r.kangiderNama,
      'outlet': r.outlet,
      'outlet_id': r.outletId,
      'cached_at': DateTime.now().millisecondsSinceEpoch,
    };
  }

  AttendanceRecord _fromRow(Map<String, dynamic> row) {
    return AttendanceRecord(
      id: row['id'] != null ? (row['id'] as num).toInt() : null,
      tanggalAbsensi: row['tanggal_absensi']?.toString() ?? '',
      masuk: row['masuk']?.toString(),
      pulang: row['pulang']?.toString(),
      kangider: row['kangider']?.toString(),
      keterangan: row['keterangan']?.toString(),
      latitude: (row['latitude'] as num?)?.toDouble(),
      longitude: (row['longitude'] as num?)?.toDouble(),
      selfieFileId: row['selfie_file_id']?.toString(),
      checkInSource: row['check_in_source']?.toString(),
      latitudePulang: (row['latitude_pulang'] as num?)?.toDouble(),
      longitudePulang: (row['longitude_pulang'] as num?)?.toDouble(),
      selfiePulangFileId: row['selfie_pulang_file_id']?.toString(),
      kangiderNama: row['kangider_nama']?.toString(),
      outlet: row['outlet']?.toString(),
      outletId: row['outlet_id'] != null
          ? int.tryParse(row['outlet_id'].toString())
          : null,
    );
  }
}

/// Helper: encode list record ke JSON string (untuk sync_log/debug).
String encodeRecords(List<AttendanceRecord> records) {
  return jsonEncode(records.map((r) => r.toJson()).toList());
}
