import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/holiday_model.dart';
import '../data/holiday_repository.dart';

final holidayRepositoryProvider = Provider<HolidayRepository>((ref) {
  return HolidayRepository();
});

/// Hari libur hari ini (null jika bukan hari libur).
final todayHolidayProvider = FutureProvider<Holiday?>((ref) async {
  final repo = ref.read(holidayRepositoryProvider);
  return repo.getTodayHoliday();
});

/// Semua hari libur tahun ini.
final holidaysProvider = FutureProvider<List<Holiday>>((ref) async {
  final repo = ref.read(holidayRepositoryProvider);
  return repo.getHolidays();
});
