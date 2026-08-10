import 'dart:io';
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/image_utils.dart';
import '../../../core/utils/location_utils.dart';
import '../../auth/providers/auth_providers.dart';
import '../../outlet/data/outlet_model.dart';
import '../../outlet/presentation/outlet_map_widget.dart';
import '../../outlet/presentation/outlet_picker_sheet.dart';
import '../../outlet/providers/outlet_providers.dart';
import '../../sync/providers/sync_providers.dart';
import '../data/attendance_model.dart';
import '../providers/attendance_providers.dart';

class CheckOutPage extends ConsumerStatefulWidget {
  final String? reason;
  const CheckOutPage({super.key, this.reason});

  @override
  ConsumerState<CheckOutPage> createState() => _CheckOutPageState();
}

class _CheckOutPageState extends ConsumerState<CheckOutPage> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;

  double? _latitude;
  double? _longitude;
  bool? _isWithinRadius;
  bool _isLocationLoading = true;
  String? _locationError;
  double? _distanceToOutlet;
  XFile? _capturedSelfie;
  bool _isSubmitting = false;

  Outlet? _selectedOutlet;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _getCurrentLocation();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) return;

      final frontCamera = _cameras!.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (mounted) setState(() => _isCameraInitialized = true);
    } catch (_) {
      if (mounted) setState(() => _isCameraInitialized = false);
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLocationLoading = true;
      _locationError = null;
    });

    try {
      final position = await LocationUtils.getCurrentLocation();
      if (!mounted) return;

      final distances = await ref.read(outletDistancesProvider(
        (lat: position.latitude, lng: position.longitude),
      ).future);

      final nearest = distances.isEmpty ? null : distances.first;
      final withinAny = distances.any((d) => d.isWithinRadius);

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _isWithinRadius = withinAny;
        _distanceToOutlet = nearest?.distanceMeters;
        if (_selectedOutlet == null &&
            nearest != null &&
            nearest.isWithinRadius) {
          _selectedOutlet = nearest.outlet;
        }
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

  Future<void> _openOutletPicker() async {
    if (_latitude == null || _longitude == null) {
      _showError('GPS belum siap, tunggu sebentar...');
      return;
    }
    final picked = await showOutletPickerSheet(
      context,
      userLatitude: _latitude!,
      userLongitude: _longitude!,
      selectedOutletId: _selectedOutlet?.id,
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedOutlet = picked;
        if (_latitude != null && _longitude != null) {
          final d = LocationUtils.distanceTo(
            _latitude!,
            _longitude!,
            picked.latitude,
            picked.longitude,
          );
          _distanceToOutlet = d;
          _isWithinRadius = d <= picked.radiusMeters;
        }
      });
    }
  }

  String _distanceLabel(double meters) {
    if (meters < 1000) return '${meters.round()}m';
    return '${(meters / 1000).toStringAsFixed(1)}km';
  }

  Future<void> _takePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      _showError('Kamera depan belum siap');
      return;
    }
    try {
      final file = await _cameraController!.takePicture();
      if (mounted) setState(() => _capturedSelfie = file);
    } catch (e) {
      _showError('Gagal mengambil selfie: $e');
    }
  }

  void _retakePhoto() {
    setState(() => _capturedSelfie = null);
  }

  Future<void> _handleSubmit() async {
    if (_capturedSelfie == null || _latitude == null || _longitude == null) {
      _showError('Silakan ambil foto selfie dan pastikan GPS aktif');
      return;
    }
    if (_selectedOutlet == null || _isWithinRadius != true) {
      _showError(
        'Check-out hanya dapat dilakukan di dalam radius outlet yang aktif.',
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final kangiderId = await ref.read(kangiderIdProvider.future);
      if (kangiderId == null) {
        _showError('User tidak teridentifikasi');
        return;
      }

      final repo = ref.read(attendanceRepositoryProvider);
      final compressedFile = await ImageUtils.compressImage(_capturedSelfie!);

      final todayRecord = await ref.read(todayAttendanceProvider.future);
      if (todayRecord == null) {
        _showError('Data absensi masuk hari ini tidak ditemukan');
        return;
      }

      final now = DateTime.now();
      final request = CheckOutRequest(
        pulang: AppDateUtils.formatTime(now),
        latitudePulang: _latitude,
        longitudePulang: _longitude,
        selfiePulangFileId: 'pending',
        outletId: _selectedOutlet!.id,
        keterangan: widget.reason,
      );

      try {
        // Coba online
        final fileId = await repo.uploadSelfie(compressedFile);
        final onlineRequest = CheckOutRequest(
          pulang: request.pulang,
          latitudePulang: request.latitudePulang,
          longitudePulang: request.longitudePulang,
          selfiePulangFileId: fileId,
          outletId: request.outletId,
          keterangan: request.keterangan,
          clientRequestId: request.clientRequestId,
        );
        await repo.checkOut(todayRecord.id!, onlineRequest);

        ref.invalidate(todayAttendanceProvider);
        ref.invalidate(historyProvider);

        if (mounted) _showSuccessDialog();
      } on DioException catch (onlineError) {
        if (!_isOfflineError(onlineError)) rethrow;
        // Offline fallback: enqueue
        final syncRepo = ref.read(syncRepositoryProvider);
        await syncRepo.enqueueCheckOut(
          recordId: todayRecord.id!,
          request: request,
          selfiePath: compressedFile.path,
        );
        ref.invalidate(pendingSyncCountProvider);

        if (mounted) _showOfflineSuccessDialog();
      }
    } catch (e) {
      _showError('Gagal mengirim absensi pulang: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  bool _isOfflineError(DioException error) =>
      error.type == DioExceptionType.connectionError ||
      error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.receiveTimeout ||
      error.type == DioExceptionType.sendTimeout;

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.red,
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.green, size: 28),
            SizedBox(width: 10),
            Text('Absen Pulang Sah!',
                style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
          ],
        ),
        content:
            const Text('Foto selfie dan lokasi GPS telah berhasil dikirim.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/home');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100)),
            ),
            child: const Text('OK',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showOfflineSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.cloud_off_rounded, color: AppColors.amber, size: 28),
            SizedBox(width: 10),
            Text('Tersimpan Offline',
                style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
          ],
        ),
        content: const Text(
          'Absen pulang kamu disimpan lokal dan akan otomatis ter-sync '
          'saat koneksi internet tersedia.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/home');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.amber,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100)),
            ),
            child: const Text('OK',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gpsStatusText = _isLocationLoading
        ? 'Mendapatkan GPS...'
        : (_isWithinRadius == true
            ? 'Dalam radius ${_selectedOutlet?.shortName ?? 'outlet'}'
                '${_distanceToOutlet != null ? ' · ${_distanceLabel(_distanceToOutlet!)}' : ''}'
            : (_locationError != null
                ? 'GPS Gagal'
                : 'Luar radius ${_selectedOutlet?.shortName ?? 'outlet'}'));

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Column(
          children: [
            // Topbar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => context.go('/home'),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.close_rounded,
                          color: Colors.white, size: 18),
                    ),
                  ),
                  const Text(
                    'Absen Pulang',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 32),
                ],
              ),
            ),

            // Outlet Selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: GestureDetector(
                onTap: _isLocationLoading ? null : _openOutletPicker,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _isWithinRadius == true
                          ? AppColors.green.withValues(alpha: 0.5)
                          : Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.red.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Icon(Icons.storefront_rounded,
                            color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedOutlet?.shortName ??
                                  (_isLocationLoading
                                      ? 'Mencari outlet terdekat...'
                                      : 'Pilih outlet'),
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            if (_distanceToOutlet != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  '${_distanceLabel(_distanceToOutlet!)} dari kamu'
                                  '${_isWithinRadius == true ? ' · dalam radius' : ''}',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    color: _isWithinRadius == true
                                        ? AppColors.green
                                        : Colors.white.withValues(alpha: 0.6),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const Icon(Icons.unfold_more_rounded,
                          color: Colors.white54, size: 18),
                    ],
                  ),
                ),
              ),
            ),

            // Map preview outlet
            if (_latitude != null && _longitude != null) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
                child: _MapPreview(
                  userLatitude: _latitude!,
                  userLongitude: _longitude!,
                  selectedOutlet: _selectedOutlet,
                  onOutletTap: (outlet) {
                    setState(() {
                      _selectedOutlet = outlet;
                      final d = LocationUtils.distanceTo(
                        _latitude!,
                        _longitude!,
                        outlet.latitude,
                        outlet.longitude,
                      );
                      _distanceToOutlet = d;
                      _isWithinRadius = d <= outlet.radiusMeters;
                    });
                  },
                ),
              ),
            ],

            // Camera Viewport Frame
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C20),
                  borderRadius: BorderRadius.circular(20),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Preview Camera or Captured Photo
                    if (_capturedSelfie != null)
                      (kIsWeb || _capturedSelfie!.path.startsWith('http'))
                          ? Image.network(
                              _capturedSelfie!.path,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.person_rounded,
                                        size: 70, color: Colors.white70),
                                    SizedBox(height: 8),
                                    Text('Foto Selfie Terambil',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            )
                          : Image.file(
                              File(_capturedSelfie!.path),
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.person_rounded,
                                        size: 70, color: Colors.white70),
                                    SizedBox(height: 8),
                                    Text('Foto Selfie Terambil',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            )
                    else if (_isCameraInitialized && _cameraController != null)
                      CameraPreview(_cameraController!)
                    else
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt_outlined,
                                  size: 36, color: Colors.white70),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Kamera Web / Simulasi Standby',
                              style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white70),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: _takePhoto,
                              icon: const Icon(Icons.camera_alt_rounded,
                                  size: 16),
                              label: const Text('Ambil / Simulasi Foto Selfie'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.red,
                                foregroundColor: Colors.white,
                                textStyle: const TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.w700),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100)),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Top GPS Badge Overlay
                    Positioned(
                      top: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.red.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 7),
                            Text(
                              gpsStatusText,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Face Guide Overlay
                    if (_capturedSelfie == null)
                      Container(
                        width: 150,
                        height: 190,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.35),
                            width: 2.5,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Shutter / Action Controls
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              child: _capturedSelfie == null
                  ? GestureDetector(
                      onTap: _takePhoto,
                      child: Container(
                        width: 66,
                        height: 66,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        alignment: Alignment.center,
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: const BoxDecoration(
                            color: AppColors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: OutlinedButton(
                              onPressed: _retakePhoto,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.white24),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100)),
                              ),
                              child: const Text('Ulangi Foto',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _handleSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.red,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100)),
                              ),
                              child: _isSubmitting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2))
                                  : const Text('Kirim Absen',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Map preview yang watch outlet provider dari Riverpod.
class _MapPreview extends ConsumerWidget {
  const _MapPreview({
    required this.userLatitude,
    required this.userLongitude,
    required this.selectedOutlet,
    required this.onOutletTap,
  });

  final double userLatitude;
  final double userLongitude;
  final Outlet? selectedOutlet;
  final ValueChanged<Outlet> onOutletTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outletsAsync = ref.watch(outletsProvider);

    return outletsAsync.when(
      data: (outlets) => OutletMapWidget(
        outlets: outlets,
        userLatitude: userLatitude,
        userLongitude: userLongitude,
        selectedOutlet: selectedOutlet,
        height: 140,
        onOutletTap: onOutletTap,
      ),
      loading: () => Container(
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            color: Colors.white54,
            strokeWidth: 2,
          ),
        ),
      ),
      error: (e, _) => Container(
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.map_outlined, color: Colors.white30, size: 32),
      ),
    );
  }
}
