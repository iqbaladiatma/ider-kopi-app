import 'package:camera/camera.dart';
import 'package:dio/dio.dart';

import '../../../core/config/api_provider.dart';
import '../../../core/config/app_config.dart';
import '../../../core/network/directus_client.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/mock_data.dart';
import 'attendance_model.dart';

class AttendanceRepository {
  AttendanceRepository._internal();
  static final AttendanceRepository _instance = AttendanceRepository._internal();
  factory AttendanceRepository() => _instance;

  final DirectusClient _client = DirectusClient.instance;

  Future<AttendanceRecord?> getTodayAttendance(String kangiderId) async {
    final today = AppDateUtils.todayDateString();

    if (AppConfig.useMockAuth) {
      return _mockTodayAttendance(kangiderId, today);
    }

    final isDirectus = AppConfig.apiProvider == ApiProvider.directus;
    final endpoint = isDirectus ? '/items/absensi_ider' : '/api/v1/attendance/logs/me';
    final query = isDirectus
        ? {
            'filter[kangider][_eq]': kangiderId,
            'filter[tanggal_absensi][_eq]': today,
            'limit': 1,
          }
        : null;

    try {
      final response = await _client.get(endpoint, query: query);
      final data = response.data['data'] as List;
      if (data.isEmpty) return null;
      return AttendanceRecord.fromJson(data.first as Map<String, dynamic>);
    } catch (_) {
      return _mockTodayAttendance(kangiderId, today);
    }
  }

  AttendanceRecord? _mockTodayAttendance(String kangiderId, String today) {
    final record = MockData.mockAllAttendance.firstWhere(
      (r) => r['kangider'] == kangiderId && r['tanggal_absensi'] == today,
      orElse: () => <String, dynamic>{},
    );
    return record.isEmpty ? null : AttendanceRecord.fromJson(record);
  }

  Future<AttendanceRecord> checkIn(CheckInRequest req) async {
    if (AppConfig.useMockAuth) {
      return _mockCheckIn(req);
    }

    final endpoint = AppConfig.apiProvider == ApiProvider.directus
        ? '/items/absensi_ider'
        : '/api/v1/attendance/logs';

    try {
      final response = await _client.post(
        endpoint,
        body: req.toJson(),
      );

      final data = response.data['data'] as Map<String, dynamic>;
      return AttendanceRecord.fromJson(data);
    } catch (_) {
      return _mockCheckIn(req);
    }
  }

  AttendanceRecord _mockCheckIn(CheckInRequest req) {
    final newRecord = <String, dynamic>{
      ...req.toJson(),
      'id': DateTime.now().millisecondsSinceEpoch,
      'pulang': null,
    };
    MockData.mockAllAttendance.add(newRecord);
    return AttendanceRecord.fromJson(newRecord);
  }

  Future<AttendanceRecord> checkOut(int id, CheckOutRequest req) async {
    if (AppConfig.useMockAuth) {
      return _mockCheckOut(id, req);
    }

    final isDirectus = AppConfig.apiProvider == ApiProvider.directus;
    final endpoint = isDirectus ? '/items/absensi_ider/$id' : '/api/v1/attendance/logs/$id';

    try {
      final response = isDirectus
          ? await _client.patch(endpoint, body: req.toJson())
          : await _client.post(endpoint, body: req.toJson());

      final data = response.data['data'] as Map<String, dynamic>;
      return AttendanceRecord.fromJson(data);
    } catch (_) {
      return _mockCheckOut(id, req);
    }
  }

  AttendanceRecord _mockCheckOut(int id, CheckOutRequest req) {
    final index = MockData.mockAllAttendance.indexWhere(
      (r) => r['id'].toString() == id.toString(),
    );
    if (index == -1) {
      final fallback = <String, dynamic>{
        'id': id,
        'tanggal_absensi': AppDateUtils.todayDateString(),
        'masuk': '08:00:00',
        'pulang': req.pulang,
        'keterangan': req.keterangan,
      };
      return AttendanceRecord.fromJson(fallback);
    }

    final record = MockData.mockAllAttendance[index];
    record['pulang'] = req.pulang;
    if (req.latitudePulang != null) record['latitude_pulang'] = req.latitudePulang;
    if (req.longitudePulang != null) record['longitude_pulang'] = req.longitudePulang;
    if (req.selfiePulangFileId != null) record['selfie_pulang_file_id'] = req.selfiePulangFileId;
    if (req.keterangan != null) record['keterangan'] = req.keterangan;
    return AttendanceRecord.fromJson(record);
  }

