import 'package:camera/camera.dart';
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
  const CheckOutPage({super.key, this.reason});

  final String? reason;

  @override
  ConsumerState<CheckOutPage> createState() => _CheckOutPageState();
}

class _CheckOutPageState extends ConsumerState<CheckOutPage> {
  double? _latitude;
  double? _longitude;
  bool? _isWithinRadius;
  bool _isLocationLoading = true;
  String? _locationError;
  XFile? _selfieFile;
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
      if (!mounted) return;
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _isWithinRadius = withinRadius;
        _isLocationLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
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

      String? keterangan = widget.reason;
      if (widget.reason == 'Izin') {
        if (!mounted) return;
        final izinReason = await _showReasonDialog(
          context,
          title: 'Alasan Izin',
          hint: 'Tulis alasan izin...',
        );
        if (!mounted) return;
        if (izinReason == null || izinReason.trim().isEmpty) {
          _showError('Alasan izin wajib diisi');
          return;
        }
        keterangan = 'Izin: ${izinReason.trim()}';
      } else if (widget.reason == 'Lembur') {
        if (!mounted) return;
        final lemburReason = await _showReasonDialog(
          context,
          title: 'Keterangan Lembur',
          hint: 'Tulis kegiatan / pekerjaan lembur...',
        );
        if (!mounted) return;
        if (lemburReason != null && lemburReason.trim().isNotEmpty) {
          keterangan = 'Lembur: ${lemburReason.trim()}';
        } else {
          keterangan = 'Lembur';
        }
      } else {
        keterangan = 'Check Out';
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
        keterangan: keterangan,
      );

      await repo.checkOut(todayRecord.id!, request);

      ref.invalidate(todayAttendanceProvider);
      ref.invalidate(historyProvider);

      if (mounted) {
        _showSuccess(keterangan);
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) {
          final navigator = Navigator.of(context, rootNavigator: true);
          if (navigator.canPop()) navigator.pop();
          context.go('/home');
        }
      }
    } catch (e) {
      _showError('Gagal memproses absensi: $e');
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

  void _showSuccess(String? keterangan) {
    if (!mounted) return;
    final isLembur = widget.reason == 'Lembur';
    final isIzin = widget.reason == 'Izin';
    final title = isLembur ? 'Absensi Lembur Terkirim!' : (isIzin ? 'Izin Terkirim!' : 'Check Out Berhasil!');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.25),
                    width: 2,
                  ),
                ),
                child: const Icon(Icons.check_rounded, color: AppColors.success, size: 44),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tercatat pada ${AppDateUtils.formatTime(DateTime.now())} WIB',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              if (keterangan != null && keterangan.isNotEmpty) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    keterangan,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                  ),
                ),
              ],
              const SizedBox(height: 4),
              const Text(
                'Terima kasih & selamat beristirahat!',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todayAsync = ref.watch(todayAttendanceProvider);
    final isLembur = widget.reason == 'Lembur';
    final isIzin = widget.reason == 'Izin';
    final pageTitle = isLembur ? 'Absensi Lembur' : (isIzin ? 'Absensi Izin' : 'Absensi Pulang');
    final buttonLabel = isLembur ? 'KIRIM ABSENSI LEMBUR' : (isIzin ? 'KIRIM PERMOHONAN IZIN' : 'CHECK OUT');
    final buttonIcon = isLembur ? Icons.work_history_rounded : (isIzin ? Icons.sick_rounded : Icons.logout_rounded);
    final cameraLabel = isLembur ? 'Foto Selfie Lembur (Opsional)' : (isIzin ? 'Foto Selfie Izin (Opsional)' : 'Foto Selfie Pulang (Opsional)');

    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle),
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
              label: cameraLabel,
              onPhotoCaptured: (file) {
                setState(() => _selfieFile = file);
              },
            ),
            const SizedBox(height: 16),
            _buildTimeDisplay(),
            const SizedBox(height: 24),
            CustomButton(
              label: buttonLabel,
              icon: buttonIcon,
              onPressed: _canSubmit ? _handleSubmit : null,
              isLoading: _isSubmitting,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<String?> _showReasonDialog(BuildContext context, {required String title, required String hint}) {
    String? reason;
    return showDialog<String?>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: TextField(
          autofocus: true,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
          ),
          onChanged: (value) => reason = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(reason?.trim()),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckInSummary(AsyncValue<AttendanceRecord?> todayAsync) {
    return todayAsync.when(
      loading: () => Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: const Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5)),
      ),
      error: (e, _) => Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: const Center(child: Text('Gagal memuat', style: TextStyle(color: AppColors.textMuted))),
      ),
      data: (record) {
        if (record == null || !record.hasCheckedIn) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warningLight,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.warning_rounded, color: AppColors.warningDark, size: 18),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Anda belum check-in hari ini',
                  style: TextStyle(
                    color: AppColors.warningDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.login_rounded, color: AppColors.success, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Check In Hari Ini',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppDateUtils.formatTimeWIB(record.masuk),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.success,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
              if (record.latitude != null && record.longitude != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on_rounded, size: 13, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        '${record.latitude!.toStringAsFixed(2)}, ${record.longitude!.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeDisplay() {
    final now = DateTime.now();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.access_time_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Waktu Check Out',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 3),
              Text(
                '${AppDateUtils.formatTime(now)} WIB',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
