import 'package:camera/camera.dart';
import 'package:dio/dio.dart';

import '../../features/attendance/data/attendance_model.dart';
import '../config/app_config.dart';
import '../storage/secure_storage.dart';
import 'attendance_data_source.dart';

/// Implementasi `AttendanceDataSource` untuk Go backend custom (v2.0).
///
/// Go backend punya response format yang lebih flat dibanding Directus:
/// ```json
/// { "data": {...}, "message": "success" }
/// ```
/// atau array langsung untuk list endpoint.
class GoAttendanceDataSource implements AttendanceDataSource {
  final Dio _dio;
  final SecureStorage _storage;

  GoAttendanceDataSource({
    required Dio dio,
    required SecureStorage storage,
  })  : _dio = dio,
        _storage = storage;

  /// Helper untuk inject Bearer token ke request.
  Future<Map<String, dynamic>> _authHeaders() async {
    final token = await _storage.getAccessToken();
    return token == null ? {} : {'Authorization': 'Bearer $token'};
  }

  @override
  Future<String> uploadSelfie(XFile file) async {
    final bytes = await file.readAsBytes();
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        bytes,
        filename: 'selfie_${DateTime.now().millisecondsSinceEpoch}.jpg',
      ),
    });

    final headers = await _authHeaders();
    final response = await _dio.post(
      '/api/v1/attendance/upload-selfie',
      data: formData,
      options: Options(headers: headers),
    );

    // Go backend return: { "data": { "file_id": "xxx" } }
    final data = response.data['data'] as Map<String, dynamic>;
    return data['file_id'].toString();
  }

  @override
  Future<AttendanceRecord> checkIn(CheckInRequest request) async {
    final headers = await _authHeaders();
    final response = await _dio.post(
      '/api/v1/attendance/check-in',
      data: request.toJson(),
      options: Options(headers: headers),
    );

    final data = response.data['data'] as Map<String, dynamic>;
    return AttendanceRecord.fromJson(data);
  }

  @override
  Future<AttendanceRecord> checkOut(int recordId, CheckOutRequest request) async {
    final headers = await _authHeaders();
    final response = await _dio.patch(
      '/api/v1/attendance/check-out/$recordId',
      data: request.toJson(),
      options: Options(headers: headers),
    );

    final data = response.data['data'] as Map<String, dynamic>;
    return AttendanceRecord.fromJson(data);
  }

  @override
  Future<AttendanceRecord?> getTodayAttendance(String kangiderId) async {
    final headers = await _authHeaders();
    final response = await _dio.get(
      '/api/v1/attendance/today',
      queryParameters: {'kangider_id': kangiderId},
      options: Options(headers: headers),
    );

    final data = response.data['data'];
    if (data == null || data is! Map<String, dynamic>) return null;
    return AttendanceRecord.fromJson(data);
  }

  @override
  Future<List<AttendanceRecord>> getHistory(String kangiderId,
      {int limit = 30}) async {
    final headers = await _authHeaders();
    final response = await _dio.get(
      '/api/v1/attendance/history',
      queryParameters: {'kangider_id': kangiderId, 'limit': limit},
      options: Options(headers: headers),
    );

    final data = response.data['data'] as List;
    return data
        .map((e) => AttendanceRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<AttendanceRecord>> getMonthlyHistory(
      String kangiderId, int year, int month) async {
    final headers = await _authHeaders();
    final monthStr = '$year-${month.toString().padLeft(2, '0')}';
    final response = await _dio.get(
      '/api/v1/attendance/history',
      queryParameters: {'kangider_id': kangiderId, 'month': monthStr},
      options: Options(headers: headers),
    );

    final data = response.data['data'] as List;
    return data
        .map((e) => AttendanceRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
