import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/notifications/notification_providers.dart';
import '../../../core/notifications/notification_service.dart';
import '../../holiday/data/holiday_repository.dart';

/// State preferensi notifikasi user.
class NotificationSettings {
  final bool checkInReminderEnabled;
  final int checkInReminderHour;
  final int checkInReminderMinute;
  final bool checkOutReminderEnabled;
  final int checkOutReminderHour;
  final int checkOutReminderMinute;

  const NotificationSettings({
    this.checkInReminderEnabled = true,
    this.checkInReminderHour = 8,
    this.checkInReminderMinute = 0,
    this.checkOutReminderEnabled = true,
    this.checkOutReminderHour = 17,
    this.checkOutReminderMinute = 0,
  });

  NotificationSettings copyWith({
    bool? checkInReminderEnabled,
    int? checkInReminderHour,
    int? checkInReminderMinute,
    bool? checkOutReminderEnabled,
    int? checkOutReminderHour,
    int? checkOutReminderMinute,
  }) {
    return NotificationSettings(
      checkInReminderEnabled:
          checkInReminderEnabled ?? this.checkInReminderEnabled,
      checkInReminderHour: checkInReminderHour ?? this.checkInReminderHour,
      checkInReminderMinute:
          checkInReminderMinute ?? this.checkInReminderMinute,
      checkOutReminderEnabled:
          checkOutReminderEnabled ?? this.checkOutReminderEnabled,
      checkOutReminderHour: checkOutReminderHour ?? this.checkOutReminderHour,
      checkOutReminderMinute:
          checkOutReminderMinute ?? this.checkOutReminderMinute,
    );
  }

  static const String _keyCheckInEnabled = 'notif_check_in_enabled';
  static const String _keyCheckInHour = 'notif_check_in_hour';
  static const String _keyCheckInMinute = 'notif_check_in_minute';
  static const String _keyCheckOutEnabled = 'notif_check_out_enabled';
  static const String _keyCheckOutHour = 'notif_check_out_hour';
  static const String _keyCheckOutMinute = 'notif_check_out_minute';

  Future<void> save(SharedPreferences prefs) async {
    await prefs.setBool(_keyCheckInEnabled, checkInReminderEnabled);
    await prefs.setInt(_keyCheckInHour, checkInReminderHour);
    await prefs.setInt(_keyCheckInMinute, checkInReminderMinute);
    await prefs.setBool(_keyCheckOutEnabled, checkOutReminderEnabled);
    await prefs.setInt(_keyCheckOutHour, checkOutReminderHour);
    await prefs.setInt(_keyCheckOutMinute, checkOutReminderMinute);
  }

  static Future<NotificationSettings> load(SharedPreferences prefs) async {
    return NotificationSettings(
      checkInReminderEnabled: prefs.getBool(_keyCheckInEnabled) ?? true,
      checkInReminderHour: prefs.getInt(_keyCheckInHour) ?? 8,
      checkInReminderMinute: prefs.getInt(_keyCheckInMinute) ?? 0,
      checkOutReminderEnabled: prefs.getBool(_keyCheckOutEnabled) ?? true,
      checkOutReminderHour: prefs.getInt(_keyCheckOutHour) ?? 17,
      checkOutReminderMinute: prefs.getInt(_keyCheckOutMinute) ?? 0,
    );
  }
}

/// Provider SharedPreferences (lazy singleton).
final sharedPreferencesProvider =
    FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

/// State notifier untuk notification settings.
class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  final SharedPreferences _prefs;
  final NotificationService _notificationService;

  NotificationSettingsNotifier(this._prefs, this._notificationService)
      : super(const NotificationSettings()) {
    _load();
  }

  Future<void> _load() async {
    final loaded = await NotificationSettings.load(_prefs);
    if (!mounted) return;
    state = loaded;
    await _applySchedule();
  }

  Future<void> _applySchedule() async {
    final s = state;

    // Cek apakah besok hari libur — jika ya, skip reminder
    final holidayRepo = HolidayRepository();
    final tomorrowHoliday = await holidayRepo.getTomorrowHoliday();
    final skipDueToHoliday = tomorrowHoliday != null;

    if (s.checkInReminderEnabled && !skipDueToHoliday) {
      await _notificationService.scheduleCheckInReminder(
        hour: s.checkInReminderHour,
        minute: s.checkInReminderMinute,
      );
    } else {
      await _notificationService.cancelCheckInReminder();
    }

    if (s.checkOutReminderEnabled && !skipDueToHoliday) {
      await _notificationService.scheduleCheckOutReminder(
        hour: s.checkOutReminderHour,
        minute: s.checkOutReminderMinute,
      );
    } else {
      await _notificationService.cancelCheckOutReminder();
    }
  }

  Future<void> toggleCheckInReminder(bool enabled) async {
    if (!mounted) return;
    state = state.copyWith(checkInReminderEnabled: enabled);
    await state.save(_prefs);
    await _applySchedule();
  }

  Future<void> setCheckInReminderTime(int hour, int minute) async {
    if (!mounted) return;
    state = state.copyWith(
      checkInReminderHour: hour,
      checkInReminderMinute: minute,
      checkInReminderEnabled: true,
    );
    await state.save(_prefs);
    await _applySchedule();
  }

  Future<void> toggleCheckOutReminder(bool enabled) async {
    if (!mounted) return;
    state = state.copyWith(checkOutReminderEnabled: enabled);
    await state.save(_prefs);
    await _applySchedule();
  }

  Future<void> setCheckOutReminderTime(int hour, int minute) async {
    if (!mounted) return;
    state = state.copyWith(
      checkOutReminderHour: hour,
      checkOutReminderMinute: minute,
      checkOutReminderEnabled: true,
    );
    await state.save(_prefs);
    await _applySchedule();
  }
}

final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
        (ref) {
  final prefsAsync = ref.watch(sharedPreferencesProvider);
  final notificationService = ref.watch(notificationServiceProvider);

  // Default state sampai prefs loaded
  return prefsAsync.maybeWhen(
    data: (prefs) => NotificationSettingsNotifier(prefs, notificationService),
    orElse: () => NotificationSettingsNotifier(
      _NullPrefs(),
      notificationService,
    ),
  );
});

/// Stub SharedPreferences untuk kasus async belum selesai.
class _NullPrefs implements SharedPreferences {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
