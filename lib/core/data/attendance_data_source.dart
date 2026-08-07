import 'package:camera/camera.dart';

import '../../features/attendance/data/attendance_model.dart';

/// Abstract interface untuk data source absensi (v2.0).
///
/// Implementasi:
/// - `DirectusAttendanceDataSource` — existing Directus API
/// - `GoAttendanceDataSource` — Go backend custom
///
/// Dipakai oleh `AttendanceRepository` via dependency injection,
/// supaya app bisa switch backend tanpa rewrite.
abstract class AttendanceDataSource {
  /// Upload file selfie, return file ID.
  Future<String> uploadSelfie(XFile file);

  /// Submit check-in.
  Future<AttendanceRecord> checkIn(CheckInRequest request);

  /// Submit check-out untuk record [recordId].
  Future<AttendanceRecord> checkOut(int recordId, CheckOutRequest request);

  /// Ambil record absensi hari ini untuk kangider tertentu.
  Future<AttendanceRecord?> getTodayAttendance(String kangiderId);

  /// Ambil riwayat absensi (default 30 hari terakhir).
  Future<List<AttendanceRecord>> getHistory(String kangiderId, {int limit = 30});

  /// Ambil riwayat absensi bulanan.
  Future<List<AttendanceRecord>> getMonthlyHistory(
    String kangiderId,
    int year,
    int month,
  );
}

/// Abstract interface untuk data source auth.
abstract class AuthDataSource {
  /// Login dengan email & password, return access token + refresh token.
  Future<({String accessToken, String refreshToken, Map<String, dynamic> user})>
      login(String email, String password);

  /// Refresh access token pakai refresh token.
  Future<String> refreshToken(String refreshToken);

  /// Logout (invalidate refresh token di server).
  Future<void> logout(String refreshToken);

  /// Ambil profil user saat ini.
  Future<Map<String, dynamic>> getCurrentUser(String accessToken);
}

/// Abstract interface untuk data source outlet.
abstract class OutletDataSource {
  /// Ambil semua outlet aktif.
  Future<List<Map<String, dynamic>>> getOutlets();
}

/// Abstract interface untuk data source admin.
abstract class AdminDataSource {
  /// Ambil semua users (untuk admin panel).
  Future<List<Map<String, dynamic>>> getUsers();

  /// Ambil semua absensi (untuk admin panel).
  Future<List<Map<String, dynamic>>> getAllAttendance({
    String? startDate,
    String? endDate,
    String? kangiderId,
  });

  /// Update user (role, status, dll).
  Future<Map<String, dynamic>> updateUser(
    String userId,
    Map<String, dynamic> updates,
  );
}
