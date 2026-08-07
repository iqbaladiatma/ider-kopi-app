import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../app_database.dart';

/// Operasi yang bisa di-queue untuk sync.
enum PendingOperation { checkIn, checkOut }

/// Status antrian sync.
enum PendingStatus { pending, syncing, synced, failed }

/// Model entri antrian sync.
class PendingSyncEntry {
  final int? localId;
  final PendingOperation operation;
  final int? recordId;
  final Map<String, dynamic> payload;
  final String? selfiePath;
  final PendingStatus status;
  final int attempts;
  final String? lastError;
  final int createdAt;
  final int updatedAt;

  const PendingSyncEntry({
    this.localId,
    required this.operation,
    this.recordId,
    required this.payload,
    this.selfiePath,
    this.status = PendingStatus.pending,
    this.attempts = 0,
    this.lastError,
    required this.createdAt,
    required this.updatedAt,
  });

  PendingSyncEntry copyWith({
    int? localId,
    PendingOperation? operation,
    int? recordId,
    Map<String, dynamic>? payload,
    String? selfiePath,
    PendingStatus? status,
    int? attempts,
    String? lastError,
    int? createdAt,
    int? updatedAt,
  }) {
    return PendingSyncEntry(
      localId: localId ?? this.localId,
      operation: operation ?? this.operation,
      recordId: recordId ?? this.recordId,
      payload: payload ?? this.payload,
      selfiePath: selfiePath ?? this.selfiePath,
      status: status ?? this.status,
      attempts: attempts ?? this.attempts,
      lastError: lastError ?? this.lastError,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory PendingSyncEntry.fromRow(Map<String, dynamic> row) {
    return PendingSyncEntry(
      localId: (row['local_id'] as num).toInt(),
      operation: row['operation'].toString() == 'check_in'
          ? PendingOperation.checkIn
          : PendingOperation.checkOut,
      recordId: row['record_id'] != null
          ? int.tryParse(row['record_id'].toString())
          : null,
      payload: jsonDecode(row['payload'].toString()) as Map<String, dynamic>,
      selfiePath: row['selfie_path']?.toString(),
      status: _parseStatus(row['status'].toString()),
      attempts: (row['attempts'] as num?)?.toInt() ?? 0,
      lastError: row['last_error']?.toString(),
      createdAt: (row['created_at'] as num).toInt(),
      updatedAt: (row['updated_at'] as num).toInt(),
    );
  }

  static PendingStatus _parseStatus(String s) {
    switch (s) {
      case 'syncing':
        return PendingStatus.syncing;
      case 'synced':
        return PendingStatus.synced;
      case 'failed':
        return PendingStatus.failed;
      default:
        return PendingStatus.pending;
    }
  }
}

/// Data Access Object untuk tabel `pending_sync`.
class PendingSyncDao {
  final AppDatabase _db;
  PendingSyncDao(this._db);

  static const String _table = 'pending_sync';

  Future<Database> get _database => _db.database;

  /// Tambah entri baru ke antrian.
  Future<int> enqueue(PendingSyncEntry entry) async {
    final db = await _database;
    final now = DateTime.now().millisecondsSinceEpoch;
    return db.insert(_table, {
      'operation': entry.operation == PendingOperation.checkIn
          ? 'check_in'
          : 'check_out',
      'record_id': entry.recordId,
      'payload': jsonEncode(entry.payload),
      'selfie_path': entry.selfiePath,
      'status': 'pending',
      'attempts': 0,
      'last_error': null,
      'created_at': entry.createdAt != 0 ? entry.createdAt : now,
      'updated_at': now,
    });
  }

  /// Ambil semua entri dengan status pending/syncing (untuk diproses).
  Future<List<PendingSyncEntry>> getPending({int limit = 50}) async {
    final db = await _database;
    final rows = await db.query(
      _table,
      where: "status IN ('pending', 'failed')",
      whereArgs: [],
      orderBy: 'created_at ASC',
      limit: limit,
    );
    return rows.map(PendingSyncEntry.fromRow).toList();
  }

  /// Hitung jumlah antrian pending (untuk badge di UI).
  Future<int> countPending() async {
    final db = await _database;
    final result = await db.rawQuery(
      "SELECT COUNT(*) FROM $_table WHERE status IN ('pending', 'failed', 'syncing')",
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Update status entri.
  Future<void> updateStatus(
    int localId, {
    required PendingStatus status,
    String? error,
    bool incrementAttempts = false,
  }) async {
    final db = await _database;
    final now = DateTime.now().millisecondsSinceEpoch;

    final updates = <String, dynamic>{
      'status': _statusName(status),
      'updated_at': now,
      if (error != null) 'last_error': error,
    };

    if (incrementAttempts) {
      await db.rawUpdate(
        'UPDATE $_table SET status = ?, last_error = ?, updated_at = ?, '
        'attempts = attempts + 1 WHERE local_id = ?',
        [_statusName(status), error ?? '', now, localId],
      );
    } else {
      await db.update(
        _table,
        updates,
        where: 'local_id = ?',
        whereArgs: [localId],
      );
    }
  }

  /// Hapus entri yang sudah synced (cleanup berkala).
  Future<int> deleteSynced() async {
    final db = await _database;
    return db.delete(_table, where: "status = 'synced'");
  }

  /// Ambil entri by local_id.
  Future<PendingSyncEntry?> getById(int localId) async {
    final db = await _database;
    final rows = await db.query(
      _table,
      where: 'local_id = ?',
      whereArgs: [localId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return PendingSyncEntry.fromRow(rows.first);
  }

  String _statusName(PendingStatus s) {
    switch (s) {
      case PendingStatus.pending:
        return 'pending';
      case PendingStatus.syncing:
        return 'syncing';
      case PendingStatus.synced:
        return 'synced';
      case PendingStatus.failed:
        return 'failed';
    }
  }
}
