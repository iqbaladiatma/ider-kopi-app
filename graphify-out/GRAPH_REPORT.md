# Graph Report - ider-kopi-app  (2026-08-11)

## Corpus Check
- 206 files · ~131,642 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 2410 nodes · 3413 edges · 163 communities (148 shown, 15 thin omitted)
- Extraction: 98% EXTRACTED · 2% INFERRED · 0% AMBIGUOUS · INFERRED: 79 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `41c80f9d`
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
- ../../../core/network/api_client.dart
- package:flutter/material.dart
- IderKopi Absensi — Project Overview
- Arsitektur Sistem
- Dependencies (pubspec.yaml)
- authRepositoryProvider
- error_view.dart
- SyncRepository
- ../../core/constants/app_colors.dart
- dart:io
- location_utils.dart
- IderKopi Absensi
- MainActivity
- widget_test.dart
- LaunchImage.imageset/README.md
- bool?
- String?
- shift_model.dart
- Rencana Pengembangan Lengkap IderKopi Absensi
- shift_schedule_page.dart
- settings_providers.dart
- recap_model.dart
- paginated_notifier.dart
- notification_service.dart
- pending_sync_dao.dart
- leave_model.dart
- outlet_map_widget.dart
- sync_repository.dart
- admin_outlet_edit_page.dart
- splash_screen.dart
- leave_form_page.dart
- admin_user_model.dart
- leave_approval_page.dart
- sync_log_dao.dart
- outlet_repository.dart
- recap_page.dart
- outlet_picker_sheet.dart
- app_database.dart
- holiday_repository.dart
- leave_repository.dart
- admin_user_form_page.dart
- kpi_repository.dart
- attendance_data_source.dart
- package:flutter/foundation.dart
- attendance_dao.dart
- outlet_dao_test.dart
- async_value_widget.dart
- outlet_providers.dart
- outlet_model.dart
- settings_page.dart
- settings_page_test.dart
- cached_image.dart
- Changelog
- ConsumerWidget
- mock_data.dart
- app_theme.dart
- ../../auth/providers/auth_providers.dart
- currentUserProvider
- kpi_page.dart
- database_providers.dart
- directus_attendance_data_source.dart
- package:flutter_riverpod/flutter_riverpod.dart
- sync_providers.dart
- outlet_dao.dart
- status_pie_chart.dart
- api_providers.dart
- ConsumerState
- recap_providers.dart
- pending_sync_badge_test.dart
- storage_backend.dart
- StatelessWidget
- attendance_bar_chart.dart
- build
- ../data/attendance_model.dart
- 10. Directus Schema & Permissions
- outlet_picker_sheet_test.dart
- static const String
- conflict_resolver.dart
- empty_view.dart
- api_provider_test.dart
- recap_model_test.dart
- sync_providers.dart
- build
- SharedPreferences
- .changePassword
- Load
- employees_test.go
- holiday_providers.dart
- holiday_model.dart
- Ider Kopi mobile authentication backend
- empty_view.dart
- attendance_bar_chart.dart
- Separate Mobile Authentication Implementation Plan
- 001_initial.sql
- attendance_dao_test.dart
- api_provider_test.dart
- T
- @iderkopi
- iderkopi/auth-backend
- ../data/attendance_model.dart
- admin_user_model_test.dart
- admin_attendance_detail_page.dart
- image_utils.dart
- api_providers.dart
- recap_model_test.dart
- PreviewReset
- NotificationSettingsNotifier
- SharedPreferences
- attendance_model_test.dart
- holiday_model_test.dart
- reset-login-passwords.sh
- empty_view.dart

## God Nodes (most connected - your core abstractions)
1. `New()` - 26 edges
2. `Win32Window` - 22 edges
3. `Server` - 14 edges
4. `outletsProvider` - 13 edges
5. `activeBrandProvider` - 12 edges
6. `MessageHandler` - 12 edges
7. `authStateProvider` - 11 edges
8. `run()` - 10 edges
9. `runResetEmployeePasswords()` - 10 edges
10. `ApiClient` - 10 edges

## Surprising Connections (you probably didn't know these)
- `main()` --calls--> `New()`  [INFERRED]
  auth-backend/cmd/auth/main.go → auth-backend/internal/api/server.go
- `run()` --calls--> `New()`  [INFERRED]
  auth-backend/cmd/auth/main.go → auth-backend/internal/api/server.go
- `run()` --calls--> `Load()`  [INFERRED]
  auth-backend/cmd/auth/main.go → auth-backend/internal/config/config.go
- `run()` --calls--> `NewTokenManager()`  [INFERRED]
  auth-backend/cmd/auth/main.go → auth-backend/internal/security/tokens.go
- `run()` --calls--> `Run()`  [INFERRED]
  auth-backend/cmd/auth/main.go → auth-backend/migrations/migrations.go

## Import Cycles
- None detected.

## Communities (163 total, 15 thin omitted)

### Community 0 - "Win32Window"
Cohesion: 0.06
Nodes (53): PluginRegistry, Point, RECT, Size, unique_ptr, RegisterPlugins(), DartProject, HWND (+45 more)

### Community 1 - "app_colors.dart"
Cohesion: 0.04
Nodes (48): amber, amberBg, AppColors, background, border, borderLight, buttonShadow, cardShadow (+40 more)

