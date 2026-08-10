# Arsitektur

```text
Flutter Android/iOS/Web
  ├─ ApiClient + JWT refresh
  ├─ feature repositories
  ├─ SQLite cache/offline queue
  └─ GPS/camera
          │ HTTP /api/v1
          ▼
Go Fiber API :2026
  ├─ authentication dan role middleware
  ├─ employee/mobile handlers
  ├─ geofence dan idempotency
  ├─ persistent selfie storage
  └─ repositories
          │
          ▼
PostgreSQL
```

## Prinsip

- Satu API client dan satu backend.
- Response mengikuti envelope Go: `success`, `data`, `message`, dan `error`.
- Employee self-route memetakan JWT `users.id` ke `employees.id` di server.
- Geofence divalidasi ulang oleh server terhadap outlet aktif.
- Check-in/check-out memakai `client_request_id` agar retry offline idempotent.
- Error online tidak disamarkan dengan mock.
- Token dan credential tidak dicatat dalam log.

Default API adalah `http://100.90.46.31:2026/api/v1`; port `9000` hanya dashboard.
