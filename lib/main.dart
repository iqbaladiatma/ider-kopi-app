import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/background/sync_worker.dart';
import 'core/notifications/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init background sync worker (v1.2 — Offline Mode)
  // Dibungkus try/catch karena workmanager bisa gagal di desktop/web test.
  try {
    await SyncWorker.init();
  } catch (_) {
    // Non-fatal: app tetap jalan, sync manual via badge tetap可用
  }

  // Init local notifications (v1.3 — Notifications & Reminders)
  try {
    await NotificationService().init();
  } catch (_) {
    // Non-fatal: app tetap jalan tanpa notifikasi
  }

  runApp(
    const ProviderScope(
      child: IderKopiApp(),
    ),
  );
}
