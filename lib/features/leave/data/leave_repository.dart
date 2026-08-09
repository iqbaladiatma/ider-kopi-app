import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/config/api_provider.dart';
import '../../../core/config/app_config.dart';
import '../../../core/network/directus_client.dart';
import 'leave_model.dart';

/// Repository untuk pengajuan izin/sakit/cuti (v2.0).
///
/// Mendukung Directus & Go backend via `AppConfig.apiProvider`.
/// Untuk sekarang, pakai Directus endpoint `/items/leave_requests`.
class LeaveRepository {
  LeaveRepository._();
  static final LeaveRepository _instance = LeaveRepository._();
  factory LeaveRepository() => _instance;

  final DirectusClient _client = DirectusClient.instance;

  /// Mock data untuk development.
  static final List<Map<String, dynamic>> _mockLeaves = [
    {
      'id': 1,
      'user_id': 'usr-0012',
      'type': 'sakit',
      'start_date': '2026-08-03',
      'end_date': '2026-08-03',
      'reason': 'Demam',
      'status': 'approved',
      'approver_id': 'usr-admin-owner',
      'approved_at': '2026-08-02T10:00:00Z',
      'approver_note': 'Semoga lekas sembuh',
      'created_at': '2026-08-01T09:00:00Z',
    },
    {
      'id': 2,
      'user_id': 'usr-0012',
      'type': 'izin',
      'start_date': '2026-08-10',
      'end_date': '2026-08-10',
      'reason': 'Urusan keluarga',
      'status': 'pending',
      'created_at': '2026-08-05T08:00:00Z',
    },
    {
      'id': 3,
      'user_id': 'usr-0014',
      'type': 'cuti',
      'start_date': '2026-08-15',
      'end_date': '2026-08-17',
      'reason': 'Cuti tahunan',
      'status': 'pending',
      'created_at': '2026-08-06T14:00:00Z',
    },
  ];

  Future<String> _leaveEndpoint([String? suffix]) {
    final isDirectus = AppConfig.apiProvider == ApiProvider.directus;
    final base = isDirectus ? '/items/leave_requests' : '/api/v1/attendance/leave-requests';
    return Future.value(suffix != null ? '$base/$suffix' : base);
  }

  /// Submit pengajuan izin baru.
  Future<LeaveRequest> submit(LeaveRequest request) async {
    if (AppConfig.useMockAuth) {
      return _mockSubmit(request);
    }

    try {
      final endpoint = await _leaveEndpoint();
      final response = await _client.post(endpoint, body: request.toJson());
      final data = response.data['data'] as Map<String, dynamic>;
      return LeaveRequest.fromJson(data);
    } catch (_) {
      return _mockSubmit(request);
    }
  }

  LeaveRequest _mockSubmit(LeaveRequest request) {
    final newRecord = <String, dynamic>{
      ...request.toJson(),
      'id': DateTime.now().millisecondsSinceEpoch,
      'status': 'pending',
      'created_at': DateTime.now().toIso8601String(),
    };
    _mockLeaves.add(newRecord);
    return LeaveRequest.fromJson(newRecord);
  }

