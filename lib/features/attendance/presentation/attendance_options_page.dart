import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../data/attendance_model.dart';
import '../providers/attendance_providers.dart';

class AttendanceOptionsPage extends ConsumerWidget {
  const AttendanceOptionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayAsync = ref.watch(todayAttendanceProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Opsi Absensi', style: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(todayAsync),
            const SizedBox(height: 28),
            const Text(
              'Pilih Jenis Absensi',
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 14),
            _buildOptions(context, todayAsync),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(AsyncValue<AttendanceRecord?> todayAsync) {
    return todayAsync.when(
      loading: () => Container(
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.red, strokeWidth: 2),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (record) {
        final isCheckedIn = record?.masuk != null;
        final isCheckedOut = record?.keluar != null;

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.line),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12101012),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Status Hari Ini',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 14),
              _buildStatusRow('Check In', record?.masuk ?? 'Belum', isCheckedIn),
              const Divider(height: 20, color: AppColors.line),
              _buildStatusRow('Check Out', record?.keluar ?? 'Belum', isCheckedOut),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusRow(String label, String value, bool isDone) {
    final color = isDone ? AppColors.green : AppColors.muted;
    final icon = isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded;
    final bgColor = isDone ? AppColors.greenBg : AppColors.surfaceAlt;

    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Space Mono',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildOptions(BuildContext context, AsyncValue<AttendanceRecord?> todayAsync) {
    final record = todayAsync.asData?.value;
    final hasCheckedIn = record?.masuk != null;
    final hasCheckedOut = record?.keluar != null;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildOptionTile(
                context,
                iconData: Icons.login_rounded,
                title: 'Absen Masuk',
                subtitle: hasCheckedIn ? 'Sudah (${record!.masuk})' : 'Selfie + GPS',
                onTap: () {
                  if (!hasCheckedIn) {
                    context.push('/check-in');
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildOptionTile(
                context,
                iconData: Icons.directions_run_rounded,
                title: 'Absen Pulang',
                subtitle: hasCheckedOut ? 'Sudah (${record!.keluar})' : 'Selesai kerja',
                onTap: () {
                  if (hasCheckedIn && !hasCheckedOut) {
                    context.push('/check-out');
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildOptionTile(
                context,
                iconData: Icons.local_hospital_rounded,
                title: 'Pengajuan Izin',
                subtitle: 'Izin keluar',
                onTap: () {
                  context.push('/check-out', extra: 'Izin');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildOptionTile(
                context,
                iconData: Icons.access_time_filled_rounded,
                title: 'Absen Lembur',
                subtitle: 'Kerja tambahan',
                onTap: () {
                  context.push('/check-out', extra: 'Lembur');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData iconData,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.line),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12101012),
              blurRadius: 14,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(iconData, color: AppColors.ink, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 10.5,
                color: AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