### Community 2 - "custom_button.dart"
Cohesion: 0.08
Nodes (24): double get, build, _buildButton, _buildButtonContent, ButtonSize, ButtonVariant, _controller, createState (+16 more)

### Community 3 - "GeneratedPluginRegistrant.swift"
Cohesion: 0.05
Nodes (34): Any, Cocoa, connectivity_plus, Flutter, flutter_local_notifications, flutter_secure_storage_macos, flutter_timezone, FlutterAppDelegate (+26 more)

### Community 4 - "mock_data.dart"
Cohesion: 0.13
Nodes (14): @pragma, ../database/app_database.dart, ../database/daos/pending_sync_dao.dart, ../database/daos/sync_log_dao.dart, ../../features/sync/data/sync_repository.dart, callbackDispatcher, cancel, init (+6 more)

### Community 5 - "attendance_model.dart"
Cohesion: 0.07
Nodes (26): CheckInRequest, checkInSource, CheckOutRequest, clientRequestId, fromJson, hasCheckedIn, hasCheckedOut, id (+18 more)

### Community 6 - "auth_model.dart"
Cohesion: 0.04
Nodes (45): DateTime, build, _buildRecordCard, _buildStatBlock, _buildStatsCard, createState, HistoryPage, _HistoryPageState (+37 more)

### Community 7 - "UI/UX Design — IderKopi Absensi"
Cohesion: 0.07
Nodes (27): 1. Design System, 2. App Theme (Flutter ThemeData), 3.1 Splash Screen, 3.2 Login Page, 3.3 Home / Dashboard, 3.4 Check-In Page (Core Feature), 3.5 Check-Out Page, 3.6 Riwayat Absensi (History) (+19 more)

### Community 8 - "my_application.cc"
Cohesion: 0.09
Nodes (22): FlPluginRegistry, FlView, GApplication, gboolean, gchar, GObject, GtkApplication, fl_register_plugins() (+14 more)

### Community 9 - "app_router.dart"
Cohesion: 0.07
Nodes (29): ChangeNotifier, ../../features/admin/presentation/admin_account_detail_page.dart, ../../features/admin/presentation/admin_employee_detail_page.dart, ../../features/attendance/presentation/attendance_options_page.dart, ../../features/attendance/presentation/check_in_page.dart, ../../features/attendance/presentation/check_out_page.dart, ../../features/auth/presentation/change_password_page.dart, ../../features/auth/presentation/login_page.dart (+21 more)

### Community 10 - "secure_storage.dart"
Cohesion: 0.07
Nodes (29): AuthRealm, _backend, clearAll, getAccessToken, getAuthRealm, getExpiresAt, getKangiderId, getMustChangePassword (+21 more)

### Community 11 - "admin_users_page.dart"
Cohesion: 0.16
Nodes (13): _activeTab, AdminUsersPage, _AdminUsersPageState, build, _buildEmployeeCard, _buildEmployeeTab, _buildOutletTab, _buildUserCard (+5 more)

### Community 12 - "camera_section.dart"
Cohesion: 0.11
Nodes (17): CameraController?, build, _buildCameraArea, _cameras, _capturedImage, _controller, createState, dispose (+9 more)

### Community 13 - "check_in_page.dart"
Cohesion: 0.07
Nodes (29): _cameraController, _cameraError, _cameras, _capturedSelfie, createState, dispose, _distanceLabel, _distanceToOutlet (+21 more)

### Community 14 - "check_out_page.dart"
Cohesion: 0.06
Nodes (30): ../../../core/utils/image_utils.dart, _cameraController, _cameraError, _cameras, _capturedSelfie, createState, dispose, _distanceLabel (+22 more)

### Community 15 - "admin_attendance_page.dart"
Cohesion: 0.04
Nodes (45): ../data/kpi_model.dart, ../data/kpi_repository.dart, absentDays, attendanceRate, calculateScore, fromJson, grade, gradeFromScore (+37 more)

### Community 16 - "admin_providers.dart"
Cohesion: 0.13
Nodes (14): ../data/admin_repository.dart, AdminRepository, accounts, activeBrand, allUsers, filter, getEmployee, getRoles (+6 more)

### Community 17 - "auth_repository.dart"
Cohesion: 0.06
Nodes (30): auth_model.dart, ../../../core/database/app_database.dart, ../../../core/network/auth_api_client.dart, _authRealm, changePassword, _client, _coreClient, getCurrentUser (+22 more)

### Community 18 - "location_card.dart"
Cohesion: 0.13
Nodes (15): build, _buildContent, _buildCoordRow, _buildMapView, _buildPlaceholderMap, createState, error, isLoading (+7 more)

### Community 19 - "auth_providers.dart"
Cohesion: 0.15
Nodes (12): ../data/auth_model.dart, ../data/auth_repository.dart, AuthRepository, authInitProvider, authState, AuthStatus, getKangiderId, getUserRole (+4 more)

### Community 20 - "admin_repository.dart"
Cohesion: 0.10
Nodes (19): admin_user_model.dart, _client, createUser, deleteUser, getAllAttendance, getEmployee, getEmployeeAccounts, getRoles (+11 more)

### Community 21 - "history_page.dart"
Cohesion: 0.10
Nodes (19): build, _confirmationController, controller, createState, _currentPasswordController, dispose, _errorMessage, helperText (+11 more)

