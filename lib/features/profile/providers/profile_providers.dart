import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../attendance/providers/attendance_providers.dart';
import '../../auth/providers/auth_providers.dart';
import '../data/profile_model.dart';

final profileInfoProvider = FutureProvider<ProfileInfo?>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) return null;

  return ProfileInfo(
    id: user.id,
    email: user.email,
    firstName: user.firstName,
    lastName: user.lastName,
    kangiderId: user.kangiderId,
    kangiderNama: user.kangiderNama,
    outlet: user.outlet,
  );
});

final profileStatsProvider =
    FutureProvider<AttendanceStats>((ref) async {
  final now = DateTime.now();
  final params = (year: now.year, month: now.month);
  final stats = await ref.watch(monthlyStatsProvider(params).future);

  return AttendanceStats(
    hadir: stats.hadir,
    terlambat: stats.terlambat,
    alpha: stats.alpha,
  );
});
