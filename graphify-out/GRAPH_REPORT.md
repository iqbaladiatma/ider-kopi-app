# Graph Report - ider-kopi-app  (2026-07-27)

## Corpus Check
- 88 files · ~35,626 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1011 nodes · 1322 edges · 67 communities (62 shown, 5 thin omitted)
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 18 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `3f2a8f9d`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Win32Window
- app_colors.dart
- custom_button.dart
- GeneratedPluginRegistrant.swift
- mock_data.dart
- attendance_model.dart
- auth_model.dart
- UI/UX Design — IderKopi Absensi
- my_application.cc
- app_router.dart
- secure_storage.dart
- admin_users_page.dart
- camera_section.dart
- check_in_page.dart
- check_out_page.dart
- admin_attendance_page.dart
- admin_providers.dart
- auth_repository.dart
- location_card.dart
- auth_providers.dart
- admin_repository.dart
- history_page.dart
- auth_interceptor.dart
- home_page.dart
- login_page.dart
- profile_model.dart
- attendance_repository.dart
- profile_providers.dart
- currentUserProvider
- attendance_providers.dart
- profile_page.dart
- directus_client.dart
- ConsumerState
- Directus Schema Changes & Setup
- gradient_header.dart
- wWinMain
- date_utils.dart
- todayAttendanceProvider
- admin_dashboard_page.dart
- admin_nav_bar.dart
- manifest.json
- package:flutter_riverpod/flutter_riverpod.dart
- bottom_nav_bar.dart
- Key Files Description
- Roadmap Pengembangan
- StatelessWidget
- admin_profile_page.dart
- package:flutter/material.dart
- IderKopi Absensi — Project Overview
- Arsitektur Sistem
- Dependencies (pubspec.yaml)
- authRepositoryProvider
- error_view.dart
- IconData
- ../../core/constants/app_colors.dart
- dart:io
- location_utils.dart
- IderKopi Absensi
- MainActivity
- widget_test.dart
- LaunchImage.imageset/README.md
- bool?
- String?

## God Nodes (most connected - your core abstractions)
1. `Win32Window` - 22 edges
2. `MessageHandler` - 12 edges
3. `FlutterWindow` - 10 edges
4. `Create` - 10 edges
5. `WndProc` - 10 edges
6. `MessageHandler` - 9 edges
7. `UI/UX Design — IderKopi Absensi` - 9 edges
8. `3. Screen Mockups` - 8 edges
9. `Roadmap Pengembangan` - 8 edges
10. `authRepositoryProvider` - 7 edges

## Surprising Connections (you probably didn't know these)
- `wWinMain()` --calls--> `CreateAndAttachConsole()`  [INFERRED]
  windows/runner/main.cpp → windows/runner/utils.cpp
- `Win32Window::Win32Window()` --calls--> `Destroy`  [INFERRED]
  windows/runner/win32_window.cpp → windows/runner/win32_window.h
- `_AdminAttendancePageState` --references--> `adminAttendanceProvider`  [EXTRACTED]
  lib/features/admin/presentation/admin_attendance_page.dart → lib/features/admin/providers/admin_providers.dart
- `AdminProfilePage` --references--> `currentUserProvider`  [EXTRACTED]
  lib/features/admin/presentation/admin_profile_page.dart → lib/features/auth/providers/auth_providers.dart
- `build` --references--> `currentUserProvider`  [EXTRACTED]
  lib/features/admin/presentation/admin_profile_page.dart → lib/features/auth/providers/auth_providers.dart

## Import Cycles
- None detected.

## Communities (67 total, 5 thin omitted)

### Community 0 - "Win32Window"
Cohesion: 0.06
Nodes (53): PluginRegistry, Point, RECT, Size, unique_ptr, RegisterPlugins(), DartProject, HWND (+45 more)

### Community 1 - "app_colors.dart"
Cohesion: 0.04
Nodes (50): AppColors, background, border, brand100, brand200, brand300, brand400, brand50 (+42 more)

### Community 2 - "custom_button.dart"
Cohesion: 0.05
Nodes (45): Animation, AnimationController, ../../../core/config/app_config.dart, _SuccessDialog, _SuccessDialogState, CameraSection, _CameraSectionState, build (+37 more)

### Community 3 - "GeneratedPluginRegistrant.swift"
Cohesion: 0.06
Nodes (29): Any, Cocoa, Flutter, flutter_secure_storage_macos, FlutterAppDelegate, FlutterImplicitEngineBridge, FlutterImplicitEngineDelegate, FlutterMacOS (+21 more)

### Community 4 - "mock_data.dart"
Cohesion: 0.05
Nodes (40): ../constants/app_colors.dart, ../../features/auth/data/auth_model.dart, AppConfig, appVersion, connectTimeout, directusApiBaseUrl, officeLatitude, officeLongitude (+32 more)

