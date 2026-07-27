# Arsitektur Sistem

## Diagram

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

## Flow

1. Flutter app login ke Directus → dapat `access_token` + `refresh_token`
2. Token disimpan di `FlutterSecureStorage`
3. Saat check-in:
   - App ambil GPS (lat/lng) via `geolocator`
   - App ambil selfie via `camera` → compress via `image`
   - Upload selfie ke `POST /files` → dapat `file_id`
   - Create record `absensi_ider` dengan: tanggal, jam masuk, kangider_id, lat/lng, selfie_file_id
4. Saat check-out:
   - Cari record absensi hari ini
   - PATCH record: jam pulang, lat/lng pulang
5. Riwayat: GET `absensi_ider` filtered by kangider, sorted by tanggal desc

## API Endpoints (Directus)

| Method | Endpoint | Fungsi |
|--------|----------|--------|
| `POST` | `/auth/login` | Login → access_token |
| `POST` | `/auth/refresh` | Refresh token |
| `GET` | `/items/kangider` | Daftar karyawan |
| `GET` | `/items/absensi_ider?filter[kangider][_eq]=XXX&filter[tanggal_absensi][_eq]=YYYY-MM-DD` | Cek absen hari ini |
| `POST` | `/files` | Upload selfie → file_id |
| `POST` | `/items/absensi_ider` | Create absensi (check-in) |
| `PATCH` | `/items/absensi_ider/:id` | Update absensi (check-out) |
| `GET` | `/items/absensi_ider?filter[kangider][_eq]=XXX&sort=-tanggal_absensi&limit=30` | Riwayat absensi |

## Auth Flow

```
Login Page
  │
  ▼
POST /auth/login { email, password }
  │
  ▼
┌─────────────────┐
│ access_token    │──▶ Store in FlutterSecureStorage
│ refresh_token   │──▶ Store in FlutterSecureStorage
│ expires         │
└─────────────────┘
  │
  ▼
Dio Interceptor:
  - Set Authorization: Bearer <token> on every request
  - On 401: call /auth/refresh → retry request
  - On refresh fail: redirect to login
```

## State Management (Riverpod)

| Provider | State | Fungsi |
|----------|-------|--------|
| `authProvider` | `AuthState` (authenticated/unauthenticated/loading) | Login, logout, token refresh |
| `attendanceProvider` | `AttendanceState` (today's check-in/out status) | Cek status absen hari ini |
| `locationProvider` | `LocationState` (loading/ready/denied/error) | GPS location |
| `historyProvider` | `AsyncValue<List<AttendanceRecord>>` | Riwayat 30 hari |
| `profileProvider` | `AsyncValue<UserProfile>` | Info karyawan + statistik |

## Error Handling Strategy

| Error Type | Handling |
|-----------|----------|
| Network timeout | Retry 3x dengan backoff, lalu show error page |
| 401 Unauthorized | Auto refresh token, retry request |
| 403 Forbidden | Show "Tidak ada akses" + logout |
| GPS denied | Show dialog "Buka Pengaturan" |
| Camera denied | Show dialog "Buka Pengaturan" |
| Upload failed | Retry upload, jika gagal 3x → simpan offline (future) |
