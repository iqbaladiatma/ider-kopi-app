import '../../features/auth/data/auth_model.dart';

class MockData {
  MockData._();

  // Mock credentials untuk testing
  // Admin: admin@iderkopi.id / admin123
  // User:  user@iderkopi.id / user123
  static const String adminEmail = 'admin@iderkopi.id';
  static const String adminPassword = 'admin123';
  static const String userEmail = 'user@iderkopi.id';
  static const String userPassword = 'user123';

  static const Map<String, String> _credentials = {
    adminEmail: adminPassword,
    userEmail: userPassword,
  };

  static bool validate(String email, String password) {
    return _credentials[email] == password;
  }

  static bool isAdmin(String email) => email == adminEmail;

  static UserProfile getUser(String email) {
    if (email == adminEmail) {
      return UserProfile(
        id: 'mock-admin-id',
        email: adminEmail,
        firstName: 'Admin',
        lastName: 'IderKopi',
        kangiderId: null,
        kangiderNama: null,
        outlet: 'HQ',
        roleId: 'mock-admin-role',
        roleName: 'Admin',
      );
    }
    return UserProfile(
      id: 'mock-user-id',
      email: userEmail,
      firstName: 'Budi',
      lastName: 'Santoso',
      kangiderId: 'KANG-001',
      kangiderNama: 'Budi Santoso',
      outlet: 'IderKopi Cibiru',
      roleId: 'mock-user-role',
      roleName: 'User',
    );
  }

  // Mock attendance data for user testing
  static List<Map<String, dynamic>> mockAttendanceRecords = [
    {
      'id': 'mock-att-1',
      'tanggal': '2026-07-26',
      'jam_masuk': '08:15:00',
      'jam_pulang': null,
      'status': 'tepat_waktu',
      'latitude': -6.123456,
      'longitude': 106.789012,
      'selfie_file_id': null,
      'kangider_id': 'KANG-001',
    },
    {
      'id': 'mock-att-2',
      'tanggal': '2026-07-25',
      'jam_masuk': '08:30:00',
      'jam_pulang': '17:05:00',
      'status': 'tepat_waktu',
      'latitude': -6.123456,
      'longitude': 106.789012,
      'selfie_file_id': null,
      'kangider_id': 'KANG-001',
    },
    {
      'id': 'mock-att-3',
      'tanggal': '2026-07-24',
      'jam_masuk': '09:15:00',
      'jam_pulang': '17:10:00',
      'status': 'terlambat',
      'latitude': -6.123456,
      'longitude': 106.789012,
      'selfie_file_id': null,
      'kangider_id': 'KANG-001',
    },
  ];

  // Mock users for admin dashboard
  static List<Map<String, dynamic>> mockUsers = [
    {
      'id': 'mock-user-1',
      'email': 'user@iderkopi.id',
      'first_name': 'Budi',
      'last_name': 'Santoso',
      'kangider_id': 'KANG-001',
      'kangider_nama': 'Budi Santoso',
      'outlet': 'IderKopi Cibiru',
      'status': 'active',
      'role': {'id': 'mock-user-role', 'name': 'User'},
    },
    {
      'id': 'mock-user-2',
      'email': 'siti@iderkopi.id',
      'first_name': 'Siti',
      'last_name': 'Nurhaliza',
      'kangider_id': 'KANG-002',
      'kangider_nama': 'Siti Nurhaliza',
      'outlet': 'IderKopi Cicaheum',
      'status': 'active',
      'role': {'id': 'mock-user-role', 'name': 'User'},
    },
    {
      'id': 'mock-user-3',
      'email': 'andi@iderkopi.id',
      'first_name': 'Andi',
      'last_name': 'Wijaya',
      'kangider_id': 'KANG-003',
      'kangider_nama': 'Andi Wijaya',
      'outlet': 'IderKopi Cibiru',
      'status': 'active',
      'role': {'id': 'mock-user-role', 'name': 'User'},
    },
    {
      'id': 'mock-admin-id',
      'email': 'admin@iderkopi.id',
      'first_name': 'Admin',
      'last_name': 'IderKopi',
      'kangider_id': null,
      'kangider_nama': null,
      'outlet': 'HQ',
      'status': 'active',
      'role': {'id': 'mock-admin-role', 'name': 'Admin'},
    },
  ];

