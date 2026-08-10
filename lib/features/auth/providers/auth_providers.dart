import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_model.dart';
import '../data/auth_repository.dart';

enum AuthStatus {
  initial,
  authenticated,
  passwordChangeRequired,
  unauthenticated,
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authStateProvider = StateProvider<AuthStatus>((ref) {
  return AuthStatus.initial;
});

final authInitProvider = FutureProvider<AuthStatus>((ref) async {
  final repo = ref.read(authRepositoryProvider);
  try {
    final isLoggedIn = await repo.isLoggedIn().timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        return false;
      },
    );
    var status = AuthStatus.unauthenticated;
    if (isLoggedIn) {
      final storedMustChangePassword = await repo.getMustChangePassword();
      if (storedMustChangePassword) {
        status = AuthStatus.passwordChangeRequired;
      } else {
        try {
          final user = await repo.getCurrentUser();
          status = user.mustChangePassword
              ? AuthStatus.passwordChangeRequired
              : AuthStatus.authenticated;
        } catch (_) {
          status = await repo.isLoggedIn()
              ? AuthStatus.authenticated
              : AuthStatus.unauthenticated;
        }
      }
    }
    ref.read(authStateProvider.notifier).state = status;
    return status;
  } catch (e) {
    ref.read(authStateProvider.notifier).state = AuthStatus.unauthenticated;
    return AuthStatus.unauthenticated;
  }
});

final currentUserProvider = FutureProvider<UserProfile?>((ref) async {
  final authState = ref.watch(authStateProvider);
  if (authState != AuthStatus.authenticated &&
      authState != AuthStatus.passwordChangeRequired) {
    return null;
  }

  final repo = ref.read(authRepositoryProvider);
  try {
    return await repo.getCurrentUser();
  } catch (e) {
    return null;
  }
});

final kangiderIdProvider = FutureProvider<String?>((ref) async {
  // Wait for current user to be loaded so kangider_id is saved to storage first.
  await ref.watch(currentUserProvider.future);
  final repo = ref.read(authRepositoryProvider);
  return await repo.getKangiderId();
});

final userRoleProvider = FutureProvider<String?>((ref) async {
  final repo = ref.read(authRepositoryProvider);
  return await repo.getUserRole();
});

final isAdminProvider = FutureProvider<bool>((ref) async {
  final role = await ref.watch(userRoleProvider.future);
  return const {
    'super_admin',
    'hr_admin',
    'manager',
    'admin_kpi_kang_ider',
  }.contains(role?.toLowerCase());
});
