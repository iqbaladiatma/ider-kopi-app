import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_providers.dart';
import '../data/recap_model.dart';
import '../data/recap_repository.dart';

final recapRepositoryProvider = Provider<RecapRepository>((ref) {
  return RecapRepository();
});

/// Recap summary untuk user login, bulan & tahun tertentu.
final monthlyRecapProvider =
    FutureProvider.family<RecapSummary, ({int year, int month})>(
        (ref, params) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) {
    throw Exception('User tidak teridentifikasi');
  }

  final repo = ref.read(recapRepositoryProvider);
  return repo.getMonthlyRecap(
    userId: user.id,
    year: params.year,
    month: params.month,
  );
});

/// Recap summary untuk user login, bulan & tahun saat ini.
final currentMonthRecapProvider = FutureProvider<RecapSummary>((ref) async {
  final now = DateTime.now();
  return ref
      .watch(monthlyRecapProvider((year: now.year, month: now.month)).future);
});