### Community 5 - "attendance_model.dart"
Cohesion: 0.05
Nodes (39): ../../../../core/utils/date_utils.dart, ../data/attendance_model.dart, int?, AttendanceRecord, AttendanceStatus, CheckInRequest, checkInSource, CheckOutRequest (+31 more)

### Community 6 - "auth_model.dart"
Cohesion: 0.05
Nodes (37): bool get, AdminUser, createdAt, CreateUserData, email, firstName, fromJson, id (+29 more)

### Community 7 - "UI/UX Design — IderKopi Absensi"
Cohesion: 0.07
Nodes (27): 1. Design System, 2. App Theme (Flutter ThemeData), 3.1 Splash Screen, 3.2 Login Page, 3.3 Home / Dashboard, 3.4 Check-In Page (Core Feature), 3.5 Check-Out Page, 3.6 Riwayat Absensi (History) (+19 more)

### Community 8 - "my_application.cc"
Cohesion: 0.09
Nodes (22): FlPluginRegistry, FlView, GApplication, gboolean, gchar, GObject, GtkApplication, fl_register_plugins() (+14 more)

### Community 9 - "app_router.dart"
Cohesion: 0.08
Nodes (23): ChangeNotifier, ../../features/admin/presentation/admin_attendance_page.dart, ../../features/admin/presentation/admin_dashboard_page.dart, ../../features/admin/presentation/admin_profile_page.dart, ../../features/admin/presentation/admin_users_page.dart, ../../features/attendance/presentation/check_in_page.dart, ../../features/attendance/presentation/check_out_page.dart, ../../features/attendance/presentation/history_page.dart (+15 more)

### Community 10 - "secure_storage.dart"
Cohesion: 0.08
Nodes (23): FlutterSecureStorage, clearAll, getAccessToken, getExpiresAt, getKangiderId, getRefreshToken, getUserEmail, getUserRole (+15 more)

### Community 11 - "admin_users_page.dart"
Cohesion: 0.09
Nodes (21): FormState, GlobalKey, controller, createState, fields, _FormField, formKey, _getInitials (+13 more)

### Community 12 - "camera_section.dart"
Cohesion: 0.10
Nodes (20): CameraController?, File?, build, _buildCameraArea, _cameras, _capturedImage, _controller, createState (+12 more)

### Community 13 - "check_in_page.dart"
Cohesion: 0.10
Nodes (20): _buildTimeCard, _canSubmit, _controller, createState, dispose, _fadeAnimation, _getCurrentLocation, initState (+12 more)

### Community 14 - "check_out_page.dart"
Cohesion: 0.10
Nodes (19): ../../../core/utils/image_utils.dart, ../../../core/utils/location_utils.dart, _buildCheckInSummary, _buildTimeDisplay, _canSubmit, createState, _getCurrentLocation, initState (+11 more)

### Community 15 - "admin_attendance_page.dart"
Cohesion: 0.12
Nodes (16): ../../attendance/presentation/widgets/status_badge.dart, _buildAttendanceList, _buildFilters, color, createState, date, _employeeSearch, _formatDate (+8 more)

### Community 16 - "admin_providers.dart"
Cohesion: 0.13
Nodes (15): ../../attendance/data/attendance_model.dart, ../data/admin_repository.dart, ../data/admin_user_model.dart, AdminRepository, build, build, adminAttendanceProvider, getAllAttendance (+7 more)

### Community 17 - "auth_repository.dart"
Cohesion: 0.12
Nodes (15): auth_model.dart, ../../../core/storage/secure_storage.dart, _client, getCurrentUser, getKangiderId, getUserEmail, getUserRole, _instance (+7 more)

### Community 18 - "location_card.dart"
Cohesion: 0.12
Nodes (15): CustomPainter, double?, build, _buildContent, _buildCoordRow, error, isLoading, isWithinRadius (+7 more)

### Community 19 - "auth_providers.dart"
Cohesion: 0.12
Nodes (15): ../data/auth_model.dart, ../data/auth_repository.dart, AuthRepository, authInitProvider, authState, AuthStatus, getKangiderId, getUserRole (+7 more)

### Community 20 - "admin_repository.dart"
Cohesion: 0.13
Nodes (14): admin_user_model.dart, ../../../core/utils/mock_data.dart, _client, createUser, deleteUser, getAllAttendance, getRoles, getTodayAttendanceCount (+6 more)

### Community 21 - "history_page.dart"
Cohesion: 0.16
Nodes (13): DateTime, build, _buildMonthPicker, createState, HistoryPage, _HistoryPageState, initState, _pickMonth (+5 more)

### Community 22 - "auth_interceptor.dart"
Cohesion: 0.14
Nodes (13): Dio, Interceptor, AuthInterceptor, dio, _isAuthEndpoint, _isRefreshing, onError, onRequest (+5 more)

