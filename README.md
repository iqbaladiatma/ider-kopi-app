# IDER KOPI Mobile

Aplikasi Flutter untuk absensi dan layanan karyawan IDER KOPI. Aplikasi memakai satu backend custom Go/Fiber dan PostgreSQL.

## Runtime

- Dashboard web: `http://100.90.46.31:9000`
- Go API via Tailscale: `http://100.90.46.31:2026/api/v1`
- Health: `http://100.90.46.31:2026/health`
- Override build: `--dart-define=CUSTOM_API_BASE_URL=<url>/api/v1`

Jangan arahkan aplikasi mobile ke port `9000`; port tersebut hanya untuk dashboard Next.js.

## Fitur

- Login JWT dan refresh token.
- Profil karyawan, shift, KPI, leave, holiday, dan rekap.
- Check-in/check-out dengan outlet, GPS, geofence server, dan selfie.
- SQLite cache, offline queue, idempotency, background sync, dan conflict handling.
- Role barrier untuk employee dan admin.

## Development

```bash
flutter pub get
flutter analyze
flutter test
flutter run --dart-define=CUSTOM_API_BASE_URL=http://100.90.46.31:2026/api/v1
```

## Dokumentasi

- `docs/00-OVERVIEW.md`
- `docs/01-ARCHITECTURE.md`
- `docs/02-CUSTOM-GO-API.md`
- `docs/03-FLUTTER-STRUCTURE.md`
- `docs/DOKUMENTASI_LENGKAP.md`