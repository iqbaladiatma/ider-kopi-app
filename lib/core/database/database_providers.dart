import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';
import 'daos/attendance_dao.dart';
import 'daos/outlet_dao.dart';
import 'daos/pending_sync_dao.dart';
import 'daos/sync_log_dao.dart';

/// Singleton database (lazy open).
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final attendanceDaoProvider = Provider<AttendanceDao>((ref) {
  return AttendanceDao(ref.read(appDatabaseProvider));
});

final outletDaoProvider = Provider<OutletDao>((ref) {
  return OutletDao(ref.read(appDatabaseProvider));
});

final pendingSyncDaoProvider = Provider<PendingSyncDao>((ref) {
  return PendingSyncDao(ref.read(appDatabaseProvider));
});

final syncLogDaoProvider = Provider<SyncLogDao>((ref) {
  return SyncLogDao(ref.read(appDatabaseProvider));
});
