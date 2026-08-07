import '../../../core/database/daos/sync_log_dao.dart';

/// Helper untuk resolve konflik sync antara data lokal & server.
///
/// Strategi default:
/// - **Duplicate check-in** (sudah ada absensi tanggal itu di server):
///   server wins → skip, log konflik
/// - **Already checked out** (record sudah ada `pulang`):
///   server wins → skip, log konflik
class ConflictResolver {
  ConflictResolver._();

  /// Handle konflik: check-in sudah ada di server untuk tanggal yang sama.
  static Future<void> resolveDuplicateCheckIn({
    required SyncLogDao syncLogDao,
    required int? localId,
    required Map<String, dynamic> localState,
    required Map<String, dynamic> serverState,
  }) async {
    await syncLogDao.insert(SyncLogEntry(
      localId: localId,
      operation: 'check_in',
      conflictType: 'duplicate_check_in',
      serverState: serverState,
      localState: localState,
      resolution: 'server_wins',
      createdAt: DateTime.now().millisecondsSinceEpoch,
    ));
  }

  /// Handle konflik: check-out sudah pernah dilakukan untuk record ini.
  static Future<void> resolveAlreadyCheckedOut({
    required SyncLogDao syncLogDao,
    required int? localId,
    required Map<String, dynamic> localState,
    required Map<String, dynamic> serverState,
  }) async {
    await syncLogDao.insert(SyncLogEntry(
      localId: localId,
      operation: 'check_out',
      conflictType: 'already_checked_out',
      serverState: serverState,
      localState: localState,
      resolution: 'server_wins',
      createdAt: DateTime.now().millisecondsSinceEpoch,
    ));
  }

  /// Handle konflik generic (server error, dll).
  static Future<void> logGenericConflict({
    required SyncLogDao syncLogDao,
    required int? localId,
    required String operation,
    required String conflictType,
    required Map<String, dynamic> localState,
    Map<String, dynamic>? serverState,
    String resolution = 'skipped',
  }) async {
    await syncLogDao.insert(SyncLogEntry(
      localId: localId,
      operation: operation,
      conflictType: conflictType,
      serverState: serverState,
      localState: localState,
      resolution: resolution,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    ));
  }
}