### Community 22 - "auth_interceptor.dart"
Cohesion: 0.06
Nodes (32): auth_api_client.dart, auth_interceptor.dart, Dio, Dio get, authInterceptor, _create, delete, _dio (+24 more)

### Community 23 - "home_page.dart"
Cohesion: 0.06
Nodes (41): CustomPainter, dart:math, ../data/holiday_model.dart, ../data/holiday_repository.dart, ../../holiday/providers/holiday_providers.dart, build, AdminDashboardPage, build (+33 more)

### Community 24 - "login_page.dart"
Cohesion: 0.12
Nodes (16): createState, dispose, _emailController, _emailFocusNode, errorMessage, initState, _isAdminMode, _isLoading (+8 more)

### Community 25 - "profile_model.dart"
Cohesion: 0.14
Nodes (13): alpha, email, firstName, fromJson, hadir, id, kangiderId, kangiderNama (+5 more)

### Community 26 - "attendance_repository.dart"
Cohesion: 0.13
Nodes (14): attendance_model.dart, ../../../core/data/attendance_data_source.dart, checkIn, checkOut, _client, getHistory, getMonthlyHistory, getTodayAttendance (+6 more)

### Community 27 - "profile_providers.dart"
Cohesion: 0.10
Nodes (22): admin_attendance_detail_page.dart, ../../attendance/data/attendance_model.dart, Color, ../../core/constants/app_colors.dart, ../../core/providers/brand_provider.dart, createState, _selectedFilterIndex, _buildCompactStat (+14 more)

### Community 28 - "currentUserProvider"
Cohesion: 0.11
Nodes (18): apiBaseUrl, AppConfig, appVersion, authApiBaseUrl, _configuredAuthApiBaseUrl, _configuredCoreApiBaseUrl, connectTimeout, coreApiBaseUrl (+10 more)

### Community 29 - "attendance_providers.dart"
Cohesion: 0.11
Nodes (18): ../data/attendance_repository.dart, alpha, cached, dao, endDate, endStr, hadir, historyProvider (+10 more)

### Community 30 - "profile_page.dart"
Cohesion: 0.22
Nodes (8): ../../attendance/providers/attendance_providers.dart, ../../auth/providers/auth_providers.dart, ../data/profile_model.dart, AttendanceStats, now, params, stats, user

### Community 31 - "directus_client.dart"
Cohesion: 0.17
Nodes (13): changePasswordRequest, loginRequest, principal, refreshRequest, sessionResponse, userResponse, Server, Context (+5 more)

### Community 32 - "ConsumerState"
Cohesion: 0.14
Nodes (15): core/router/app_router.dart, dart:async, features/sync/providers/sync_providers.dart, build, _connectivitySub, createState, dispose, IderKopiApp (+7 more)

### Community 33 - "Directus Schema Changes & Setup"
Cohesion: 0.15
Nodes (14): adminAccountResponse, resetAdminAccountPasswordRequest, syncAdminAccountProfileRequest, updateAdminAccountStatusRequest, Server, Ctx, Time, UUID (+6 more)

### Community 34 - "gradient_header.dart"
Cohesion: 0.10
Nodes (19): dart:ui, double?, EdgeInsets, Gradient?, borderRadius, build, child, gradient (+11 more)

### Community 35 - "wWinMain"
Cohesion: 0.17
Nodes (12): Context, Run(), Conn, _In_, _In_opt_, vector, wWinMain(), string (+4 more)

### Community 36 - "date_utils.dart"
Cohesion: 0.12
Nodes (16): AppDateUtils, _days, daysInMonth, formatDate, formatDateShort, formatFullDate, formatMonthYear, formatTime (+8 more)

### Community 37 - "todayAttendanceProvider"
Cohesion: 0.29
Nodes (12): ConsumerState, _CheckInPageState, _getCurrentLocation, _handleSubmit, _CheckOutPageState, _getCurrentLocation, _handleSubmit, attendanceRepositoryProvider (+4 more)

### Community 38 - "admin_dashboard_page.dart"
Cohesion: 0.19
Nodes (15): CameraSection, _CameraSectionState, _LoadingPulse, _LoadingPulseState, OutletMapWidget, _OutletMapWidgetState, AdminShell, _AdminShellState (+7 more)

### Community 39 - "admin_nav_bar.dart"
Cohesion: 0.14
Nodes (13): ../../features/admin/presentation/admin_attendance_page.dart, ../../features/admin/presentation/admin_dashboard_page.dart, ../../features/admin/presentation/admin_profile_page.dart, ../../features/admin/presentation/admin_users_page.dart, build, child, createState, currentPath (+5 more)

### Community 40 - "manifest.json"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 41 - "package:flutter_riverpod/flutter_riverpod.dart"
Cohesion: 0.67
Nodes (3): T, TestJWTClaimsAndAlgorithm(), TestRefreshTokenHash()

### Community 42 - "bottom_nav_bar.dart"
Cohesion: 0.13
Nodes (14): ../../features/attendance/presentation/history_page.dart, ../../features/attendance/presentation/home_page.dart, ../../features/profile/presentation/profile_page.dart, build, _buildNavItem, child, createState, currentPath (+6 more)

