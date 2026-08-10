# Custom Go API Contract

Base path: `/api/v1`.

## Public

- `POST /auth/login`
- `POST /auth/refresh`
- `GET /health` berada di root server.

## Employee authenticated

- `GET /auth/me`
- `POST /auth/logout`
- `GET /employees/me`
- `GET /employees/me/shift`
- `GET /outlets`
- `GET /holidays?year=YYYY`
- `POST /attendance/selfie`
- `POST /attendance/check-in`
- `POST /attendance/check-out`
- `GET /attendance/today`
- `GET /attendance/history?month=YYYY-MM`
- `GET /attendance/recap/me?month=YYYY-MM`
- `POST /attendance/leave-requests`
- `GET /attendance/leave-requests/me`
- `DELETE /attendance/leave-requests/me/:id`
- `GET /kpi/me`

## Kontrak data

- Entity ID memakai UUID string.
- Upload selfie berupa multipart dan menghasilkan storage key/URL.
- Koordinat wajib valid dan outlet harus aktif.
- `client_request_id` wajib stabil saat retry offline.
- List kosong adalah data valid; aplikasi tidak membuat koordinat palsu.