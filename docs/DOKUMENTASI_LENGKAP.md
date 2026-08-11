# Dokumentasi Lengkap IDER KOPI Mobile (v2.0.0+1)

Dokumentasi resmi dan panduan penggunaan aplikasi presensi IDER KOPI Mobile (Flutter) & Go/Fiber Backend Service.

- 📄 **Dokumen PDF Resmi**: [Dokumentasi_Lengkap_IderKopi_Absensi.pdf](file:///c:/Misi-NUS/iderkopi-absensi/Dokumentasi_Lengkap_IderKopi_Absensi.pdf)
- 🌐 **Sumber HTML Layout A4**: [DOKUMENTASI_LENGKAP.html](file:///c:/Misi-NUS/iderkopi-absensi/docs/DOKUMENTASI_LENGKAP.html)

## Ringkasan System v2.0.0+1

- **Architecture**: Flutter 3.13+ (Android, iOS, Web) berkomunikasi langsung dengan custom **Go/Fiber REST API** (`http://100.90.46.31:2026/api/v1`).
- **Database Backend**: PostgreSQL 16 (Port `5433` via Docker) menyimpan data karyawan, absensi, KPI, outlet, shift, cuti, rekap, dan holiday.
- **Offline-First & Queue**: SQLite (`sqflite`) menyimpan antrean transaksi presensi offline yang otomatis disinkronkan via `workmanager` saat koneksi pulih.
- **Idempotensi & Keamanan**: Menggunakan header `client_request_id` (UUID v4) untuk mencegah duplikasi absensi, serta token JWT terenkripsi di Keystore/Keychain.
- **Geofencing & Selfie**: Validasi radius koordinat GPS server-side & client-side (max 150 meter) dan kompresi foto selfie (<250 KB) sebelum dikirim via multipart request.
- **Credentials Default**: Password karyawan (`iderkophebat`) dan password admin (`adminiderkophebat`).

## Prosedur Verifikasi Kode

```bash
# 1. Analisis Kode Flutter
flutter analyze

# 2. Unit Testing Flutter (150 tests)
flutter test

# 3. Backend Go Vet & Testing
cd auth-backend && go vet ./... && go test ./...
```