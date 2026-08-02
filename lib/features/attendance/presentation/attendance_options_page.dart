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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pilih Absensi'),
        backgroundColor: AppColors.background,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(todayAsync),
            const SizedBox(height: 28),
            const Text(
              'Pilih jenis absensi:',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.2,
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
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5),
        ),
      ),
      error: (e, _) => Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: const Center(child: Text('Gagal memuat', style: TextStyle(color: AppColors.textMuted))),
      ),
      data: (record) {
        if (record == null) {
          return Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
              boxShadow: AppTheme.softShadow,
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.receipt_long_rounded, color: AppColors.textMuted, size: 22),
                ),
                const SizedBox(width: 14),
                const Text(
                  'Belum ada data absensi hari ini.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
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
            boxShadow: AppTheme.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.today_rounded, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Status Hari Ini',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildStatusRow('Check In', record.masuk ?? '-', record.hasCheckedIn),
              const Divider(height: 20, color: AppColors.borderLight),
              _buildStatusRow('Check Out', record.pulang ?? '-', record.hasCheckedOut),
              if (record.keterangan != null) ...[
                const Divider(height: 20, color: AppColors.borderLight),
                Row(
                  children: [
                    const Icon(Icons.notes_rounded, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Text(
                      record.keterangan!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusRow(String label, String value, bool isDone) {
    final color = isDone ? AppColors.success : AppColors.textMuted;
    final icon = isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded;
    final bgColor = isDone ? AppColors.successLight : AppColors.surfaceAlt;
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
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
        final hasCheckedIn = record != null && record.hasCheckedIn;
        final hasCheckedOut = record != null && record.hasCheckedOut;

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildOptionCard(
                    context,
                    icon: Icons.login_rounded,
                    label: 'Masuk',
                    subtitle: hasCheckedIn ? 'Sudah Check-In (${record.masuk} WIB)' : 'Check in kehadiran',
                    enabled: true,
                    onTap: () {
                      if (!hasCheckedIn) {
                        context.push('/check-in');
                      } else {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            title: const Text('Sudah Check-In'),
                            content: Text(
                              'Anda sudah melakukan Check In hari ini pukul ${record.masuk} WIB.\n\nApakah Anda ingin mengisi ulang form check-in?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Batal'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  context.push('/check-in');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: const Text('Lanjutkan Check In', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    isPrimary: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildOptionCard(
                    context,
                    icon: Icons.logout_rounded,
                    label: 'Keluar',
                    subtitle: hasCheckedOut
                        ? 'Sudah Pulang (${record.pulang} WIB)'
                        : (hasCheckedIn ? 'Check out selesai kerja' : 'Belum Check-In'),
                    enabled: true,
                    onTap: () {
                      if (!hasCheckedIn) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Anda belum melakukan Check-In hari ini.'),
                            backgroundColor: AppColors.warningDark,
                          ),
                        );
                      } else if (hasCheckedOut) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Anda sudah Check-Out hari ini pukul ${record.pulang} WIB.'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      } else {
                        context.push('/check-out');
                      }
                    },
                    isPrimary: false,
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
                    subtitle: 'Izin meninggalkan tempat',
                    enabled: true,
                    onTap: () {
                      if (!hasCheckedIn) {
                        context.push('/check-in');
                      } else {
                        context.push('/check-out', extra: 'Izin');
                      }
                    },
                    isPrimary: false,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildOptionCard(
                    context,
                    icon: Icons.work_history_rounded,
                    label: 'Lembur',
                    subtitle: 'Bekerja di luar jam kerja',
                    enabled: true,
                    onTap: () {
                      if (!hasCheckedIn) {
                        context.push('/check-in');
                      } else {
                        context.push('/check-out', extra: 'Lembur');
                      }
                    },
                    isPrimary: false,
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
    required String subtitle,
    required bool enabled,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
              boxShadow: AppTheme.softShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: enabled && isPrimary ? AppColors.primaryGradient : null,
                    color: enabled
                        ? (isPrimary ? null : AppColors.primaryLight)
                        : AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: enabled && isPrimary
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    icon,
                    color: enabled
                        ? (isPrimary ? Colors.white : AppColors.primary)
                        : AppColors.textMuted,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: enabled ? AppColors.textPrimary : AppColors.textMuted,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    height: 1.3,
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