### Community 44 - "Roadmap Pengembangan"
Cohesion: 0.50
Nodes (3): Berikutnya, Roadmap, Selesai

### Community 45 - "StatelessWidget"
Cohesion: 0.20
Nodes (11): ../../../core/database/database_providers.dart, ../data/sync_repository.dart, SyncResult, build, PendingSyncBadge, manualSyncProvider, pendingCount, pendingSyncCountProvider (+3 more)

### Community 46 - "../../../core/network/api_client.dart"
Cohesion: 0.14
Nodes (14): ../../../core/config/app_config.dart, ../../../core/network/api_client.dart, kpi_model.dart, ApiClient, _client, getMyKpi, _instance, _mockKpi (+6 more)

### Community 47 - "package:flutter/material.dart"
Cohesion: 0.15
Nodes (13): bool get, AdminUserFormPage, _AdminUserFormPageState, createState, dispose, _emailController, initState, isEditing (+5 more)

### Community 48 - "IderKopi Absensi — Project Overview"
Cohesion: 0.50
Nodes (3): Domain, IDER KOPI Mobile — Overview, Topologi

### Community 50 - "Dependencies (pubspec.yaml)"
Cohesion: 0.25
Nodes (7): Android (`android/app/src/main/AndroidManifest.xml`), Core Dependencies, Dependencies (pubspec.yaml), Dev Dependencies, Full pubspec.yaml, iOS (`ios/Runner/Info.plist`), Permissions

### Community 51 - "authRepositoryProvider"
Cohesion: 0.20
Nodes (15): AdminProfilePage, _handleLogout, ChangePasswordPage, _ChangePasswordPageState, _submit, _handleLogin, initState, authRepositoryProvider (+7 more)

### Community 52 - "error_view.dart"
Cohesion: 0.17
Nodes (11): ../constants/app_colors.dart, AppTheme, buttonShadow, cardShadow, cardShadowLarge, floatingShadow, gradientShadow, light (+3 more)

### Community 53 - "SyncRepository"
Cohesion: 0.11
Nodes (18): Interceptor, adminAuthDio, authDio, AuthInterceptor, _isAuthenticationBootstrapEndpoint, onError, onRequest, _performRefresh (+10 more)

### Community 54 - "../../core/constants/app_colors.dart"
Cohesion: 0.22
Nodes (8): build, _buildPlaceholder, _buildSelfieThumbnail, _buildTimeChip, HistoryListItem, record, selfieUrl, package:cached_network_image/cached_network_image.dart

### Community 55 - "dart:io"
Cohesion: 0.18
Nodes (19): Apply(), first(), Context, Pool, Time, UUID, LoadCurrent(), NewSource() (+11 more)

### Community 56 - "location_utils.dart"
Cohesion: 0.33
Nodes (5): distanceTo, getCurrentLocation, isWithinOutletRadius, LocationUtils, package:geolocator/geolocator.dart

### Community 57 - "IderKopi Absensi"
Cohesion: 0.33
Nodes (5): Development, Dokumentasi, Fitur, IDER KOPI Mobile, Runtime

### Community 59 - "widget_test.dart"
Cohesion: 0.11
Nodes (12): package:flutter_test/flutter_test.dart, package:iderkopi_absensi/core/notifications/notification_service.dart, package:iderkopi_absensi/features/admin/data/admin_user_model.dart, package:iderkopi_absensi/features/auth/data/auth_model.dart, package:iderkopi_absensi/features/kpi/data/kpi_model.dart, package:iderkopi_absensi/features/recap/data/recap_model.dart, main, main (+4 more)

### Community 67 - "shift_model.dart"
Cohesion: 0.10
Nodes (19): copyWith, date, endTime, _formatTime, fromJson, id, isActive, isWithinShift (+11 more)

### Community 68 - "Rencana Pengembangan Lengkap IderKopi Absensi"
Cohesion: 0.50
Nodes (3): Development Plan, Kontrak wajib, Quality gate

### Community 69 - "shift_schedule_page.dart"
Cohesion: 0.10
Nodes (21): UserShift, build, _buildCalendar, _buildLegend, _buildMonthPicker, _buildUpcomingShifts, color, createState (+13 more)

### Community 70 - "settings_providers.dart"
Cohesion: 0.06
Nodes (31): ../../../core/notifications/notification_providers.dart, ../../holiday/data/holiday_repository.dart, _applySchedule, checkInReminderEnabled, checkInReminderHour, checkInReminderMinute, checkOutReminderEnabled, checkOutReminderHour (+23 more)

### Community 71 - "recap_model.dart"
Cohesion: 0.06
Nodes (31): absent, 
  leave, 
  holiday, 
  weekend,, absentCount, absentDays, build, checkInTime, checkOutTime, date, days (+23 more)

### Community 72 - "paginated_notifier.dart"
Cohesion: 0.07
Nodes (27): AppBrand, AppBrandNotifier, badgeText, code, iconData, lightColor, name, outletFilter (+19 more)

### Community 73 - "notification_service.dart"
Cohesion: 0.07
Nodes (28): FlutterLocalNotificationsPlugin, cancelAll, cancelCheckInReminder, cancelCheckOutReminder, _channelDesc, _channelId, _channelName, _checkInReminderId (+20 more)

