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
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        strokeWidth: 2.5,
        onRefresh: () async {
          ref.invalidate(todayAttendanceProvider);
          ref.invalidate(historyProvider);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 0,
              floating: true,
              snap: true,
              backgroundColor: AppColors.background,
              elevation: 0,
              scrolledUnderElevation: 0.5,
              shadowColor: AppColors.cardShadow,
              title: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(Icons.coffee_rounded, size: 17, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'IderKopi',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: IconButton(
                    icon: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(Icons.person_outline_rounded, size: 18, color: AppColors.textSecondary),
                    ),
                    onPressed: () => context.go('/profile'),
                  ),
                ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildGreetingCard(userAsync),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Status Hari Ini'),
                  const SizedBox(height: 10),
                  _buildTodayStatus(context, todayAsync),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Aksi Cepat'),
                  const SizedBox(height: 10),
                  _buildActionCards(context, todayAsync),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Riwayat Terkini'),
                  const SizedBox(height: 10),
                  _buildRecentHistory(historyAsync),
                  const SizedBox(height: 16),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildGreetingCard(AsyncValue userAsync) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.gradientShadow,
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -30,
            right: -15,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -15,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 60,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.25),
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
          '${AppDateUtils.greeting()} 👋',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        if (outlet.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.store_rounded, size: 12, color: Colors.white70),
                const SizedBox(width: 5),
                Text(
                  outlet,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_today_rounded, color: Colors.white70, size: 13),
              const SizedBox(width: 6),
              Text(
                AppDateUtils.formatDate(DateTime.now()),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTodayStatus(BuildContext context, AsyncValue<AttendanceRecord?> todayAsync) {
    return todayAsync.when(
      loading: () => _buildLoadingCard(height: 100),
      error: (e, _) => _buildStatusEmptyCard(),
      data: (record) {
        if (record == null) return _buildStatusEmptyCard();
        return AttendanceSummaryCard(record: record);
      },
    );
  }

  Widget _buildStatusEmptyCard() {
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
          _buildStatusRow('Check In', 'Belum', false),
          const Divider(height: 24, color: AppColors.borderLight),
          _buildStatusRow('Check Out', 'Belum', false),
        ],
      ),
    );
  }

  Widget _buildLoadingCard({required double height}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, bool isDone) {
    final color = isDone ? AppColors.success : AppColors.textMuted;
    final icon = isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded;
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCards(BuildContext context, AsyncValue<AttendanceRecord?> todayAsync) {
    return todayAsync.when(
      loading: () => Row(
        children: [
          Expanded(child: _buildLoadingCard(height: 96)),
          const SizedBox(width: 12),
          Expanded(child: _buildLoadingCard(height: 96)),
        ],
      ),
      error: (_, __) => _buildTwoActions(context,
        left: (Icons.camera_alt_rounded, 'Check In', () => context.push('/check-in'), true),
        right: (Icons.receipt_long_rounded, 'Riwayat', () => context.go('/history'), true),
      ),
      data: (record) {
        if (record == null || !record.hasCheckedIn) {
          return _buildTwoActions(context,
            left: (Icons.camera_alt_rounded, 'Check In', () => context.push('/check-in'), true),
            right: (Icons.receipt_long_rounded, 'Riwayat', () => context.go('/history'), true),
          );
        }
        if (record.hasCheckedOut) {
          return _buildTwoActions(context,
            left: (Icons.check_circle_outline_rounded, 'Selesai', null, false),
            right: (Icons.receipt_long_rounded, 'Riwayat', () => context.go('/history'), true),
          );
        }
        if (!_isWorkingHours()) {
          return _buildTwoActions(context,
            left: (Icons.logout_rounded, 'Check Out', () => context.push('/check-out'), true),
            right: (Icons.receipt_long_rounded, 'Riwayat', () => context.go('/history'), true),
          );
        }
        return Column(
          children: [
            _buildTwoActions(context,
              left: (Icons.logout_rounded, 'Check Out', null, false),
              right: (Icons.receipt_long_rounded, 'Riwayat', () => context.go('/history'), true),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: AppColors.warningDark, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Pilih alasan check out awal:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.warningDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _buildTwoActions(context,
              left: (Icons.work_history_rounded, 'Lembur', () => _goToCheckOut(context, 'Lembur'), true),
              right: (Icons.sick_rounded, 'Izin', () => _goToCheckOut(context, 'Izin'), true),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTwoActions(
    BuildContext context, {
    required (IconData, String, VoidCallback?, bool) left,
    required (IconData, String, VoidCallback?, bool) right,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            context,
            icon: left.$1,
            label: left.$2,
            onTap: left.$3,
            enabled: left.$4,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            context,
            icon: right.$1,
            label: right.$2,
            onTap: right.$3,
            enabled: right.$4,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    bool enabled = true,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.45,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
              boxShadow: AppTheme.softShadow,
            ),
            child: Column(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: enabled
                        ? AppColors.primaryGradient
                        : null,
                    color: enabled ? null : AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: enabled
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
                    color: enabled ? Colors.white : AppColors.textMuted,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: enabled ? AppColors.textPrimary : AppColors.textMuted,
                    letterSpacing: -0.1,
                  ),
                ),
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
        height: 160,
        child: Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5)),
      ),
      error: (e, _) => const SizedBox(
        height: 80,
        child: Center(
          child: Text('Gagal memuat riwayat', style: TextStyle(color: AppColors.textMuted)),
        ),
      ),
      data: (records) {
        if (records.isEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long_rounded, size: 44, color: AppColors.textLight),
                SizedBox(height: 12),
                Text(
                  'Belum ada riwayat',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Mulai absen hari ini',
                  style: TextStyle(color: AppColors.textLight, fontSize: 13),
                ),
              ],
            ),
          );
        }
        final recent = records.take(3).toList();
        return Column(
          children: recent
              .map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: HistoryListItem(record: r),
                  ))
              .toList(),
        );
      },
    );
  }
}
