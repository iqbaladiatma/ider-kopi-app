import '../../features/auth/data/auth_model.dart';

class MockData {
  MockData._();

  static const String defaultPassword = 'iderkopiku123';

  // Seeded User Profiles (KangIder -> Otomatis ke Outlet IderKopi)
  static final List<UserProfile> _seededProfiles = [
    UserProfile(
      id: 'usr-admin-owner',
      email: 'ider@iderkopi.id',
      firstName: 'Kang',
      lastName: 'Ider',
      kangiderId: null,
      kangiderNama: 'Kang Ider (Owner)',
      outlet: 'IderKopi - HQ / Semua Outlet',
      roleId: 'role-admin',
      roleName: 'Admin',
    ),
    UserProfile(
      id: 'usr-dewi-anjani',
      email: 'dewi@iderkopi.id',
      firstName: 'Dewi',
      lastName: 'Anjani',
      kangiderId: 'IDR-0012',
      kangiderNama: 'Dewi Anjani',
      outlet: 'IderKopi - Malioboro',
      roleId: 'role-user',
      roleName: 'Karyawan',
    ),
    UserProfile(
      id: 'usr-rangga-pradana',
      email: 'rangga@iderkopi.id',
      firstName: 'Rangga',
      lastName: 'Pradana',
      kangiderId: 'IDR-0014',
      kangiderNama: 'Rangga Pradana',
      outlet: 'IderKopi - Malioboro',
      roleId: 'role-user',
      roleName: 'Karyawan',
    ),
    UserProfile(
      id: 'usr-siti-nuraini',
      email: 'siti@iderkopi.id',
      firstName: 'Siti',
      lastName: 'Nuraini',
      kangiderId: 'IDR-0015',
      kangiderNama: 'Siti Nuraini',
      outlet: 'IderKopi - Kotabaru',
      roleId: 'role-user',
      roleName: 'Karyawan',
    ),
    UserProfile(
      id: 'usr-nadia-aulia',
      email: 'nadia@iderkopi.id',
      firstName: 'Nadia',
      lastName: 'Aulia',
      kangiderId: 'IDR-0018',
      kangiderNama: 'Nadia Aulia',
      outlet: 'IderKopi - Sudirman',
      roleId: 'role-user',
      roleName: 'Karyawan',
    ),
    UserProfile(
      id: 'usr-bagas-firmansyah',
      email: 'bagas@iderkopi.id',
      firstName: 'Bagas',
      lastName: 'Firmansyah',
      kangiderId: 'IDR-0021',
      kangiderNama: 'Bagas Firmansyah',
      outlet: 'IderKopi - Kotabaru',
      roleId: 'role-user',
      roleName: 'Karyawan',
    ),
    UserProfile(
      id: 'usr-yoga-kurniawan',
      email: 'yoga@iderkopi.id',
      firstName: 'Yoga',
      lastName: 'Kurniawan',
      kangiderId: 'IDR-0024',
      kangiderNama: 'Yoga Kurniawan',
      outlet: 'IderKopi - Sudirman',
      roleId: 'role-user',
      roleName: 'Karyawan',
    ),
  ];

  static bool validate(String email, String password) {
    if (password == defaultPassword || password == 'admin123' || password == 'user123') {
      return true;
    }
    return true;
  }

  static bool isAdmin(String email) {
    final cleanEmail = email.trim().toLowerCase();
    return cleanEmail == 'ider@iderkopi.id' ||
        cleanEmail == 'admin@iderkopi.id' ||
        cleanEmail.contains('admin');
  }

  static UserProfile getUser(String email) {
    final cleanEmail = email.trim().toLowerCase();
    final found = _seededProfiles.firstWhere(
      (p) => p.email.toLowerCase() == cleanEmail,
      orElse: () => isAdmin(email) ? _seededProfiles.first : _seededProfiles[1],
    );
    return found;
  }