### Community 74 - "pending_sync_dao.dart"
Cohesion: 0.07
Nodes (26): attempts, copyWith, countPending, createdAt, _database, _db, deleteSynced, enqueue (+18 more)

### Community 75 - "leave_model.dart"
Cohesion: 0.07
Nodes (27): izin,
  sakit,, approvedAt, approverId, approverNote, attachmentFileId, canEdit, clientRequestId, copyWith (+19 more)

### Community 76 - "outlet_map_widget.dart"
Cohesion: 0.09
Nodes (21): ../../../core/constants/map_constants.dart, build, _buildOutletPin, _buildUserPin, createState, didUpdateWidget, dispose, _fitBounds (+13 more)

### Community 77 - "sync_repository.dart"
Cohesion: 0.10
Nodes (20): ../../attendance/data/attendance_repository.dart, conflict_resolver.dart, ../../../core/database/daos/pending_sync_dao.dart, int get, attendanceRepo, enqueueCheckIn, enqueueCheckOut, failed (+12 more)

### Community 78 - "admin_outlet_edit_page.dart"
Cohesion: 0.10
Nodes (20): _addressController, AdminOutletEditPage, _AdminOutletEditPageState, build, createState, dispose, _handleSave, initState (+12 more)

### Community 79 - "splash_screen.dart"
Cohesion: 0.11
Nodes (18): Animation, AnimationController, build, _controller, createState, dispose, _fadeAnimation, _logoController (+10 more)

### Community 80 - "leave_form_page.dart"
Cohesion: 0.12
Nodes (15): LeaveType, build, createState, _DateField, dispose, _endDate, _isSubmitting, label (+7 more)

### Community 81 - "admin_user_model.dart"
Cohesion: 0.05
Nodes (39): accountActive, brand, copyWith, createdAt, CreateUserData, department, departmentId, departmentName (+31 more)

### Community 82 - "leave_approval_page.dart"
Cohesion: 0.18
Nodes (11): ../data/leave_model.dart, leave_form_page.dart, build, _buildEmptyState, _formatDate, leave, _LeaveCard, LeaveListPage (+3 more)

### Community 83 - "sync_log_dao.dart"
Cohesion: 0.10
Nodes (19): int?, clear, conflictType, count, createdAt, _database, _db, fromRow (+11 more)

### Community 84 - "outlet_repository.dart"
Cohesion: 0.11
Nodes (17): ../../../core/storage/secure_storage.dart, addOutlet, _cacheKey, _cacheTimestampKey, _cacheTtl, clearCache, _client, getOutletById (+9 more)

### Community 85 - "recap_page.dart"
Cohesion: 0.10
Nodes (20): RecapDay, build, _buildDetailTable, _buildMonthPicker, _buildSummaryRow, color, createState, day (+12 more)

### Community 86 - "outlet_picker_sheet.dart"
Cohesion: 0.13
Nodes (15): ../data/outlet_model.dart, createState, distance, _EmptyOutletState, isSelected, onRetry, onTap, OutletPickerSheet (+7 more)

### Community 87 - "app_database.dart"
Cohesion: 0.11
Nodes (17): Database?, clearCache, clearTestDatabase, close, _db, _dbName, _dbVersion, _instance (+9 more)

### Community 88 - "holiday_repository.dart"
Cohesion: 0.18
Nodes (10): ../../../core/utils/mock_data.dart, holiday_model.dart, _client, getHolidayForDate, getHolidays, getTodayHoliday, getTomorrowHoliday, hasCache (+2 more)

### Community 89 - "leave_repository.dart"
Cohesion: 0.14
Nodes (13): leave_model.dart, approve, _client, _decodeList, delete, getMyLeaves, getPendingLeaves, _instance (+5 more)

### Community 90 - "admin_user_form_page.dart"
Cohesion: 0.16
Nodes (14): admin_user_form_page.dart, AdminUser, _toggleAccount, AdminUserDetailPage, _AdminUserDetailPageState, _buildDetailTile, _confirmDelete, createState (+6 more)

### Community 91 - "kpi_repository.dart"
Cohesion: 0.15
Nodes (13): FlutterSecureStorage, createPlatformStorageBackend, deleteAll, read, _storage, write, createPlatformStorageBackend, deleteAll (+5 more)

### Community 92 - "attendance_data_source.dart"
Cohesion: 0.11
Nodes (17): ../../../features/attendance/data/attendance_model.dart, AdminDataSource, AuthDataSource, checkIn, checkOut, getAllAttendance, getCurrentUser, getHistory (+9 more)

### Community 93 - "package:flutter/foundation.dart"
Cohesion: 0.14
Nodes (12): app.dart, core/background/sync_worker.dart, core/notifications/notification_service.dart, notificationServiceProvider, main, package:flutter_riverpod/flutter_riverpod.dart, package:iderkopi_absensi/core/router/app_router.dart, package:iderkopi_absensi/features/auth/presentation/change_password_page.dart (+4 more)

### Community 94 - "attendance_dao.dart"
Cohesion: 0.12
Nodes (15): dart:convert, _database, _db, deleteByKangider, encodeRecords, _fromRow, getHistory, getMonthlyHistory (+7 more)

### Community 95 - "outlet_dao_test.dart"
Cohesion: 0.25
Nodes (7): SyncLogDao, package:iderkopi_absensi/core/database/daos/sync_log_dao.dart, package:iderkopi_absensi/features/sync/data/conflict_resolver.dart, dao, main, main, syncLogDao