  // Mock attendance data for all employees (admin view)
  static List<Map<String, dynamic>> mockAllAttendance = [
    {
      'id': 'mock-att-all-1',
      'tanggal_absensi': '2026-07-26',
      'masuk': '08:15:00',
      'pulang': null,
      'kangider': 'KANG-001',
      'kangider_nama': 'Budi Santoso',
      'outlet': 'IderKopi Cibiru',
      'keterangan': null,
      'latitude': -6.123456,
      'longitude': 106.789012,
    },
    {
      'id': 'mock-att-all-2',
      'tanggal_absensi': '2026-07-26',
      'masuk': '08:45:00',
      'pulang': null,
      'kangider': 'KANG-002',
      'kangider_nama': 'Siti Nurhaliza',
      'outlet': 'IderKopi Cicaheum',
      'keterangan': null,
      'latitude': -6.123456,
      'longitude': 106.789012,
    },
    {
      'id': 'mock-att-all-3',
      'tanggal_absensi': '2026-07-26',
      'masuk': '09:15:00',
      'pulang': null,
      'kangider': 'KANG-003',
      'kangider_nama': 'Andi Wijaya',
      'outlet': 'IderKopi Cibiru',
      'keterangan': null,
      'latitude': -6.123456,
      'longitude': 106.789012,
    },
    {
      'id': 'mock-att-all-4',
      'tanggal_absensi': '2026-07-25',
      'masuk': '08:05:00',
      'pulang': '17:00:00',
      'kangider': 'KANG-001',
      'kangider_nama': 'Budi Santoso',
      'outlet': 'IderKopi Cibiru',
      'keterangan': null,
      'latitude': -6.123456,
      'longitude': 106.789012,
    },
    {
      'id': 'mock-att-all-5',
      'tanggal_absensi': '2026-07-25',
      'masuk': '08:30:00',
      'pulang': '17:15:00',
      'kangider': 'KANG-002',
      'kangider_nama': 'Siti Nurhaliza',
      'outlet': 'IderKopi Cicaheum',
      'keterangan': null,
      'latitude': -6.123456,
      'longitude': 106.789012,
    },
    {
      'id': 'mock-att-all-6',
      'tanggal_absensi': '2026-07-25',
      'masuk': null,
      'pulang': null,
      'kangider': 'KANG-003',
      'kangider_nama': 'Andi Wijaya',
      'outlet': 'IderKopi Cibiru',
      'keterangan': 'Izin sakit',
      'latitude': null,
      'longitude': null,
    },
    {
      'id': 'mock-att-all-7',
      'tanggal_absensi': '2026-07-24',
      'masuk': '09:20:00',
      'pulang': '17:30:00',
      'kangider': 'KANG-001',
      'kangider_nama': 'Budi Santoso',
      'outlet': 'IderKopi Cibiru',
      'keterangan': null,
      'latitude': -6.123456,
      'longitude': 106.789012,
    },
    {
      'id': 'mock-att-all-8',
      'tanggal_absensi': '2026-07-24',
      'masuk': '08:10:00',
      'pulang': '17:05:00',
      'kangider': 'KANG-002',
      'kangider_nama': 'Siti Nurhaliza',
      'outlet': 'IderKopi Cicaheum',
      'keterangan': null,
      'latitude': -6.123456,
      'longitude': 106.789012,
    },
    {
      'id': 'mock-att-all-9',
      'tanggal_absensi': '2026-07-24',
      'masuk': '08:50:00',
      'pulang': '17:20:00',
      'kangider': 'KANG-003',
      'kangider_nama': 'Andi Wijaya',
      'outlet': 'IderKopi Cibiru',
      'keterangan': null,
      'latitude': -6.123456,
      'longitude': 106.789012,
    },
    {
      'id': 'mock-att-all-10',
      'tanggal_absensi': '2026-07-23',
      'masuk': '08:00:00',
      'pulang': '17:00:00',
      'kangider': 'KANG-001',
      'kangider_nama': 'Budi Santoso',
      'outlet': 'IderKopi Cibiru',
      'keterangan': null,
      'latitude': -6.123456,
      'longitude': 106.789012,
    },
    {
      'id': 'mock-att-all-11',
      'tanggal_absensi': '2026-07-23',
      'masuk': '08:20:00',
      'pulang': '17:10:00',
      'kangider': 'KANG-002',
      'kangider_nama': 'Siti Nurhaliza',
      'outlet': 'IderKopi Cicaheum',
      'keterangan': null,
      'latitude': -6.123456,
      'longitude': 106.789012,
    },
    {
      'id': 'mock-att-all-12',
      'tanggal_absensi': '2026-07-23',
      'masuk': '09:30:00',
      'pulang': '17:45:00',
      'kangider': 'KANG-003',
      'kangider_nama': 'Andi Wijaya',
      'outlet': 'IderKopi Cibiru',
      'keterangan': null,
      'latitude': -6.123456,
      'longitude': 106.789012,
    },
  ];

  static List<Map<String, dynamic>> mockRoles = [
    {'id': 'mock-admin-role', 'name': 'Admin'},
    {'id': 'mock-user-role', 'name': 'User'},
  ];
}
