import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/brand_provider.dart';
import '../../attendance/data/attendance_model.dart';
import '../data/admin_repository.dart';
import '../data/admin_user_model.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository();
});

final usersProvider = FutureProvider<List<AdminUser>>((ref) async {
  final repo = ref.read(adminRepositoryProvider);
  final activeBrand = ref.watch(activeBrandProvider);
  final allUsers = await repo.getUsers();

  if (activeBrand.outletFilter == null) {
    return allUsers;
  }

  final filter = activeBrand.outletFilter!.toLowerCase();
  return allUsers.where((u) {
    final userOutlet = (u.outlet ?? '').toLowerCase();
    return userOutlet.contains(filter);
  }).toList();
});

final userCountProvider = FutureProvider<int>((ref) async {
  final users = await ref.watch(employeeAccountsProvider.future);
  return users.where((u) => u.employeeActive).length;
});

final employeeAccountsProvider =
    FutureProvider<List<MobileEmployeeAccount>>((ref) async {
  final repo = ref.read(adminRepositoryProvider);
  final activeBrand = ref.watch(activeBrandProvider);
  final accounts = await repo.getEmployeeAccounts();
  if (activeBrand.outletFilter == null) return accounts;
  final filter = activeBrand.outletFilter!.toLowerCase();
  return accounts
      .where((account) => account.brand.toLowerCase().contains(filter))
      .toList();
});

final rolesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.read(adminRepositoryProvider);
  return await repo.getRoles();
});

final todayAttendanceCountProvider = FutureProvider<int>((ref) async {
  final today = DateTime.now().toIso8601String().split('T').first;
  final records = await ref.watch(
    adminAttendanceProvider((date: today, employee: null)).future,
  );
  return records.where((r) => r.masuk != null).length;
});

final adminAttendanceProvider = FutureProvider.family<List<AttendanceRecord>,
    ({String? date, String? employee})>((ref, params) async {
  final repo = ref.read(adminRepositoryProvider);
  final activeBrand = ref.watch(activeBrandProvider);

  final records = await repo.getAllAttendance(
    dateFilter: params.date,
    employeeFilter: params.employee,
  );

  if (activeBrand.outletFilter == null) {
    return records;
  }

  final filter = activeBrand.outletFilter!.toLowerCase();
  return records.where((r) {
    final outletStr = (r.outlet ?? '').toLowerCase();
    return outletStr.contains(filter);
  }).toList();
});
