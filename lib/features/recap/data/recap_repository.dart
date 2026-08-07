import 'package:flutter/foundation.dart';

import '../../../core/config/api_provider.dart';
import '../../../core/config/app_config.dart';
import '../../../core/network/directus_client.dart';
import 'recap_model.dart';

/// Repository untuk recap absensi bulanan (v2.0).
class RecapRepository {
  RecapRepository._();
  static final RecapRepository _instance = RecapRepository._();
  factory RecapRepository() => _instance;

  final DirectusClient _client = DirectusClient.instance;

  /// Ambil recap absensi bulanan untuk user tertentu.
  Future<RecapSummary> getMonthlyRecap({
    required String userId,
    required int year,
    required int month,
  }) async {
    if (AppConfig.useMockAuth) {
      return RecapBuilder.mockFor(year, month);
    }

    try {
      final isDirectus = AppConfig.apiProvider == ApiProvider.directus;
      final endpoint = isDirectus ? '/items/recap_monthly' : '/api/v1/attendance/recap';
      final query = isDirectus
          ? {
              'filter[user_id][_eq]': userId,
              'filter[year][_eq]': year,
              'filter[month][_eq]': month,
              'limit': 31,
              'sort[]': 'date',
            }
          : {
              'period': 'monthly',
              'date_from': '$year-${month.toString().padLeft(2, '0')}-01',
              'date_to': '$year-${month.toString().padLeft(2, '0')}-${DateTime(year, month + 1, 0).day}',
            };

      final response = await _client.get(endpoint, query: query);
      final data = response.data['data'] as List?;
      if (data == null || data.isEmpty) return RecapBuilder.mockFor(year, month);

      final days = data
          .map((e) => RecapDay.fromJson(e as Map<String, dynamic>))
          .toList();
      return RecapBuilder.build(year: year, month: month, days: days);
    } catch (e) {
      if (kDebugMode) debugPrint('RecapRepository.getMonthlyRecap error: $e');
      return RecapBuilder.mockFor(year, month);
    }
  }
}
