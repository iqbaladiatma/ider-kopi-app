import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

import '../../features/attendance/data/attendance_repository.dart';
import '../../features/sync/data/sync_repository.dart';
import '../database/app_database.dart';
import '../database/daos/pending_sync_dao.dart';
import '../database/daos/sync_log_dao.dart';

/// Callback dispatcher untuk [Workmanager].
///
/// Dipanggil oleh OS secara periodic (setiap 15 menit) saat network connected.
/// Tidak boleh bergantung pada WidgetRef / ProviderScope karena berjalan
/// di isolate terpisah. Kita instantiate repository manual di sini.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      final db = AppDatabase();
      final pendingDao = PendingSyncDao(db);
      final syncLogDao = SyncLogDao(db);
      final attendanceRepo = AttendanceRepository();

      final syncRepo = SyncRepository(
        pendingDao: pendingDao,
        syncLogDao: syncLogDao,
        attendanceRepo: attendanceRepo,
      );

      final result = await syncRepo.syncAll();

      if (kDebugMode) {
        debugPrint(
          'SyncWorker: background sync done — '
          'success=${result.success}, failed=${result.failed}, '
          'skipped=${result.skipped}',
        );
      }

      await db.close();
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('SyncWorker: background sync error: $e');
      }
      return false;
    }
  });
}

/// Wrapper untuk inisialisasi [Workmanager] di main.dart.
class SyncWorker {
  SyncWorker._();

  static const String _taskName = 'iderkopi.syncPending';
  static const Duration _interval = Duration(minutes: 15);

  /// Init workmanager & register periodic task.
  static Future<void> init() async {
    await Workmanager().initialize(callbackDispatcher);

    // Hanya register periodic task sekali (idempotent by tag)
    await Workmanager().registerPeriodicTask(
      _taskName,
      _taskName,
      frequency: _interval,
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      initialDelay: const Duration(minutes: 5),
    );
  }

  /// Cancel semua task (dipakai saat logout).
  static Future<void> cancel() async {
    await Workmanager().cancelByTag(_taskName);
  }

  /// Trigger one-off sync langsung (untuk debug atau manual trigger dari UI).
  static Future<void> triggerOneOff() async {
    await Workmanager().registerOneOffTask(
      'iderkopi.syncOneOff',
      'iderkopi.syncPending',
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
  }
}
