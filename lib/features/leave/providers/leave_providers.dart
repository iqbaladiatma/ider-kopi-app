import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_providers.dart';
import '../data/leave_model.dart';
import '../data/leave_repository.dart';

final leaveRepositoryProvider = Provider<LeaveRepository>((ref) {
  return LeaveRepository();
});

/// Daftar pengajuan izin milik user login.
final myLeavesProvider = FutureProvider<List<LeaveRequest>>((ref) async {
  final userAsync = ref.watch(currentUserProvider);
  final user = userAsync.valueOrNull;
  if (user == null) return [];

  final repo = ref.read(leaveRepositoryProvider);
  return repo.getMyLeaves(user.id);
});

/// Daftar pengajuan pending (untuk manager/admin).
final pendingLeavesProvider = FutureProvider<List<LeaveRequest>>((ref) async {
  // Hanya manager/admin yang boleh akses
  final role = await ref.watch(userRoleProvider.future);
  if (!const {
    'super_admin',
    'hr_admin',
    'manager',
  }.contains(role?.toLowerCase())) {
    return [];
  }

  final repo = ref.read(leaveRepositoryProvider);
  return repo.getPendingLeaves();
});

/// Submit pengajuan izin baru.
final submitLeaveProvider =
    FutureProvider.family<LeaveRequest, LeaveRequest>((ref, request) async {
  final repo = ref.read(leaveRepositoryProvider);
  final result = await repo.submit(request);
  ref.invalidate(myLeavesProvider);
  ref.invalidate(pendingLeavesProvider);
  return result;
});

/// Approve pengajuan (manager).
final approveLeaveProvider = FutureProvider.family<LeaveRequest,
    ({String leaveId, String approverId, String? note})>((ref, params) async {
  final repo = ref.read(leaveRepositoryProvider);
  final result = await repo.approve(
    params.leaveId,
    approverId: params.approverId,
    note: params.note,
  );
  ref.invalidate(pendingLeavesProvider);
  ref.invalidate(myLeavesProvider);
  return result;
});

/// Reject pengajuan (manager).
final rejectLeaveProvider = FutureProvider.family<LeaveRequest,
    ({String leaveId, String approverId, String? note})>((ref, params) async {
  final repo = ref.read(leaveRepositoryProvider);
  final result = await repo.reject(
    params.leaveId,
    approverId: params.approverId,
    note: params.note,
  );
  ref.invalidate(pendingLeavesProvider);
  ref.invalidate(myLeavesProvider);
  return result;
});
