import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_providers.dart';
import '../../auth/providers/auth_providers.dart';
import '../../attendance/providers/attendance_providers.dart';
import '../data/sync_repository.dart';

final syncRepositoryProvider = Provider<SyncRepository>((ref) {
  return SyncRepository(
    pendingDao: ref.read(pendingSyncDaoProvider),
    syncLogDao: ref.read(syncLogDaoProvider),
    attendanceRepo: ref.read(attendanceRepositoryProvider),
  );
});

/// Jumlah antrian pending sync (untuk badge di home page).
/// Refresh otomatis setiap kali ada perubahan state auth.
final pendingSyncCountProvider = FutureProvider<int>((ref) async {
  // Watch auth state supaya reset saat logout
  ref.watch(authStateProvider);
  final repo = ref.read(syncRepositoryProvider);
  return await repo.pendingCount();
});

/// Trigger sync manual (dipanggil dari tombol "Sync Now").
final manualSyncProvider = FutureProvider<SyncResult>((ref) async {
  final repo = ref.read(syncRepositoryProvider);
  final result = await repo.syncAll();
  // Refresh count setelah sync
  ref.invalidate(pendingSyncCountProvider);
  // Refresh history supaya data baru muncul
  ref.invalidate(historyProvider);
  return result;
});