  Future<List<AttendanceRecord>> getHistory(String kangiderId,
      {int limit = 30}) async {
    if (AppConfig.useMockAuth) {
      return _mockHistory(kangiderId, limit);
    }

    final isDirectus = AppConfig.apiProvider == ApiProvider.directus;
    final endpoint = isDirectus ? '/items/absensi_ider' : '/api/v1/attendance/logs/me';
    final query = isDirectus
        ? {
            'filter[kangider][_eq]': kangiderId,
            'sort[]': '-tanggal_absensi',
            'limit': limit,
          }
        : null;

    try {
      final response = await _client.get(endpoint, query: query);
      final data = response.data['data'] as List;
      return data
          .map((e) => AttendanceRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return _mockHistory(kangiderId, limit);
    }
  }

  List<AttendanceRecord> _mockHistory(String kangiderId, int limit) {
    final records = MockData.mockAllAttendance
        .where((r) => r['kangider'] == kangiderId)
        .toList()
      ..sort((a, b) {
        final dateCompare = (b['tanggal_absensi'] as String)
            .compareTo(a['tanggal_absensi'] as String);
        if (dateCompare != 0) return dateCompare;
        return (b['masuk'] ?? '').toString()
            .compareTo((a['masuk'] ?? '').toString());
      });
    return records
        .take(limit)
        .map((e) => AttendanceRecord.fromJson(e))
        .toList();
  }

  Future<String> uploadSelfie(XFile imageFile) async {
    if (AppConfig.useMockAuth) {
      return 'mock-selfie-${DateTime.now().millisecondsSinceEpoch}';
    }

    try {
      final bytes = await imageFile.readAsBytes();
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          bytes,
          filename: 'selfie_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });

      final response = await _client.post('/files', formData: formData);
      final data = response.data['data'] as Map<String, dynamic>;
      return data['id'] as String;
    } catch (_) {
      return 'mock-selfie-${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  Future<List<AttendanceRecord>> getMonthlyHistory(
      String kangiderId, int year, int month) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0);

    final startStr = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
    final endStr = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';

    if (AppConfig.useMockAuth) {
      return _mockMonthlyHistory(kangiderId, startStr, endStr);
    }

    try {
      final response = await _client.get('/items/absensi_ider', query: {
        'filter[kangider][_eq]': kangiderId,
        'filter[tanggal_absensi][_between]': '$startStr,$endStr',
        'sort[]': '-tanggal_absensi',
        'limit': 31,
      });

      final data = response.data['data'] as List;
      return data
          .map((e) => AttendanceRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return _mockMonthlyHistory(kangiderId, startStr, endStr);
    }
  }

  List<AttendanceRecord> _mockMonthlyHistory(String kangiderId, String startStr, String endStr) {
    final records = MockData.mockAllAttendance
        .where((r) =>
            r['kangider'] == kangiderId &&
            _between(r['tanggal_absensi'] as String, startStr, endStr))
        .toList()
      ..sort((a, b) {
        final dateCompare = (b['tanggal_absensi'] as String)
            .compareTo(a['tanggal_absensi'] as String);
        if (dateCompare != 0) return dateCompare;
        return (b['masuk'] ?? '').toString()
            .compareTo((a['masuk'] ?? '').toString());
      });
    return records
        .take(31)
        .map((e) => AttendanceRecord.fromJson(e))
        .toList();
  }


  static bool _between(String value, String start, String end) {
    return value.compareTo(start) >= 0 && value.compareTo(end) <= 0;
  }
}
