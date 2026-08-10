import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import 'kpi_model.dart';

class KpiRepository {
  KpiRepository._();
  static final KpiRepository _instance = KpiRepository._();
  factory KpiRepository() => _instance;

  final ApiClient _client = ApiClient.instance;

  Future<KpiSummary> getMyKpi({
    required String userId,
    required int year,
    required int month,
  }) async {
    if (AppConfig.useMockAuth) return _mockKpi(userId, year, month);
    final monthKey = '$year-${month.toString().padLeft(2, '0')}';
    final responses = await Future.wait([
      _client.get('kpi/me'),
      _client.get('attendance/recap/me', query: {'month': monthKey}),
    ]);
    final raw = ((responses[0].data as Map<String, dynamic>)['data']
            as List<dynamic>?) ??
        const [];
    Map<String, dynamic>? selected;
    for (final item in raw) {
      final value = (item as Map).cast<String, dynamic>();
      final period = value['period'] as Map?;
      final start =
          DateTime.tryParse(period?['period_start']?.toString() ?? '');
      if (start == null || (start.year == year && start.month == month)) {
        selected = value;
        break;
      }
    }
    final stats = (responses[1].data as Map<String, dynamic>)['data']
        as Map<String, dynamic>;
    final present = (stats['hadir_tepat_waktu'] as num?)?.toInt() ?? 0;
    final late = (stats['terlambat'] as num?)?.toInt() ?? 0;
    final leave = ((stats['izin'] as num?)?.toInt() ?? 0) +
        ((stats['sakit'] as num?)?.toInt() ?? 0) +
        ((stats['cuti'] as num?)?.toInt() ?? 0);
    final total = (stats['total_days'] as num?)?.toInt() ?? 0;
    final score = (selected?['final_score'] as num?)?.toDouble() ?? 0;
    return KpiSummary(
      id: selected?['id']?.toString(),
      userId: userId,
      year: year,
      month: month,
      totalWorkingDays: total,
      presentDays: present + late,
      lateDays: late,
      absentDays: (stats['alpha'] as num?)?.toInt() ?? 0,
      leaveDays: leave,
      attendanceRate: (stats['attendance_rate'] as num?)?.toDouble() ?? 0,
      lateRate: total == 0 ? 0 : late / total * 100,
      score: score,
      grade: KpiSummary.gradeFromScore(score),
    );
  }

  KpiSummary _mockKpi(String userId, int year, int month) => KpiSummary(
        id: '00000000-0000-4000-8000-000000000001',
        userId: userId,
        year: year,
        month: month,
        totalWorkingDays: 22,
        presentDays: 20,
        lateDays: 3,
        absentDays: 1,
        leaveDays: 1,
        attendanceRate: 90.9,
        lateRate: 15,
        score: 88,
        grade: 'B',
      );
}
