import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_providers.dart';
import '../data/kpi_model.dart';
import '../data/kpi_repository.dart';

final kpiRepositoryProvider = Provider<KpiRepository>((ref) {
  return KpiRepository();
});

/// KPI summary untuk user login, bulan & tahun tertentu.
final myKpiProvider =
    FutureProvider.family<KpiSummary, ({int year, int month})>((ref, params) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) {
    throw Exception('User tidak teridentifikasi');
  }

  final repo = ref.read(kpiRepositoryProvider);
  return repo.getMyKpi(
    userId: user.id,
    year: params.year,
    month: params.month,
  );
});

/// KPI summary untuk user login, bulan & tahun saat ini.
final currentMonthKpiProvider = FutureProvider<KpiSummary>((ref) async {
  final now = DateTime.now();
  return ref.watch(myKpiProvider((year: now.year, month: now.month)).future);
});