  /// Ambil semua pengajuan milik user tertentu.
  Future<List<LeaveRequest>> getMyLeaves(String userId) async {
    if (AppConfig.useMockAuth) {
      return _mockMyLeaves(userId);
    }

    try {
      final isDirectus = AppConfig.apiProvider == ApiProvider.directus;
      final endpoint = await _leaveEndpoint();
      final query = isDirectus
          ? {'filter[user_id][_eq]': userId, 'sort[]': '-created_at', 'limit': 50}
          : null;
      final response = await _client.get(endpoint, query: query);
      final data = response.data['data'] as List;
      return data.map((e) => LeaveRequest.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return _mockMyLeaves(userId);
    }
  }

  List<LeaveRequest> _mockMyLeaves(String userId) {
    final records = _mockLeaves
        .where((r) => r['user_id'] == userId)
        .toList()
      ..sort((a, b) => (b['created_at'] as String)
          .compareTo(a['created_at'] as String));
    return records.map((e) => LeaveRequest.fromJson(e)).toList();
  }

  /// Ambil semua pengajuan pending (untuk manager/admin).
  Future<List<LeaveRequest>> getPendingLeaves() async {
    if (AppConfig.useMockAuth) {
      return _mockPendingLeaves();
    }

    try {
      final isDirectus = AppConfig.apiProvider == ApiProvider.directus;
      final endpoint = await _leaveEndpoint();
      final query = isDirectus
          ? {'filter[status][_eq]': 'pending', 'sort[]': '-created_at', 'limit': 100}
          : null;
      final response = await _client.get(endpoint, query: query);
      final data = response.data['data'] as List;
      return data.map((e) => LeaveRequest.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return _mockPendingLeaves();
    }
  }

  List<LeaveRequest> _mockPendingLeaves() {
    final records = _mockLeaves
        .where((r) => r['status'] == 'pending')
        .toList()
      ..sort((a, b) => (b['created_at'] as String)
          .compareTo(a['created_at'] as String));
    return records.map((e) => LeaveRequest.fromJson(e)).toList();
  }

  /// Approve pengajuan (manager only).
  Future<LeaveRequest> approve(
    int leaveId, {
    required String approverId,
    String? note,
  }) async {
    if (AppConfig.useMockAuth) {
      return _mockApprove(leaveId, approverId: approverId, note: note);
    }

    try {
      final isDirectus = AppConfig.apiProvider == ApiProvider.directus;
      final endpoint = isDirectus
          ? await _leaveEndpoint('$leaveId')
          : await _leaveEndpoint('$leaveId/approve');
      final body = isDirectus
          ? {'status': 'approved', 'approver_id': approverId, 'approved_at': DateTime.now().toIso8601String(), if (note != null) 'approver_note': note}
          : {'note': note};
      final response = await _client.patch(endpoint, body: body);
      final data = response.data['data'] as Map<String, dynamic>;
      return LeaveRequest.fromJson(data);
    } catch (_) {
      return _mockApprove(leaveId, approverId: approverId, note: note);
    }
  }

  LeaveRequest _mockApprove(int leaveId, {required String approverId, String? note}) {
    final index = _mockLeaves.indexWhere((r) => r['id'] == leaveId);
    if (index == -1) throw Exception('Pengajuan tidak ditemukan');
    _mockLeaves[index]['status'] = 'approved';
    _mockLeaves[index]['approver_id'] = approverId;
    _mockLeaves[index]['approved_at'] = DateTime.now().toIso8601String();
    if (note != null) _mockLeaves[index]['approver_note'] = note;
    return LeaveRequest.fromJson(_mockLeaves[index]);
  }

  /// Reject pengajuan (manager only).
  Future<LeaveRequest> reject(
    int leaveId, {
    required String approverId,
    String? note,
  }) async {
    if (AppConfig.useMockAuth) {
      return _mockReject(leaveId, approverId: approverId, note: note);
    }

    try {
      final isDirectus = AppConfig.apiProvider == ApiProvider.directus;
      final endpoint = isDirectus
          ? await _leaveEndpoint('$leaveId')
          : await _leaveEndpoint('$leaveId/reject');
      final body = isDirectus
          ? {'status': 'rejected', 'approver_id': approverId, 'approved_at': DateTime.now().toIso8601String(), if (note != null) 'approver_note': note}
          : {'note': note};
      final response = await _client.patch(endpoint, body: body);
      final data = response.data['data'] as Map<String, dynamic>;
      return LeaveRequest.fromJson(data);
    } catch (_) {
      return _mockReject(leaveId, approverId: approverId, note: note);
    }
  }

  LeaveRequest _mockReject(int leaveId, {required String approverId, String? note}) {
    final index = _mockLeaves.indexWhere((r) => r['id'] == leaveId);
    if (index == -1) throw Exception('Pengajuan tidak ditemukan');
    _mockLeaves[index]['status'] = 'rejected';
    _mockLeaves[index]['approver_id'] = approverId;
    _mockLeaves[index]['approved_at'] = DateTime.now().toIso8601String();
    if (note != null) _mockLeaves[index]['approver_note'] = note;
    return LeaveRequest.fromJson(_mockLeaves[index]);
  }


  /// Hapus pengajuan (hanya jika masih pending).
  Future<void> delete(int leaveId) async {
    if (AppConfig.useMockAuth) {
      _mockLeaves.removeWhere((r) => r['id'] == leaveId);
      return;
    }

    final endpoint = await _leaveEndpoint('$leaveId');
    await _client.delete(endpoint);
  }
}
