import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_providers.dart';
import '../data/attendance_model.dart';
import '../data/attendance_repository.dart';

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepository();
});

final todayAttendanceProvider =
    FutureProvider<AttendanceRecord?>((ref) async {
  final kangiderId = await ref.watch(kangiderIdProvider.future);
  if (kangiderId == null) return null;

  final repo = ref.read(attendanceRepositoryProvider);
  return await repo.getTodayAttendance(kangiderId);
});

final historyProvider =
    FutureProvider<List<AttendanceRecord>>((ref) async {
  final kangiderId = await ref.watch(kangiderIdProvider.future);
  if (kangiderId == null) return [];

  final repo = ref.read(attendanceRepositoryProvider);
  return await repo.getHistory(kangiderId);
});

final monthlyHistoryProvider =
    FutureProvider.family<List<AttendanceRecord>, ({int year, int month})>(
        (ref, params) async {
  final kangiderId = await ref.watch(kangiderIdProvider.future);
  if (kangiderId == null) return [];

  final repo = ref.read(attendanceRepositoryProvider);
  return await repo.getMonthlyHistory(kangiderId, params.year, params.month);
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
