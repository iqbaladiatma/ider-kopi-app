# Dokumentasi Lengkap — IderKopi Absensi

Dokumen ini adalah panduan lengkap untuk project **IderKopi Absensi**: aplikasi absensi mobile berbasis Flutter yang terhubung ke backend Directus REST API di `https://api.iderkopi.id`.

---

## Daftar Isi

1. [Gambaran Umum](#1-gambaran-umum)
2. [Tech Stack](#2-tech-stack)
3. [Fitur Aplikasi](#3-fitur-aplikasi)
4. [Arsitektur Sistem](#4-arsitektur-sistem)
5. [Struktur Folder & File](#5-struktur-folder--file)
6. [Konfigurasi Project](#6-konfigurasi-project)
7. [Setup & Instalasi](#7-setup--instalasi)
8. [Alur Autentikasi](#8-alur-autentikasi)
9. [Alur Absensi](#9-alur-absensi)
10. [Directus Schema & Permissions](#10-directus-schema--permissions)
11. [State Management (Riverpod)](#11-state-management-riverpod)
12. [UI/UX & Design System](#12-uiux--design-system)
13. [Dependencies](#13-dependencies)
14. [Testing](#14-testing)
15. [Build & Deployment](#15-build--deployment)
16. [Roadmap](#16-roadmap)
17. [Catatan Penting](#17-catatan-penting)

---

## 1. Gambaran Umum

**IderKopi Absensi** adalah aplikasi mobile untuk karyawan IderKopi (Kang Ider) guna mencatat kehadiran harian dengan:

- Login menggunakan akun Directus
- Check-in dengan GPS location + foto selfie
- Check-out dengan update record absensi
- Riwayat absensi 30 hari terakhir
- Profil karyawan + statistik kehadiran bulanan
- Panel admin untuk monitoring user dan absensi

Aplikasi ini berkomunikasi langsung dengan Directus REST API. Data absensi disimpan di collection `absensi_ider` dan data karyawan di collection `kangider`.

### Related Project

- **IderKopi HRIS (web)**: `c:\Misi-NUS\ideerkopi` — backend Go + frontend Next.js
- Aplikasi Flutter ini berkomunikasi langsung ke Directus, tidak melewati backend Go.

---

## 2. Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile App | Flutter (Dart) |
| Backend API | Directus REST API (`https://api.iderkopi.id`) |
| Database | PostgreSQL (melalui Directus) |
| Storage | Directus Files (foto selfie) |
| State Management | `flutter_riverpod` |
| HTTP Client | `dio` |
| Navigation | `go_router` |
| GPS | `geolocator` |
| Camera | `camera` |
| Image Processing | `image` |
| Secure Storage | `flutter_secure_storage` |
| Linting | `flutter_lints` |

---

## 3. Fitur Aplikasi

### Fitur User (Karyawan)

| Fitur | Keterangan |
|-------|-----------|
| Splash Screen | Loading saat aplikasi dicek token-nya |
| Login | Email & password Directus, dengan mock auth untuk testing |
| Home/Dashboard | Greeting, status absensi hari ini, ringkasan riwayat terakhir |
| Check-In | GPS location + kamera selfie + upload ke Directus |
| Check-Out | Update record absensi hari ini dengan waktu pulang |
| Attendance Options | Pilihan menu check-in / check-out |
| Riwayat Absensi | List 30 hari terakhir dengan status & thumbnail selfie |
| Profile | Info karyawan + statistik kehadiran bulan ini |

### Fitur Admin

| Fitur | Keterangan |
|-------|-----------|
| Admin Dashboard | Ringkasan jumlah user dan jumlah absensi hari ini |
| Kelola User | List, tambah, edit, hapus user karyawan |
| Monitoring Absensi | Lihat seluruh data absensi karyawan dengan filter tanggal & nama |
| Admin Profile | Profil admin + logout |

---

## 4. Arsitektur Sistem

### Diagram Arsitektur

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  Flutter App    │────▶│  Directus API    │────▶│  PostgreSQL     │
│  (Android/iOS)  │     │  api.iderkopi.id │     │  (Directus DB)  │
└─────────────────┘     └──────────────────┘     └─────────────────┘
     │                         │
     │ GPS + Camera            │ Files endpoint
     ▼                         ▼
┌─────────────────┐     ┌──────────────────┐
│  Device Sensor  │     │  Directus Files  │
│  (GPS, Camera)  │     │  (Selfie photos) │
└─────────────────┘     └──────────────────┘
```

### Alur Umum

1. Flutter app login ke Directus → mendapatkan `access_token` + `refresh_token`
2. Token disimpan di `FlutterSecureStorage`
3. Setiap request Dio akan otomatis menyisipkan `Authorization: Bearer <token>`
4. Saat check-in:
   - Ambil GPS (lat/lng) via `geolocator`
   - Ambil selfie via `camera`
   - Kompres gambar via `image`
   - Upload selfie ke `POST /files` → mendapatkan `file_id`
   - Create record `absensi_ider` dengan data lengkap
5. Saat check-out:
   - Cari record absensi hari ini
   - PATCH record: jam pulang, lat/lng pulang, selfie pulang
6. Riwayat: GET `absensi_ider` filtered by `kangider`, sorted by tanggal desc

---

## 5. Struktur Folder & File

```
iderkopi-absensi/
├── android/                          # Konfigurasi Android
├── ios/                              # Konfigurasi iOS
├── lib/
│   ├── main.dart                     # Entry point + ProviderScope
│   ├── app.dart                      # MaterialApp.router + theme
│   │
│   ├── core/
│   │   ├── config/
│   │   │   └── app_config.dart       # API URL, timeout, koordinat kantor
│   │   ├── constants/
│   │   │   └── app_colors.dart       # Semua color palette
│   │   ├── network/
│   │   │   ├── directus_client.dart  # Dio singleton + interceptors
│   │   │   └── auth_interceptor.dart # Token inject + auto refresh on 401
│   │   ├── storage/
│   │   │   └── secure_storage.dart   # FlutterSecureStorage wrapper
│   │   ├── theme/
│   │   │   └── app_theme.dart        # ThemeData lengkap
│   │   ├── utils/
│   │   │   ├── date_utils.dart       # Format tanggal/waktu & greeting
│   │   │   ├── image_utils.dart      # Kompresi gambar selfie
│   │   │   ├── location_utils.dart   # GPS helper & geofencing
│   │   │   └── mock_data.dart        # Data mock untuk testing
│   │   └── router/
│   │       └── app_router.dart       # go_router + redirect berdasarkan role
│   │
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   │   ├── auth_model.dart       # AuthTokens, LoginRequest, UserProfile
│   │   │   │   └── auth_repository.dart  # Login, logout, current user
│   │   │   ├── presentation/
│   │   │   │   ├── login_page.dart
│   │   │   │   └── splash_screen.dart
│   │   │   └── providers/
│   │   │       └── auth_providers.dart   # authStateProvider, currentUserProvider, dll
│   │   │
│   │   ├── attendance/
│   │   │   ├── data/
│   │   │   │   ├── attendance_model.dart       # AttendanceRecord, CheckIn/OutRequest
│   │   │   │   └── attendance_repository.dart  # CRUD absensi + upload selfie
│   │   │   ├── presentation/
│   │   │   │   ├── home_page.dart
│   │   │   │   ├── attendance_options_page.dart
│   │   │   │   ├── check_in_page.dart
│   │   │   │   ├── check_out_page.dart
│   │   │   │   ├── history_page.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── attendance_summary_card.dart
│   │   │   │       ├── camera_section.dart
│   │   │   │       ├── history_list_item.dart
│   │   │   │       ├── location_card.dart
│   │   │   │       └── status_badge.dart
│   │   │   └── providers/
│   │   │       └── attendance_providers.dart   # todayAttendanceProvider, historyProvider, monthlyStatsProvider
│   │   │
│   │   ├── profile/
│   │   │   ├── data/
│   │   │   │   └── profile_model.dart          # ProfileInfo, AttendanceStats
│   │   │   ├── presentation/
│   │   │   │   └── profile_page.dart
│   │   │   └── providers/
│   │   │       └── profile_providers.dart      # profileInfoProvider, profileStatsProvider
│   │   │
│   │   └── admin/
│   │       ├── data/
│   │       │   ├── admin_user_model.dart       # AdminUser, CreateUserData
│   │       │   └── admin_repository.dart       # CRUD user, monitoring absensi
│   │       ├── presentation/
│   │       │   ├── admin_dashboard_page.dart
│   │       │   ├── admin_users_page.dart
│   │       │   ├── admin_attendance_page.dart
│   │       │   └── admin_profile_page.dart
│   │       └── providers/
│   │           └── admin_providers.dart        # usersProvider, adminAttendanceProvider, dll
│   │
│   └── shared/
│       └── widgets/
│           ├── admin_nav_bar.dart
│           ├── bottom_nav_bar.dart
│           ├── custom_button.dart
│           ├── empty_view.dart
│           ├── error_view.dart
│           ├── gradient_header.dart
│           └── loading_overlay.dart
│
├── assets/
│   ├── images/
│   └── icons/
├── docs/                             # Dokumentasi project
├── test/                             # Unit & widget tests
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

---

## 6. Konfigurasi Project

File konfigurasi utama: `lib/core/config/app_config.dart`

```dart
class AppConfig {
  AppConfig._();

  static const String directusApiBaseUrl = 'https://api.iderkopi.id';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const int retryCount = 3;
  static const Duration retryBackoff = Duration(seconds: 2);

  static const double officeRadiusMeters = 100.0;
  static const double officeLatitude = -6.123456;
  static const double officeLongitude = 106.789012;

  static const String appVersion = '1.0.0';

  // Set ke true untuk pakai mock auth (testing tanpa Directus)
  static const bool useMockAuth = true;
}
```

### Catatan Penting Konfigurasi

- `useMockAuth`: saat `true`, aplikasi tidak memanggil Directus. Login, absensi, dan user management menggunakan data mock. Sangat berguna untuk development & UI testing.
- `officeLatitude` / `officeLongitude`: koordinat default kantor untuk fallback GPS dan geofencing.
- `officeRadiusMeters`: radius dalam meter untuk validasi jarak karyawan ke kantor.

---

## 7. Setup & Instalasi

### Prasyarat

- Flutter SDK >= 3.13.0
- Dart SDK >= 3.0.0
- Android Studio / Xcode (untuk emulator/physical device)
- Akun Directus & API URL yang aktif (jika tidak pakai mock)

### Langkah Instalasi

```bash
# 1. Clone atau buka project
cd iderkopi-absensi

# 2. Install dependencies
flutter pub get

# 3. Jalankan aplikasi
flutter run

# 4. (Opsional) Build release
flutter build apk --release
flutter build appbundle --release
```

### Akun Mock untuk Testing

Saat `useMockAuth = true`, gunakan akun berikut:

| Role | Email | Password |
|------|-------|----------|
| Admin | `admin@iderkopi.id` | `admin123` |
| User | `user@iderkopi.id` | `user123` |

---

## 8. Alur Autentikasi

### Model Autentikasi (`lib/features/auth/data/auth_model.dart`)

| Class | Keterangan |
|-------|-----------|
| `AuthTokens` | Menyimpan `accessToken`, `refreshToken`, `expiresAt` |
| `LoginRequest` | Payload email & password untuk login |
| `UserProfile` | Data user: id, email, nama, kangider_id, outlet, role |

### Auth Repository (`lib/features/auth/data/auth_repository.dart`)

| Method | Fungsi |
|--------|--------|
| `login(email, password)` | Login ke Directus atau mock login |
| `getCurrentUser()` | Ambil data user saat ini dari `/users/me` |
| `logout()` | Hapus token & call `/auth/logout` |
| `isLoggedIn()` | Cek apakah access token masih valid |
| `getKangiderId()` | Ambil kangider_id dari secure storage |
| `getUserRole()` | Ambil role user dari secure storage |

### Secure Storage (`lib/core/storage/secure_storage.dart`)

Key yang disimpan:

| Key | Keterangan |
|-----|-----------|
| `access_token` | Bearer token |
| `refresh_token` | Token untuk refresh |
| `expires_at` | Waktu kedaluwarsa token |
| `user_email` | Email user |
| `kangider_id` | ID karyawan untuk filter data absensi |
| `user_role` | Role user (Admin / User) |

### Auth Interceptor (`lib/core/network/auth_interceptor.dart`)

- `onRequest`: menyisipkan `Authorization: Bearer <token>` untuk setiap request kecuali endpoint `/auth/login` dan `/auth/refresh`
- `onError` (401): otomatis memanggil `/auth/refresh`, lalu retry request asli
- Jika refresh gagal: clear storage, user diarahkan ke login

### Auth Flow

```
SplashScreen
   │
   ▼
authInitProvider (cek token di storage)
   │
   ├── Token valid ──▶ HomePage (User) / AdminDashboardPage (Admin)
   │
   └── Token tidak valid ──▶ LoginPage
            │
            ▼
    LoginPage ──▶ POST /auth/login
            │
            ▼
    Simpan token ──▶ HomePage / AdminDashboardPage
```

---

## 9. Alur Absensi

### Model Absensi (`lib/features/attendance/data/attendance_model.dart`)

| Class | Keterangan |
|-------|-----------|
| `AttendanceRecord` | Record absensi lengkap dari Directus |
| `CheckInRequest` | Payload untuk create absensi |
| `CheckOutRequest` | Payload untuk update absensi |

| Field `AttendanceRecord` | Tipe | Keterangan |
|--------------------------|------|-----------|
| `id` | int? | Primary key |
| `tanggalAbsensi` | String | Tanggal absen (YYYY-MM-DD) |
| `masuk` | String? | Jam masuk (HH:MM:SS) |
| `pulang` | String? | Jam pulang (HH:MM:SS) |
| `kangider` | String? | FK ke `kangider.id` |
| `keterangan` | String? | Catatan |
| `latitude` | double? | Latitude saat check-in |
| `longitude` | double? | Longitude saat check-in |
| `selfieFileId` | String? | Directus file ID selfie masuk |
| `checkInSource` | String? | Sumber: "app", "manual", "device" |
| `latitudePulang` | double? | Latitude saat check-out |
| `longitudePulang` | double? | Longitude saat check-out |
| `selfiePulangFileId` | String? | Directus file ID selfie pulang |

### Attendance Repository

| Method | Fungsi |
|--------|--------|
| `getTodayAttendance(kangiderId)` | Cek apakah sudah absen hari ini |
| `checkIn(CheckInRequest)` | Create record absensi baru |
| `checkOut(int id, CheckOutRequest)` | Update record absensi untuk jam pulang |
| `getHistory(kangiderId, limit: 30)` | Riwayat 30 hari terakhir |
| `getMonthlyHistory(kangiderId, year, month)` | Riwayat per bulan |
| `uploadSelfie(XFile)` | Upload foto ke `/files` |

### Status Absensi

| Status | Kondisi |
|--------|---------|
| `Tepat Waktu` | Check-in sebelum atau tepat jam 08:00 |
| `Terlambat` | Check-in setelah jam 08:00 |
| `Alpha` | Belum check-in sama sekali |
| `Belum Absen` | State default sebelum proses absensi |

### Check-In Flow

```
User tap Check-In
   │
   ▼
getCurrentLocation() ──▶ latitude, longitude
   │
   ▼
CameraSection ──▶ ambil foto selfie
   │
   ▼
compressImage() ──▶ resize & kompres
   │
   ▼
uploadSelfie() ──▶ POST /files ──▶ file_id
   │
   ▼
checkIn() ──▶ POST /items/absensi_ider
```

### Check-Out Flow

```
User tap Check-Out
   │
   ▼
getTodayAttendance() ──▶ dapat record ID
   │
   ▼
getCurrentLocation() ──▶ latitude_pulang, longitude_pulang
   │
   ▼
(Opsional) foto selfie pulang
   │
   ▼
checkOut(id, CheckOutRequest) ──▶ PATCH /items/absensi_ider/:id
```

---

## 10. Directus Schema & Permissions

### Collection: `kangider`

| Field | Tipe | Keterangan |
|-------|------|-----------|
| `id` | string/UUID | Primary key |
| `nama` | string | Nama karyawan |

### Collection: `absensi_ider`

#### Existing Fields

| Field | Tipe | Keterangan |
|-------|------|-----------|
| `id` | auto increment | Primary key |
| `tanggal_absensi` | date | Tanggal absen |
| `masuk` | string (time) | Jam masuk |
| `pulang` | string (time) | Jam pulang |
| `kangider` | string | Foreign key ke `kangider.id` |
| `keterangan` | string (nullable) | Catatan |

#### New Fields

| Field | Tipe | Keterangan |
|-------|------|-----------|
| `latitude` | float (nullable) | GPS latitude check-in |
| `longitude` | float (nullable) | GPS longitude check-in |
| `selfie_file_id` | uuid (nullable) | File ID selfie masuk |
| `check_in_source` | string (default: "app") | Sumber absensi |
| `latitude_pulang` | float (nullable) | GPS latitude check-out |
| `longitude_pulang` | float (nullable) | GPS longitude check-out |
| `selfie_pulang_file_id` | uuid (nullable) | File ID selfie pulang |

### SQL Migration Referensi

```sql
ALTER TABLE absensi_ider
  ADD COLUMN latitude DOUBLE PRECISION,
  ADD COLUMN longitude DOUBLE PRECISION,
  ADD COLUMN selfie_file_id VARCHAR(36),
  ADD COLUMN check_in_source VARCHAR(20) DEFAULT 'app',
  ADD COLUMN latitude_pulang DOUBLE PRECISION,
  ADD COLUMN longitude_pulang DOUBLE PRECISION,
  ADD COLUMN selfie_pulang_file_id VARCHAR(36);
```

### Role & Permissions

Buat role baru **"App User"** dengan permission:

| Collection | Permission | Fields | Filter |
|-----------|-----------|--------|--------|
| `kangider` | read | `id, nama` | — |
| `absensi_ider` | create | semua field absensi | — |
| `absensi_ider` | read | all fields | `kangider = CURRENT_USER.kangider_id` |
| `absensi_ider` | update | `pulang, lat_pulang, lng_pulang, selfie_pulang, keterangan` | `kangider = CURRENT_USER.kangider_id` |
| `files` | create | — | — |
| `files` | read | — | `uploaded_by = CURRENT_USER` |

Catatan:
- App User **tidak boleh delete** `absensi_ider`
- App User hanya bisa lihat & update data miliknya sendiri
- Admin role memiliki akses penuh ke `users`, `absensi_ider`, dan `files`

### Endpoint Directus yang Digunakan

| Method | Endpoint | Fungsi |
|--------|----------|--------|
| `POST` | `/auth/login` | Login |
| `POST` | `/auth/refresh` | Refresh token |
| `POST` | `/auth/logout` | Logout |
| `GET` | `/users/me` | Data user login |
| `GET` | `/users` | List users (admin) |
| `POST` | `/users` | Create user (admin) |
| `PATCH` | `/users/:id` | Update user (admin) |
| `DELETE` | `/users/:id` | Delete user (admin) |
| `GET` | `/roles` | List roles |
| `GET` | `/items/absensi_ider` | Read absensi |
| `POST` | `/items/absensi_ider` | Create absensi |
| `PATCH` | `/items/absensi_ider/:id` | Update absensi |
| `POST` | `/files` | Upload selfie |

---

## 11. State Management (Riverpod)

### Auth Providers (`lib/features/auth/providers/auth_providers.dart`)

| Provider | State | Fungsi |
|----------|-------|--------|
| `authRepositoryProvider` | `AuthRepository` singleton | Akses repository |
| `authStateProvider` | `AuthStatus` | Status auth: initial, authenticated, unauthenticated |
| `authInitProvider` | `Future<AuthStatus>` | Inisialisasi cek token |
| `currentUserProvider` | `Future<UserProfile?>` | Data user saat ini |
| `kangiderIdProvider` | `Future<String?>` | ID karyawan |
| `userRoleProvider` | `Future<String?>` | Role user |
| `isAdminProvider` | `Future<bool>` | Cek apakah admin |

### Attendance Providers (`lib/features/attendance/providers/attendance_providers.dart`)

| Provider | State | Fungsi |
|----------|-------|--------|
| `attendanceRepositoryProvider` | `AttendanceRepository` | Akses repository |
| `todayAttendanceProvider` | `Future<AttendanceRecord?>` | Status absen hari ini |
| `historyProvider` | `Future<List<AttendanceRecord>>` | Riwayat 30 hari |
| `monthlyHistoryProvider` | `FutureProvider.family` | Riwayat per bulan |
| `monthlyStatsProvider` | `FutureProvider.family<MonthlyStats>` | Statistik bulanan |

### Admin Providers (`lib/features/admin/providers/admin_providers.dart`)

| Provider | State | Fungsi |
|----------|-------|--------|
| `adminRepositoryProvider` | `AdminRepository` | Akses repository |
| `usersProvider` | `Future<List<AdminUser>>` | List semua user |
| `userCountProvider` | `Future<int>` | Jumlah user |
| `rolesProvider` | `Future<List<Map>>` | List roles |
| `todayAttendanceCountProvider` | `Future<int>` | Jumlah absensi hari ini |
| `adminAttendanceProvider` | `FutureProvider.family` | Semua data absensi dengan filter |

---

## 12. UI/UX & Design System

### Color Palette (`lib/core/constants/app_colors.dart`)

| Role | Color | Hex |
|------|-------|-----|
| Primary | Red 600 | `#DC2030` |
| Primary Dark | Red 700/800 | `#B91424` / `#991222` |
| Primary Light | Red 100 | `#FFE4E6` |
| Background | Off-white | `#FCFCFD` |
| Surface | White | `#FFFFFF` |
| Surface Alt | Gray 50 | `#F7F8FA` |
| Text Primary | Near black | `#0D1117` |
| Text Secondary | Gray | `#4A5568` |
| Text Muted | Light gray | `#9AA5B4` |
| Success | Green | `#0F9960` |
| Warning | Amber | `#E5A20B` |
| Error | Red | `#DC2030` |

### Typography

- Font: `Inter`
- Headline: 18–22px bold
- Body: 14–16px regular/medium
- Caption: 12px

### Spacing & Radius

- Spacing scale: 4, 8, 12, 16, 20, 24, 32
- Radius: 12, 14, 16, 18, 24

### Screen List

| Route | Screen | Role |
|-------|--------|------|
| `/splash` | SplashScreen | All |
| `/login` | LoginPage | Guest |
| `/home` | HomePage | User |
| `/attendance-options` | AttendanceOptionsPage | User |
| `/check-in` | CheckInPage | User |
| `/check-out` | CheckOutPage | User |
| `/history` | HistoryPage | User |
| `/profile` | ProfilePage | User |
| `/admin` | AdminDashboardPage | Admin |
| `/admin/users` | AdminUsersPage | Admin |
| `/admin/attendance` | AdminAttendancePage | Admin |
| `/admin/profile` | AdminProfilePage | Admin |

### Bottom Navigation

**User (`MainShell`)**:
- Home
- Attendance (FAB tengah)
- Riwayat
- Profil

**Admin (`AdminShell`)**:
- Dashboard
- Users
- Attendance
- Profile

---

## 13. Dependencies

File: `pubspec.yaml`

### Dependencies Utama

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.6
  dio: ^5.4.0
  flutter_riverpod: ^2.4.0
  riverpod_annotation: ^2.3.0
  go_router: ^13.0.0
  flutter_secure_storage: ^9.0.0
  geolocator: ^11.0.0
  geocoding: ^2.1.0
  camera: ^0.10.5
  image: ^4.1.0
  path_provider: ^2.1.0
  google_maps_flutter: ^2.5.0
  intl: ^0.18.0
  freezed_annotation: ^2.4.0
  json_annotation: ^4.8.0
  cached_network_image: ^3.3.0
  flutter_svg: ^2.0.9
```

### Dev Dependencies

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  build_runner: ^2.4.0
  freezed: ^2.4.0
  json_serializable: ^6.7.0
  riverpod_generator: ^2.3.0
  mockito: ^5.4.0
  integration_test:
    sdk: flutter
```

### Izin Aplikasi

**Android** (`android/app/src/main/AndroidManifest.xml`):

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-feature android:name="android.hardware.camera" android:required="true" />
<uses-feature android:name="android.hardware.location.gps" android:required="true" />
```

**iOS** (`ios/Runner/Info.plist`):

```xml
<key>NSCameraUsageDescription</key>
<string>Aplikasi membutuhkan kamera untuk foto selfie saat absensi</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Aplikasi membutuhkan lokasi untuk mencatat posisi saat absensi</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>Aplikasi membutuhkan lokasi untuk mencatat posisi saat absensi</string>
```

---

## 14. Testing

### Tingkatan Test

| Level | Tool | Cakupan |
|-------|------|---------|
| Unit Test | `flutter_test` + `mockito` | Repository, model, utils |
| Widget Test | `flutter_test` | Halaman & reusable widgets |
| Integration Test | `integration_test` | Flow: login → check-in → check-out → history |
| Manual Test | — | Akurasi GPS, kualitas kamera, kecepatan upload |

### Cara Menjalankan Test

```bash
# Unit & widget tests
flutter test

# Integration tests
flutter test integration_test/app_test.dart

# Analyze
flutter analyze
```

### Lint Rules (`analysis_options.yaml`)

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    prefer_const_constructors: true
    prefer_const_literals_to_create_immutables: true
    avoid_print: true

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
```

---

## 15. Build & Deployment

### Android

```bash
# APK release
flutter build apk --release

# App Bundle untuk Play Store
flutter build appbundle --release
```

Output:
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

### iOS

```bash
flutter build ios --release
```

Lanjutkan archive & upload via Xcode ke App Store Connect.

### Web (tidak direkomendasikan untuk production karena kamera & GPS)

```bash
flutter build web
```

---

## 16. Roadmap

### MVP (v1.0.0)

| Phase | Fitur |
|-------|-------|
| 1 | Project setup: Flutter init, theme, router, Directus client |
| 2 | Auth: login page, token storage, auth interceptor |
| 3 | Home/Dashboard: greeting card, status hari ini, quick actions |
| 4 | Check-In: GPS location, camera selfie, upload, submit |
| 5 | Check-Out: update record, optional selfie |
| 6 | Riwayat: list 30 hari, filter bulan, thumbnail selfie |
| 7 | Profile: info karyawan, statistik bulanan, logout |
| 8 | Admin panel: dashboard, users, attendance monitoring |
| 9 | Polish: animations, error states, empty states, testing |

### v1.1 — Geofencing & Multi-Outlet

- Validasi radius kantor (geofencing)
- Pilih outlet saat check-in
- Map preview interaktif
- Offline location cache

### v1.2 — Offline Mode

- Queue absensi saat offline
- Local SQLite cache
- Background sync dengan `workmanager`
- Conflict resolution

### v1.3 — Notifications

- Push reminder check-in & check-out
- Local notifications
- Holiday awareness

### v2.0 — Integrasi Go Backend

- Pengajuan izin/sakit/cuti
- Approval manager
- KPI preview
- Attendance recap dengan grafik
- Shift schedule

---

## 17. Catatan Penting

1. **Mock Auth**: Saat ini `AppConfig.useMockAuth = true`, artinya aplikasi berjalan sepenuhnya tanpa backend. Untuk production, ubah ke `false` dan pastikan Directus API accessible.

2. **Admin Flow**: Admin memiliki shell navigation tersendiri (`AdminShell`) yang berbeda dengan user biasa. Routing otomatis redirect berdasarkan `userRoleProvider`.

3. **GPS Fallback**: Jika GPS tidak tersedia atau permission ditolak, aplikasi akan menggunakan koordinat kantor dari `AppConfig.officeLatitude` / `officeLongitude`.

4. **Image Compression**: Foto selfie dikompresi menjadi max width 720px dengan quality 70% sebelum upload untuk menghemat bandwidth.

5. **Token Expiry**: Token dianggap expired jika `expiresAt` sudah lewat. Auto-refresh akan berjalan saat menerima HTTP 401.

6. **Status Terlambat**: Karyawan dianggap terlambat jika check-in setelah jam 08:00. Logika ini ada di `AttendanceRecord._isLate()` dan `AppDateUtils.isLate()`.

7. **Data Mock**: Data mock user, admin, dan absensi tersedia di `lib/core/utils/mock_data.dart`. Cocok untuk demo dan pengembangan UI.

8. **Security**: Jangan commit file `.env` atau credential asli ke repository. Gunakan secure storage untuk token.

9. **Error Handling**: Error handling terpusat di interceptor dan repository. UI menampilkan `ErrorView` dengan tombol retry.

10. **Performance**: Gunakan `const` constructors sesuai lint rule, dan hindari `print` (gunakan `debugPrint` jika diperlukan).

---

## Referensi File Utama

- Entry point: `lib/main.dart`
- App config: `lib/app.dart`
- Router: `lib/core/router/app_router.dart`
- Theme: `lib/core/theme/app_theme.dart`
- Colors: `lib/core/constants/app_colors.dart`
- HTTP Client: `lib/core/network/directus_client.dart`
- Auth Interceptor: `lib/core/network/auth_interceptor.dart`
- Secure Storage: `lib/core/storage/secure_storage.dart`
- Mock Data: `lib/core/utils/mock_data.dart`
- Auth Repository: `lib/features/auth/data/auth_repository.dart`
- Attendance Repository: `lib/features/attendance/data/attendance_repository.dart`
- Admin Repository: `lib/features/admin/data/admin_repository.dart`
- Pubspec: `pubspec.yaml`

---

*Dokumentasi ini dibuat untuk memberikan gambaran lengkap mengenai project IderKopi Absensi. Untuk pertanyaan lebih lanjut, silakan merujuk ke file-file sumber yang disebutkan di atas.*
