import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/api_provider.dart';
import '../config/app_config.dart';
import '../data/attendance_data_source.dart';
import '../data/directus_attendance_data_source.dart';
import '../data/go_attendance_data_source.dart';
import '../network/auth_interceptor.dart';
import '../storage/secure_storage.dart';
import '../../features/attendance/data/attendance_repository.dart';

/// Provider untuk Dio yang dipakai Go backend (terpisah dari DirectusClient).
final goDioProvider = Provider<Dio>((ref) {
  final storage = SecureStorage();
  final dio = Dio(BaseOptions(
    baseUrl: AppConfig.goApiBaseUrl,
    connectTimeout: AppConfig.connectTimeout,
    receiveTimeout: AppConfig.receiveTimeout,
    headers: {'Content-Type': 'application/json'},
  ));

  dio.interceptors.add(AuthInterceptor(storage: storage, dio: dio));

  if (kDebugMode) {
    dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: false,
      responseBody: true,
      error: true,
    ));
  }

  return dio;
});

/// Provider untuk `AttendanceDataSource` aktif (Directus atau Go).
///
/// Switch otomatis berdasarkan `AppConfig.apiProvider`.
final attendanceDataSourceProvider = Provider<AttendanceDataSource>((ref) {
  switch (AppConfig.apiProvider) {
    case ApiProvider.directus:
    case ApiProvider.customWeb:
      return DirectusAttendanceDataSource(AttendanceRepository());
    case ApiProvider.goBackend:
      return GoAttendanceDataSource(
        dio: ref.read(goDioProvider),
        storage: SecureStorage(),
      );
  }

});

/// Provider untuk `AttendanceRepository` yang pakai data source aktif.
///
/// NOTE: Untuk backward compatibility, `AttendanceRepository` existing
/// tetap dipakai langsung di banyak tempat. Refactor bertahap.
/// Provider ini disediakan untuk feature baru yang mau pakai interface.
final attendanceRepositoryV2Provider = Provider<AttendanceRepository>((ref) {
  // Untuk sekarang, tetap return singleton existing.
  // Setelah full migration, ini akan pakai data source dari provider.
  return AttendanceRepository();
});
