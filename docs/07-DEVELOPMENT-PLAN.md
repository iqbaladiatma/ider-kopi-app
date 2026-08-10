# Development Plan

## Kontrak wajib

- Backend tunggal: Go/Fiber project IDER KOPI.
- PostgreSQL adalah source of truth server.
- Port API `2026`; port dashboard `9000`.
- Tidak ada mock fallback pada production error.
- Tidak ada bypass geofence atau koordinat produksi palsu.
- Semua perubahan schema memakai migration additive.

## Quality gate

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
cd /Users/ainud/Projects/ider-kopi/backend && go test ./...
```

Sebelum deployment, verifikasi migration, health lokal/Tailscale, authorization, container restart count, dan Graphify.