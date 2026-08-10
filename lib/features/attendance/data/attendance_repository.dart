import 'package:camera/camera.dart';
import 'package:dio/dio.dart';

import '../../../core/config/app_config.dart';
import '../../../core/data/attendance_data_source.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/mock_data.dart';
import 'attendance_model.dart';

class AttendanceRepository implements AttendanceDataSource {
  AttendanceRepository._();
  static final AttendanceRepository _instance = AttendanceRepository._();
  factory AttendanceRepository() => _instance;

  final ApiClient _client = ApiClient.instance;

  List<dynamic> _listData(Response<dynamic> response) {
    final envelope = response.data as Map<String, dynamic>;
    return (envelope['data'] as List<dynamic>?) ?? const [];
  }

  Map<String, dynamic> _objectData(Response<dynamic> response) {
    final envelope = response.data as Map<String, dynamic>;
    return (envelope['data'] as Map).cast<String, dynamic>();
  }

  @override
  Future<AttendanceRecord?> getTodayAttendance(String kangiderId) async {
    if (AppConfig.useMockAuth) {
      final today = AppDateUtils.todayDateString();
      final record = MockData.mockAllAttendance.firstWhere(
        (item) =>
            item['kangider'].toString() == kangiderId &&
            item['tanggal_absensi'] == today,
        orElse: () => <String, dynamic>{},
      );
      return record.isEmpty ? null : AttendanceRecord.fromJson(record);
    }
    final today = AppDateUtils.todayDateString();
    final records = await getHistory(kangiderId, limit: 31);
    for (final record in records) {
      if (record.tanggalAbsensi == today) return record;
    }
    return null;
  }

  @override
  Future<AttendanceRecord> checkIn(CheckInRequest request) async {
    if (AppConfig.useMockAuth) {
      final data = <String, dynamic>{
        ...request.toJson(),
        'id': request.clientRequestId,
      };
      MockData.mockAllAttendance.add(data);
      return AttendanceRecord.fromJson(data);
    }
    final response = await _client.post(
      'attendance/check-in',
      body: request.toGoJson(),
      options: Options(
        headers: {'X-Idempotency-Key': request.clientRequestId},
      ),
    );
    return AttendanceRecord.fromJson(_objectData(response));
  }

  @override
  Future<AttendanceRecord> checkOut(
    String recordId,
    CheckOutRequest request,
  ) async {
    if (AppConfig.useMockAuth) {
      final index = MockData.mockAllAttendance.indexWhere(
        (item) => item['id'].toString() == recordId,
      );
      if (index < 0) throw StateError('Attendance record not found');
      MockData.mockAllAttendance[index].addAll(request.toJson());
      return AttendanceRecord.fromJson(MockData.mockAllAttendance[index]);
    }
    final response = await _client.post(
      'attendance/check-out',
      body: request.toGoJson(),
    );
    return AttendanceRecord.fromJson(_objectData(response));
  }

  @override
  Future<List<AttendanceRecord>> getHistory(
    String kangiderId, {
    int limit = 30,
  }) async {
    if (AppConfig.useMockAuth) {
      return MockData.mockAllAttendance
          .where((item) => item['kangider'].toString() == kangiderId)
          .take(limit)
          .map(AttendanceRecord.fromJson)
          .toList();
    }
    final response = await _client.get(
      'attendance/logs/me',
      query: {'page': 1, 'page_size': limit},
    );
    return _listData(response)
        .map((item) => AttendanceRecord.fromJson(
              (item as Map).cast<String, dynamic>(),
            ))
        .toList();
  }

  @override
  Future<List<AttendanceRecord>> getMonthlyHistory(
    String kangiderId,
    int year,
    int month,
  ) async {
    if (AppConfig.useMockAuth) {
      final prefix = '$year-${month.toString().padLeft(2, '0')}';
      final records = await getHistory(kangiderId, limit: 1000);
      return records
          .where((record) => record.tanggalAbsensi.startsWith(prefix))
          .toList();
    }
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
    return _listData(response)
        .map((item) => AttendanceRecord.fromJson(
              (item as Map).cast<String, dynamic>(),
            ))
        .toList();
  }

  @override
  Future<String> uploadSelfie(XFile file) async {
    if (AppConfig.useMockAuth) return 'mock-${file.name}';
    final bytes = await file.readAsBytes();
    final response = await _client.post(
      'attendance/selfies',
      formData: FormData.fromMap({
        'selfie': MultipartFile.fromBytes(bytes, filename: file.name),
      }),
    );
    return _objectData(response)['key'].toString();
  }
}
