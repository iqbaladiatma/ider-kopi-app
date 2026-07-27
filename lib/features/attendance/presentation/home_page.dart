import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../auth/providers/auth_providers.dart';
import '../data/attendance_model.dart';
import '../providers/attendance_providers.dart';
import 'widgets/attendance_summary_card.dart';
import 'widgets/history_list_item.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final todayAsync = ref.watch(todayAttendanceProvider);
    final historyAsync = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('IderKopi Absensi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.go('/profile'),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(todayAttendanceProvider);
          ref.invalidate(historyProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGreetingCard(userAsync),
              const SizedBox(height: 28),
              _buildSectionTitle('Status Hari Ini'),
              const SizedBox(height: 10),
              _buildTodayStatus(context, todayAsync),
              const SizedBox(height: 28),
              _buildActionCards(context, todayAsync),
              const SizedBox(height: 28),
              _buildSectionTitle('Riwayat Terkini'),
              const SizedBox(height: 10),
              _buildRecentHistory(historyAsync),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildGreetingCard(AsyncValue userAsync) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.gradientShadow,
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -10,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -10,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          userAsync.when(
            loading: () => const SizedBox(
              height: 90,
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            error: (_, __) => _buildGreetingContent('Pengguna', ''),
            data: (user) => _buildGreetingContent(
              user?.fullName ?? 'Pengguna',
              user?.outlet ?? user?.kangiderNama ?? '',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreetingContent(String name, String outlet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${AppDateUtils.greeting()},',
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 2),
        Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (outlet.isNotEmpty) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              outlet,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
        const SizedBox(height: 14),
        Row(
          children: [
            const Icon(Icons.calendar_today_rounded,
                color: Colors.white70, size: 14),
            const SizedBox(width: 6),
            Text(
              AppDateUtils.formatDate(DateTime.now()),
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTodayStatus(BuildContext context, AsyncValue<AttendanceRecord?> todayAsync) {
    return todayAsync.when(
      loading: () => const Card(
        child: SizedBox(
          height: 120,
          child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
        ),
      ),
      error: (e, _) => Card(
        child: SizedBox(
          height: 120,
          child: Center(child: Text('Gagal memuat: $e')),
        ),
      ),
      data: (record) {
        if (record == null) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusRow('Check In', 'Belum', false),
                  const Divider(height: 24),
                  _buildStatusRow('Check Out', 'Belum', false),
                ],
              ),
            ),
          );
        }
        return AttendanceSummaryCard(record: record);
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
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }

  Widget _buildActionCards(BuildContext context, AsyncValue<AttendanceRecord?> todayAsync) {
    return todayAsync.when(
      loading: () => const Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 96,
              child: Card(
                child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 96,
              child: Card(
                child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              ),
            ),
          ),
        ],
      ),
      error: (_, __) => Row(
        children: [
          Expanded(
            child: _buildActionCard(
              context,
              icon: Icons.camera_alt_rounded,
              label: 'Check In',
              onTap: () => context.go('/check-in'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionCard(
              context,
              icon: Icons.receipt_long_rounded,
              label: 'Riwayat',
              onTap: () => context.go('/history'),
            ),
          ),
        ],
      ),
      data: (record) {
        if (record == null || !record.hasCheckedIn) {
          return Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  context,
                  icon: Icons.camera_alt_rounded,
                  label: 'Check In',
                  onTap: () => context.go('/check-in'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  context,
                  icon: Icons.receipt_long_rounded,
                  label: 'Riwayat',
                  onTap: () => context.go('/history'),
                ),
              ),
            ],
          );
        }

        if (record.hasCheckedOut) {
          return Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  context,
                  icon: Icons.check_circle_rounded,
                  label: 'Selesai',
                  onTap: null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  context,
                  icon: Icons.receipt_long_rounded,
                  label: 'Riwayat',
                  onTap: () => context.go('/history'),
                ),
              ),
            ],
          );
        }

        if (!_isWorkingHours()) {
          return Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  context,
                  icon: Icons.logout_rounded,
                  label: 'Check Out',
                  onTap: () => context.go('/check-out'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  context,
                  icon: Icons.receipt_long_rounded,
                  label: 'Riwayat',
                  onTap: () => context.go('/history'),
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    context,
                    icon: Icons.logout_rounded,
                    label: 'Check Out',
                    onTap: null,
                    subtitle: 'Masih jam kerja',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    context,
                    icon: Icons.receipt_long_rounded,
                    label: 'Riwayat',
                    onTap: () => context.go('/history'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'Pilih alasan check out awal:',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    context,
                    icon: Icons.work_history_rounded,
                    label: 'Lembur',
                    onTap: () => _goToCheckOut(context, 'Lembur'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    context,
                    icon: Icons.sick_rounded,
                    label: 'Izin',
                    onTap: () => _goToCheckOut(context, 'Izin'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    String? subtitle,
  }) {
    final enabled = onTap != null;
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
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
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isWorkingHours() {
    final now = DateTime.now();
    return now.hour >= 8 && now.hour < 17;
  }

  void _goToCheckOut(BuildContext context, String reason) {
    context.push('/check-out', extra: reason);
  }

  Widget _buildRecentHistory(AsyncValue<List<AttendanceRecord>> historyAsync) {
    return historyAsync.when(
      loading: () => const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      ),
      error: (e, _) => SizedBox(
        height: 100,
        child: Center(child: Text('Gagal memuat riwayat: $e')),
      ),
      data: (records) {
        if (records.isEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_rounded,
                      size: 48, color: AppColors.gray300),
                  SizedBox(height: 12),
                  Text(
                    'Belum ada riwayat',
                    style: TextStyle(color: AppColors.gray500, fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Mulai absen hari ini',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                  ),
                ],
              ),
            ),
          );
        }

        final recent = records.take(3).toList();
        return Column(
          children: recent.map((r) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: HistoryListItem(record: r),
          )).toList(),
        );
      },
    );
  }
}
