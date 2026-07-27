import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../data/attendance_model.dart';
import '../providers/attendance_providers.dart';

class AttendanceOptionsPage extends ConsumerWidget {
  const AttendanceOptionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayAsync = ref.watch(todayAttendanceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Absensi'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(todayAsync),
            const SizedBox(height: 24),
            const Text(
              'Pilih jenis absensi:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            _buildOptions(context, todayAsync),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(AsyncValue<AttendanceRecord?> todayAsync) {
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
        if (record == null) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Belum ada data absensi hari ini.'),
            ),
          );
        }

        final masuk = record.masuk ?? '-';
        final pulang = record.pulang ?? '-';
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusRow('Check In', masuk, record.hasCheckedIn),
                const Divider(height: 24),
                _buildStatusRow('Check Out', pulang, record.hasCheckedOut),
                if (record.keterangan != null) ...[
                  const Divider(height: 24),
                  Text(
                    'Keterangan: ${record.keterangan}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusRow(String label, String value, bool isDone) {
    final color = isDone ? AppColors.success : AppColors.error;
    final icon = isDone ? Icons.check_circle : Icons.radio_button_unchecked;
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildOptions(BuildContext context, AsyncValue<AttendanceRecord?> todayAsync) {
    return todayAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (record) {
        final canCheckIn = record == null || !record.hasCheckedIn;
        final canCheckOut =
            record != null && record.hasCheckedIn && !record.hasCheckedOut;

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildOptionCard(
                    context,
                    icon: Icons.login_rounded,
                    label: 'Masuk',
                    enabled: canCheckIn,
                    onTap: () => context.go('/check-in'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildOptionCard(
                    context,
                    icon: Icons.logout_rounded,
                    label: 'Keluar',
                    enabled: canCheckOut,
                    onTap: () => context.go('/check-out'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildOptionCard(
                    context,
                    icon: Icons.sick_rounded,
                    label: 'Izin',
                    enabled: canCheckOut,
                    onTap: () => context.push('/check-out', extra: 'Izin'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildOptionCard(
                    context,
                    icon: Icons.work_history_rounded,
                    label: 'Lembur',
                    enabled: canCheckOut,
                    onTap: () => context.push('/check-out', extra: 'Lembur'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.45,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: AppTheme.softShadow,
            ),
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: AppColors.primary),
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
