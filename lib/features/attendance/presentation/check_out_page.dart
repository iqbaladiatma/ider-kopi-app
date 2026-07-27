import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/image_utils.dart';
import '../../../core/utils/location_utils.dart';
import '../../../shared/widgets/custom_button.dart';
import '../data/attendance_model.dart';
import '../providers/attendance_providers.dart';
import 'widgets/camera_section.dart';
import 'widgets/location_card.dart';

class CheckOutPage extends ConsumerStatefulWidget {
  const CheckOutPage({super.key});

  @override
  ConsumerState<CheckOutPage> createState() => _CheckOutPageState();
}

class _CheckOutPageState extends ConsumerState<CheckOutPage> {
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

  bool get _canSubmit => !_isSubmitting && _latitude != null && _longitude != null;

  Future<void> _handleSubmit() async {
    if (!_canSubmit) return;

    setState(() => _isSubmitting = true);

    try {
      final todayRecord = await ref.read(todayAttendanceProvider.future);
      if (todayRecord == null || todayRecord.id == null) {
        _showError('Belum ada record check-in hari ini');
        return;
      }

      final repo = ref.read(attendanceRepositoryProvider);
      String? selfieFileId;

      if (_selfieFile != null) {
        final compressedFile = await ImageUtils.compressImage(_selfieFile!);
        selfieFileId = await repo.uploadSelfie(compressedFile);
      }

      final now = DateTime.now();
      final request = CheckOutRequest(
        pulang: AppDateUtils.formatTime(now),
        latitudePulang: _latitude,
        longitudePulang: _longitude,
        selfiePulangFileId: selfieFileId,
      );

      await repo.checkOut(todayRecord.id!, request);

      ref.invalidate(todayAttendanceProvider);
      ref.invalidate(historyProvider);

      if (mounted) {
        _showSuccess();
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) context.go('/home');
      }
    } catch (e) {
      _showError('Gagal check-out: $e');
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
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.successLight,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.2),
                ),
              ),
              child: const Icon(Icons.check_rounded, color: AppColors.success, size: 40),
            ),
            const SizedBox(height: 18),
            const Text(
              'Check Out Berhasil',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Pulang pada ${AppDateUtils.formatTime(DateTime.now())} WIB',
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

  @override
  Widget build(BuildContext context) {
    final todayAsync = ref.watch(todayAttendanceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Absensi Pulang'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCheckInSummary(todayAsync),
            const SizedBox(height: 16),
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
                  icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
                  label: const Text(
                    'Coba Lagi',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            CameraSection(
              label: 'Foto Selfie Pulang (Opsional)',
              onPhotoCaptured: (file) {
                setState(() => _selfieFile = file);
              },
            ),
            const SizedBox(height: 16),
            _buildTimeDisplay(),
            const SizedBox(height: 24),
            CustomButton(
              label: 'CHECK OUT',
              icon: Icons.logout_rounded,
              onPressed: _canSubmit ? _handleSubmit : null,
              isLoading: _isSubmitting,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckInSummary(AsyncValue<AttendanceRecord?> todayAsync) {
    return todayAsync.when(
      loading: () => const Card(
        child: SizedBox(
          height: 100,
          child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
        ),
      ),
      error: (e, _) => Card(
        child: SizedBox(
          height: 100,
          child: Center(child: Text('Gagal memuat: $e')),
        ),
      ),
      data: (record) {
        if (record == null || !record.hasCheckedIn) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.warning_rounded, color: AppColors.warning),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Anda belum check-in hari ini',
                      style: TextStyle(color: AppColors.warning),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Card(
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(
                  width: 4,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.horizontal(left: Radius.circular(16)),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Check In Hari Ini',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              AppDateUtils.formatTimeWIB(record.masuk),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (record.latitude != null && record.longitude != null)
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded, size: 16, color: AppColors.textMuted),
                              const SizedBox(width: 4),
                              Text(
                                '${record.latitude!.toStringAsFixed(2)}, ${record.longitude!.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.camera_alt_rounded, size: 16, color: AppColors.textMuted),
                            const SizedBox(width: 4),
                            Text(
                              record.selfieFileId != null ? 'Selfie tersimpan' : 'Tanpa selfie',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeDisplay() {
    final now = DateTime.now();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.access_time_rounded, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'Jam: ${AppDateUtils.formatTime(now)} WIB',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
