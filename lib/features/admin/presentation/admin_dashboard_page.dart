import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/providers/brand_provider.dart';
import '../../../core/utils/date_utils.dart';
import '../../attendance/data/attendance_model.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/admin_providers.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final userCountAsync = ref.watch(userCountProvider);
    final todayAttCountAsync = ref.watch(todayAttendanceCountProvider);
    final attendanceListAsync = ref.watch(adminAttendanceProvider((date: null, employee: null)));
    final activeBrand = ref.watch(activeBrandProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: RefreshIndicator(
        color: AppColors.ink,
        onRefresh: () async {
          ref.invalidate(userCountProvider);
          ref.invalidate(todayAttendanceCountProvider);
          ref.invalidate(adminAttendanceProvider((date: null, employee: null)));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Signature Block Header Dark Ink
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  22,
                  MediaQuery.of(context).padding.top + 16,
                  22,
                  24,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.ink,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
                ),
                child: Column(
                  children: [
                    // Header Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Panel Admin ${activeBrand.name}',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              AppDateUtils.formatFullDate(DateTime.now()),
                              style: const TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),

                        // Mode Badge Pill & Admin Avatar
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'AI',
                                style: TextStyle(
                                  fontFamily: 'Sora',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
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
                                      fontSize: 9,
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

                    const SizedBox(height: 18),

                    // KPI Grid 2x2
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.45,
                      children: [
                        _buildKpiCard(
                          stripColor: AppColors.green,
                          label: 'HADIR',
                          value: todayAttCountAsync.when(
                            data: (count) => '$count',
                            loading: () => '...',
                            error: (_, __) => '0',
                          ),
                          sub: userCountAsync.when(
                            data: (total) => 'dari $total karyawan',
                            loading: () => 'karyawan',
                            error: (_, __) => 'karyawan',
                          ),
                        ),
                        _buildKpiCard(
                          stripColor: AppColors.amber,
                          label: 'TERLAMBAT',
                          value: '4',
                          sub: 'rata² 22 menit',
                        ),
                        _buildKpiCard(
                          stripColor: AppColors.red,
                          label: 'TIDAK HADIR',
                          value: '2',
                          sub: 'tanpa keterangan',
                        ),
                        _buildKpiCard(
                          stripColor: AppColors.ink,
                          label: 'OUTLET AKTIF',
                          value: '5',
                          sub: 'semua normal',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Feed Section Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Absen Masuk Terbaru (${activeBrand.name})',
                      style: const TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/admin/attendance'),
                      child: const Text(
                        'Semua',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Feed List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: attendanceListAsync.when(
                  loading: () => const SizedBox(
                    height: 120,
                    child: Center(child: CircularProgressIndicator(color: AppColors.ink)),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (records) {
                    if (records.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            'Belum ada absen masuk hari ini',
                            style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.muted),
                          ),
                        ),
                      );
                    }

                    final recentRecords = records.take(6).toList();
                    return Column(
                      children: recentRecords.map((rec) => _buildFeedItem(rec)).toList(),
                    );
                  },
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKpiCard({
    required Color stripColor,
    required String label,
    required String value,
    required String sub,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
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
          Container(
            width: 22,
            height: 3,
            decoration: BoxDecoration(
              color: stripColor,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Space Mono',
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
              color: AppColors.muted,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Sora',
              fontSize: 23,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 9.5,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedItem(AttendanceRecord rec) {
    final name = rec.kangiderNama ?? 'Karyawan';
    final initials = name.isNotEmpty
        ? name.trim().split(' ').map((e) => e[0]).take(2).join()
        : 'IK';
    final outlet = rec.outlet ?? 'Malioboro';
    final timeStr = rec.masuk ?? '--:--';
    final isLate = rec.isLate ?? false;

    final Color tagBg;
    final Color tagColor;
    final String tagLabel;

    if (isLate) {
      tagBg = AppColors.amberBg;
      tagColor = AppColors.amber;
      tagLabel = 'Telat';
    } else {
      tagBg = AppColors.greenBg;
      tagColor = AppColors.green;
      tagLabel = 'Hadir';
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(11),
            ),
            alignment: Alignment.center,
            child: Text(
              initials.toUpperCase(),
              style: const TextStyle(
                fontFamily: 'Sora',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  '$outlet · $timeStr',
                  style: const TextStyle(
                    fontFamily: 'Space Mono',
                    fontSize: 10,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: tagBg,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: tagColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  tagLabel,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: tagColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
