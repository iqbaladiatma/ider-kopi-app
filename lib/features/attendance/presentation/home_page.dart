import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/providers/brand_provider.dart';
import '../../../core/utils/date_utils.dart';
import '../../auth/providers/auth_providers.dart';
import '../data/attendance_model.dart';
import '../providers/attendance_providers.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final todayAsync = ref.watch(todayAttendanceProvider);
    final activeBrand = ref.watch(activeBrandProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: RefreshIndicator(
        color: activeBrand.primaryColor,
        onRefresh: () async {
          ref.invalidate(todayAttendanceProvider);
          ref.invalidate(historyProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Signature Header + Floating Ring Card
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // Block Header
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(
                      22,
                      MediaQuery.of(context).padding.top + 16,
                      22,
                      56,
                    ),
                    decoration: BoxDecoration(
                      color: activeBrand.primaryColor,
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(26)),
                    ),
                    child: Column(
                      children: [
                        // Top Header Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppDateUtils.formatFullDate(DateTime.now()),
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                userAsync.when(
                                  data: (user) => Text(
                                    user?.fullName ?? 'Karyawan',
                                    style: const TextStyle(
                                      fontFamily: 'Sora',
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  loading: () => const SizedBox(
                                    width: 120,
                                    height: 24,
                                    child: LinearProgressIndicator(color: Colors.white, backgroundColor: Colors.white24),
                                  ),
                                  error: (_, __) => const Text(
                                    'Karyawan',
                                    style: TextStyle(
                                      fontFamily: 'Sora',
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // Avatar Circle & Mode Pill
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                userAsync.when(
                                  data: (user) {
                                    final initials = user?.fullName.isNotEmpty == true
                                        ? user!.fullName.trim().split(' ').map((e) => e[0]).take(2).join()
                                        : 'IK';
                                    return Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.16),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        initials.toUpperCase(),
                                        style: const TextStyle(
                                          fontFamily: 'Sora',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  },
                                  loading: () => const SizedBox(width: 38, height: 38),
                                  error: (_, __) => const SizedBox(width: 38, height: 38),
                                ),
                                const SizedBox(height: 8),

                                // Mode Badge Pill
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(activeBrand.iconData, color: Colors.white, size: 12),
                                      const SizedBox(width: 4),
                                      Text(
                                        activeBrand.badgeText,
                                        style: const TextStyle(
                                          fontFamily: 'Space Mono',
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Floating Ring Card (Overlay)
                  Positioned(
                    left: 22,
                    right: 22,
                    bottom: -36,
                    child: _buildRingCard(todayAsync, activeBrand),
                  ),
                ],
              ),

              const SizedBox(height: 52),

              // Main Body Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Column(
                  children: [
                    // Punch Button (Absen Masuk / Absen Pulang)
                    _buildPunchButton(context, todayAsync, activeBrand),

                    const SizedBox(height: 6),
                    const Text(
                      'Wajib foto selfie + lokasi GPS',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10.5,
                        color: AppColors.muted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Feature Cards: Izin & Lembur
                    _buildFeatureActionCards(context, todayAsync),

                    const SizedBox(height: 24),

                    // Section Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Aktivitas Hari Ini (${activeBrand.name})',
                          style: const TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/history'),
                          child: Text(
                            'Riwayat',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: activeBrand.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Timeline
                    _buildTimeline(todayAsync),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRingCard(AsyncValue<AttendanceRecord?> todayAsync, AppBrand activeBrand) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2E101012),
            blurRadius: 30,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ring Chart
          SizedBox(
            width: 74,
            height: 74,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(74, 74),
                  painter: _RingPainter(
                    ringColor: activeBrand.primaryColor,
                    progress: todayAsync.when(
                      data: (rec) => rec?.keluar != null ? 1.0 : (rec?.masuk != null ? 0.5 : 0.0),
                      loading: () => 0.0,
                      error: (_, __) => 0.0,
                    ),
                  ),
                ),
                Text(
                  todayAsync.when(
                    data: (rec) => rec?.keluar != null ? '100%' : (rec?.masuk != null ? '50%' : '0%'),
                    loading: () => '0%',
                    error: (_, __) => '0%',
                  ),
                  style: const TextStyle(
                    fontFamily: 'Space Mono',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Time Info
          Expanded(
            child: todayAsync.when(
              data: (rec) {
                final displayTime = rec?.masuk ?? '07:30';
                final subText = rec?.keluar != null
                    ? 'Shift selesai hari ini'
                    : (rec?.masuk != null ? 'Sudah absen masuk (${activeBrand.name})' : 'Belum absen hari ini');
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      displayTime,
                      style: const TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subText,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                );
              },
              loading: () => const SizedBox(
                height: 40,
                child: Center(child: CircularProgressIndicator(color: AppColors.red, strokeWidth: 2)),
              ),
              error: (_, __) => const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '--:--',
                    style: TextStyle(fontFamily: 'Sora', fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  Text('Belum absen', style: TextStyle(fontSize: 11, color: AppColors.muted)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPunchButton(BuildContext context, AsyncValue<AttendanceRecord?> todayAsync, AppBrand activeBrand) {
    final hasCheckedIn = todayAsync.asData?.value?.masuk != null;
    final hasCheckedOut = todayAsync.asData?.value?.keluar != null;

    final String label;
    final VoidCallback? onPressed;

    if (hasCheckedOut) {
      label = 'Absensi Selesai Hari Ini';
      onPressed = null;
    } else if (hasCheckedIn) {
      label = 'Absen Pulang (${activeBrand.name})';
      onPressed = () => context.go('/check-out');
    } else {
      label = 'Absen Masuk (${activeBrand.name})';
      onPressed = () => context.go('/check-in');
    }

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: activeBrand.primaryColor,
          disabledBackgroundColor: AppColors.muted.withValues(alpha: 0.3),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.access_time_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 9),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureActionCards(BuildContext context, AsyncValue<AttendanceRecord?> todayAsync) {
    final rec = todayAsync.asData?.value;
    final hasCheckedIn = rec?.masuk != null;

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (!hasCheckedIn) {
                context.go('/check-in');
              } else {
                context.go('/check-out', extra: 'Izin');
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.line),
              ),
              child: const Row(
                children: [
                  Icon(Icons.local_hospital_rounded, color: AppColors.ink, size: 20),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Izin',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      Text(
                        'Pengajuan Izin',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (!hasCheckedIn) {
                context.go('/check-in');
              } else {
                context.go('/check-out', extra: 'Lembur');
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.line),
              ),
              child: const Row(
                children: [
                  Icon(Icons.access_time_filled_rounded, color: AppColors.ink, size: 20),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lembur',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      Text(
                        'Absen Lembur',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeline(AsyncValue<AttendanceRecord?> todayAsync) {
    final rec = todayAsync.asData?.value;
    final isDoneIn = rec?.masuk != null;
    final isDoneOut = rec?.keluar != null;

    return Column(
      children: [
        // Item Masuk
        Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.line)),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isDoneIn ? AppColors.greenBg : AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(
                  isDoneIn ? Icons.check_rounded : Icons.radio_button_unchecked_rounded,
                  size: isDoneIn ? 18 : 14,
                  color: isDoneIn ? AppColors.green : AppColors.muted,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Absen Masuk',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      isDoneIn ? '${rec!.masuk} WIB · Tepat waktu' : 'Estimasi 07:30 WIB',
                      style: const TextStyle(
                        fontFamily: 'Space Mono',
                        fontSize: 11,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Item Pulang
        Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.line)),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isDoneOut ? AppColors.greenBg : AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(
                  isDoneOut ? Icons.check_rounded : Icons.radio_button_unchecked_rounded,
                  size: isDoneOut ? 18 : 14,
                  color: isDoneOut ? AppColors.green : AppColors.muted,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Absen Pulang',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      isDoneOut ? '${rec!.keluar} WIB' : 'Estimasi 17:00 WIB',
                      style: const TextStyle(
                        fontFamily: 'Space Mono',
                        fontSize: 11,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress, required this.ringColor});

  final double progress;
  final Color ringColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 8) / 2;

    final trackPaint = Paint()
      ..color = AppColors.surfaceAlt
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    final fillPaint = Paint()
      ..color = ringColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.ringColor != ringColor;
}
