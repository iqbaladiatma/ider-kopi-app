import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Ambil local timezone IANA identifier (e.g. "Asia/Jakarta").
/// Fallback ke "Asia/Jakarta" jika platform tidak support.
Future<String> _getLocalTimezone() async {
  try {
    final info = await FlutterTimezone.getLocalTimezone();
    return info.identifier;
  } catch (_) {
    return 'Asia/Jakarta';
  }
}

/// Service untuk local notifications — reminder check-in & check-out.
///
/// Schedule daily recurring notification at specific time (WIB).
/// Tap notification → buka app (handle di top-level handler).
class NotificationService {
  NotificationService._();
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;

  static const String _channelId = 'attendance_reminders';
  static const String _channelName = 'Reminder Absensi';
  static const String _channelDesc =
      'Pengingat untuk check-in dan check-out harian';

  static const int _checkInReminderId = 1001;
  static const int _checkOutReminderId = 1002;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _isTestMode = false;

  /// Set test mode — skip platform channel calls (untuk unit test).
  void enableTestMode() {
    _isTestMode = true;
    _initialized = true;
  }

  /// Init plugin + timezone. Wajib dipanggil di main.dart sebelum schedule.
  Future<void> init() async {
    if (_initialized || _isTestMode) return;

    try {
      // 1. Init timezone
      tz.initializeTimeZones();
      final timezoneName = await _getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneName));

      // 2. Init local notifications
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _plugin.initialize(
        settings: settings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      // 3. Create Android channel (API 26+)
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDesc,
        importance: Importance.high,
      ));

      _initialized = true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('NotificationService.init error: $e');
      }
      // Non-fatal: app tetap jalan tanpa notifikasi
      _initialized = true;
    }
  }

  /// Callback saat user tap notifikasi.
  void Function(NotificationResponse)? onTapCallback;

  void _onNotificationTap(NotificationResponse response) {
    if (kDebugMode) {
      debugPrint('Notification tapped: id=${response.id}, payload=${response.payload}');
    }
    onTapCallback?.call(response);
  }

  /// Schedule reminder check-in harian.
  ///
  /// [hour] = jam dalam WIB (default 8), [minute] = menit (default 0).
  /// Akan repeat setiap hari di jam tersebut.
  Future<void> scheduleCheckInReminder({
    int hour = 8,
    int minute = 0,
  }) async {
    if (!_initialized) return;
    if (_isTestMode) return;

    try {
      await _plugin.zonedSchedule(
        id: _checkInReminderId,
        title: 'Sudah check-in belum? ☕',
        body: 'Jangan lupa absen masuk! Tap untuk buka app.',
        scheduledDate: _nextInstanceOf(hour, minute),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDesc,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'check_in',
      );
    } catch (e) {
      if (kDebugMode) debugPrint('scheduleCheckInReminder error: $e');
    }
  }

  /// Schedule reminder check-out harian.
  Future<void> scheduleCheckOutReminder({
    int hour = 17,
    int minute = 0,
  }) async {
    if (!_initialized) return;
    if (_isTestMode) return;

    try {
      await _plugin.zonedSchedule(
        id: _checkOutReminderId,
        title: 'Sudah check-out? 🏠',
        body: 'Absen pulang dulu sebelum pulang! Tap untuk buka app.',
        scheduledDate: _nextInstanceOf(hour, minute),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDesc,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'check_out',
      );
    } catch (e) {
      if (kDebugMode) debugPrint('scheduleCheckOutReminder error: $e');
    }
  }

  /// Cancel reminder check-in.
  Future<void> cancelCheckInReminder() async {
    if (_isTestMode) return;
    try {
      await _plugin.cancel(id: _checkInReminderId);
    } catch (_) {}
  }

  /// Cancel reminder check-out.
  Future<void> cancelCheckOutReminder() async {
    if (_isTestMode) return;
    try {
      await _plugin.cancel(id: _checkOutReminderId);
    } catch (_) {}
  }

  /// Cancel semua notifikasi.
  Future<void> cancelAll() async {
    if (_isTestMode) return;
    try {
      await _plugin.cancelAll();
    } catch (_) {}
  }

  /// Tampilkan notifikasi langsung (untuk testing atau alert sync selesai).
  Future<void> showInstant({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized || _isTestMode) return;
    try {
      await _plugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDesc,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: payload,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('showInstant error: $e');
    }
  }

  /// Request permission (iOS). Di Android permission lewat manifest.
  Future<bool> requestPermissions() async {
    if (_isTestMode) return true;
    try {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final granted = await ios?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? true;
    } catch (_) {
      return false;
    }
  }

  /// Hitung instance berikutnya dari jam tertentu (hari ini atau besok).
  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    // Jika waktu sudah lewat hari ini, schedule untuk besok
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  // Getters untuk testing
  int get checkInReminderId => _checkInReminderId;
  int get checkOutReminderId => _checkOutReminderId;
  String get channelId => _channelId;
  bool get isInitialized => _initialized;
}
