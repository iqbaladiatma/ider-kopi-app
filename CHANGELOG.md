# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-08-05

### Added — v2.0 Integrasi Go Backend
- **Abstract API Layer**: App bisa switch antara Directus & Go backend via `--dart-define=API_PROVIDER=goBackend`
- **Leave Request**: Karyawan ajukan izin/sakit/cuti; manager approve/reject
- **KPI Preview**: Skor KPI bulanan dengan grade A-E, breakdown kehadiran/terlambat/alpha/cuti
- **Attendance Recap**: Bar chart per minggu + pie chart distribusi status + detail table per hari
- **Shift Schedule**: Calendar view jadwal shift + upcoming shifts list
- **fl_chart** dependency untuk grafik
- 41 unit test baru (Leave, KPI, Recap, Shift, ApiProvider)

### Changed
- App version bumped to 2.0.0
- `pubspec.yaml`: tambah config `flutter_launcher_icons` & `flutter_native_splash`
- Profile page: tambah menu Pengajuan Izin, KPI Saya, Rekap Bulanan, Jadwal Shift
- Router: tambah route `/leave`, `/leave/form`, `/leave/approval`, `/kpi`, `/recap`, `/shift`

## [1.3.0] - 2026-08-05

### Added — v1.3 Notifications & Reminders
- **Local Notifications**: Reminder check-in (08:00) & check-out (17:00) via `flutter_local_notifications`
- **Holiday Awareness**: Reminder otomatis diskip jika besok hari libur nasional
- **Holiday Banner**: Indikator hari libur di home page
- **Settings Page**: Toggle reminder + time picker, simpan di SharedPreferences
- **Mock holidays**: 12 hari libur nasional 2026
- 27 unit & widget test baru (Holiday, NotificationService, NotificationSettings, SettingsPage)

### Changed
- `main.dart`: Init NotificationService saat startup
- `AndroidManifest.xml`: Tambah permission SCHEDULE_EXACT_ALARM, POST_NOTIFICATIONS, VIBRATE
- Profile page: tambah menu "Pengaturan Notifikasi"

## [1.2.0] - 2026-08-04

### Added — v1.2 Offline Mode
- **SQLite local caching** via `sqflite`: DAOs for attendance, outlets, pending sync, sync logs
- **Offline queue**: Check-in/out tanpa internet, sync otomatis saat online
- **Background sync** via `workmanager`
- **Conflict resolution**: Last-write-wins dengan timestamp
- **PendingSyncBadge**: Indikator jumlah absensi yang belum sync
- `connectivity_plus` untuk deteksi online/offline

## [1.1.0] - 2026-08-03

### Added — v1.1 Geofencing & Multi-Outlet
- **Outlet data model**: Multi-outlet dengan lat/lng/radius
- **Outlet picker**: Pilih outlet saat check-in
- **Multi-outlet geofencing**: Validasi lokasi per outlet
- **Interactive map preview** via `google_maps_flutter`
- **Offline location caching**: Outlet disimpan di SQLite

## [1.0.0] - 2026-07-26

### Added — MVP
- Authentication via Directus (mock mode untuk dev)
- Check-in dengan GPS + selfie
- Check-out dengan GPS + selfie
- History absensi
- Admin panel (dashboard, users, attendance, profile)
- Bottom navigation
- Splash screen dengan animasi
