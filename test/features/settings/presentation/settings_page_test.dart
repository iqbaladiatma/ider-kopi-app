import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iderkopi_absensi/core/notifications/notification_providers.dart';
import 'package:iderkopi_absensi/core/notifications/notification_service.dart';
import 'package:iderkopi_absensi/features/settings/presentation/settings_page.dart';
import 'package:iderkopi_absensi/features/settings/providers/settings_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;
  late NotificationService notificationService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    notificationService = NotificationService();
    notificationService.enableTestMode();
  });

  testWidgets('SettingsPage renders section header & reminder cards',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) async => prefs),
          notificationServiceProvider.overrideWithValue(notificationService),
        ],
        child: const MaterialApp(
          home: SettingsPage(),
        ),
      ),
    );
    // Pump a few frames without settling (avoid Dio pending timers)
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Section header
    expect(find.text('Reminder Absensi'), findsOneWidget);
    expect(find.text('Atur pengingat check-in & check-out harian'),
        findsOneWidget);

    // Reminder cards
    expect(find.text('Reminder Check-In'), findsOneWidget);
    expect(find.text('Reminder Check-Out'), findsOneWidget);
  });

  testWidgets('info card about holiday skip is visible',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) async => prefs),
          notificationServiceProvider.overrideWithValue(notificationService),
        ],
        child: const MaterialApp(
          home: SettingsPage(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.textContaining('hari libur nasional'), findsOneWidget);
  });
}
