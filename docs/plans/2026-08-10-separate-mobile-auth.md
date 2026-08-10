# Separate Mobile Authentication Implementation Plan

> **For Hermes:** Use subagent-driven-development skill to implement this plan task-by-task.

**Goal:** Memisahkan authentication Flutter sepenuhnya dari backend/database utama IDER KOPI sambil tetap menyinkronkan profil employee secara read-only dari API IDER KOPI.

**Architecture:** Backend utama port 2026 hanya menyediakan employee/attendance/business data dan endpoint service-to-service read-only untuk sinkronisasi employee. Backend auth baru di `auth-backend/` berjalan pada port 2027 dengan PostgreSQL/volume sendiri, menyimpan account, bcrypt hash, JWT/refresh token, dan forced first-login password change. Flutter memakai dua base URL: auth ke 2027 dan business/employee ke 2026.

**Tech Stack:** Go 1.23, Fiber, pgx/PostgreSQL, JWT, bcrypt, Flutter/Riverpod/GoRouter, Docker Compose/OrbStack.

---

### Task 1: Cleanup dan employee sync API backend utama

**Objective:** Hapus coupling mobile login dari backend utama, pertahankan employee brand, dan sediakan employee sync endpoint read-only dengan service token.

**Files:**
- Modify backend auth/middleware/routes/models/repositories yang berubah pada migration 000014.
- Delete `backend/cmd/provision_employee_accounts/`.
- Create additive cleanup migration setelah 000014; jangan rewrite migration applied.
- Add tests for service-token authorization and read-only employee payload.

**Verification:** `gofmt`, `go test ./...`, migration up on disposable clone, API unauthorized/authorized contract tests.

### Task 2: Backend auth terpisah milik Flutter

**Objective:** Buat service auth mandiri dengan database sendiri dan sinkronisasi employee dari API utama.

**Files:**
- Create `auth-backend/go.mod`, `cmd/api`, `cmd/migrate`, `cmd/sync_employees`, `cmd/provision_accounts`.
- Create internal config/model/repository/service/handler/middleware packages.
- Create additive migrations for `employees`, `users`, `roles`, and `refresh_tokens` in auth DB.
- Modify Flutter workspace Docker Compose with `auth-db`, `auth-migrations`, and `auth-api` services; port auth API 2027; use named volume separate.

**Requirements:** bcrypt only; unique normalized emails and external employee IDs; JWT access/refresh; login/me/refresh/logout/change-password; server-side `must_change_password` enforcement; transactional idempotent sync/provisioning; no plaintext password logs/source; service sync token runtime-only; unit/integration tests.

**Verification:** `go test ./...`, Docker build, isolated migration, sync dry-run/apply/retry, provisioning dry-run/apply/retry.

### Task 3: Flutter dual-API integration

**Objective:** Arahkan auth ke backend auth 2027 dan employee/attendance/business data ke backend utama 2026.

**Files:**
- Modify app config, API clients/interceptors, auth repository/model/router/change-password flow.
- Ensure tokens are only sent to auth service unless a business endpoint explicitly requires a separate business token.
- Add/update tests for login, restart/deep-link forced password change, logout, and URL routing.

**Verification:** `dart format`, `flutter analyze`, `flutter test --concurrency=1`, `flutter build web`.

### Task 4: Integration, security review, and deployment

**Objective:** Verify complete split and deploy without deleting either PostgreSQL volume.

**Steps:**
1. Spec review then security/code-quality review for all three workstreams.
2. Run full Go and Flutter gates plus Graphify updates.
3. Backup production backend DB; create separate auth DB volume.
4. Apply backend cleanup migration and deploy backend 2026.
5. Deploy auth DB/API 2027 and Flutter web 9100.
6. Configure service sync secret outside source.
7. Sync 33 active employees and verify 25 IDER KOPI / 8 IDER POINT.
8. Provision accounts with hidden temporary-password input and forced first-login change.
9. Smoke test 2026/2027/9000/9100 and verify database separation.

**Safety:** Tidak commit/push; tidak membaca/menampilkan credential; tidak menghapus volume; tidak menggunakan API employee sebagai auth provider.
