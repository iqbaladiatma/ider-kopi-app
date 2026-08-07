import 'package:camera/camera.dart';

import '../../features/attendance/data/attendance_model.dart';
import '../../features/attendance/data/attendance_repository.dart';
import 'attendance_data_source.dart';

/// Implementasi `AttendanceDataSource` untuk Directus API (existing).
///
/// Ini adalah thin wrapper di atas `AttendanceRepository` existing,
/// supaya bisa dipakai via interface tanpa rewrite besar.
class DirectusAttendanceDataSource implements AttendanceDataSource {
  final AttendanceRepository _repo;

  DirectusAttendanceDataSource(this._repo);

  @override
  Future<String> uploadSelfie(XFile file) => _repo.uploadSelfie(file);

  @override
  Future<AttendanceRecord> checkIn(CheckInRequest request) =>
      _repo.checkIn(request);

  @override
  Future<AttendanceRecord> checkOut(int recordId, CheckOutRequest request) =>
      _repo.checkOut(recordId, request);

  @override
  Future<AttendanceRecord?> getTodayAttendance(String kangiderId) =>
      _repo.getTodayAttendance(kangiderId);

  @override
  Future<List<AttendanceRecord>> getHistory(String kangiderId,
          {int limit = 30}) =>
      _repo.getHistory(kangiderId, limit: limit);

  @override
  Future<List<AttendanceRecord>> getMonthlyHistory(
          String kangiderId, int year, int month) =>
      _repo.getMonthlyHistory(kangiderId, year, month);
}