### Community 23 - "home_page.dart"
Cohesion: 0.14
Nodes (13): _buildActionCard, _buildActionCards, _buildGreetingCard, _buildGreetingContent, _buildRecentHistory, _buildSectionTitle, _buildStatusRow, _buildTodayStatus (+5 more)

### Community 24 - "login_page.dart"
Cohesion: 0.14
Nodes (13): build, _buildDemoCard, _buildEmailField, _buildGradientHeader, _buildPasswordField, createState, dispose, _emailController (+5 more)

### Community 25 - "profile_model.dart"
Cohesion: 0.14
Nodes (13): alpha, email, firstName, fromJson, hadir, id, kangiderId, kangiderNama (+5 more)

### Community 26 - "attendance_repository.dart"
Cohesion: 0.15
Nodes (12): attendance_model.dart, ../../../core/network/directus_client.dart, AttendanceRepository, checkIn, checkOut, _client, getHistory, getMonthlyHistory (+4 more)

### Community 27 - "profile_providers.dart"
Cohesion: 0.18
Nodes (12): ../../attendance/providers/attendance_providers.dart, ../../auth/providers/auth_providers.dart, ../data/profile_model.dart, AttendanceStats, build, ProfilePage, now, params (+4 more)

### Community 28 - "currentUserProvider"
Cohesion: 0.21
Nodes (13): ConsumerWidget, AdminDashboardPage, build, build, todayAttendanceCountProvider, userCountProvider, build, HomePage (+5 more)

### Community 29 - "attendance_providers.dart"
Cohesion: 0.15
Nodes (12): ../data/attendance_repository.dart, alpha, getHistory, getMonthlyHistory, getTodayAttendance, hadir, kangiderId, MonthlyStats (+4 more)

### Community 30 - "profile_page.dart"
Cohesion: 0.15
Nodes (12): _buildInfoRow, _buildInfoSection, _buildProfileHeader, _buildSettingsSection, _buildStatRow, _buildStatsSection, icon, label (+4 more)

### Community 31 - "directus_client.dart"
Cohesion: 0.17
Nodes (11): auth_interceptor.dart, ../config/app_config.dart, Dio get, delete, _dio, DirectusClient, _instance, patch (+3 more)

### Community 32 - "ConsumerState"
Cohesion: 0.20
Nodes (12): ConsumerState, ConsumerStatefulWidget, AdminAttendancePage, _AdminAttendancePageState, AdminUsersPage, _AdminUsersPageState, _confirmDelete, _showAddUserDialog (+4 more)

### Community 33 - "Directus Schema Changes & Setup"
Cohesion: 0.17
Nodes (11): 1. Collection: `absensi_ider` — New Fields, 2. Collection: `kangider` (No Changes), 3. Directus Role & Permissions Setup, 4. User Account Setup, 5. Environment Configuration, Buat Role Baru: "App User", Directus Schema Changes & Setup, Existing Fields (+3 more)

### Community 34 - "gradient_header.dart"
Cohesion: 0.17
Nodes (11): EdgeInsets, Gradient?, borderRadius, build, child, gradient, GradientHeader, padding (+3 more)

### Community 35 - "wWinMain"
Cohesion: 0.24
Nodes (9): _In_, _In_opt_, vector, wWinMain(), string, wchar_t, CreateAndAttachConsole(), GetCommandLineArguments() (+1 more)

### Community 36 - "date_utils.dart"
Cohesion: 0.17
Nodes (11): AppDateUtils, formatDate, formatDateShort, formatMonthYear, formatTime, formatTimeShort, formatTimeWIB, greeting (+3 more)

### Community 37 - "todayAttendanceProvider"
Cohesion: 0.23
Nodes (12): build, CheckInPage, _CheckInPageState, _handleSubmit, build, CheckOutPage, _CheckOutPageState, _handleSubmit (+4 more)

### Community 38 - "admin_dashboard_page.dart"
Cohesion: 0.18
Nodes (10): Color, color, icon, label, _MenuCard, onTap, subtitle, title (+2 more)

### Community 39 - "admin_nav_bar.dart"
Cohesion: 0.18
Nodes (10): activeIcon, _AdminBottomNav, build, _buildItem, child, currentPath, icon, label (+2 more)

### Community 40 - "manifest.json"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 41 - "package:flutter_riverpod/flutter_riverpod.dart"
Cohesion: 0.22
Nodes (8): app.dart, core/router/app_router.dart, ../../core/theme/app_theme.dart, build, IderKopiApp, appRouterProvider, main, package:flutter_riverpod/flutter_riverpod.dart

### Community 42 - "bottom_nav_bar.dart"
Cohesion: 0.20
Nodes (9): _BottomNav, build, _buildItem, child, currentPath, _isActive, MainShell, package:flutter/services.dart (+1 more)

