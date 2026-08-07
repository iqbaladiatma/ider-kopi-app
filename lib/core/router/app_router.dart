import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/presentation/admin_attendance_page.dart';
import '../../features/admin/presentation/admin_dashboard_page.dart';
import '../../features/admin/presentation/admin_profile_page.dart';
import '../../features/admin/presentation/admin_users_page.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../features/attendance/presentation/attendance_options_page.dart';
import '../../features/attendance/presentation/check_in_page.dart';
import '../../features/attendance/presentation/check_out_page.dart';
import '../../features/attendance/presentation/history_page.dart';
import '../../features/attendance/presentation/home_page.dart';
import '../../features/kpi/presentation/kpi_page.dart';
import '../../features/leave/presentation/leave_approval_page.dart';
import '../../features/leave/presentation/leave_form_page.dart';
import '../../features/leave/presentation/leave_list_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/recap/presentation/recap_page.dart';
import '../../features/settings/presentation/settings_page.dart';
import '../../features/shift/presentation/shift_schedule_page.dart';
import '../../shared/widgets/admin_nav_bar.dart';
import '../../shared/widgets/bottom_nav_bar.dart';

class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this._ref) {
    _ref.read(authInitProvider);
    _ref.listen(authStateProvider, (_, __) => notifyListeners());
    _ref.listen(userRoleProvider, (_, __) => notifyListeners());
    _ref.listen(authInitProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;

  bool get isInitializing =>
      _ref.read(authInitProvider).isLoading ||
      _ref.read(authStateProvider) == AuthStatus.initial;

  bool get isLoggedIn =>
      _ref.read(authStateProvider) == AuthStatus.authenticated;

  bool get isAdmin {
    final role = _ref.read(userRoleProvider).asData?.value;
    return role?.toLowerCase() == 'admin';
  }
}

final _routerNotifierProvider = Provider<_RouterNotifier>((ref) {
  return _RouterNotifier(ref);
});

Page<dynamic> _buildTransitionPage({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.04, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(_routerNotifierProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: (context, state) {
      final isSplashRoute = state.matchedLocation == '/splash';
      final isLoginRoute = state.matchedLocation == '/login';

      if (notifier.isInitializing) {
        return isSplashRoute ? null : '/splash';
      }

      if (isSplashRoute) {
        return notifier.isLoggedIn
            ? (notifier.isAdmin ? '/admin' : '/home')
            : '/login';
      }

      final isLoggedIn = notifier.isLoggedIn;
      final isAdmin = notifier.isAdmin;
      final isAdminRoute = state.matchedLocation.startsWith('/admin');
      final isUserRoute = state.matchedLocation == '/home' ||
          state.matchedLocation == '/attendance-options' ||
          state.matchedLocation.startsWith('/check') ||
          state.matchedLocation == '/history' ||
          state.matchedLocation == '/profile';

      if (!isLoggedIn && !isLoginRoute) return '/login';
      if (isLoggedIn && isLoginRoute) {
        return isAdmin ? '/admin' : '/home';
      }
      if (isLoggedIn && isAdminRoute && !isAdmin) return '/home';
      if (isLoggedIn && isUserRoute && isAdmin) return '/admin';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => _buildTransitionPage(
          context: context,
          state: state,
          child: const LoginPage(),
        ),
      ),
      GoRoute(
        path: '/check-in',
        pageBuilder: (context, state) => _buildTransitionPage(
          context: context,
          state: state,
          child: const CheckInPage(),
        ),
      ),
      GoRoute(
        path: '/check-out',
        pageBuilder: (context, state) => _buildTransitionPage(
          context: context,
          state: state,
          child: CheckOutPage(reason: state.extra as String?),
        ),
      ),
      // Admin routes with shell
      ShellRoute(
        builder: (_, __, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: '/admin',
            builder: (_, __) => const AdminDashboardPage(),
          ),
          GoRoute(
            path: '/admin/users',
            builder: (_, __) => const AdminUsersPage(),
          ),
          GoRoute(
            path: '/admin/attendance',
            builder: (_, __) => const AdminAttendancePage(),
          ),
          GoRoute(
            path: '/admin/profile',
            builder: (_, __) => const AdminProfilePage(),
          ),
        ],
      ),
      // User routes with shell
      ShellRoute(
        builder: (_, __, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, __) => const HomePage(),
          ),
          GoRoute(
            path: '/attendance-options',
            builder: (_, __) => const AttendanceOptionsPage(),
          ),
          GoRoute(
            path: '/history',
            builder: (_, __) => const HistoryPage(),
          ),
          GoRoute(
            path: '/profile',
            builder: (_, __) => const ProfilePage(),
          ),
          GoRoute(
            path: '/settings',
            builder: (_, __) => const SettingsPage(),
          ),
          GoRoute(
            path: '/leave',
            builder: (_, __) => const LeaveListPage(),
          ),
          GoRoute(
            path: '/leave/form',
            builder: (_, __) => const LeaveFormPage(),
          ),
          GoRoute(
            path: '/leave/approval',
            builder: (_, __) => const LeaveApprovalPage(),
          ),
          GoRoute(
            path: '/kpi',
            builder: (_, __) => const KpiPage(),
          ),
          GoRoute(
            path: '/recap',
            builder: (_, __) => const RecapPage(),
          ),
          GoRoute(
            path: '/shift',
            builder: (_, __) => const ShiftSchedulePage(),
          ),
        ],
      ),
    ],
  );
});
