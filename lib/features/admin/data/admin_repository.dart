import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/mock_data.dart';
import '../../attendance/data/attendance_model.dart';
import 'admin_user_model.dart';

class AdminRepository {
  AdminRepository._();
  static final AdminRepository _instance = AdminRepository._();
  factory AdminRepository() => _instance;

  final ApiClient _client = ApiClient.instance;

  List<dynamic> _list(dynamic responseData) =>
      ((responseData as Map<String, dynamic>)['data'] as List<dynamic>?) ??
      const [];

  Future<List<AdminUser>> getUsers({int limit = 100, int offset = 0}) async {
    if (AppConfig.useMockAuth) {
      return MockData.mockUsers.map(AdminUser.fromJson).toList();
    }
    final response = await _client.get('users');
    return _list(response.data)
        .map((item) => AdminUser.fromJson(
              (item as Map).cast<String, dynamic>(),
            ))
        .toList();
  }

  Future<AdminUser> getUser(String id) async {
    if (AppConfig.useMockAuth) {
      return AdminUser.fromJson(
        MockData.mockUsers.firstWhere((user) => user['id'] == id),
      );
    }
    final response = await _client.get('users/$id');
    final data = (response.data as Map<String, dynamic>)['data'] as Map;
    return AdminUser.fromJson(data.cast<String, dynamic>());
  }

  Future<AdminUser> createUser(CreateUserData data) async {
    if (AppConfig.useMockAuth) {
      final raw = <String, dynamic>{
        ...data.toJson(),
        'id': 'mock-${DateTime.now().microsecondsSinceEpoch}',
        'role': {'id': data.roleId, 'name': 'employee'},
        'is_active': true,
      };
      MockData.mockUsers.add(raw);
      return AdminUser.fromJson(raw);
    }
    final response = await _client.post('users', body: data.toJson());
    final result = (response.data as Map<String, dynamic>)['data'] as Map;
    return AdminUser.fromJson(result.cast<String, dynamic>());
  }

  Future<void> updateUser(String id, Map<String, dynamic> updates) async {
    if (AppConfig.useMockAuth) {
      final index = MockData.mockUsers.indexWhere((user) => user['id'] == id);
      if (index >= 0) MockData.mockUsers[index].addAll(updates);
      return;
    }
    final current = await getUser(id);
    await _client.put('users/$id', body: {
      'email': updates['email'] ?? current.email,
      if (updates['password'] != null) 'password': updates['password'],
      'role_id': updates['role_id'] ?? updates['role'] ?? current.roleId,
      'is_active': updates['is_active'] ?? current.isActive,
    });
  }

  Future<void> deleteUser(String id) async {
    if (AppConfig.useMockAuth) {
      MockData.mockUsers.removeWhere((user) => user['id'] == id);
      return;
    }
    await _client.delete('users/$id');
  }

  Future<List<Map<String, dynamic>>> getRoles() async {
    if (AppConfig.useMockAuth) return MockData.mockRoles;
    final response = await _client.get('roles');
    return _list(response.data)
        .map((item) => (item as Map).cast<String, dynamic>())
        .toList();
  }

  Future<List<MobileEmployeeAccount>> getEmployeeAccounts() async {
    final response = await _client.get('mobile-auth/accounts');
    return _list(response.data)
        .map((item) => MobileEmployeeAccount.fromJson(
              (item as Map).cast<String, dynamic>(),
            ))
        .toList();
  }

  Future<void> setEmployeeAccountActive(
    String employeeId, {
    required bool active,
  }) async {
    await _client.put(
      'mobile-auth/accounts/$employeeId/status',
      body: {'active': active},
    );
  }

  Future<void> resetEmployeePassword(
    String employeeId,
    String newPassword,
  ) async {
    await _client.post(
      'mobile-auth/accounts/$employeeId/reset-password',
      body: {'new_password': newPassword},
    );
  }

  Future<CoreEmployee> getEmployee(String employeeId) async {
    final response = await _client.get('employees/$employeeId');
    final data = (response.data as Map<String, dynamic>)['data'] as Map;
    return CoreEmployee.fromJson(data.cast<String, dynamic>());
  }

  Future<CoreEmployee> updateEmployee(
    String employeeId,
    Map<String, dynamic> updates,
  ) async {
    final response = await _client.put('employees/$employeeId', body: updates);
    final data = (response.data as Map<String, dynamic>)['data'] as Map;
    final employee = CoreEmployee.fromJson(data.cast<String, dynamic>());
    await _client.post('mobile-auth/accounts/$employeeId/sync-profile');
    return employee;
  }

  Future<int> getUserCount() async => (await getUsers()).length;

  Future<List<AttendanceRecord>> getAllAttendance({
    String? dateFilter,
    String? employeeFilter,
    int limit = 100,
  }) async {
    if (AppConfig.useMockAuth) {
      return MockData.mockAllAttendance
          .map(AttendanceRecord.fromJson)
          .where((record) =>
              dateFilter == null || record.tanggalAbsensi == dateFilter)
          .toList();
    }
    final response = await _client.get('attendance/logs', query: {
      if (dateFilter != null) 'date_from': dateFilter,
      if (dateFilter != null) 'date_to': dateFilter,
      if (employeeFilter != null) 'employee_id': employeeFilter,
      'page': 1,
      'page_size': limit,
    });
    return _list(response.data)
        .map((item) => AttendanceRecord.fromJson(
              (item as Map).cast<String, dynamic>(),
            ))
        .toList();
  }

  Future<int> getTodayAttendanceCount() async {
    final today = DateTime.now().toIso8601String().split('T').first;
    return (await getAllAttendance(dateFilter: today)).length;
  }
}