  // Seeded List for Admin Dashboard / User Management
  static List<Map<String, dynamic>> mockUsers = [
    {
      'id': 'usr-dewi-anjani',
      'email': 'dewi@iderkopi.id',
      'first_name': 'Dewi',
      'last_name': 'Anjani',
      'kangider_id': 'IDR-0012',
      'kangider_nama': 'Dewi Anjani',
      'outlet': 'IderKopi - Malioboro',
      'status': 'active',
      'role': {'id': 'role-user', 'name': 'Karyawan'},
    },
    {
      'id': 'usr-rangga-pradana',
      'email': 'rangga@iderkopi.id',
      'first_name': 'Rangga',
      'last_name': 'Pradana',
      'kangider_id': 'IDR-0014',
      'kangider_nama': 'Rangga Pradana',
      'outlet': 'IderKopi - Malioboro',
      'status': 'active',
      'role': {'id': 'role-user', 'name': 'Karyawan'},
    },
    {
      'id': 'usr-siti-nuraini',
      'email': 'siti@iderkopi.id',
      'first_name': 'Siti',
      'last_name': 'Nuraini',
      'kangider_id': 'IDR-0015',
      'kangider_nama': 'Siti Nuraini',
      'outlet': 'IderKopi - Kotabaru',
      'status': 'active',
      'role': {'id': 'role-user', 'name': 'Karyawan'},
    },
    {
      'id': 'usr-nadia-aulia',
      'email': 'nadia@iderkopi.id',
      'first_name': 'Nadia',
      'last_name': 'Aulia',
      'kangider_id': 'IDR-0018',
      'kangider_nama': 'Nadia Aulia',
      'outlet': 'IderKopi - Sudirman',
      'status': 'active',
      'role': {'id': 'role-user', 'name': 'Karyawan'},
    },
    {
      'id': 'usr-bagas-firmansyah',
      'email': 'bagas@iderkopi.id',
      'first_name': 'Bagas',
      'last_name': 'Firmansyah',
      'kangider_id': 'IDR-0021',
      'kangider_nama': 'Bagas Firmansyah',
      'outlet': 'IderKopi - Kotabaru',
      'status': 'active',
      'role': {'id': 'role-user', 'name': 'Karyawan'},
    },
    {
      'id': 'usr-yoga-kurniawan',
      'email': 'yoga@iderkopi.id',
      'first_name': 'Yoga',
      'last_name': 'Kurniawan',
      'kangider_id': 'IDR-0024',
      'kangider_nama': 'Yoga Kurniawan',
      'outlet': 'IderKopi - Sudirman',
      'status': 'active',
      'role': {'id': 'role-user', 'name': 'Karyawan'},
    },
    {
      'id': 'usr-admin-owner',
      'email': 'ider@iderkopi.id',
      'first_name': 'Kang',
      'last_name': 'Ider',
      'kangider_id': null,
      'kangider_nama': 'Kang Ider',
      'outlet': 'IderKopi - HQ / Semua Outlet',
      'status': 'active',
      'role': {'id': 'role-admin', 'name': 'Admin'},
    },
  ];

  // Seeded Attendance Records
  static List<Map<String, dynamic>> mockAllAttendance = [
    {
      'id': 'att-01',
      'tanggal_absensi': '2026-08-03',
      'masuk': '07:52:00',
      'pulang': '17:04:00',
      'kangider': 'IDR-0012',
      'kangider_nama': 'Dewi Anjani',
      'outlet': 'IderKopi - Malioboro',
      'keterangan': 'Tepat waktu',
      'latitude': -7.7928,
      'longitude': 110.3658,
    },
    {
      'id': 'att-02',
      'tanggal_absensi': '2026-08-03',
      'masuk': '08:41:00',
      'pulang': '17:10:00',
      'kangider': 'IDR-0014',
      'kangider_nama': 'Rangga Pradana',
      'outlet': 'IderKopi - Malioboro',
      'keterangan': 'Terlambat 41m',
      'latitude': -7.7928,
      'longitude': 110.3658,
    },
    {
      'id': 'att-03',
      'tanggal_absensi': '2026-08-03',
      'masuk': '07:45:00',
      'pulang': null,
      'kangider': 'IDR-0015',
      'kangider_nama': 'Siti Nuraini',
      'outlet': 'IderKopi - Kotabaru',
      'keterangan': 'Tepat waktu',
      'latitude': -7.7850,
      'longitude': 110.3720,
    },
    {
      'id': 'att-04',
      'tanggal_absensi': '2026-08-03',
      'masuk': '07:50:00',
      'pulang': null,
      'kangider': 'IDR-0018',
      'kangider_nama': 'Nadia Aulia',
      'outlet': 'IderKopi - Sudirman',
      'keterangan': 'Tepat waktu',
      'latitude': -7.7830,
      'longitude': 110.3750,
    },
    {
      'id': 'att-05',
      'tanggal_absensi': '2026-08-03',
      'masuk': null,
      'pulang': null,
      'kangider': 'IDR-0021',
      'kangider_nama': 'Bagas Firmansyah',
      'outlet': 'IderKopi - Kotabaru',
      'keterangan': 'Tanpa keterangan',
      'latitude': null,
      'longitude': null,
    },
    {
      'id': 'att-06',
      'tanggal_absensi': '2026-08-03',
      'masuk': '07:38:00',
      'pulang': null,
      'kangider': 'IDR-0024',
      'kangider_nama': 'Yoga Kurniawan',
      'outlet': 'IderKopi - Sudirman',
      'keterangan': 'Tepat waktu',
      'latitude': -7.7830,
      'longitude': 110.3750,
    },
  ];

