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
import '../../features/attendance/presentation/check_in_page.dart';
import '../../features/attendance/presentation/check_out_page.dart';
import '../../features/attendance/presentation/history_page.dart';
import '../../features/attendance/presentation/home_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../shared/widgets/admin_nav_bar.dart';
import '../../shared/widgets/bottom_nav_bar.dart';

class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this._ref) {
    // Trigger auth init immediately
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

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(_routerNotifierProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: (context, state) {
      final isSplashRoute = state.matchedLocation == '/splash';
      final isLoginRoute = state.matchedLocation == '/login';

      // While initializing auth, stay on splash
      if (notifier.isInitializing) {
        return isSplashRoute ? null : '/splash';
      }

      // Auth initialized — leave splash
      if (isSplashRoute) {
        return notifier.isLoggedIn
            ? (notifier.isAdmin ? '/admin' : '/home')
            : '/login';
      }

      final isLoggedIn = notifier.isLoggedIn;
      final isAdmin = notifier.isAdmin;
      final isAdminRoute = state.matchedLocation.startsWith('/admin');
      final isUserRoute = state.matchedLocation == '/home' ||
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
        builder: (_, __) => const LoginPage(),
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
            path: '/check-in',
            builder: (_, __) => const CheckInPage(),
          ),
          GoRoute(
            path: '/check-out',
            builder: (_, __) => const CheckOutPage(),
          ),
          GoRoute(
            path: '/history',
            builder: (_, __) => const HistoryPage(),
          ),
          GoRoute(
            path: '/profile',
            builder: (_, __) => const ProfilePage(),
          ),
        ],
      ),
    ],
  );
});
