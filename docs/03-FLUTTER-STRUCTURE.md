# Struktur Flutter

```text
lib/
├── core/
│   ├── background/       # Workmanager sync
│   ├── config/           # AppConfig dan API base URL
│   ├── data/             # abstract data source
│   ├── database/         # SQLite, DAO, pending queue
│   ├── network/          # ApiClient dan auth interceptor
│   ├── providers/        # dependency providers
│   ├── router/           # GoRouter + role barrier
│   └── storage/          # secure/conditional storage
├── features/             # auth, attendance, outlet, shift,
│                         # leave, holiday, KPI, recap, sync, admin
└── shared/
```

Repository menerima `ApiClient` melalui provider. Model server memakai UUID string. Cache dan queue mempertahankan request ID agar replay tidak menduplikasi absensi.