import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/mock_data.dart';
import 'holiday_model.dart';

class HolidayRepository {
  HolidayRepository._();
  static final HolidayRepository _instance = HolidayRepository._();
  factory HolidayRepository() => _instance;

  final ApiClient _client = ApiClient.instance;

  Future<List<Holiday>> getHolidays(
      {int? year, bool forceRefresh = false}) async {
    final selectedYear = year ?? DateTime.now().year;
    if (AppConfig.useMockAuth) {
      return MockData.mockHolidays
          .map(Holiday.fromJson)
          .where((holiday) => holiday.tanggal.year == selectedYear)
          .toList();
    }
    final response = await _client.get(
      'holidays',
      query: {'year': selectedYear},
    );
    final data =
        (response.data as Map<String, dynamic>)['data'] as List<dynamic>;
    return data
        .map((item) => Holiday.fromJson((item as Map).cast<String, dynamic>()))
        .toList();
  }

  Future<Holiday?> getHolidayForDate(DateTime date) async {
    final holidays = await getHolidays(year: date.year);
    for (final holiday in holidays) {
      if (holiday.isSameDate(date)) return holiday;
    }
    return null;
  }

  Future<Holiday?> getTodayHoliday() => getHolidayForDate(DateTime.now());

  Future<Holiday?> getTomorrowHoliday() =>
      getHolidayForDate(DateTime.now().add(const Duration(days: 1)));

  Future<bool> hasCache(int year) async => false;
}
