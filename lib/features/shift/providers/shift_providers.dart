import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_providers.dart';
import '../data/shift_model.dart';
import '../data/shift_repository.dart';

final shiftRepositoryProvider = Provider<ShiftRepository>((ref) {
  return ShiftRepository();
});

/// Semua shift aktif.
final shiftsProvider = FutureProvider<List<Shift>>((ref) async {
  final repo = ref.read(shiftRepositoryProvider);
  return repo.getShifts();
});

/// Jadwal shift user login untuk bulan tertentu.
final myShiftsProvider =
    FutureProvider.family<List<UserShift>, ({int year, int month})>((ref, params) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) return [];

  final repo = ref.read(shiftRepositoryProvider);
  return repo.getMyShifts(
    userId: user.id,
    year: params.year,
    month: params.month,
  );
});

/// Jadwal shift user login untuk bulan saat ini.
final currentMonthShiftsProvider = FutureProvider<List<UserShift>>((ref) async {
  final now = DateTime.now();
  return ref.watch(myShiftsProvider((year: now.year, month: now.month)).future);
});
