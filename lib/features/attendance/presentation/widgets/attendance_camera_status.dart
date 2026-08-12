import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

String attendanceCameraErrorMessage(Object error) {
  if (error is CameraException) {
    switch (error.code) {
      case 'CameraAccessDenied':
        return 'Izin kamera ditolak. Izinkan kamera pada browser, lalu coba lagi.';
      case 'CameraAccessDeniedWithoutPrompt':
        return 'Izin kamera diblokir. Buka pengaturan situs browser dan izinkan kamera.';
      case 'CameraAccessRestricted':
        return 'Akses kamera dibatasi oleh pengaturan perangkat.';
      case 'CameraUnavailable':
        return 'Kamera depan tidak ditemukan pada perangkat ini.';
    }
  }
  return 'Kamera gagal dibuka. Periksa izin kamera, lalu coba lagi.';
}

class AttendanceCameraStatus extends StatelessWidget {
  const AttendanceCameraStatus({
    super.key,
    required this.isInitializing,
    required this.errorMessage,
    required this.onRetry,
  });

  final bool isInitializing;
  final String? errorMessage;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (isInitializing) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white70, strokeWidth: 2.5),
            SizedBox(height: 14),
            Text(
              'Menyiapkan kamera...',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.no_photography_outlined,
                size: 36,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage ?? 'Kamera belum siap.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                height: 1.4,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 17),
              label: const Text('Coba Lagi / Izinkan Kamera'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
