# Rencana Pengembangan Lengkap IderKopi Absensi

> Dokumen ini adalah **single source of truth** untuk roadmap pengembangan aplikasi IderKopi Absensi.
> Setiap phase punya: tujuan, deliverable, task breakdown, file yang akan diubah/dibuat,
> dependency baru, kriteria selesai (DoD), dan risiko.

**Status terakhir diperbarui:** 2026-08-05
**Versi saat ini:** v1.0.0 (MVP) — selesai kecuali testing & integrasi Directus asli
**Branch strategi:** `main` (stable), `dev` (integration), `feature/*` (per fitur)

---

## Daftar Isi

1. [Status Saat Ini (Baseline)](#1-status-saat-ini-baseline)
2. [Tahap 0 — Finalisasi MVP v1.0.0](#tahap-0--finalisasi-mvp-v100)
3. [Tahap 1 — v1.1 Geofencing & Multi-Outlet](#tahap-1--v11-geofencing--multi-outlet)
4. [Tahap 2 — v1.2 Offline Mode](#tahap-2--v12-offline-mode)
5. [Tahap 3 — v1.3 Notifications & Reminders](#tahap-3--v13-notifications--reminders)
6. [Tahap 4 — v2.0 Integrasi Go Backend](#tahap-4--v20-integrasi-go-backend)
7. [Testing Strategy per Fase](#testing-strategy-per-fase)
8. [Deployment Pipeline](#deployment-pipeline)
9. [Risiko & Mitigasi Global](#risiko--mitigasi-global)
10. [Glossarium](#glossarium)

---

## 1. Status Saat Ini (Baseline)

### Yang Sudah Ada

| Area | Status | Catatan |
|------|--------|---------|
| Project setup (Flutter, theme, router, Directus client) | ✅ | `lib/core/` lengkap |
| Auth (login, token storage, auth interceptor) | ⚠️ | Kode ada, tapi `useMockAuth = true` — belum diuji ke Directus asli |
| Home/Dashboard | ✅ | `home_page.dart` |
| Check-In (GPS, camera, upload, submit) | ✅ | `check_in_page.dart` + widget pendukung |
| Check-Out | ✅ | `check_out_page.dart` |
| Riwayat (list 30 hari, filter bulan) | ✅ | `history_page.dart` |
| Profile + statistik bulanan | ✅ | `profile_page.dart` |
| Admin panel (dashboard, users, attendance) | ✅ | `admin/*` |
| Animasi, error/empty state | ⚠️ | Sebagian, perlu polish |
| Testing | ❌ | Hanya placeholder `expect(true, isTrue)` |
| Geofencing multi-outlet | ❌ | Hanya 1 titik hardcoded di `app_config.dart` |
| Map preview interaktif | ❌ | `google_maps_flutter` di pubspec tapi belum dipakai |
| Offline mode | ❌ | Tidak ada SQLite/workmanager |
| Notifications | ❌ | Tidak ada package notifikasi |
| Go backend integration | ❌ | Masih Directus |

### Tech Debt yang Wajib Dibayar di Tahap 0

1. `AppConfig.useMockAuth = true` → harus bisa `false` dan tetap jalan
2. Repository pakai singleton `factory` + fallback ke mock diam-diam → menyembunyikan bug produksi
3. Tidak ada test sungguhan → sulit refactor aman
4. `officeLatitude/Longitude` hardcoded → blokir multi-outlet
5. Tidak ada CI/CD → setiap rilis manual

---

## Tahap 0 — Finalisasi MVP v1.0.0

**Tujuan:** Membuat kode MVP siap produksi sebelum nambah fitur baru.
**Estimasi:** 3–5 hari kerja
**Branch:** `feature/mvp-finalization`

### 0.1 Aktifkan Integrasi Directus Asli

**Deliverable:** App bisa login & CRUD absensi ke `https://api.iderkopi.id` tanpa mock.

**Task:**
- [ ] Verifikasi schema Directus sesuai `docs/02-DIRECTUS-SCHEMA.md` (field `latitude`, `longitude`, `selfie_file_id`, dst. sudah ada)
- [ ] Setup role "App User" di Directus admin dengan permission sesuai dokumen
- [ ] Buat minimal 2 user test di Directus: 1 admin, 1 karyawan
- [ ] Ubah `AppConfig.useMockAuth = false` dan jalankan app
- [ ] Perbaiki error yang muncul saat hit API asli (kemungkinan field mapping di `auth_model.dart` & `attendance_model.dart`)
- [ ] Pastikan flow: login → check-in (upload selfie) → check-out → history → logout jalan end-to-end
- [ ] Hapus fallback diam-diam ke mock di `admin_repository.dart` (ganti dengan error jelas)

**File yang diubah:**
- `lib/core/config/app_config.dart` — flip flag, mungkin pindah ke env (`--dart-define`)
- `lib/features/auth/data/auth_repository.dart` — hapus branch mock atau guard dengan jelas
- `lib/features/attendance/data/attendance_repository.dart` — sama
- `lib/features/admin/data/admin_repository.dart` — hapus fallback mock diam-diam

**DoD:**
- Login dengan akun Directus asli berhasil
- Check-in menghasilkan record di Directus + selfie muncul di `/files`
- History menampilkan data dari server, bukan mock

### 0.2 Testing Foundation

**Deliverable:** Coverage minimal 60% untuk layer data & utilitas.

**Task:**
- [ ] Setup `mocktail` (lebih modern dari `mockito` untuk null-safety) — tambahkan ke dev_dependencies
- [ ] Buat `test/core/utils/location_utils_test.dart` — test `distanceToOffice`, `isWithinOfficeRadius`
- [ ] Buat `test/core/utils/date_utils_test.dart` — test format tanggal
- [ ] Buat `test/features/auth/data/auth_repository_test.dart` — mock `DirectusClient`, test login sukses/gagal
- [ ] Buat `test/features/attendance/data/attendance_repository_test.dart` — test check-in, check-out, history
- [ ] Buat `test/features/attendance/data/attendance_model_test.dart` — test `fromJson`, `status`, `isLate`
- [ ] Buat widget test untuk `LoginPage`, `HomePage`, `CheckInPage` (smoke test render)
- [ ] Tambah script di CI: `flutter test --coverage`, gunakan `lcov` untuk laporan

**File baru:**
- `test/core/utils/location_utils_test.dart`
- `test/core/utils/date_utils_test.dart`
- `test/features/auth/data/auth_repository_test.dart`
- `test/features/attendance/data/attendance_repository_test.dart`
- `test/features/attendance/data/attendance_model_test.dart`
- `test/features/auth/presentation/login_page_test.dart`
- `test/features/attendance/presentation/check_in_page_test.dart`

**DoD:**
- `flutter test` lulus semua
- Coverage ≥ 60% untuk `lib/core/` dan `lib/features/*/data/`

### 0.3 Refactor Repository Pattern

**Deliverable:** Repository tidak lagi singleton; di-inject via Riverpod provider.

**Task:**
- [ ] Hapus pattern `factory` singleton di `AuthRepository`, `AttendanceRepository`, `AdminRepository`
- [ ] Buat provider Riverpod untuk masing-masing repository (`authRepositoryProvider`, dst.)
- [ ] Inject `DirectusClient` lewat constructor (bukan `DirectusClient.instance`)
- [ ] Update semua pemanggilan repository di provider layer

**File yang diubah:**
- `lib/features/auth/data/auth_repository.dart`
- `lib/features/attendance/data/attendance_repository.dart`
- `lib/features/admin/data/admin_repository.dart`
- `lib/features/*/providers/*_providers.dart`

**DoD:**
- Tidak ada `factory` constructor di repository
- Semua repository didapat via `ref.read(xxxRepositoryProvider)`

### 0.4 CI/CD Pipeline

**Deliverable:** GitHub Actions untuk test + build otomatis.

**Task:**
- [ ] Buat `.github/workflows/ci.yml`:
  - Trigger: push ke `main`, `dev`, dan PR
  - Job: `flutter pub get`, `flutter analyze`, `flutter test`, `flutter build apk --debug`
- [ ] Buat `.github/workflows/release.yml`:
  - Trigger: tag `v*.*.*`
  - Job: build APK + IPA release, upload ke GitHub Releases
- [ ] Tambah `Makefile` atau script `tool/build.sh` untuk konsistensi

**File baru:**
- `.github/workflows/ci.yml`
- `.github/workflows/release.yml`
- `Makefile` (opsional)

**DoD:**
- Setiap PR otomatis di-analyze dan di-test
- Tag `v1.0.0` menghasilkan APK di GitHub Releases

### 0.5 Polish UI/UX

**Deliverable:** Animasi halus, loading state konsisten, error state informatif.

**Task:**
- [ ] Audit semua page untuk loading skeleton (bukan hanya spinner)
- [ ] Tambah `shimmer` package untuk skeleton loading
- [ ] Tambah haptic feedback saat check-in/check-out sukses
- [ ] Tambah animasi sukses (Lottie/checkmark) setelah submit absensi
- [ ] Konsistenkan `ErrorView` & `EmptyView` di semua list page
- [ ] Dark mode support (opsional, nilai tambah)

**File yang diubah:**
- `lib/shared/widgets/loading_overlay.dart` → tambah skeleton variant
- `lib/features/attendance/presentation/check_in_page.dart` — animasi sukses
- `lib/features/attendance/presentation/check_out_page.dart` — animasi sukses
- `lib/features/attendance/presentation/history_page.dart` — skeleton list
- `lib/features/admin/presentation/admin_attendance_page.dart` — skeleton list

**DoD:**
- Tidak ada lagi bare spinner tanpa konteks
- Check-in sukses menampilkan feedback visual jelas

---

## Tahap 1 — v1.1 Geofencing & Multi-Outlet

**Tujuan:** Validasi lokasi berbasis multi-outlet, dengan map preview.
**Estimasi:** 7–10 hari kerja
**Branch:** `feature/v1.1-geofencing-multi-outlet`

### 1.1 Data Model Outlet

**Deliverable:** Outlet sebagai entitas terpisah, bisa di-fetch dari backend.

**Task:**
- [ ] Buat collection `outlet_ider` di Directus:
  ```sql
  CREATE TABLE outlet_ider (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nama VARCHAR(100) NOT NULL,
    alamat TEXT,
    latitude DOUBLE NOT NULL,
    longitude DOUBLE NOT NULL,
    radius_meters INT DEFAULT 100,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  );
  ```
- [ ] Seed data: Malioboro, Kotabaru, Sudirman, HQ (sesuaikan koordinat asli)
- [ ] Buat `lib/features/outlet/data/outlet_model.dart`:
  ```dart
  class Outlet {
    final int id;
    final String nama;
    final String? alamat;
    final double latitude;
    final double longitude;
    final double radiusMeters;
    final bool isActive;
  }
  ```
- [ ] Buat `lib/features/outlet/data/outlet_repository.dart` — fetch `/items/outlet_ider`
- [ ] Buat `lib/features/outlet/providers/outlet_providers.dart` — `outletsProvider`, `nearestOutletProvider`

**File baru:**
- `lib/features/outlet/data/outlet_model.dart`
- `lib/features/outlet/data/outlet_repository.dart`
- `lib/features/outlet/providers/outlet_providers.dart`

**DoD:**
- `outletsProvider` mengembalikan list outlet dari Directus
- `nearestOutletProvider` mengembalikan outlet terdekat berdasarkan GPS user

### 1.2 Outlet Picker di Check-In

**Deliverable:** User bisa pilih outlet saat check-in (untuk karyawan rotasi).

**Task:**
- [ ] Buat widget `OutletPickerSheet` (bottom sheet dengan list outlet + jarak ke user)
- [ ] Default: outlet terdekat terpilih otomatis jika dalam radius
- [ ] Jika tidak ada outlet dalam radius, tampilkan warning + opsi "Tetap absen (butuh approval)"
- [ ] Tambah field `outlet_id` ke `CheckInRequest` dan `AttendanceRecord`
- [ ] Update `attendance_repository.dart` untuk kirim `outlet_id` saat check-in
- [ ] Tambah kolom `outlet_id` (FK) di `absensi_ider` Directus

**File baru/ubah:**
- `lib/features/attendance/presentation/widgets/outlet_picker_sheet.dart` (baru)
- `lib/features/attendance/data/attendance_model.dart` — tambah `outletId`
- `lib/features/attendance/data/attendance_repository.dart` — kirim `outlet_id`
- `lib/features/attendance/presentation/check_in_page.dart` — integrasi picker

**DoD:**
- User bisa pilih outlet dari bottom sheet
- Record absensi tersimpan dengan `outlet_id` yang benar

### 1.3 Geofencing Validation

**Deliverable:** Validasi radius berdasarkan outlet terpilih, bukan hardcoded.

**Task:**
- [ ] Refactor `LocationUtils`:
  - Hapus `distanceToOffice` & `isWithinOfficeRadius` yang hardcoded
  - Tambah `distanceToOutlet(Outlet outlet, double lat, double lng)`
  - Tambah `isWithinOutletRadius(Outlet outlet, double lat, double lng)`
- [ ] Update `check_in_page.dart`:
  - Ambil GPS → cari outlet terdekat → validasi radius
  - Tampilkan jarak ke outlet di `LocationCard`
  - Jika di luar radius: disable tombol submit, tampilkan info "Anda X meter dari outlet Y"
- [ ] Update `check_out_page.dart` dengan validasi yang sama
- [ ] Hapus `AppConfig.officeLatitude/Longitude/officeRadiusMeters` (dipindah ke data outlet)

**File yang diubah:**
- `lib/core/utils/location_utils.dart`
- `lib/core/config/app_config.dart` — hapus constant office
- `lib/features/attendance/presentation/check_in_page.dart`
- `lib/features/attendance/presentation/check_out_page.dart`
- `lib/features/attendance/presentation/widgets/location_card.dart`

**DoD:**
- Check-in hanya bisa dilakukan jika dalam radius outlet terpilih
- UI menampilkan jarak real-time ke outlet

### 1.4 Map Preview Interaktif

**Deliverable:** Google Maps dengan marker outlet + lokasi user.

**Task:**
- [ ] Buat widget `OutletMapWidget` menggunakan `google_maps_flutter`:
  - Marker untuk semua outlet (merah = di luar radius, hijau = di dalam radius)
  - Marker biru untuk lokasi user saat ini
  - Circle polygon untuk visualisasi radius tiap outlet
  - Auto-zoom ke outlet terdekat
- [ ] Tambah map preview di `check_in_page.dart` (di atas `LocationCard`)
- [ ] Tambah map preview di `home_page.dart` (mini map di greeting card)
- [ ] Setup Google Maps API Key:
  - Android: `android/app/src/main/AndroidManifest.xml` (meta-data)
  - iOS: `ios/Runner/AppDelegate.swift` (GMSServices)
  - Simpan API key di `AppConfig` (bukan hardcoded, pake `--dart-define`)

**File baru/ubah:**
- `lib/features/attendance/presentation/widgets/outlet_map_widget.dart` (baru)
- `lib/features/attendance/presentation/check_in_page.dart`
- `lib/features/attendance/presentation/home_page.dart`
- `android/app/src/main/AndroidManifest.xml`
- `ios/Runner/AppDelegate.swift`

**DoD:**
- Map render dengan marker outlet & user
- Circle radius terlihat di map
- Tap marker outlet → tampilkan nama & jarak

### 1.5 Offline Location Cache

**Deliverable:** Koordinat outlet di-cache lokal, validasi tetap jalan offline.

**Task:**
- [ ] Tambah dependency `shared_preferences` (atau `flutter_secure_storage` yang sudah ada)
- [ ] Cache list outlet di `OutletRepository` dengan TTL 24 jam
- [ ] Saat offline, gunakan outlet dari cache untuk validasi radius
- [ ] Tampilkan banner "Mode offline — data outlet dari cache" jika tidak ada koneksi

**File yang diubah:**
- `lib/features/outlet/data/outlet_repository.dart`
- `lib/core/network/directus_client.dart` — tambah helper `isOnline()`

**DoD:**
- App bisa validasi radius tanpa internet (selama outlet sudah pernah di-cache)
- Banner offline muncul saat tidak ada koneksi

### 1.6 Testing v1.1

- [ ] `test/features/outlet/data/outlet_repository_test.dart`
- [ ] `test/features/outlet/data/outlet_model_test.dart`
- [ ] `test/core/utils/location_utils_test.dart` — update untuk multi-outlet
- [ ] Widget test `OutletPickerSheet`, `OutletMapWidget` (mock GoogleMap)

---

## Tahap 2 — v1.2 Offline Mode

**Tujuan:** App tetap berfungsi saat tidak ada internet; sync otomatis saat online.
**Estimasi:** 10–14 hari kerja
**Branch:** `feature/v1.2-offline-mode`

### 2.1 Local SQLite Cache

**Deliverable:** Riwayat absensi & data user di-cache di SQLite.

**Task:**
- [ ] Tambah dependencies:
  ```yaml
  sqflite: ^2.3.0
  path: ^1.8.3
  drift: ^2.14.0          # ORM di atas sqflite
  drift_dev: ^2.14.0      # dev
  sqlite3_flutter_libs: ^0.5.0
  ```
- [ ] Buat `lib/core/database/app_database.dart` (drift setup):
  - Tables: `AttendanceEntity`, `OutletEntity`, `PendingSyncEntity`, `UserEntity`
- [ ] Buat `lib/core/database/daos/attendance_dao.dart`:
  - `insertAttendance`, `getAttendanceByDate`, `getAllAttendance`, `deleteAll`
- [ ] Buat `lib/core/database/daos/outlet_dao.dart`
- [ ] Buat `lib/core/database/daos/pending_sync_dao.dart`
- [ ] Update `AttendanceRepository`:
  - Saat fetch history: cek SQLite dulu → tampilkan → fetch API → update SQLite
  - Pattern: **cache-first, network-refresh**

**File baru:**
- `lib/core/database/app_database.dart`
- `lib/core/database/daos/attendance_dao.dart`
- `lib/core/database/daos/outlet_dao.dart`
- `lib/core/database/daos/pending_sync_dao.dart`
- `lib/core/database/daos/user_dao.dart`

**DoD:**
- History page bisa render dari SQLite saat offline
- Data SQLite ter-update saat fetch API sukses

### 2.2 Offline Queue untuk Absensi

**Deliverable:** Check-in/check-out bisa dilakukan offline, di-queue untuk sync.

**Task:**
- [ ] Buat `lib/features/sync/data/sync_repository.dart`:
  - `enqueueCheckIn(CheckInRequest, XFile selfie)`
  - `enqueueCheckOut(CheckOutRequest)`
  - `getPendingSyncs()`
  - `markSynced(id)`, `markFailed(id, error)`
- [ ] Saat check-in:
  - Cek koneksi internet
  - Jika online: langsung kirim ke API (existing flow)
  - Jika offline: simpan ke `PendingSyncEntity` + selfie di local file
  - Tampilkan badge "X absensi pending sync" di home
- [ ] Saat check-out: sama
- [ ] Buat `lib/features/sync/providers/sync_providers.dart`:
  - `pendingSyncCountProvider` — jumlah antrian
  - `syncAllProvider` — trigger sync manual

**File baru:**
- `lib/features/sync/data/sync_repository.dart`
- `lib/features/sync/providers/sync_providers.dart`
- `lib/features/sync/presentation/widgets/pending_sync_badge.dart`

**DoD:**
- Check-in offline berhasil (data tersimpan lokal)
- Badge pending sync muncul di home
- Tombol "Sync Now" memproses antrian

### 2.3 Background Sync dengan Workmanager

**Deliverable:** Sync otomatis saat network restored, tanpa buka app.

**Task:**
- [ ] Tambah dependencies:
  ```yaml
  workmanager: ^0.5.2
  connectivity_plus: ^5.0.2
  ```
- [ ] Buat `lib/core/background/sync_worker.dart`:
  - `callbackDispatcher` → jalankan `SyncRepository.syncAll()`
  - Register di `main.dart` dengan `Workmanager().initialize()`
  - Schedule periodic task (setiap 15 menit) + constraints: `networkType: connected`
- [ ] Tambah listener `connectivity_plus` di `app.dart`:
  - Saat status berubah ke online → trigger sync langsung
- [ ] Notifikasi lokal saat sync selesai (bridge ke v1.3)

**File baru/ubah:**
- `lib/core/background/sync_worker.dart` (baru)
- `lib/main.dart` — init workmanager
- `lib/app.dart` — listener connectivity

**DoD:**
- Background sync jalan setiap 15 menit saat online
- Saat phone reconnect, sync langsung trigger

### 2.4 Conflict Resolution

**Deliverable:** Handle konflik jika absensi sudah ada di server.

**Task:**
- [ ] Saat sync check-in, jika server return 400 (sudah ada absensi tanggal itu):
  - Bandingkan data lokal vs server
  - Strategi: **server wins** untuk field yang sudah ada, **local wins** untuk field kosong
  - Update SQLite dengan hasil merge
- [ ] Saat sync check-out, jika record sudah ada `pulang`:
  - Tampilkan notifikasi "Check-out tanggal X sudah pernah dilakukan"
  - Simpan log konflik untuk audit
- [ ] Buat `lib/features/sync/data/conflict_resolver.dart`

**File baru:**
- `lib/features/sync/data/conflict_resolver.dart`

**DoD:**
- Konflik tidak menyebabkan crash
- Data final konsisten antara lokal & server
- Log konflik tersimpan untuk audit

### 2.5 Testing v1.2

- [ ] `test/core/database/daos/attendance_dao_test.dart`
- [ ] `test/features/sync/data/sync_repository_test.dart`
- [ ] `test/features/sync/data/conflict_resolver_test.dart`
- [ ] Integration test: check-in offline → enable network → verify sync

---

## Tahap 3 — v1.3 Notifications & Reminders

**Tujuan:** Reminder check-in/check-out + holiday awareness.
**Estimasi:** 5–7 hari kerja
**Branch:** `feature/v1.3-notifications`

### 3.1 Local Notifications Setup

**Deliverable:** Schedule reminder harian check-in (08:00) & check-out (17:00).

**Task:**
- [ ] Tambah dependencies:
  ```yaml
  flutter_local_notifications: ^16.3.0
  timezone: ^0.9.2
  flutter_timezone: ^1.0.8
  ```
- [ ] Buat `lib/core/notifications/notification_service.dart`:
  - `init()` — setup channels (Android) & request permission (iOS)
  - `scheduleDailyReminder(hour, minute, title, body)`
  - `cancelAll()`
- [ ] Channel Android: `attendance_reminders` (importance: high)
- [ ] Schedule di `main.dart` setelah login sukses:
  - 08:00 → "Sudah check-in belum? Jangan lupa absen masuk!"
  - 17:00 → "Sudah check-out? Absen pulang dulu sebelum pulang!"
- [ ] Tap notification → buka app ke `/home` atau langsung `/check-in`

**File baru:**
- `lib/core/notifications/notification_service.dart`

**DoD:**
- Notifikasi muncul di jam yang dijadwalkan
- Tap notifikasi membuka app

### 3.2 Holiday Awareness

**Deliverable:** Skip reminder pada hari libur.

**Task:**
- [ ] Buat collection `hari_libur` di Directus:
  ```sql
  CREATE TABLE hari_libur (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tanggal DATE NOT NULL UNIQUE,
    nama VARCHAR(100) NOT NULL,
    is_nasional BOOLEAN DEFAULT TRUE
  );
  ```
- [ ] Buat `lib/features/holiday/data/holiday_repository.dart` — fetch & cache 1 tahun
- [ ] Sebelum schedule reminder, cek apakah besok hari libur:
  - Jika ya: skip reminder
  - Jika kerja: schedule seperti biasa
- [ ] Tampilkan indikator "Hari Libur: Nama Libur" di home page

**File baru:**
- `lib/features/holiday/data/holiday_model.dart`
- `lib/features/holiday/data/holiday_repository.dart`
- `lib/features/holiday/providers/holiday_providers.dart`

**DoD:**
- Reminder tidak muncul di hari libur
- Home page menampilkan info hari libur

### 3.3 Push Notification (Optional, untuk v1.3+)

**Deliverable:** Notifikasi dari backend (misal: approval cuti, pengumuman).

**Task:**
- [ ] Tambah dependencies:
  ```yaml
  firebase_messaging: ^14.7.0
  firebase_core: ^2.24.0
  ```
- [ ] Setup Firebase project untuk IderKopi Absensi
- [ ] Daftarkan token FCM ke backend (tabel `device_tokens` di Directus)
- [ ] Handle foreground & background message
- [ ] Topik: `announcement`, `leave_approval`, `attendance_reminder`

**File baru:**
- `lib/core/notifications/push_notification_service.dart`
- `lib/features/auth/data/device_token_repository.dart`

**DoD:**
- Notifikasi push diterima di foreground & background
- Token FCM terdaftar di backend

### 3.4 Settings Page untuk Notification

**Deliverable:** User bisa enable/disable reminder.

**Task:**
- [ ] Buat `lib/features/settings/presentation/settings_page.dart`:
  - Toggle: Reminder check-in (on/off + time picker)
  - Toggle: Reminder check-out (on/off + time picker)
  - Toggle: Push notification
- [ ] Simpan preferensi di `shared_preferences`
- [ ] Tambah route `/settings` & entry di profile page

**File baru:**
- `lib/features/settings/presentation/settings_page.dart`
- `lib/features/settings/providers/settings_providers.dart`

**DoD:**
- User bisa matikan/nyalakan reminder
- Perubahan langsung efektif

### 3.5 Testing v1.3

- [ ] `test/core/notifications/notification_service_test.dart`
- [ ] `test/features/holiday/data/holiday_repository_test.dart`
- [ ] Integration test: schedule reminder → verify fired (mock time)

---

## Tahap 4 — v2.0 Integrasi Go Backend

**Tujuan:** Pindah dari Directus ke Go backend custom; tambah fitur leave, KPI, shift.
**Estimasi:** 20–30 hari kerja (termasuk backend)
**Branch:** `feature/v2.0-go-backend`

### 4.1 Go Backend — Foundation

**Deliverable:** Go API server dengan auth, migration, dan endpoint paritas Directus.

**Task:**
- [ ] Inisialisasi project Go: `github.com/iderkopi/backend-go`
- [ ] Tech stack:
  - Framework: **Echo** atau **Gin** (pilih satu, konsisten)
  - Database: **PostgreSQL** (sama seperti Directus)
  - ORM: **GORM** atau **sqlc** (rekomendasi: sqlc untuk type safety)
  - Migration: **golang-migrate**
  - Auth: **JWT** (access + refresh)
  - Docs: **OpenAPI/Swagger** via `swaggo/swag`
- [ ] Struktur folder:
  ```
  backend-go/
  ├── cmd/server/main.go
  ├── internal/
  │   ├── config/
  │   ├── handler/
  │   ├── service/
  │   ├── repository/
  │   ├── model/
  │   └── middleware/
  ├── migrations/
  ├── docs/             # Swagger
  └── go.mod
  ```
- [ ] Endpoint paritas Directus (untuk migrasi bertahap):
  - `POST /api/v1/auth/login`
  - `POST /api/v1/auth/refresh`
  - `POST /api/v1/auth/logout`
  - `GET /api/v1/users/me`
  - `GET /api/v1/attendance/today`
  - `POST /api/v1/attendance/check-in`
  - `PATCH /api/v1/attendance/check-out/:id`
  - `GET /api/v1/attendance/history`
  - `GET /api/v1/outlets`
  - `GET /api/v1/admin/users`
  - `GET /api/v1/admin/attendance`
- [ ] Migration: import data dari Directus PostgreSQL (sama DB, tinggal pointing)

**File baru:** (repo terpisah `iderkopi/backend-go`)

**DoD:**
- Semua endpoint paritas jalan & lulus test
- Swagger docs accessible di `/swagger/index.html`
- App Flutter bisa switch antara Directus & Go via `AppConfig.apiProvider`

### 4.2 Flutter — Abstract API Layer

**Deliverable:** App bisa switch antara Directus & Go backend tanpa rewrite.

**Task:**
- [ ] Buat interface `AttendanceDataSource` (abstract class)
- [ ] Implementasi `DirectusAttendanceDataSource` (existing, refactor)
- [ ] Implementasi `GoAttendanceDataSource` (baru, sesuaikan response Go)
- [ ] Buat `lib/core/config/api_provider.dart`:
  ```dart
  enum ApiProvider { directus, goBackend }
  ```
- [ ] `AttendanceRepository` menerima `AttendanceDataSource` (DI)
- [ ] Sama untuk `AuthDataSource`, `OutletDataSource`, `AdminDataSource`
- [ ] Config via `--dart-define=API_PROVIDER=goBackend`

**File baru/ubah:**
- `lib/core/data/attendance_data_source.dart` (interface)
- `lib/core/data/directus_attendance_data_source.dart`
- `lib/core/data/go_attendance_data_source.dart`
- `lib/core/config/api_provider.dart`
- Semua repository di-refactor untuk pakai interface

**DoD:**
- Flip `API_PROVIDER` → app pakai backend yang benar
- Smoke test lulus untuk kedua provider

### 4.3 Leave Request (Pengajuan Izin/Sakit/Cuti)

**Deliverable:** Karyawan bisa ajukan izin/sakit/cuti; manager approve/reject.

**Task:**
- [ ] Backend Go: tabel `leave_requests`
  ```sql
  CREATE TABLE leave_requests (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(id),
    type VARCHAR(20) NOT NULL,  -- 'izin', 'sakit', 'cuti'
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    reason TEXT,
    attachment_file_id VARCHAR(36),  -- surat dokter dll
    status VARCHAR(20) DEFAULT 'pending',  -- pending, approved, rejected
    approver_id INT REFERENCES users(id),
    approved_at TIMESTAMP,
    approver_note TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  );
  ```
- [ ] Endpoint Go:
  - `POST /api/v1/leaves` — submit request
  - `GET /api/v1/leaves` — list milik user
  - `GET /api/v1/leaves/pending` — untuk manager
  - `PATCH /api/v1/leaves/:id/approve`
  - `PATCH /api/v1/leaves/:id/reject`
- [ ] Flutter: `lib/features/leave/`
  - `leave_model.dart`, `leave_repository.dart`, `leave_providers.dart`
  - `presentation/leave_list_page.dart` — list pengajuan user
  - `presentation/leave_form_page.dart` — form ajuan (jenis, tanggal, alasan, upload surat)
  - `presentation/leave_approval_page.dart` — untuk manager (list pending + approve/reject)
- [ ] Tambah tab/bottom nav entry "Izin" untuk user
- [ ] Tambah menu "Approval" di admin panel

**File baru:**
- `lib/features/leave/data/leave_model.dart`
- `lib/features/leave/data/leave_repository.dart`
- `lib/features/leave/providers/leave_providers.dart`
- `lib/features/leave/presentation/leave_list_page.dart`
- `lib/features/leave/presentation/leave_form_page.dart`
- `lib/features/leave/presentation/leave_approval_page.dart`

**DoD:**
- User bisa submit pengajuan izin/sakit/cuti
- Manager bisa approve/reject
- Status update real-time (atau pull-to-refresh)

### 4.4 KPI Preview

**Deliverable:** Karyawan lihat KPI score sendiri (kehadiran, keterlambatan, performance).

**Task:**
- [ ] Backend Go: view/table `kpi_summary`
  - Hitung otomatis: % kehadiran, jumlah terlambat, jumlah alpha, jumlah cuti
  - Refresh via cron job atau on-demand
- [ ] Endpoint: `GET /api/v1/kpi/me?month=YYYY-MM`
- [ ] Flutter: `lib/features/kpi/`
  - `kpi_model.dart` — score, kehadiran %, terlambat count, alpha count
  - `kpi_repository.dart`, `kpi_providers.dart`
  - `presentation/kpi_page.dart` — card score + breakdown
- [ ] Tambah entry di profile page "Lihat KPI saya"

**File baru:**
- `lib/features/kpi/data/kpi_model.dart`
- `lib/features/kpi/data/kpi_repository.dart`
- `lib/features/kpi/providers/kpi_providers.dart`
- `lib/features/kpi/presentation/kpi_page.dart`

**DoD:**
- KPI page menampilkan score & breakdown bulanan
- Data konsisten dengan data absensi

### 4.5 Attendance Recap dengan Grafik

**Deliverable:** Summary bulanan dengan grafik (bar/line chart).

**Task:**
- [ ] Tambah dependency `fl_chart: ^0.66.0`
- [ ] Backend: `GET /api/v1/attendance/recap?month=YYYY-MM` — return agregasi harian
- [ ] Flutter: `lib/features/recap/`
  - `recap_model.dart` — list harian: tanggal, status, jam masuk/pulang
  - `recap_repository.dart`, `recap_providers.dart`
  - `presentation/recap_page.dart`:
    - Bar chart: kehadiran per minggu
    - Pie chart: distribusi status (tepat waktu, terlambat, alpha, cuti)
    - Tabel detail per hari
- [ ] Tambah entry di profile/home "Rekap Bulanan"

**File baru:**
- `lib/features/recap/data/recap_model.dart`
- `lib/features/recap/data/recap_repository.dart`
- `lib/features/recap/providers/recap_providers.dart`
- `lib/features/recap/presentation/recap_page.dart`
- `lib/features/recap/presentation/widgets/attendance_bar_chart.dart`
- `lib/features/recap/presentation/widgets/status_pie_chart.dart`

**DoD:**
- Grafik render dengan data bulanan
- Bisa ganti bulan via picker

### 4.6 Shift Schedule

**Deliverable:** Karyawan lihat jadwal shift; admin bisa assign shift.

**Task:**
- [ ] Backend Go: tabel `shifts` & `user_shifts`
  ```sql
  CREATE TABLE shifts (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,        -- 'Pagi', 'Siang', 'Malam'
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    outlet_id INT REFERENCES outlet_ider(id)
  );
  CREATE TABLE user_shifts (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(id),
    shift_id INT NOT NULL REFERENCES shifts(id),
    date DATE NOT NULL,
    UNIQUE(user_id, date)
  );
  ```
- [ ] Endpoint:
  - `GET /api/v1/shifts/mine` — jadwal shift user login
  - `POST /api/v1/admin/shifts/assign` — admin assign shift
  - `GET /api/v1/admin/shifts` — list semua shift
- [ ] Flutter: `lib/features/shift/`
  - `shift_model.dart`, `shift_repository.dart`, `shift_providers.dart`
  - `presentation/shift_schedule_page.dart` — calendar view jadwal
  - Admin: `presentation/admin_shift_assign_page.dart`
- [ ] Integrasi dengan attendance: jika user check-in di luar jam shift → flag "off-shift"

**File baru:**
- `lib/features/shift/data/shift_model.dart`
- `lib/features/shift/data/shift_repository.dart`
- `lib/features/shift/providers/shift_providers.dart`
- `lib/features/shift/presentation/shift_schedule_page.dart`
- `lib/features/admin/presentation/admin_shift_assign_page.dart`

**DoD:**
- User lihat jadwal shift dalam calendar view
- Admin bisa assign shift ke karyawan
- Check-in di luar jam shift ter-flag

### 4.7 Sync dengan HRIS Web

**Deliverable:** Data ter-sync dengan dashboard web (jika ada).

**Task:**
- [ ] Identifikasi HRIS web yang dipakai (atau build dashboard web baru dengan Flutter Web)
- [ ] Jika build sendiri: gunakan Flutter Web share codebase dengan app mobile
- [ ] Endpoint Go sudah menyediakan data yang sama, web tinggal konsumsi
- [ ] Realtime update via WebSocket (opsional) atau polling 30 detik

**DoD:**
- Perubahan di app langsung terlihat di web (dalam 30 detik)

### 4.8 Testing v2.0

- [ ] Backend Go: unit test untuk semua handler & service (coverage ≥ 70%)
- [ ] Backend Go: integration test dengan testcontainers PostgreSQL
- [ ] Flutter: test untuk `GoAttendanceDataSource` (mock Dio)
- [ ] Flutter: widget test untuk leave form, KPI page, recap page, shift page
- [ ] E2E test: login → ajukan cuti → manager approve → cek KPI ter-update

---

## Testing Strategy per Fase

| Fase | Unit Test | Widget Test | Integration Test | Manual Test |
|------|-----------|-------------|-------------------|-------------|
| 0 | Repository, utils, model | Login, Home, CheckIn (smoke) | — | Login Directus asli |
| 1.1-1.5 | Outlet repo, location utils | OutletPicker, OutletMap | — | GPS accuracy multi-outlet |
| 2.1-2.4 | DAO, sync repo, conflict | PendingSyncBadge | Offline check-in → sync | Offline mode real device |
| 3.1-3.4 | Notification service, holiday | Settings page | Schedule reminder | Notifikasi di real device |
| 4.1-4.7 | Go backend, data source | Leave, KPI, Recap, Shift | Full E2E flow | Performance dengan data 1 tahun |

## Deployment Pipeline

| Versi | Platform | Method | Channel |
|-------|----------|--------|---------|
| v1.0.0 | Android APK | `flutter build apk --release` + GitHub Release | Internal testing |
| v1.1 | Android APK | GitHub Release | Internal + outlet pilot |
| v1.2 | Android APK | GitHub Release | Internal + outlet pilot |
| v1.3 | Android Play Store | Google Play Console (Internal → Closed → Production) | Closed testing |
| v2.0 | Android + iOS | Play Store + App Store | Production rollout |

### Release Checklist (per rilis)

- [ ] Update `pubspec.yaml` version
- [ ] Update `CHANGELOG.md`
- [ ] `flutter analyze` — 0 warning
- [ ] `flutter test` — semua lulus
- [ ] Build APK release → install di device test → smoke test
- [ ] Tag git `vX.Y.Z` + push tag
- [ ] CI build & upload ke GitHub Releases
- [ ] Update dokumentasi (jika ada breaking change)

---

## Risiko & Mitigasi Global

| Risiko | Dampak | Mitigasi |
|--------|--------|----------|
| Directus API down | App tidak bisa absen | Offline mode (v1.2) + fallback ke local queue |
| GPS tidak akurat | False negative radius | Toleransi +10m, opsi manual override dengan approval |
| Google Maps API key bocor | Biaya tagihan | Restrict key by app package + SHA-1 di Google Cloud Console |
| Backend Go delay | v2.0 mundur | Tetap pakai Directus untuk v1.x, Go hanya untuk v2.0 |
| Data migration Directus → Go | Kehilangan data | Same PostgreSQL DB, tinggal pointing; backup sebelum switch |
| Perubahan schema Directus breaking | App crash | Versi API di header (`Accept-Version: v1`); semver ketat |
| Performa SQLite dengan data besar | App lambat | Pagination di DAO, index pada `tanggal_absensi` & `kangider_id` |
| Notifikasi tidak muncul di Xiaomi/Oppo | User tidak ingat absen | Dokumentasi "disable battery optimization" + cek permission saat startup |

---

## Glossarium

- **DoD** — Definition of Done, kriteria sebuah task dianggap selesai
- **DAO** — Data Access Object, layer akses database
- **DI** — Dependency Injection
- **FCM** — Firebase Cloud Messaging
- **HRIS** — Human Resource Information System
- **KPI** — Key Performance Indicator
- **MVP** — Minimum Viable Product
- **TTL** — Time To Live, masa berlaku cache
- **Workmanager** — Plugin Flutter untuk background task terjadwal

---

## Catatan Implementasi

- **Urutan eksekusi wajib:** Tahap 0 → 1 → 2 → 3 → 4. Jangan skip Tahap 0.
- **Setiap tahap punya branch sendiri**, merge ke `dev` setelah DoD tercapai.
- **Code review wajib** sebelum merge (minimal 1 reviewer).
- **Demo ke stakeholder** di akhir setiap tahap.
- **Update dokumen ini** setiap ada perubahan scope atau setelah tahap selesai (tandai dengan ✅).
