import 'package:flutter_test/flutter_test.dart';
import 'package:iderkopi_absensi/features/settings/providers/settings_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('NotificationSettings', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('default values are correct', () {
      const s = NotificationSettings();
      expect(s.checkInReminderEnabled, isTrue);
      expect(s.checkInReminderHour, 8);
      expect(s.checkInReminderMinute, 0);
      expect(s.checkOutReminderEnabled, isTrue);
      expect(s.checkOutReminderHour, 17);
      expect(s.checkOutReminderMinute, 0);
    });

    test('copyWith updates only specified fields', () {
      const s = NotificationSettings();
      final updated = s.copyWith(
        checkInReminderEnabled: false,
        checkInReminderHour: 9,
      );
      expect(updated.checkInReminderEnabled, isFalse);
      expect(updated.checkInReminderHour, 9);
      // Other fields unchanged
      expect(updated.checkInReminderMinute, 0);
      expect(updated.checkOutReminderEnabled, isTrue);
    });

    test('save & load round-trips correctly', () async {
      final prefs = await SharedPreferences.getInstance();
      const original = NotificationSettings(
        checkInReminderEnabled: false,
        checkInReminderHour: 9,
        checkInReminderMinute: 30,
        checkOutReminderEnabled: true,
        checkOutReminderHour: 18,
        checkOutReminderMinute: 15,
      );

      await original.save(prefs);
      final loaded = await NotificationSettings.load(prefs);

      expect(loaded.checkInReminderEnabled, isFalse);
      expect(loaded.checkInReminderHour, 9);
      expect(loaded.checkInReminderMinute, 30);
      expect(loaded.checkOutReminderEnabled, isTrue);
      expect(loaded.checkOutReminderHour, 18);
      expect(loaded.checkOutReminderMinute, 15);
    });

    test('load returns defaults when no saved values', () async {
      final prefs = await SharedPreferences.getInstance();
      final loaded = await NotificationSettings.load(prefs);

      expect(loaded.checkInReminderEnabled, isTrue);
      expect(loaded.checkInReminderHour, 8);
      expect(loaded.checkOutReminderEnabled, isTrue);
      expect(loaded.checkOutReminderHour, 17);
    });

    test('save persists all fields to SharedPreferences', () async {
      final prefs = await SharedPreferences.getInstance();
      const s = NotificationSettings(
        checkInReminderEnabled: false,
        checkInReminderHour: 10,
        checkInReminderMinute: 15,
        checkOutReminderEnabled: false,
        checkOutReminderHour: 16,
        checkOutReminderMinute: 45,
      );

      await s.save(prefs);

      expect(prefs.getBool('notif_check_in_enabled'), isFalse);
      expect(prefs.getInt('notif_check_in_hour'), 10);
      expect(prefs.getInt('notif_check_in_minute'), 15);
      expect(prefs.getBool('notif_check_out_enabled'), isFalse);
      expect(prefs.getInt('notif_check_out_hour'), 16);
      expect(prefs.getInt('notif_check_out_minute'), 45);
    });
  });
}
