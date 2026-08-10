# IDER KOPI Mobile — Overview

Aplikasi mobile internal untuk absensi dan layanan karyawan. Semua data server berasal dari PostgreSQL melalui custom Go/Fiber API di project `/Users/ainud/Projects/ider-kopi`.

## Topologi

| Komponen | Alamat |
|---|---|
| Flutter API | `http://100.90.46.31:2026/api/v1` |
| Health | `http://100.90.46.31:2026/health` |
| Dashboard Next.js | `http://100.90.46.31:9000` |
| PostgreSQL lokal | port `5433` |

## Domain

- Auth dan profil employee.
- Attendance, selfie, outlet, geofence, holiday, shift.
- Leave request, rekap, KPI, dan admin outlet.
- Offline cache/queue SQLite dan background synchronization.

Port `9000` bukan endpoint API Flutter.