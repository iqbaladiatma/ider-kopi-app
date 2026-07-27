# Directus Schema Changes & Setup

## 1. Collection: `absensi_ider` — New Fields

### Existing Fields

| Field | Type | Keterangan |
|-------|------|-----------|
| `id` | auto increment (int) | PK |
| `tanggal_absensi` | date | Tanggal absen |
| `masuk` | string (time) | Jam masuk (format: `HH:MM:SS`) |
| `pulang` | string (time) | Jam pulang (format: `HH:MM:SS`) |
| `kangider` | string | FK ke `kangider.id` |
| `keterangan` | string (nullable) | Catatan |

### New Fields (ditambahkan via Directus admin)

| Field | Type | Keterangan |
|-------|------|-----------|
| `latitude` | float (nullable) | GPS latitude saat check-in |
| `longitude` | float (nullable) | GPS longitude saat check-in |
| `selfie_file_id` | string (uuid, nullable) | Directus file ID untuk foto selfie check-in |
| `check_in_source` | string (default: "app") | Source: "app" / "manual" / "device" |
| `latitude_pulang` | float (nullable) | GPS latitude saat check-out |
| `longitude_pulang` | float (nullable) | GPS longitude saat check-out |
| `selfie_pulang_file_id` | string (uuid, nullable) | Directus file ID untuk foto selfie check-out |

### SQL Migration (referensi)

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

## 2. Collection: `kangider` (No Changes)

| Field | Type |
|-------|------|
| `id` | string (UUID) |
| `nama` | string |

## 3. Directus Role & Permissions Setup

### Buat Role Baru: "App User"

| Collection | Permission | Fields | Filter |
|-----------|-----------|--------|--------|
| `kangider` | **read** | `id, nama` | — |
| `absensi_ider` | **create** | `tanggal_absensi, masuk, pulang, kangider, keterangan, latitude, longitude, selfie_file_id, check_in_source, latitude_pulang, longitude_pulang, selfie_pulang_file_id` | — |
| `absensi_ider` | **read** | all fields | `kangider = CURRENT_USER.kangider_id` (user hanya lihat data sendiri) |
| `absensi_ider` | **update** | `pulang, latitude_pulang, longitude_pulang, selfie_pulang_file_id, keterangan` | `kangider = CURRENT_USER.kangider_id` |
| `files` | **create** | — | — |
| `files` | **read** | — | `uploaded_by = CURRENT_USER` |

### Notes
- App User **tidak bisa delete** absensi_ider
- App User hanya bisa read/update data miliknya sendiri (filter by kangider)
- Upload selfie via `/files` endpoint, lalu simpan file_id ke `absensi_ider`

## 4. User Account Setup

Setiap karyawan Kang Ider perlu akun Directus:

1. Buat user di Directus dengan email karyawan
2. Assign role "App User"
3. Set field custom `kangider_id` di user (untuk filtering absensi sendiri)

Alternatif: gunakan single service account (email/password yang sama untuk semua) jika MVP tidak butuh per-user isolation. Tapi **tidak recommended** untuk production.

## 5. Environment Configuration

```env
# Flutter app config
DIRECTUS_API_BASE_URL=https://api.iderkopi.id
DIRECTUS_EMAIL=               # service account or per-user
DIRECTUS_PASSWORD=
```

Untuk MVP, app akan menerima input email/password dari user di login page (per-user auth).
