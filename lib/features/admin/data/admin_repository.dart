import '../../../core/config/api_provider.dart';
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

  /// Ambil seluruh data karyawan dari API (/api/v1/employees atau Directus /users)
  Future<List<AdminUser>> getUsers({int limit = 100, int offset = 0}) async {
    if (AppConfig.useMockAuth) {
      return MockData.mockUsers.map((e) => AdminUser.fromJson(e)).toList();
    }

    final isDirectus = AppConfig.apiProvider == ApiProvider.directus;

    if (!isDirectus) {
      try {
        final response = await _client.get('/api/v1/employees');
        final data = response.data['data'] as List;
        return data.map((e) {
          final map = e as Map<String, dynamic>;
          final dept = map['department'] is Map ? map['department']['name']?.toString() : null;
          return AdminUser(
            id: map['id']?.toString() ?? '',
            email: map['email']?.toString() ?? 'karyawan@iderkopi.id',
            firstName: map['full_name']?.toString(),
            kangiderId: map['employee_code']?.toString() ?? map['external_kangider_id']?.toString(),
            kangiderNama: map['full_name']?.toString(),
            outlet: dept ?? 'IderKopi',
            status: (map['is_active'] == true) ? 'active' : 'inactive',
            roleName: map['position'] is Map ? map['position']['name']?.toString() : 'Karyawan',
          );
        }).toList();
      } catch (_) {
        return MockData.mockUsers.map((e) => AdminUser.fromJson(e)).toList();
      }
    }

    try {
      // 1. Coba ambil dari /users (Users collection di Directus)
      final response = await _client.get('/users', query: {
        'fields': 'id,email,first_name,last_name,kangider_id,kangider_nama,outlet,status,created_at,role.id,role.name',
        'limit': limit.toString(),
        'offset': offset.toString(),
        'sort': '-created_at',
      });

      final data = response.data['data'] as List;
      final users = data.map((e) => AdminUser.fromJson(e as Map<String, dynamic>)).toList();

      if (users.isNotEmpty) {
        return users;
      }
    } catch (_) {
      // Jika /users error, coba endpoint alternatif Directus
    }

    try {
      // 2. Coba endpoint alternatif Directus (/items/karyawan atau /items/kangider)
      final response = await _client.get('/items/karyawan', query: {
        'limit': limit.toString(),
        'offset': offset.toString(),
      });

      final data = response.data['data'] as List;
      return data.map((e) {
        final map = e as Map<String, dynamic>;
        return AdminUser(
          id: map['id']?.toString() ?? 'usr-${DateTime.now().millisecondsSinceEpoch}',
          email: map['email']?.toString() ?? 'karyawan@iderkopi.id',
          firstName: map['nama']?.toString() ?? map['first_name']?.toString(),
          lastName: map['last_name']?.toString(),
          kangiderId: map['kangider_id']?.toString() ?? map['nip']?.toString(),
          kangiderNama: map['nama']?.toString() ?? map['kangider_nama']?.toString(),
          outlet: map['outlet']?.toString() ?? 'Malioboro',
          status: map['status']?.toString() ?? 'active',
          roleName: map['role']?.toString() ?? 'Karyawan',
        );
      }).toList();
    } catch (e) {
      // Fallback jika API belum aktif atau offline saat testing
      return MockData.mockUsers.map((e) => AdminUser.fromJson(e)).toList();
    }
  }

  Future<AdminUser> getUser(String id) async {
    if (AppConfig.useMockAuth) {
      final user = MockData.mockUsers.firstWhere((u) => u['id'] == id, orElse: () => MockData.mockUsers.first);
      return AdminUser.fromJson(user);
    }

    try {
      final response = await _client.get('/users/$id', query: {
        'fields': 'id,email,first_name,last_name,kangider_id,kangider_nama,outlet,status,created_at,role.id,role.name',
      });

      final data = response.data['data'] as Map<String, dynamic>;
      return AdminUser.fromJson(data);
    } catch (e) {
      final user = MockData.mockUsers.firstWhere((u) => u['id'] == id, orElse: () => MockData.mockUsers.first);
      return AdminUser.fromJson(user);
    }
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
        'role': {'id': data.roleId, 'name': 'Karyawan'},
      };
      MockData.mockUsers.add(newUser);
      return AdminUser.fromJson(newUser);
    }

    try {
      final response = await _client.post('/users', body: data.toJson());
      final result = response.data['data'] as Map<String, dynamic>;
      return AdminUser.fromJson(result);
    } catch (e) {
      final newUser = <String, dynamic>{
        'id': 'user-${DateTime.now().millisecondsSinceEpoch}',
        'email': data.email,
        'first_name': data.firstName,
        'last_name': data.lastName,
        'kangider_id': null,
        'kangider_nama': data.kangiderNama,
        'outlet': data.outlet,
        'status': 'active',
        'role': {'id': data.roleId, 'name': 'Karyawan'},
      };
      MockData.mockUsers.add(newUser);
      return AdminUser.fromJson(newUser);
    }
  }

  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    if (AppConfig.useMockAuth) {
      final index = MockData.mockUsers.indexWhere((u) => u['id'] == id);
      if (index != -1) {
        MockData.mockUsers[index].addAll(data);
      }
      return;
    }

    try {
      await _client.patch('/users/$id', body: data);
    } catch (_) {
      final index = MockData.mockUsers.indexWhere((u) => u['id'] == id);
      if (index != -1) {
        MockData.mockUsers[index].addAll(data);
      }
    }
  }

  Future<void> deleteUser(String id) async {
    if (AppConfig.useMockAuth) {
      MockData.mockUsers.removeWhere((u) => u['id'] == id);
      return;
    }

    try {
      await _client.delete('/users/$id');
    } catch (_) {
      MockData.mockUsers.removeWhere((u) => u['id'] == id);
    }
  }

  Future<List<Map<String, dynamic>>> getRoles() async {
    if (AppConfig.useMockAuth) {
      return MockData.mockRoles;
    }

    try {
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
    } catch (_) {
      return MockData.mockRoles;
    }
  }

  Future<int> getUserCount() async {
    final users = await getUsers();
    return users.where((u) => u.roleName?.toLowerCase() != 'admin').length;
  }

  Future<List<AttendanceRecord>> getAllAttendance({
    String? dateFilter,
    String? employeeFilter,
    int limit = 100,
  }) async {
    if (!AppConfig.useMockAuth) {
      try {
        final queryParams = <String, String>{
          'limit': limit.toString(),
          'sort': '-tanggal_absensi',
        };

        if (dateFilter != null && dateFilter.isNotEmpty) {
          queryParams['filter[tanggal_absensi][_eq]'] = dateFilter;
        }

        final response = await _client.get('/items/absensi', query: queryParams);
        final data = response.data['data'] as List;
        return data.map((e) => AttendanceRecord.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {
        // Fallback jika API bermasalah
      }
    }

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
              (r.kangider ?? '').toLowerCase().contains(employeeFilter.toLowerCase()) ||
              (MockData.mockAllAttendance.firstWhere(
                (m) => m['id'] == r.id?.toString(),
                orElse: () => {},
              )['kangider_nama'] ?? '')
                  .toString()
                  .toLowerCase()
                  .contains(employeeFilter.toLowerCase()))
          .toList();
    }

    return records;
  }

  Future<int> getTodayAttendanceCount() async {
    final today = DateTime.now().toString().split(' ').first;
    final records = await getAllAttendance(dateFilter: today);
    return records.length;
  }
}
