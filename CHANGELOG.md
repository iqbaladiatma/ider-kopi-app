# Changelog

## 2.0.0 — Custom Go API

- Satu backend Go/Fiber dan PostgreSQL untuk seluruh fitur mobile.
- Auth JWT/refresh, profil employee, attendance, outlet, geofence, selfie, holiday, shift, leave, recap, KPI, dan admin.
- UUID string end-to-end termasuk SQLite/offline queue.
- Idempotent check-in/check-out dan background replay.
- Conditional storage untuk native dan web.
- Role barriers dan cache cleanup pada logout.
- Production mock fallback dan geofence bypass dihapus.

## 1.0.0 — MVP

- Login, check-in/check-out, history, dan profile dasar.