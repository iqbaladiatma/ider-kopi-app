# IderKopi Absensi

Aplikasi absensi mobile (Flutter) untuk karyawan IderKopi (Kang Ider).
Terhubung langsung ke Directus API di `api.iderkopi.id`.

## Fitur MVP

1. **Login** — Directus email/password authentication
2. **Check-In** — GPS location + foto selfie → submit ke Directus
3. **Check-Out** — Update record absensi dengan waktu pulang
4. **Riwayat Absensi** — List 30 hari terakhir dengan status & thumbnail selfie
5. **Profile** — Info karyawan + statistik kehadiran bulan ini

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile App | Flutter (Dart) |
| Backend API | Directus REST API (`api.iderkopi.id`) |
| State Management | Riverpod |
| HTTP Client | Dio |
| Navigation | go_router |
| GPS | geolocator |
| Maps | Mapbox (via flutter_map) |
| Camera | camera + image |

## Setup

1. Install Flutter SDK >= 3.13.0
2. Run `flutter pub get`
3. Run `flutter run`

## Dokumentasi

- **Dokumentasi Lengkap**: [`docs/DOKUMENTASI_LENGKAP.md`](docs/DOKUMENTASI_LENGKAP.md)
- Lihat folder `docs/` untuk dokumentasi modular lainnya:
  - `00-OVERVIEW.md` — gambaran umum project
  - `01-ARCHITECTURE.md` — arsitektur sistem & API
  - `02-DIRECTUS-SCHEMA.md` — schema & permissions Directus
  - `03-FLUTTER-STRUCTURE.md` — struktur folder Flutter
  - `04-UI-UX-DESIGN.md` — design system & mockup
  - `05-DEPENDENCIES.md` — daftar dependencies
  - `06-ROADMAP.md` — roadmap pengembangan
