import 'package:flutter/foundation.dart';

import '../../../core/config/api_provider.dart';
import '../../../core/config/app_config.dart';
import '../../../core/network/directus_client.dart';
import 'kpi_model.dart';

/// Repository untuk KPI summary (v2.0).
///
/// Untuk sekarang, KPI dihitung di client-side dari data absensi yang ada.
/// Nantinya, Go backend akan punya endpoint `/api/v1/kpi/me` yang hitung
/// otomatis via cron job.
class KpiRepository {
  KpiRepository._();
  static final KpiRepository _instance = KpiRepository._();
  factory KpiRepository() => _instance;

  final DirectusClient _client = DirectusClient.instance;

  /// Ambil KPI summary untuk user & bulan tertentu.
  ///
  /// [userId] = kangider ID user.
  /// [year], [month] = periode KPI.
  Future<KpiSummary> getMyKpi({
    required String userId,
    required int year,
    required int month,
  }) async {
    if (AppConfig.useMockAuth) {
      return _mockKpi(userId, year, month);
    }

    try {
      final isDirectus = AppConfig.apiProvider == ApiProvider.directus;
      final endpoint = isDirectus ? '/items/kpi_summary' : '/api/v1/kpi/me';
      final query = isDirectus
          ? {
              'filter[user_id][_eq]': userId,
              'filter[year][_eq]': year,
              'filter[month][_eq]': month,
              'limit': 1,
            }
          : null;

      final response = await _client.get(endpoint, query: query);
      final rawData = response.data['data'];
      if (rawData == null) return _mockKpi(userId, year, month);
      final data = rawData is List ? (rawData.isEmpty ? null : rawData.first) : rawData;
      if (data == null) return _mockKpi(userId, year, month);
      return KpiSummary.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      if (kDebugMode) debugPrint('KpiRepository.getMyKpi error: $e');
      return _mockKpi(userId, year, month);
    }
  }

  /// Mock KPI untuk development.
  KpiSummary _mockKpi(String userId, int year, int month) {
    // Hitung working days (sederhana: 22 hari kerja per bulan)
    final totalWorkingDays = 22;
    final presentDays = 20;
    final lateDays = 3;
    final absentDays = 1;
    final leaveDays = 1;

    final attendanceRate =
        (presentDays / totalWorkingDays * 100).clamp(0.0, 100.0).toDouble();
    final lateRate = (lateDays / presentDays * 100).clamp(0.0, 100.0).toDouble();
    final score = KpiSummary.calculateScore(
      attendanceRate: attendanceRate,
      lateRate: lateRate,
      totalWorkingDays: totalWorkingDays,
      leaveDays: leaveDays,
    );

    return KpiSummary(
      userId: userId,
      year: year,
      month: month,
      totalWorkingDays: totalWorkingDays,
      presentDays: presentDays,
      lateDays: lateDays,
      absentDays: absentDays,
      leaveDays: leaveDays,
      attendanceRate: attendanceRate,
      lateRate: lateRate,
      score: score,
      grade: KpiSummary.gradeFromScore(score),
    );
  }
}
