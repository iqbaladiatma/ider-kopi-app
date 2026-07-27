# Roadmap Pengembangan

## MVP (v1.0.0)

| Phase | Fitur | Estimasi |
|-------|-------|----------|
| **1** | Project setup: Flutter init, theme, router, Directus client | 1 hari |
| **2** | Auth: login page, token storage, auth interceptor | 1 hari |
| **3** | Home/Dashboard: greeting card, status hari ini, quick actions | 1 hari |
| **4** | Check-In: GPS location, camera selfie, upload, submit | 2 hari |
| **5** | Check-Out: update record, optional selfie | 0.5 hari |
| **6** | Riwayat: list 30 hari, filter bulan, thumbnail selfie | 1 hari |
| **7** | Profile: info karyawan, statistik bulanan, logout | 0.5 hari |
| **8** | Polish: animations, error states, empty states, testing | 1 hari |

**Total estimasi MVP: ~8 hari**

---

## v1.1 — Geofencing & Multi-Outlet

| Fitur | Keterangan |
|-------|-----------|
| Geofencing | Pre-define koordinat outlet, validasi radius (100m), warning jika di luar |
| Multi-outlet | Pilih outlet saat check-in (untuk karyawan yang rotasi) |
| Map preview interaktif | Google Maps dengan marker outlet & current location |
| Offline location cache | Simpan koordinat outlet untuk validasi offline |

## v1.2 — Offline Mode

| Fitur | Keterangan |
|-------|-----------|
| Offline queue | Simpan absensi saat no internet, sync saat online |
| Local SQLite | Cache riwayat absensi untuk akses offline |
| Background sync | Workmanager untuk auto-sync saat network restored |
| Conflict resolution | Handle jika absensi sudah ada di server |

## v1.3 — Notifications & Reminders

| Fitur | Keterangan |
|-------|-----------|
| Push notification | Reminder check-in (jam 8:00) & check-out (jam 17:00) |
| Local notifications | flutter_local_notifications untuk schedule |
| Holiday awareness | Skip reminder pada hari libur (data dari backend) |
| Badge counter | Jumlah absensi pending sync |

## v2.0 — Integrasi Go Backend

| Fitur | Keterangan |
|-------|-----------|
| Leave request | Ajukan izin/sakit/cuti dari app |
| Leave approval | Manager approve/reject dari app |
| KPI preview | Lihat KPI score sendiri |
| Attendance recap | Summary bulanan dengan grafik |
| Shift schedule | Lihat jadwal shift |
| Sync dengan HRIS web | Data ter-sync dengan dashboard web |

---

## Testing Strategy

| Level | Tool | Coverage |
|-------|------|----------|
| Unit test | flutter_test + mockito | Repository, controllers, utils |
| Widget test | flutter_test | Semua page + reusable widgets |
| Integration test | integration_test | Flow: login → check-in → check-out → history |
| Manual test | — | GPS accuracy, camera quality, upload speed |

## Deployment

| Platform | Method | Status |
|----------|--------|--------|
| Android APK | `flutter build apk --release` | MVP |
| Android Play Store | Google Play Console | v1.1+ |
| iOS App Store | Apple App Store | v1.1+ |
