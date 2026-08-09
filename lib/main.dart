import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/background/sync_worker.dart';
import 'core/notifications/notification_service.dart';

void main() async {
  debugPrint('DEBUG: main() start');
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('DEBUG: binding initialized');

  // Init background sync worker (v1.2 — Offline Mode)
  // Dibungkus try/catch karena workmanager bisa gagal di desktop/web test.
  // Skip di web karena workmanager tidak support platform web.
  if (!kIsWeb) {
    try {
      await SyncWorker.init();
    } catch (_) {
      // Non-fatal: app tetap jalan, sync manual via badge tetap可用
    }
  }

  // Init local notifications (v1.3 — Notifications & Reminders)
  // Skip di web karena flutter_local_notifications & flutter_timezone
  // tidak support platform web dan dapat menyebabkan hang.
  if (!kIsWeb) {
    try {
      await NotificationService().init();
    } catch (_) {
      // Non-fatal: app tetap jalan tanpa notifikasi
    }
  }

  debugPrint('DEBUG: calling runApp()');
  runApp(
    const ProviderScope(
      child: IderKopiApp(),
    ),
  );
}
