# IderKopi Absensi — Project Overview

## Tentang Project

Aplikasi absensi mobile (Flutter) untuk karyawan IderKopi (Kang Ider). Terhubung langsung ke Directus API yang sudah ada di `api.iderkopi.id`.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile App | Flutter (Dart) |
| Backend API | Directus REST API (`api.iderkopi.id`) |
| Database | PostgreSQL (Directus) |
| Storage | Directus Files (selfie photos) |
| State Management | Riverpod |
| HTTP Client | Dio |
| Navigation | go_router |
| GPS | geolocator |
| Camera | camera + image |

## Fitur MVP

1. **Login** — Directus email/password authentication
2. **Check-In** — GPS location + foto selfie → submit ke Directus
3. **Check-Out** — Update record absensi dengan waktu pulang
4. **Riwayat Absensi** — List 30 hari terakhir dengan status & thumbnail selfie
5. **Profile** — Info karyawan + statistik kehadiran bulan ini

## Directus Collections

- `kangider` — daftar karyawan (existing)
- `absensi_ider` — data absensi (existing + new fields: latitude, longitude, selfie_file_id, check_in_source, latitude_pulang, longitude_pulang)

## Struktur Dokumen

| File | Konten |
|------|--------|
| `00-OVERVIEW.md` | Project overview (file ini) |
| `01-ARCHITECTURE.md` | Arsitektur sistem, API endpoints, data flow |
| `02-DIRECTUS-SCHEMA.md` | Perubahan schema Directus & setup permissions |
| `03-FLUTTER-STRUCTURE.md` | Struktur folder & file Flutter app |
| `04-UI-UX-DESIGN.md` | Design system, color palette, screen-by-screen mockup |
| `05-DEPENDENCIES.md` | pubspec.yaml dependencies & dev dependencies |
| `06-ROADMAP.md` | Roadmap pengembangan MVP → future |

## Related Project

- **IderKopi HRIS** (web): `c:\Misi-NUS\ideerkopi` — Go backend + Next.js frontend
- Backend Go existing menangani sync dari Directus, Fingerspot, Majoo
- Flutter app ini berkomunikasi langsung dengan Directus, tidak lewat Go backend
