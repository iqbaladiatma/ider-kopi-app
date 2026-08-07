import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// Setup & migrasi database SQLite lokal (v1.2 — Offline Mode).
///
/// Tabel:
/// - `attendance_cache`  : cache riwayat absensi dari server
/// - `outlet_cache`      : cache outlet
/// - `pending_sync`      : antrian absensi yang belum ter-sync ke server
/// - `sync_log`          : log konflik sync untuk audit
class AppDatabase {
  AppDatabase._();
  static final AppDatabase _instance = AppDatabase._();
  factory AppDatabase() => _instance;

  static const String _dbName = 'iderkopi_absensi.db';
  static const int _dbVersion = 1;

  Database? _db;

  /// Untuk testing: inject in-memory database.
  /// Set via [setTestDatabase] di setUp test.
  static Database? _testDb;

  /// Inject database untuk testing (in-memory).
  static void setTestDatabase(Database db) {
    _testDb = db;
  }

  /// Clear test database injection.
  static void clearTestDatabase() {
    _testDb = null;
  }

  /// Buka database (lazy — sekali per session).
  Future<Database> get database async {
    if (_testDb != null) return _testDb!;
    if (_db != null && _db!.isOpen) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE attendance_cache (
        id INTEGER PRIMARY KEY,
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
        outlet_id INTEGER,
        cached_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_attendance_kangider
        ON attendance_cache(kangider, tanggal_absensi)
    ''');

    await db.execute('''
      CREATE TABLE outlet_cache (
        id INTEGER PRIMARY KEY,
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
        operation TEXT NOT NULL,           -- 'check_in' | 'check_out'
        record_id INTEGER,                 -- id record di server (untuk check_out)
        payload TEXT NOT NULL,             -- JSON dari CheckInRequest/CheckOutRequest
        selfie_path TEXT,                  -- path file selfie lokal (untuk check-in)
        status TEXT NOT NULL DEFAULT 'pending', -- pending | syncing | synced | failed
        attempts INTEGER NOT NULL DEFAULT 0,
        last_error TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_pending_status
        ON pending_sync(status, created_at)
    ''');

    await db.execute('''
      CREATE TABLE sync_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        local_id INTEGER,
        operation TEXT,
        conflict_type TEXT,                -- 'duplicate_check_in' | 'already_checked_out' | 'server_error'
        server_state TEXT,                 -- JSON snapshot data server
        local_state TEXT,                  -- JSON snapshot data lokal
        resolution TEXT,                   -- 'server_wins' | 'local_wins' | 'merged' | 'skipped'
        created_at INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Placeholder untuk migrasi schema versi mendatang.
    // Contoh:
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE attendance_cache ADD COLUMN shift_id INTEGER');
    // }
  }

  /// Tutup & reset database (untuk logout atau testing).
  Future<void> close() async {
    if (_db != null && _db!.isOpen) {
      await _db!.close();
      _db = null;
    }
  }

  /// Hapus semua data cache (dipakai saat logout).
  /// Tidak menghapus pending_sync agar antrian tetap diproses.
  Future<void> clearCache() async {
    final db = await database;
    await db.delete('attendance_cache');
    await db.delete('outlet_cache');
  }

  /// Hard reset — hapus SEMUA tabel (untuk testing).
  Future<void> resetAll() async {
    final db = await database;
    await db.delete('attendance_cache');
    await db.delete('outlet_cache');
    await db.delete('pending_sync');
    await db.delete('sync_log');
  }
}
