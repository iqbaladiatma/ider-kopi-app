import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_providers.dart';
import '../../auth/providers/auth_providers.dart';
import '../data/attendance_model.dart';
import '../data/attendance_repository.dart';

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepository();
});

final todayAttendanceProvider = FutureProvider<AttendanceRecord?>((ref) async {
  final kangiderId = await ref.watch(kangiderIdProvider.future);
  if (kangiderId == null) return null;

  final repo = ref.read(attendanceRepositoryProvider);
  final record = await repo.getTodayAttendance(kangiderId);

  // Cache ke SQLite jika ada record
  if (record != null) {
    try {
      final dao = ref.read(attendanceDaoProvider);
      await dao.upsert(record);
    } catch (_) {}
  }

  return record;
});

/// History provider dengan cache-first strategy (v1.2).
///
/// 1. Coba baca dari SQLite cache → return langsung (cepat)
/// 2. Fetch dari API di background → update cache → invalidate
/// 3. Jika API gagal, cache tetap dipakai (offline mode)
final historyProvider = FutureProvider<List<AttendanceRecord>>((ref) async {
  final kangiderId = await ref.watch(kangiderIdProvider.future);
  if (kangiderId == null) return [];

  final dao = ref.read(attendanceDaoProvider);
  final repo = ref.read(attendanceRepositoryProvider);

  // 1. Cache-first
  List<AttendanceRecord> cached = [];
  try {
    cached = await dao.getHistory(kangiderId);
  } catch (_) {}

  // 2. Refresh dari API (best-effort)
  try {
    final fresh = await repo.getHistory(kangiderId);
    await dao.upsertAll(fresh);
    return fresh;
  } catch (_) {
    // 3. Fallback ke cache jika API gagal
    if (cached.isNotEmpty) return cached;
    rethrow;
  }
});

final monthlyHistoryProvider =
    FutureProvider.family<List<AttendanceRecord>, ({int year, int month})>(
        (ref, params) async {
  final kangiderId = await ref.watch(kangiderIdProvider.future);
  if (kangiderId == null) return [];

  final dao = ref.read(attendanceDaoProvider);
  final repo = ref.read(attendanceRepositoryProvider);

  // Cache-first
  final startDate = DateTime(params.year, params.month, 1);
  final endDate = DateTime(params.year, params.month + 1, 0);
  final startStr = _toIsoDate(startDate);
  final endStr = _toIsoDate(endDate);

  List<AttendanceRecord> cached = [];
  try {
    cached = await dao.getMonthlyHistory(kangiderId, startStr, endStr);
  } catch (_) {}

  try {
    final fresh =
        await repo.getMonthlyHistory(kangiderId, params.year, params.month);
    await dao.upsertAll(fresh);
    return fresh;
  } catch (_) {
    if (cached.isNotEmpty) return cached;
    rethrow;
  }
});

final monthlyStatsProvider =
    FutureProvider.family<MonthlyStats, ({int year, int month})>(
        (ref, params) async {
  final records = await ref.watch(monthlyHistoryProvider(params).future);

  int hadir = 0;
  int terlambat = 0;
  int alpha = 0;

  for (final r in records) {
    switch (r.status) {
      case AttendanceStatus.tepatWaktu:
        hadir++;
        break;
      case AttendanceStatus.terlambat:
        terlambat++;
        hadir++;
        break;
      case AttendanceStatus.alpha:
        alpha++;
        break;
      case AttendanceStatus.belumAbsen:
        break;
    }
  }

  return MonthlyStats(hadir: hadir, terlambat: terlambat, alpha: alpha);
});

class MonthlyStats {
  final int hadir;
  final int terlambat;
  final int alpha;

  MonthlyStats({
    required this.hadir,
    required this.terlambat,
    required this.alpha,
  });
}

String _toIsoDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
