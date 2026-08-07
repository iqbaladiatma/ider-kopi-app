import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../app_database.dart';

/// Log konflik sync untuk audit.
class SyncLogEntry {
  final int? id;
  final int? localId;
  final String? operation;
  final String? conflictType;
  final Map<String, dynamic>? serverState;
  final Map<String, dynamic>? localState;
  final String resolution;
  final int createdAt;

  const SyncLogEntry({
    this.id,
    this.localId,
    this.operation,
    this.conflictType,
    this.serverState,
    this.localState,
    required this.resolution,
    required this.createdAt,
  });

  Map<String, dynamic> toRow() {
    return {
      if (id != null) 'id': id,
      'local_id': localId,
      'operation': operation,
      'conflict_type': conflictType,
      'server_state': serverState != null ? jsonEncode(serverState) : null,
      'local_state': localState != null ? jsonEncode(localState) : null,
      'resolution': resolution,
      'created_at': createdAt,
    };
  }

  factory SyncLogEntry.fromRow(Map<String, dynamic> row) {
    return SyncLogEntry(
      id: row['id'] != null ? (row['id'] as num).toInt() : null,
      localId: row['local_id'] != null
          ? int.tryParse(row['local_id'].toString())
          : null,
      operation: row['operation']?.toString(),
      conflictType: row['conflict_type']?.toString(),
      serverState: row['server_state'] != null
          ? jsonDecode(row['server_state'].toString()) as Map<String, dynamic>
          : null,
      localState: row['local_state'] != null
          ? jsonDecode(row['local_state'].toString()) as Map<String, dynamic>
          : null,
      resolution: row['resolution'].toString(),
      createdAt: (row['created_at'] as num).toInt(),
    );
  }
}

/// DAO untuk tabel `sync_log`.
class SyncLogDao {
  final AppDatabase _db;
  SyncLogDao(this._db);

  static const String _table = 'sync_log';

  Future<Database> get _database => _db.database;

  Future<int> insert(SyncLogEntry entry) async {
    final db = await _database;
    return db.insert(_table, entry.toRow());
  }

  Future<List<SyncLogEntry>> getAll({int limit = 100}) async {
    final db = await _database;
    final rows = await db.query(
      _table,
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return rows.map(SyncLogEntry.fromRow).toList();
  }

  Future<int> count() async {
    final db = await _database;
    final r = await db.rawQuery('SELECT COUNT(*) FROM $_table');
    return Sqflite.firstIntValue(r) ?? 0;
  }

  Future<void> clear() async {
    final db = await _database;
    await db.delete(_table);
  }
}
