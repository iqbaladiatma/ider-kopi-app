import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iderkopi_absensi/core/router/app_router.dart';
import 'package:iderkopi_absensi/features/auth/presentation/change_password_page.dart';
import 'package:iderkopi_absensi/features/auth/providers/auth_providers.dart';

ProviderContainer _forcedPasswordContainer() {
  return ProviderContainer(
    overrides: [
      authStateProvider.overrideWith(
        (ref) => AuthStatus.passwordChangeRequired,
      ),
      authInitProvider.overrideWith(
        (ref) async => AuthStatus.passwordChangeRequired,
      ),
    ],
  );
}

void main() {
  testWidgets('restart restores forced password screen', (tester) async {
    final container = _forcedPasswordContainer();
    addTearDown(container.dispose);
    final router = container.read(appRouterProvider);
    addTearDown(router.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ChangePasswordPage), findsOneWidget);
    expect(router.routeInformationProvider.value.uri.path, '/change-password');
  });

  testWidgets('deep link cannot bypass forced password screen', (tester) async {
    final container = _forcedPasswordContainer();
    addTearDown(container.dispose);
    final router = container.read(appRouterProvider);
    addTearDown(router.dispose);

    router.go('/profile');
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ChangePasswordPage), findsOneWidget);
    expect(router.routeInformationProvider.value.uri.path, '/change-password');
  });
}
