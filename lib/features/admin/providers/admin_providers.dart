import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../attendance/data/attendance_model.dart';
import '../data/admin_repository.dart';
import '../data/admin_user_model.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository();
});

final usersProvider = FutureProvider<List<AdminUser>>((ref) async {
  final repo = ref.read(adminRepositoryProvider);
  return await repo.getUsers();
});

final userCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.read(adminRepositoryProvider);
  return await repo.getUserCount();
});

final rolesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.read(adminRepositoryProvider);
  return await repo.getRoles();
});

final todayAttendanceCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.read(adminRepositoryProvider);
  return await repo.getTodayAttendanceCount();
});

final adminAttendanceProvider =
    FutureProvider.family<List<AttendanceRecord>, ({String? date, String? employee})>(
        (ref, params) async {
  final repo = ref.read(adminRepositoryProvider);
  return await repo.getAllAttendance(
    dateFilter: params.date,
    employeeFilter: params.employee,
  );
});
