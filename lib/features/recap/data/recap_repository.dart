import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../attendance/data/attendance_model.dart';
import 'recap_model.dart';

class RecapRepository {
  RecapRepository._();
  static final RecapRepository _instance = RecapRepository._();
  factory RecapRepository() => _instance;

  final ApiClient _client = ApiClient.instance;

  Future<RecapSummary> getMonthlyRecap({
    required String userId,
    required int year,
    required int month,
  }) async {
    if (AppConfig.useMockAuth) return RecapBuilder.mockFor(year, month);
    final lastDay = DateTime(year, month + 1, 0).day;
    final prefix = '$year-${month.toString().padLeft(2, '0')}';
    final response = await _client.get(
      'attendance/logs/me',
      query: {
        'date_from': '$prefix-01',
        'date_to': '$prefix-${lastDay.toString().padLeft(2, '0')}',
        'page': 1,
        'page_size': 31,
      },
    );
    final data =
        (response.data as Map<String, dynamic>)['data'] as List<dynamic>;
    final days = data.map((item) {
      final record = AttendanceRecord.fromJson(
        (item as Map).cast<String, dynamic>(),
      );
      return RecapDay.fromJson({
        'date': record.tanggalAbsensi,
        'status': record.keterangan,
        'check_in_time': record.masuk,
        'check_out_time': record.pulang,
        'outlet_name': record.outlet,
      });
    }).toList();
    return RecapBuilder.build(year: year, month: month, days: days);
  }
}
