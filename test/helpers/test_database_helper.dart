import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Helper untuk testing DAO dengan in-memory SQLite via sqflite_common_ffi.
///
/// Inisialisasi sekali per test session (setUpAll), lalu buat database baru
/// per test (setUp) dengan schema yang sama seperti production.
class TestDatabaseHelper {
  TestDatabaseHelper._();

  static bool _initialized = false;
  static int _databaseSequence = 0;

  /// Init FFI — wajib dipanggil di setUpAll sekali.
  static void initFfi() {
    if (_initialized) return;
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    _initialized = true;
  }

  /// Buat in-memory database dengan schema production.
  static Future<Database> createInMemory() async {
    initFfi();
    // :memory: tidak bisa dipakai langsung dengan path_provider, jadi
    // pakai file temp yang akan dihapus otomatis oleh OS.
    final sequence = _databaseSequence++;
    final db = await openDatabase(
      p.join(
        Directory.systemTemp.path,
        'iderkopi_test_${DateTime.now().microsecondsSinceEpoch}_$sequence.db',
      ),
      version: 1,
      onCreate: _onCreate,
    );
    return db;
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE attendance_cache (
        id TEXT PRIMARY KEY,
        tanggal_absensi TEXT NOT NULL,
        masuk TEXT,
        pulang TEXT,
        kangider TEXT,
        keterangan TEXT,
        latitude REAL,
        longitude REAL,
        selfie_file_id TEXT,
        check_in_source TEXT,
        latitude_pulang REAL,
        longitude_pulang REAL,
        selfie_pulang_file_id TEXT,
        kangider_nama TEXT,
        outlet TEXT,
        outlet_id TEXT,
        cached_at INTEGER NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_attendance_kangider ON attendance_cache(kangider, tanggal_absensi)',
    );

    await db.execute('''
      CREATE TABLE outlet_cache (
        id TEXT PRIMARY KEY,
        nama TEXT NOT NULL,
        alamat TEXT,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        radius_meters REAL NOT NULL DEFAULT 100,
        is_active INTEGER NOT NULL DEFAULT 1,
        cached_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE pending_sync (
        local_id INTEGER PRIMARY KEY AUTOINCREMENT,
        operation TEXT NOT NULL,
        record_id TEXT,
        payload TEXT NOT NULL,
        selfie_path TEXT,
        status TEXT NOT NULL DEFAULT 'pending',
        attempts INTEGER NOT NULL DEFAULT 0,
        last_error TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_pending_status ON pending_sync(status, created_at)',
    );

    await db.execute('''
      CREATE TABLE sync_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        local_id INTEGER,
        operation TEXT,
        conflict_type TEXT,
        server_state TEXT,
        local_state TEXT,
        resolution TEXT,
        created_at INTEGER NOT NULL
      )
    ''');
  }
}
