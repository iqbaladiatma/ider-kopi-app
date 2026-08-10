import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import 'leave_model.dart';

class LeaveRepository {
  LeaveRepository._();
  static final LeaveRepository _instance = LeaveRepository._();
  factory LeaveRepository() => _instance;

  final ApiClient _client = ApiClient.instance;
  final List<LeaveRequest> _mockLeaves = [];

  List<LeaveRequest> _decodeList(dynamic responseData) {
    final data =
        (responseData as Map<String, dynamic>)['data'] as List<dynamic>;
    return data
        .map((item) => LeaveRequest.fromJson(
              (item as Map).cast<String, dynamic>(),
            ))
        .toList();
  }

  Future<LeaveRequest> submit(LeaveRequest request) async {
    if (AppConfig.useMockAuth) {
      final result = request.copyWith(
        id: request.clientRequestId,
        status: LeaveStatus.pending,
        createdAt: DateTime.now(),
      );
      _mockLeaves.add(result);
      return result;
    }
    final response = await _client.post(
      'attendance/leave-requests',
      body: request.toGoJson(),
    );
    final data = (response.data as Map<String, dynamic>)['data'] as Map;
    return LeaveRequest.fromJson(data.cast<String, dynamic>());
  }

  Future<List<LeaveRequest>> getMyLeaves(String userId) async {
    if (AppConfig.useMockAuth) {
      return _mockLeaves.where((leave) => leave.userId == userId).toList();
    }
    final response = await _client.get(
      'attendance/leave-requests/me',
    );
    return _decodeList(response.data);
  }

  Future<List<LeaveRequest>> getPendingLeaves() async {
    if (AppConfig.useMockAuth) {
      return _mockLeaves
          .where((leave) => leave.status == LeaveStatus.pending)
          .toList();
    }
    final response = await _client.get(
      'attendance/leave-requests',
      query: {'status': 'pending'},
    );
    return _decodeList(response.data);
  }

  Future<LeaveRequest> approve(
    String leaveId, {
    required String approverId,
    String? note,
  }) =>
      _setStatus(leaveId, LeaveStatus.approved, approverId: approverId);

  Future<LeaveRequest> reject(
    String leaveId, {
    required String approverId,
    String? note,
  }) =>
      _setStatus(leaveId, LeaveStatus.rejected, approverId: approverId);

  Future<LeaveRequest> _setStatus(
    String leaveId,
    LeaveStatus status, {
    required String approverId,
  }) async {
    if (AppConfig.useMockAuth) {
      final index = _mockLeaves.indexWhere((leave) => leave.id == leaveId);
      if (index < 0) throw StateError('Pengajuan tidak ditemukan');
      final result = _mockLeaves[index].copyWith(
        status: status,
        approverId: approverId,
        approvedAt: DateTime.now(),
      );
      _mockLeaves[index] = result;
      return result;
    }
    final action = status == LeaveStatus.approved ? 'approve' : 'reject';
    await _client.put(
      'attendance/leave-requests/$leaveId/$action',
      body: {'status': status.name},
    );
    return LeaveRequest(
      id: leaveId,
      userId: '',
      type: LeaveType.izin,
      startDate: DateTime.now(),
      endDate: DateTime.now(),
      status: status,
      approverId: approverId,
      approvedAt: DateTime.now(),
    );
  }

  Future<void> delete(String leaveId) async {
    if (AppConfig.useMockAuth) {
      _mockLeaves.removeWhere((leave) => leave.id == leaveId);
      return;
    }
    await _client.delete('attendance/leave-requests/me/$leaveId');
  }
}
