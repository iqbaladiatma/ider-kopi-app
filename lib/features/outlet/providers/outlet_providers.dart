import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/location_utils.dart';
import '../data/outlet_model.dart';
import '../data/outlet_repository.dart';

final outletRepositoryProvider = Provider<OutletRepository>((ref) {
  return OutletRepository();
});

/// List semua outlet aktif (cache-first, refresh background).
final outletsProvider = FutureProvider<List<Outlet>>((ref) async {
  final repo = ref.read(outletRepositoryProvider);
  return await repo.getOutlets();
});

/// Force refresh outlet dari API (untuk pull-to-refresh).
final outletsRefreshProvider = FutureProvider<List<Outlet>>((ref) async {
  final repo = ref.read(outletRepositoryProvider);
  return await repo.getOutlets(forceRefresh: true);
});

/// Outlet terpilih oleh user saat check-in (default: null = belum pilih).
/// Dipakai oleh check-in & check-out page.
final selectedOutletProvider = StateProvider<Outlet?>((ref) => null);

/// Hitung jarak user ke setiap outlet & return list sorted by distance.
/// Input: posisi user (lat, lng).
final outletDistancesProvider =
    FutureProvider.family<List<OutletDistance>, ({double lat, double lng})>(
        (ref, params) async {
  final outlets = await ref.watch(outletsProvider.future);
  final distances = <OutletDistance>[];

  for (final outlet in outlets) {
    final d = LocationUtils.distanceTo(
      params.lat,
      params.lng,
      outlet.latitude,
      outlet.longitude,
    );
    distances.add(OutletDistance(
      outlet: outlet,
      distanceMeters: d,
      isWithinRadius: d <= outlet.radiusMeters,
    ));
  }

  distances.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
  return distances;
});

/// Outlet terdekat dengan posisi user (null jika tidak ada outlet).
final nearestOutletProvider =
    FutureProvider.family<OutletDistance?, ({double lat, double lng})>(
        (ref, params) async {
  final distances = await ref.watch(outletDistancesProvider(params).future);
  return distances.isEmpty ? null : distances.first;
});

/// Cek apakah ada outlet dalam radius dari posisi user.
final hasOutletInRadiusProvider =
    FutureProvider.family<bool, ({double lat, double lng})>(
        (ref, params) async {
  final distances = await ref.watch(outletDistancesProvider(params).future);
  return distances.any((d) => d.isWithinRadius);
});

/// True jika cache outlet stale (lebih dari 24 jam) atau API offline.
/// Dipakai untuk menampilkan banner "Mode offline" di UI.
final isOutletCacheStaleProvider = FutureProvider<bool>((ref) async {
  // Pastikan outletsProvider sudah di-resolve (load cache)
  await ref.watch(outletsProvider.future);
  final repo = ref.read(outletRepositoryProvider);
  return await repo.isCacheStale();
});