### Community 96 - "async_value_widget.dart"
Cohesion: 0.14
Nodes (13): AsyncValue, AsyncListWidget, build, emptyIcon, emptyMessage, emptyValue, emptyWidget, errorTitle (+5 more)

### Community 97 - "outlet_providers.dart"
Cohesion: 0.13
Nodes (14): ../../../core/utils/location_utils.dart, ../data/outlet_repository.dart, OutletRepository, any, distances, getOutlets, hasOutletInRadiusProvider, isCacheStale (+6 more)

### Community 98 - "outlet_model.dart"
Cohesion: 0.12
Nodes (15): alamat, distanceMeters, fromJson, hasValidGeofence, id, isActive, isWithinRadius, latitude (+7 more)

### Community 99 - "settings_page.dart"
Cohesion: 0.12
Nodes (17): build, enabled, hour, icon, iconColor, minute, onTimeChanged, onToggle (+9 more)

### Community 100 - "settings_page_test.dart"
Cohesion: 0.17
Nodes (11): NotificationService, _NullPrefs, package:iderkopi_absensi/core/notifications/notification_providers.dart, package:iderkopi_absensi/features/settings/presentation/settings_page.dart, package:iderkopi_absensi/features/settings/providers/settings_providers.dart, package:shared_preferences/shared_preferences.dart, SharedPreferences, main (+3 more)

### Community 101 - "cached_image.dart"
Cohesion: 0.22
Nodes (13): App, T, TestCORSPreflight(), TestInternalAdminAuthFailsClosed(), TestParseAuthorization(), Duration, Logger, Pool (+5 more)

### Community 102 - "Changelog"
Cohesion: 0.50
Nodes (3): 1.0.0 — MVP, 2.0.0 — Custom Go API, Changelog

### Community 103 - "ConsumerWidget"
Cohesion: 0.17
Nodes (15): ConsumerWidget, AdminAttendanceDetailPage, _editEmployee, build, _MapPreview, _OfflineBanner, _showOfflineSuccessDialog, _showSuccessDialog (+7 more)

### Community 104 - "mock_data.dart"
Cohesion: 0.14
Nodes (13): ../../features/auth/data/auth_model.dart, getUser, isAdmin, mockAllAttendance, MockData, mockHolidays, mockOutlets, mockRoles (+5 more)

### Community 105 - "app_theme.dart"
Cohesion: 0.29
Nodes (7): ConsumerStatefulWidget, AdminAttendancePage, _AdminAttendancePageState, build, adminAttendanceProvider, CheckInPage, CheckOutPage

### Community 106 - "../../auth/providers/auth_providers.dart"
Cohesion: 0.18
Nodes (11): class, AdminShiftSettingsPage, _AdminShiftSettingsPageState, createState, _handleSave, _isSaving, _jamMasuk, _jamPulang (+3 more)

### Community 107 - "currentUserProvider"
Cohesion: 0.18
Nodes (10): ../data/leave_repository.dart, LeaveRepository, getMyLeaves, getPendingLeaves, leaveRepositoryProvider, repo, result, role (+2 more)

### Community 108 - "kpi_page.dart"
Cohesion: 0.18
Nodes (10): package:path/path.dart, package:sqflite_common_ffi/sqflite_ffi.dart, static bool, static int, createInMemory, _databaseSequence, initFfi, _initialized (+2 more)

### Community 109 - "database_providers.dart"
Cohesion: 0.17
Nodes (11): app_database.dart, daos/attendance_dao.dart, daos/outlet_dao.dart, daos/pending_sync_dao.dart, daos/sync_log_dao.dart, AppDatabase, appDatabaseProvider, attendanceDaoProvider (+3 more)

### Community 110 - "directus_attendance_data_source.dart"
Cohesion: 0.50
Nodes (3): Dokumentasi Lengkap IDER KOPI Mobile (v2.0.0+1), Prosedur Verifikasi Kode, Ringkasan System v2.0.0+1

### Community 111 - "package:flutter_riverpod/flutter_riverpod.dart"
Cohesion: 0.11
Nodes (19): dart:typed_data, Exception, HttpClientAdapter, AuthLoginException, ChangePasswordException, package:iderkopi_absensi/core/network/api_client.dart, package:iderkopi_absensi/core/network/auth_api_client.dart, package:iderkopi_absensi/core/network/auth_interceptor.dart (+11 more)

### Community 112 - "sync_providers.dart"
Cohesion: 0.17
Nodes (11): assignShift, _client, getMyShifts, getShifts, _instance, isCheckInOnShift, _mockShifts, ShiftRepository (+3 more)

### Community 113 - "outlet_dao.dart"
Cohesion: 0.15
Nodes (12): ../../../features/outlet/data/outlet_model.dart, Future, clear, _database, _db, _fromRow, getAll, getById (+4 more)

### Community 114 - "status_pie_chart.dart"
Cohesion: 0.17
Nodes (11): RecapStatus, build, _buildSegments, color, distribution, label, _Segment, status (+3 more)

### Community 115 - "api_providers.dart"
Cohesion: 0.25
Nodes (8): LeaveRequest, build, _buildEmptyState, _formatDate, leave, LeaveApprovalPage, pendingLeavesProvider, ../providers/leave_providers.dart