  static List<Map<String, dynamic>> mockRoles = [
    {'id': 'role-admin', 'name': 'Admin'},
    {'id': 'role-user', 'name': 'Karyawan'},
  ];

  // Seeded Outlets (IderKopi) — koordinat Yogyakarta area
  // Dipakai untuk geofencing multi-outlet di v1.1.
  static List<Map<String, dynamic>> mockOutlets = [
    {
      'id': 1,
      'nama': 'IderKopi - HQ',
      'alamat': 'Jl. Kaliurang KM 5, Yogyakarta',
      'latitude': -7.7550,
      'longitude': 110.4080,
      'radius_meters': 100.0,
      'is_active': true,
    },
    {
      'id': 2,
      'nama': 'IderKopi - Malioboro',
      'alamat': 'Jl. Malioboro No. 52, Yogyakarta',
      'latitude': -7.7928,
      'longitude': 110.3658,
      'radius_meters': 100.0,
      'is_active': true,
    },
    {
      'id': 3,
      'nama': 'IderKopi - Kotabaru',
      'alamat': 'Jl. C. Simanjuntak No. 18, Yogyakarta',
      'latitude': -7.7850,
      'longitude': 110.3720,
      'radius_meters': 120.0,
      'is_active': true,
    },
    {
      'id': 4,
      'nama': 'IderKopi - Sudirman',
      'alamat': 'Jl. Jend. Sudirman, Yogyakarta',
      'latitude': -7.7830,
      'longitude': 110.3750,
      'radius_meters': 100.0,
      'is_active': true,
    },
  ];

  /// Mock hari libur nasional 2026 (subset).
  static List<Map<String, dynamic>> mockHolidays = [
    {'id': 1, 'tanggal': '2026-01-01', 'nama': 'Tahun Baru 2026', 'is_nasional': true},
    {'id': 2, 'tanggal': '2026-02-17', 'nama': 'Tahun Baru Imlek', 'is_nasional': true},
    {'id': 3, 'tanggal': '2026-03-03', 'nama': 'Hari Raya Nyepi', 'is_nasional': true},
    {'id': 4, 'tanggal': '2026-03-31', 'nama': 'Wafat Isa Al Masih', 'is_nasional': true},
    {'id': 5, 'tanggal': '2026-04-18', 'nama': 'Jumat Agung', 'is_nasional': true},
    {'id': 6, 'tanggal': '2026-05-01', 'nama': 'Hari Buruh Internasional', 'is_nasional': true},
    {'id': 7, 'tanggal': '2026-05-21', 'nama': 'Kenaikan Isa Al Masih', 'is_nasional': true},
    {'id': 8, 'tanggal': '2026-06-01', 'nama': 'Hari Lahir Pancasila', 'is_nasional': true},
    {'id': 9, 'tanggal': '2026-06-17', 'nama': 'Hari Raya Idul Adha', 'is_nasional': true},
    {'id': 10, 'tanggal': '2026-08-17', 'nama': 'Hari Kemerdekaan RI', 'is_nasional': true},
    {'id': 11, 'tanggal': '2026-09-27', 'nama': 'Maulid Nabi Muhammad', 'is_nasional': true},
    {'id': 12, 'tanggal': '2026-12-25', 'nama': 'Hari Raya Natal', 'is_nasional': true},
  ];
}
