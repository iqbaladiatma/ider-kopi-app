import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/attendance/data/attendance_repository.dart';
import '../data/attendance_data_source.dart';

final attendanceDataSourceProvider = Provider<AttendanceDataSource>((ref) {
  return AttendanceRepository();
});

final attendanceRepositoryV2Provider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepository();
});
