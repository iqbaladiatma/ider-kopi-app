# Dokumentasi Lengkap IDER KOPI Mobile

## Sistem

Flutter berkomunikasi dengan custom Go/Fiber API. API menyimpan domain employee, attendance, KPI, outlet, shift, leave, recap, dan holiday di PostgreSQL. Dashboard Next.js adalah client lain dari API yang sama.

## Konfigurasi

Default mobile API adalah `http://100.90.46.31:2026/api/v1`. Environment lain memakai `--dart-define=CUSTOM_API_BASE_URL=http://HOST:2026/api/v1`. Port `9000` hanya dashboard web.

## Authentication

Access token dikirim sebagai Bearer token. Interceptor melakukan single-flight refresh saat 401; kegagalan refresh membersihkan sesi dan cache user.

## Attendance

1. Aplikasi mengambil outlet aktif.
2. Device mengambil GPS dan selfie.
3. Selfie di-upload dengan multipart.
4. Request mengirim UUID outlet, koordinat, storage key, dan `client_request_id`.
5. Server memvalidasi outlet, Haversine/radius, user→employee, dan idempotency.

Operasi retryable disimpan di SQLite ketika network gagal. Replay hanya dihapus setelah respons server sukses.

## Empty state dan error

- Outlet kosong ditampilkan sebagai actionable empty state.
- Aplikasi tidak membuat outlet, lokasi, atau KPI palsu.
- Error server diteruskan ke UI atau offline queue sesuai jenis operasi.

## Operasional

- Health: `GET /health`.
- API: port `2026`.
- Dashboard: port `9000`.
- PostgreSQL lokal: port `5433`.
- Selfie tersimpan pada persistent Docker volume.

## Verification

```bash
flutter analyze
flutter test
cd /Users/ainud/Projects/ider-kopi/backend && go test ./...
```

Setelah perubahan kode jalankan `graphify update .` pada masing-masing workspace.