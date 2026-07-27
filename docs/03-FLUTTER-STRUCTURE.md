# Flutter Project Structure

## Folder Layout

```
iderkopi-absensi/
├── android/
├── ios/
├── lib/
│   ├── main.dart                          # Entry point + ProviderScope
│   ├── app.dart                           # MaterialApp + router config
│   │
│   ├── core/
│   │   ├── config/
│   │   │   └── app_config.dart            # API base URL, constants
│   │   ├── theme
│   │   │   └── app_theme.dart             # ThemeData (colors, typography)
│   │   ├── constants/
│   │   │   └── app_colors.dart            # Color constants
│   │   ├── network/
│   │   │   ├── directus_client.dart       # Dio instance + interceptors
│   │   │   └── auth_interceptor.dart      # Token inject + refresh on 401
│   │   ├── storage/
│   │   │   └── secure_storage.dart        # FlutterSecureStorage wrapper
│   │   ├── utils/
│   │   │   ├── location_utils.dart        # GPS helper (getCurrentLocation)
│   │   │   ├── date_utils.dart            # Date formatting (intl)
│   │   │   └── image_utils.dart           # Image compress before upload
│   │   └── router/
│   │       └── app_router.dart            # go_router route definitions
│   │
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   │   ├── auth_repository.dart   # login(), refresh(), logout()
│   │   │   │   └── auth_model.dart        # AuthTokens, LoginRequest
│   │   │   ├── presentation/
│   │   │   │   ├── login_page.dart
│   │   │   │   └── login_controller.dart  # Riverpod notifier
│   │   │   └── providers/
│   │   │       └── auth_providers.dart    # authProvider, authStateProvider
│   │   │
│   │   ├── attendance/
│   │   │   ├── data/
│   │   │   │   ├── attendance_repository.dart  # CRUD absensi_ider
│   │   │   │   └── attendance_model.dart       # AttendanceRecord, CheckInRequest
│   │   │   ├── presentation/
│   │   │   │   ├── home_page.dart              # Dashboard utama
│   │   │   │   ├── check_in_page.dart          # Camera + GPS + submit
│   │   │   │   ├── check_out_page.dart
│   │   │   │   └── history_page.dart
│   │   │   ├── presentation/widgets/
│   │   │   │   ├── location_card.dart          # GPS info + mini map
│   │   │   │   ├── camera_section.dart         # Camera preview + capture
│   │   │   │   ├── status_badge.dart           # Tepat waktu / Terlambat / Alpha
│   │   │   │   ├── attendance_summary_card.dart
│   │   │   │   └── history_list_item.dart
│   │   │   └── providers/
│   │   │       └── attendance_providers.dart   # todayProvider, historyProvider
│   │   │
│   │   └── profile/
│   │       ├── data/
│   │       │   └── profile_model.dart
│   │       ├── presentation/
│   │       │   └── profile_page.dart
│   │       └── providers/
│   │           └── profile_providers.dart
│   │
│   └── shared/
│       └── widgets/
│           ├── custom_button.dart          # Primary, outlined, danger variants
│           ├── loading_overlay.dart        # Full-screen loading
│           ├── error_view.dart             # Error state with retry
│           ├── empty_view.dart             # Empty state illustration
│           ├── gradient_header.dart        # Red gradient card
│           └── bottom_nav_bar.dart         # Custom bottom navigation
│
├── assets/
│   ├── images/
│   │   ├── iderkopi_logo.png              # App logo
│   │   └── empty_state.png                # Illustration
│   └── icons/
│
├── docs/                                   # Documentation (this folder)
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

## Key Files Description

### `core/network/directus_client.dart`

```dart
class DirectusClient {
  final Dio _dio;
  final SecureStorage _storage;

  // Singleton Dio dengan:
  // - BaseOptions: baseUrl, connectTimeout, receiveTimeout
  // - AuthInterceptor: inject Bearer token, refresh on 401
  // - LogInterceptor (dev only)

  Future<Response> get(String path, {Map<String, dynamic>? query});
  Future<Response> post(String path, {dynamic body, FormData? formData});
  Future<Response> patch(String path, {dynamic body});
}
```

### `core/network/auth_interceptor.dart`

```dart
class AuthInterceptor extends Interceptor {
  // onRequest: inject Authorization: Bearer <token>
  // onError: if 401 → call /auth/refresh → retry original request
  //          if refresh fails → clear tokens → redirect to login
}
```

### `features/attendance/data/attendance_repository.dart`

```dart
class AttendanceRepository {
  final DirectusClient _client;

  Future<AttendanceRecord?> getTodayAttendance(String kangiderId);
  Future<AttendanceRecord> checkIn(CheckInRequest req);
  Future<AttendanceRecord> checkOut(String id, CheckOutRequest req);
  Future<List<AttendanceRecord>> getHistory(String kangiderId, {int limit = 30});
  Future<String> uploadSelfie(File imageFile);  // returns file_id
}
```

### `core/router/app_router.dart`

```dart
final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (_, __) => LoginPage()),
    ShellRoute(
      builder: (_, __, child) => MainShell(child: child),  // bottom nav
      routes: [
        GoRoute(path: '/home', builder: (_, __) => HomePage()),
        GoRoute(path: '/check-in', builder: (_, __) => CheckInPage()),
        GoRoute(path: '/check-out', builder: (_, __) => CheckOutPage()),
        GoRoute(path: '/history', builder: (_, __) => HistoryPage()),
        GoRoute(path: '/profile', builder: (_, __) => ProfilePage()),
      ],
    ),
  ],
  redirect: (context, state) {
    // Redirect ke /login jika belum auth
    // Redirect ke /home jika sudah auth tapi di /login
  },
);
```

## Naming Conventions

- **Files**: `snake_case.dart`
- **Classes**: `PascalCase`
- **Providers**: `camelCaseProvider` (e.g., `authProvider`, `historyProvider`)
- **States**: `PascalCaseState` (e.g., `AuthState`, `LocationState`)
- **Models**: `PascalCase` with `freezed` + `json_serializable`
