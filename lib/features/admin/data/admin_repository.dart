import '../../../core/config/app_config.dart';
import '../../../core/network/directus_client.dart';
import '../../../core/utils/mock_data.dart';
import '../../attendance/data/attendance_model.dart';
import 'admin_user_model.dart';

class AdminRepository {
  AdminRepository._internal();
  static final AdminRepository _instance = AdminRepository._internal();
  factory AdminRepository() => _instance;

  final DirectusClient _client = DirectusClient.instance;

  Future<List<AdminUser>> getUsers({int limit = 100, int offset = 0}) async {
    if (AppConfig.useMockAuth) {
      return MockData.mockUsers
          .map((e) => AdminUser.fromJson(e))
          .toList();
    }

    final response = await _client.get('/users', query: {
      'fields': 'id,email,first_name,last_name,kangider_id,kangider_nama,outlet,status,created_at,role.id,role.name',
      'limit': limit.toString(),
      'offset': offset.toString(),
      'sort': '-created_at',
    });

    final data = response.data['data'] as List;
    return data.map((e) => AdminUser.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<AdminUser> getUser(String id) async {
    if (AppConfig.useMockAuth) {
      final user = MockData.mockUsers.firstWhere((u) => u['id'] == id);
      return AdminUser.fromJson(user);
    }

    final response = await _client.get('/users/$id', query: {
      'fields': 'id,email,first_name,last_name,kangider_id,kangider_nama,outlet,status,created_at,role.id,role.name',
    });

    final data = response.data['data'] as Map<String, dynamic>;
    return AdminUser.fromJson(data);
  }

  Future<AdminUser> createUser(CreateUserData data) async {
    if (AppConfig.useMockAuth) {
      final newUser = <String, dynamic>{
        'id': 'mock-user-${DateTime.now().millisecondsSinceEpoch}',
        'email': data.email,
        'first_name': data.firstName,
        'last_name': data.lastName,
        'kangider_id': null,
        'kangider_nama': data.kangiderNama,
        'outlet': data.outlet,
        'status': 'active',
        'role': {'id': data.roleId, 'name': 'User'},
      };
      MockData.mockUsers.add(newUser);
      return AdminUser.fromJson(newUser);
    }

    final response = await _client.post('/users', body: data.toJson());
    final result = response.data['data'] as Map<String, dynamic>;
    return AdminUser.fromJson(result);
  }

  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    if (AppConfig.useMockAuth) {
      final index = MockData.mockUsers.indexWhere((u) => u['id'] == id);
      if (index != -1) {
        MockData.mockUsers[index].addAll(data);
      }
      return;
    }

    await _client.patch('/users/$id', body: data);
  }

  Future<void> deleteUser(String id) async {
    if (AppConfig.useMockAuth) {
      MockData.mockUsers.removeWhere((u) => u['id'] == id);
      return;
    }

    await _client.delete('/users/$id');
  }

  Future<List<Map<String, dynamic>>> getRoles() async {
    if (AppConfig.useMockAuth) {
      return MockData.mockRoles;
    }

    final response = await _client.get('/roles', query: {
      'fields': 'id,name',
    });

    final data = response.data['data'] as List;
    return data
        .map((e) => {
              'id': e['id']?.toString() ?? '',
              'name': e['name']?.toString() ?? '',
            })
        .toList();
  }

  Future<int> getUserCount() async {
    if (AppConfig.useMockAuth) {
      return MockData.mockUsers
          .where((u) => u['role']?['name']?.toString().toLowerCase() != 'admin')
          .length;
    }

    final response = await _client.get('/users', query: {
      'aggregate': 'count',
    });

    final data = response.data['data'] as List;
    if (data.isNotEmpty) {
      final count = data[0]['count'];
      if (count is int) return count;
      return int.tryParse(count.toString()) ?? 0;
    }
    return 0;
  }

  Future<List<AttendanceRecord>> getAllAttendance({
    String? dateFilter,
    String? employeeFilter,
    int limit = 100,
  }) async {
    if (AppConfig.useMockAuth) {
      var records = MockData.mockAllAttendance.map((e) {
        final json = Map<String, dynamic>.from(e);
        return AttendanceRecord.fromJson(json);
      }).toList();

      if (dateFilter != null && dateFilter.isNotEmpty) {
        records = records.where((r) => r.tanggalAbsensi == dateFilter).toList();
      }
      if (employeeFilter != null && employeeFilter.isNotEmpty) {
        records = records
            .where((r) =>
                (r.kangider ?? '')
                    .toLowerCase()
                    .contains(employeeFilter.toLowerCase()) ||
                (MockData.mockAllAttendance.firstWhere(
                  (m) => m['id'] == r.id?.toString(),
                  orElse: () => {},
                )['kangider_nama'] ?? '')
                    .toLowerCase()
                    .contains(employeeFilter.toLowerCase()))
            .toList();
      }

      records.sort((a, b) => b.tanggalAbsensi.compareTo(a.tanggalAbsensi));
      return records.take(limit).toList();
    }

    final query = <String, dynamic>{
      'sort[]': '-tanggal_absensi,-masuk',
      'limit': limit.toString(),
    };

    if (dateFilter != null && dateFilter.isNotEmpty) {
      query['filter[tanggal_absensi][_eq]'] = dateFilter;
    }
    if (employeeFilter != null && employeeFilter.isNotEmpty) {
      query['filter[kangider_nama][_contains]'] = employeeFilter;
    }

    final response = await _client.get('/items/absensi_ider', query: query);
    final data = response.data['data'] as List;
    return data
        .map((e) => AttendanceRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<int> getTodayAttendanceCount() async {
    if (AppConfig.useMockAuth) {
      final today = DateTime.now();
      final todayStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      return MockData.mockAllAttendance
          .where((a) =>
              a['tanggal_absensi'] == todayStr && a['masuk'] != null)
          .length;
    }

    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final response = await _client.get('/items/absensi_ider', query: {
      'filter[tanggal_absensi][_eq]': todayStr,
      'filter[masuk][_nnull]': 'true',
      'aggregate': 'count',
    });

    final data = response.data['data'] as List;
    if (data.isNotEmpty) {
      final count = data[0]['count'];
      if (count is int) return count;
      return int.tryParse(count.toString()) ?? 0;
    }
    return 0;
  }
}