### Community 116 - "ConsumerState"
Cohesion: 0.42
Nodes (10): applyFlag(), Context, Logger, Pool, initialPassword(), main(), run(), runProvision() (+2 more)

### Community 117 - "recap_providers.dart"
Cohesion: 0.18
Nodes (10): ../data/recap_repository.dart, RecapSummary, RecapRepository, currentMonthRecapProvider, getMonthlyRecap, now, recapRepositoryProvider, ref (+2 more)

### Community 118 - "pending_sync_badge_test.dart"
Cohesion: 0.20
Nodes (9): Fake, SyncRepository, package:iderkopi_absensi/features/sync/data/sync_repository.dart, package:iderkopi_absensi/features/sync/presentation/widgets/pending_sync_badge.dart, package:iderkopi_absensi/features/sync/providers/sync_providers.dart, count, _FakeSyncRepository, main (+1 more)

### Community 119 - "storage_backend.dart"
Cohesion: 0.22
Nodes (8): createStorageBackend, deleteAll, NativeStorageBackend, read, StorageBackend, WebStorageBackend, write, storage_backend_native.dart

### Community 120 - "StatelessWidget"
Cohesion: 0.08
Nodes (27): AsyncValueWidget, CoreEmployee, MobileEmployeeAccount, account, _DetailTile, employee, _EmployeeContent, employeeId (+19 more)

### Community 121 - "attendance_bar_chart.dart"
Cohesion: 0.18
Nodes (10): ../data/admin_user_model.dart, _AdminTile, _content, _formatDateTime, label, _resetPassword, _showError, _showOneTimePassword (+2 more)

### Community 123 - "build"
Cohesion: 0.13
Nodes (14): BorderRadius?, BoxFit, borderRadius, build, CachedImage, fileId, fit, height (+6 more)

### Community 124 - "../data/attendance_model.dart"
Cohesion: 0.24
Nodes (11): currentUserProvider, _handleApprove, _handleReject, _PendingLeaveCard, _handleSubmit, LeaveFormPage, _LeaveFormPageState, approveLeaveProvider (+3 more)

### Community 125 - "10. Directus Schema & Permissions"
Cohesion: 0.40
Nodes (4): Custom Go API Contract, Employee authenticated, Kontrak data, Public

### Community 126 - "outlet_picker_sheet_test.dart"
Cohesion: 0.25
Nodes (6): package:iderkopi_absensi/features/outlet/data/outlet_model.dart, package:iderkopi_absensi/features/outlet/presentation/outlet_picker_sheet.dart, package:iderkopi_absensi/features/outlet/providers/outlet_providers.dart, main, main, _mockOutlets

### Community 127 - "static const String"
Cohesion: 0.29
Nodes (6): ../config/app_config.dart, mapboxStyleId, MapConstants, osmTileUrl, userAgentPackageName, static const String

### Community 128 - "conflict_resolver.dart"
Cohesion: 0.33
Nodes (5): ../../../core/database/daos/sync_log_dao.dart, ConflictResolver, logGenericConflict, resolveAlreadyCheckedOut, resolveDuplicateCheckIn

### Community 129 - "empty_view.dart"
Cohesion: 0.13
Nodes (13): ../../core/theme/app_theme.dart, IconData, build, EmptyView, icon, subtitle, title, build (+5 more)

### Community 130 - "api_provider_test.dart"
Cohesion: 0.27
Nodes (10): Apply(), Context, Pool, UUID, Plan(), Preview(), T, TestPlanIsIdempotent() (+2 more)

### Community 131 - "recap_model_test.dart"
Cohesion: 0.25
Nodes (9): AdminAccountDetailPage, build, _editAccount, build, build, _handleSave, adminUserDetailProvider, rolesProvider (+1 more)

### Community 132 - "sync_providers.dart"
Cohesion: 0.13
Nodes (15): AdminExportRecapPage, _AdminExportRecapPageState, build, createState, formats, _handleExport, _isExporting, months (+7 more)

### Community 133 - "build"
Cohesion: 0.17
Nodes (11): ../data/shift_model.dart, ../data/shift_repository.dart, currentMonthShiftsProvider, getMyShifts, getShifts, now, repo, shiftRepositoryProvider (+3 more)

### Community 134 - "SharedPreferences"
Cohesion: 0.18
Nodes (10): ../../kpi/presentation/kpi_page.dart, ../../leave/presentation/leave_list_page.dart, _buildInfoRow, _buildMenuItem, _buildMstat, _buildStatsCard2, ../providers/profile_providers.dart, ../../recap/presentation/recap_page.dart (+2 more)

### Community 135 - ".changePassword"
Cohesion: 0.36
Nodes (6): HashPassword(), T, TestHashAndVerifyPassword(), TestValidatePassword(), ValidatePassword(), VerifyPassword()

### Community 136 - "Load"
Cohesion: 0.44
Nodes (8): allowedEmployeeSourceURL(), Duration, Load(), required(), requiredDuration(), requiredInt(), Config, URL

### Community 137 - "employees_test.go"
Cohesion: 0.31
Nodes (7): T, TestParseSourceArrayAndWrapper(), TestPlanDetectsChangesAndConflicts(), TestSourceHeaderAndSafeError(), roundTripFunc, Request, Response

