import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/image_utils.dart';
import '../../../core/utils/location_utils.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../auth/providers/auth_providers.dart';
import '../data/attendance_model.dart';
import '../providers/attendance_providers.dart';
import 'widgets/camera_section.dart';
import 'widgets/location_card.dart';

class CheckInPage extends ConsumerStatefulWidget {
  const CheckInPage({super.key});

  @override
  ConsumerState<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends ConsumerState<CheckInPage> {
  double? _latitude;
  double? _longitude;
  bool? _isWithinRadius;
  bool _isLocationLoading = true;
  String? _locationError;
  File? _selfieFile;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLocationLoading = true;
      _locationError = null;
    });

    try {
      final position = await LocationUtils.getCurrentLocation();
      final withinRadius = LocationUtils.isWithinOfficeRadius(
        position.latitude,
        position.longitude,
      );
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _isWithinRadius = withinRadius;
        _isLocationLoading = false;
      });
    } catch (e) {
      setState(() {
        _locationError = e.toString();
        _isLocationLoading = false;
      });
    }
  }

  bool get _canSubmit =>
      !_isSubmitting &&
      _selfieFile != null &&
      _latitude != null &&
      _longitude != null;

  Future<void> _handleSubmit() async {
    if (!_canSubmit) return;

    setState(() => _isSubmitting = true);

    try {
      final kangiderId = await ref.read(kangiderIdProvider.future);
      if (kangiderId == null) {
        _showError('User tidak teridentifikasi');
        return;
      }

      final repo = ref.read(attendanceRepositoryProvider);

      final compressedFile = await ImageUtils.compressImage(_selfieFile!);
      final fileId = await repo.uploadSelfie(compressedFile);

      final now = DateTime.now();
      final request = CheckInRequest(
        tanggalAbsensi: AppDateUtils.todayDateString(),
        masuk: AppDateUtils.formatTime(now),
        kangider: kangiderId,
        latitude: _latitude!,
        longitude: _longitude!,
        selfieFileId: fileId,
      );

      await repo.checkIn(request);

      ref.invalidate(todayAttendanceProvider);
      ref.invalidate(historyProvider);

      if (mounted) {
        _showSuccess();
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) context.go('/home');
      }
    } catch (e) {
      _showError('Gagal mengirim absensi: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _showSuccess() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _SuccessDialog(
        title: 'Absensi Terkirim',
        message: 'Check-in berhasil pada ${AppDateUtils.formatTime(DateTime.now())} WIB',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Absensi Masuk'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LocationCard(
              latitude: _latitude,
              longitude: _longitude,
              isWithinRadius: _isWithinRadius,
              isLoading: _isLocationLoading,
              error: _locationError,
              onRetry: _getCurrentLocation,
            ),
            if (_locationError != null) ...[
              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  onPressed: _getCurrentLocation,
                  icon: const Icon(Icons.refresh, color: AppColors.primary),
                  label: const Text(
                    'Coba Lagi',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            CameraSection(
              onPhotoCaptured: (file) {
                setState(() => _selfieFile = file);
              },
            ),
            const SizedBox(height: 16),
            _buildTimeCard(),
            const SizedBox(height: 24),
            CustomButton(
              label: 'KIRIM ABSENSI',
              onPressed: _canSubmit ? _handleSubmit : null,
              isLoading: _isSubmitting,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeCard() {
    final now = DateTime.now();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Jam',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
                Text(
                  AppDateUtils.formatTime(now),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tanggal',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
                Text(
                  AppDateUtils.formatDateShort(now),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessDialog extends StatelessWidget {
  const _SuccessDialog({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.successLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: AppColors.success, size: 36),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
