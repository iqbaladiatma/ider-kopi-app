import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/network/directus_client.dart';
import '../../../core/utils/date_utils.dart';
import 'attendance_model.dart';

class AttendanceRepository {
  AttendanceRepository._internal();
  static final AttendanceRepository _instance = AttendanceRepository._internal();
  factory AttendanceRepository() => _instance;

  final DirectusClient _client = DirectusClient.instance;

  Future<AttendanceRecord?> getTodayAttendance(String kangiderId) async {
    final today = AppDateUtils.todayDateString();
    final response = await _client.get('/items/absensi_ider', query: {
      'filter[kangider][_eq]': kangiderId,
      'filter[tanggal_absensi][_eq]': today,
      'limit': 1,
    });

    final data = response.data['data'] as List;
    if (data.isEmpty) return null;
    return AttendanceRecord.fromJson(data.first as Map<String, dynamic>);
  }

  Future<AttendanceRecord> checkIn(CheckInRequest req) async {
    final response = await _client.post(
      '/items/absensi_ider',
      body: req.toJson(),
    );

    final data = response.data['data'] as Map<String, dynamic>;
    return AttendanceRecord.fromJson(data);
  }

  Future<AttendanceRecord> checkOut(int id, CheckOutRequest req) async {
    final response = await _client.patch(
      '/items/absensi_ider/$id',
      body: req.toJson(),
    );

    final data = response.data['data'] as Map<String, dynamic>;
    return AttendanceRecord.fromJson(data);
  }

  Future<List<AttendanceRecord>> getHistory(String kangiderId,
      {int limit = 30}) async {
    final response = await _client.get('/items/absensi_ider', query: {
      'filter[kangider][_eq]': kangiderId,
      'sort[]': '-tanggal_absensi',
      'limit': limit,
    });

    final data = response.data['data'] as List;
    return data
        .map((e) => AttendanceRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<String> uploadSelfie(File imageFile) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(imageFile.path),
    });

    final response = await _client.post('/files', formData: formData);

    final data = response.data['data'] as Map<String, dynamic>;
    return data['id'] as String;
  }

  Future<List<AttendanceRecord>> getMonthlyHistory(
      String kangiderId, int year, int month) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0);

    final startStr = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
    final endStr = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';

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
  }
}