### Community 138 - "holiday_providers.dart"
Cohesion: 0.38
Nodes (7): activeBrandProvider, build, build, ProfilePage, profileInfoProvider, profileStatsProvider, showOutletModeSheet

### Community 139 - "holiday_model.dart"
Cohesion: 0.29
Nodes (6): AttendanceRecord, AttendanceSummaryCard, build, _buildTimeRow, record, status_badge.dart

### Community 140 - "Ider Kopi mobile authentication backend"
Cohesion: 0.29
Nodes (6): API, Configuration, Ider Kopi mobile authentication backend, Local verification, Runbook, Security model

### Community 141 - "empty_view.dart"
Cohesion: 0.50
Nodes (3): Admin, Daftar Akun Login IDER KOPI, Employee

### Community 142 - "attendance_bar_chart.dart"
Cohesion: 0.20
Nodes (9): ../data/recap_model.dart, AttendanceBarChart, build, color, label, _LegendDot, weeklySummaries, List (+1 more)

### Community 143 - "Separate Mobile Authentication Implementation Plan"
Cohesion: 0.33
Nodes (5): Separate Mobile Authentication Implementation Plan, Task 1: Cleanup dan employee sync API backend utama, Task 2: Backend auth terpisah milik Flutter, Task 3: Flutter dual-API integration, Task 4: Integration, security review, and deployment

### Community 144 - "001_initial.sql"
Cohesion: 0.70
Nodes (4): employees, refresh_tokens, roles, users

### Community 145 - "attendance_dao_test.dart"
Cohesion: 0.13
Nodes (14): ../../../helpers/test_database_helper.dart, AttendanceDao, OutletDao, PendingSyncDao, package:iderkopi_absensi/core/database/app_database.dart, package:iderkopi_absensi/core/database/daos/attendance_dao.dart, package:iderkopi_absensi/core/database/daos/outlet_dao.dart, package:iderkopi_absensi/core/database/daos/pending_sync_dao.dart (+6 more)

### Community 150 - "../data/attendance_model.dart"
Cohesion: 0.25
Nodes (7): ../data/attendance_model.dart, AttendanceStatus, build, size, status, StatusBadge, StatusBadgeSize

### Community 151 - "admin_user_model_test.dart"
Cohesion: 0.33
Nodes (6): _buildListItem, _buildFeedItem, build, _buildOutletCard, _onAddPressed, MaterialPageRoute

### Community 153 - "image_utils.dart"
Cohesion: 0.18
Nodes (9): dart:io, compressImage, ImageUtils, package:camera/camera.dart, package:flutter/foundation.dart, package:iderkopi_absensi/features/attendance/presentation/widgets/attendance_camera_status.dart, package:image/image.dart, package:path_provider/path_provider.dart (+1 more)

### Community 154 - "api_providers.dart"
Cohesion: 0.33
Nodes (6): ../data/attendance_data_source.dart, ../../features/attendance/data/attendance_repository.dart, AttendanceDataSource, attendanceDataSourceProvider, attendanceRepositoryV2Provider, AttendanceRepository

### Community 155 - "recap_model_test.dart"
Cohesion: 0.40
Nodes (4): ../../../core/utils/date_utils.dart, record, ../../outlet/data/outlet_model.dart, ../../outlet/presentation/outlet_map_widget.dart

### Community 156 - "PreviewReset"
Cohesion: 0.60
Nodes (5): Context, Pool, PreviewReset(), ResetActive(), ResetReport

### Community 157 - "NotificationSettingsNotifier"
Cohesion: 0.67
Nodes (4): AdminEmployeeDetailPage, build, employeeAccountsProvider, employeeDetailProvider

### Community 162 - "empty_view.dart"
Cohesion: 0.25
Nodes (7): attendanceCameraErrorMessage, AttendanceCameraStatus, build, errorMessage, isInitializing, onRetry, VoidCallback?

## Knowledge Gaps
- **1371 isolated node(s):** `iderkopi/auth-backend`, `updateAdminAccountStatusRequest`, `resetAdminAccountPasswordRequest`, `syncAdminAccountProfileRequest`, `loginRequest` (+1366 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **15 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `AppDatabase` connect `database_providers.dart` to `pending_sync_dao.dart`, `outlet_dao.dart`, `sync_log_dao.dart`, `app_database.dart`, `attendance_dao.dart`?**
  _High betweenness centrality (0.014) - this node is a cross-community bridge._
- **Why does `_submit` connect `authRepositoryProvider` to `history_page.dart`?**
  _High betweenness centrality (0.009) - this node is a cross-community bridge._
- **What connects `iderkopi/auth-backend`, `updateAdminAccountStatusRequest`, `resetAdminAccountPasswordRequest` to the rest of the system?**
  _1371 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Win32Window` be split into smaller, more focused modules?**
  _Cohesion score 0.0597567424643046 - nodes in this community are weakly interconnected._
- **Should `app_colors.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.04081632653061224 - nodes in this community are weakly interconnected._
- **Should `custom_button.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.08 - nodes in this community are weakly interconnected._
- **Should `GeneratedPluginRegistrant.swift` be split into smaller, more focused modules?**
  _Cohesion score 0.04964539007092199 - nodes in this community are weakly interconnected._