### Community 43 - "Key Files Description"
Cohesion: 0.22
Nodes (8): `core/network/auth_interceptor.dart`, `core/network/directus_client.dart`, `core/router/app_router.dart`, `features/attendance/data/attendance_repository.dart`, Flutter Project Structure, Folder Layout, Key Files Description, Naming Conventions

### Community 44 - "Roadmap Pengembangan"
Cohesion: 0.22
Nodes (8): Deployment, MVP (v1.0.0), Roadmap Pengembangan, Testing Strategy, v1.1 — Geofencing & Multi-Outlet, v1.2 — Offline Mode, v1.3 — Notifications & Reminders, v2.0 — Integrasi Go Backend

### Community 45 - "StatelessWidget"
Cohesion: 0.22
Nodes (9): _AttendanceCard, _DateGroup, _TimeChip, _SectionTitle, _StatCard, _FormDialog, _UserCard, AdminShell (+1 more)

### Community 46 - "admin_profile_page.dart"
Cohesion: 0.22
Nodes (8): icon, _InfoTile, label, _SectionLabel, _showAboutDialog, text, value, ../../../shared/widgets/gradient_header.dart

### Community 47 - "package:flutter/material.dart"
Cohesion: 0.25
Nodes (7): dart:ui, build, child, isLoading, LoadingOverlay, message, package:flutter/material.dart

### Community 48 - "IderKopi Absensi — Project Overview"
Cohesion: 0.25
Nodes (7): Directus Collections, Fitur MVP, IderKopi Absensi — Project Overview, Related Project, Struktur Dokumen, Tech Stack, Tentang Project

### Community 49 - "Arsitektur Sistem"
Cohesion: 0.25
Nodes (7): API Endpoints (Directus), Arsitektur Sistem, Auth Flow, Diagram, Error Handling Strategy, Flow, State Management (Riverpod)

### Community 50 - "Dependencies (pubspec.yaml)"
Cohesion: 0.25
Nodes (7): Android (`android/app/src/main/AndroidManifest.xml`), Core Dependencies, Dependencies (pubspec.yaml), Dev Dependencies, Full pubspec.yaml, iOS (`ios/Runner/Info.plist`), Permissions

### Community 51 - "authRepositoryProvider"
Cohesion: 0.43
Nodes (8): AdminProfilePage, _handleLogout, _handleLogin, _LoginPageState, authRepositoryProvider, authStateProvider, _handleLogout, Route /login

### Community 52 - "error_view.dart"
Cohesion: 0.25
Nodes (7): build, ErrorView, icon, message, onRetry, title, VoidCallback?

### Community 53 - "IconData"
Cohesion: 0.29
Nodes (6): IconData, build, EmptyView, icon, subtitle, title

### Community 54 - "../../core/constants/app_colors.dart"
Cohesion: 0.33
Nodes (5): ../../core/constants/app_colors.dart, AttendanceSummaryCard, build, _buildStatusRow, record

### Community 55 - "dart:io"
Cohesion: 0.33
Nodes (5): dart:io, compressImage, ImageUtils, package:image/image.dart, package:path_provider/path_provider.dart

### Community 56 - "location_utils.dart"
Cohesion: 0.33
Nodes (5): distanceToOffice, getCurrentLocation, isWithinOfficeRadius, LocationUtils, package:geolocator/geolocator.dart

### Community 57 - "IderKopi Absensi"
Cohesion: 0.33
Nodes (5): Dokumentasi, Fitur MVP, IderKopi Absensi, Setup, Tech Stack

## Knowledge Gaps
- **564 isolated node(s):** `AppConfig`, `directusApiBaseUrl`, `connectTimeout`, `receiveTimeout`, `retryCount` (+559 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **5 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `SecureStorage` connect `auth_interceptor.dart` to `auth_repository.dart`, `secure_storage.dart`?**
  _High betweenness centrality (0.042) - this node is a cross-community bridge._
- **Why does `AttendanceStats` connect `profile_providers.dart` to `profile_model.dart`?**
  _High betweenness centrality (0.025) - this node is a cross-community bridge._
- **Why does `DirectusClient` connect `directus_client.dart` to `auth_repository.dart`, `attendance_repository.dart`, `admin_repository.dart`?**
  _High betweenness centrality (0.017) - this node is a cross-community bridge._
- **What connects `AppConfig`, `directusApiBaseUrl`, `connectTimeout` to the rest of the system?**
  _564 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Win32Window` be split into smaller, more focused modules?**
  _Cohesion score 0.0597567424643046 - nodes in this community are weakly interconnected._
- **Should `app_colors.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.0392156862745098 - nodes in this community are weakly interconnected._
- **Should `custom_button.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.05365402405180388 - nodes in this community are weakly interconnected._