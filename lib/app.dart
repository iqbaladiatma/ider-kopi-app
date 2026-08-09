import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/sync/providers/sync_providers.dart';

class IderKopiApp extends ConsumerStatefulWidget {
  const IderKopiApp({super.key});

  @override
  ConsumerState<IderKopiApp> createState() => _IderKopiAppState();
}

class _IderKopiAppState extends ConsumerState<IderKopiApp> {
  StreamSubscription<ConnectivityResult>? _connectivitySub;
  bool _wasOffline = false;

  @override
  void initState() {
    super.initState();
    _initConnectivityListener();
  }

  void _initConnectivityListener() {
    if (kIsWeb) return;
    try {
      final connectivity = Connectivity();
      _connectivitySub = connectivity.onConnectivityChanged.listen((
        ConnectivityResult result,
      ) {
        final online = result != ConnectivityResult.none;

        if (_wasOffline && online) {
          // Reconnected → trigger sync langsung
          ref.invalidate(manualSyncProvider);
        }
        _wasOffline = !online;
      });
    } catch (_) {
      // connectivity_plus tidak support di semua platform (desktop test) — skip
    }
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'IderKopi Absensi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
