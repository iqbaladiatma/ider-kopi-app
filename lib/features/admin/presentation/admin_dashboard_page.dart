import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/providers/brand_provider.dart';
import '../../../core/utils/date_utils.dart';
import '../../../shared/widgets/outlet_mode_sheet.dart';
import '../../attendance/data/attendance_model.dart';
import '../../auth/providers/auth_providers.dart';

import 'admin_attendance_detail_page.dart';
import '../providers/admin_providers.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userCountAsync = ref.watch(userCountProvider);
    final todayAttCountAsync = ref.watch(todayAttendanceCountProvider);
    final attendanceListAsync = ref.watch(adminAttendanceProvider((date: null, employee: null)));
    final activeBrand = ref.watch(activeBrandProvider);

    final totalUsers = userCountAsync.asData?.value ?? 6;
    final todayHadir = todayAttCountAsync.asData?.value ?? 5;
    final attPct = totalUsers > 0 ? ((todayHadir / totalUsers) * 100).round() : 85;

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
              // Header Block Dark Ink with Mode Switcher
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  22,
                  MediaQuery.of(context).padding.top + 16,
                  22,
                  20,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.ink,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
                ),
                child: Column(
                  children: [
                    // Header Top Row
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
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),

                        // Mode Badge Pill (Clickable -> Bottom Sheet)
                        GestureDetector(
                          onTap: () => showOutletModeSheet(context, ref),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: activeBrand.primaryColor,
                              borderRadius: BorderRadius.circular(100),
                              boxShadow: [
                                BoxShadow(
                                  color: activeBrand.primaryColor.withValues(alpha: 0.4),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(activeBrand.iconData, color: Colors.white, size: 13),
                                const SizedBox(width: 5),
                                Text(
                                  activeBrand.badgeText,
                                  style: const TextStyle(
                                    fontFamily: 'Space Mono',
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 16),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Sleek Compact Attendance Summary Card with Ring Chart & Percentages
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                      ),
                      child: Row(
                        children: [
                          // Circular Percentage Ring Indicator
                          SizedBox(
                            width: 64,
                            height: 64,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 64,
                                  height: 64,
                                  child: CircularProgressIndicator(
                                    value: (attPct / 100).clamp(0.0, 1.0),
                                    strokeWidth: 6.5,
                                    backgroundColor: Colors.white.withValues(alpha: 0.12),
                                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.green),
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '$attPct%',
                                      style: const TextStyle(
                                        fontFamily: 'Sora',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const Text(
                                      'HADIR',
                                      style: TextStyle(
                                        fontFamily: 'Space Mono',
                                        fontSize: 7.5,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 14),
                          Container(width: 1, height: 48, color: Colors.white.withValues(alpha: 0.15)),
                          const SizedBox(width: 14),

                          // Compact Stat Breakdown Columns
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildCompactStat(
                                  label: 'HADIR',
                                  valStr: '$todayHadir',
                                  subStr: 'Total $totalUsers',
                                  color: AppColors.green,
                                ),
                                _buildCompactStat(
                                  label: 'TELAT',
                                  valStr: '1',
                                  subStr: 'Rata² 15m',
                                  color: AppColors.amber,
                                ),
                                _buildCompactStat(
                                  label: 'ABSEN',
                                  valStr: '${(totalUsers - todayHadir).clamp(0, 99)}',
                                  subStr: 'Izin/Sakit',
                                  color: AppColors.red,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Feed Section Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Absen Terbaru (${activeBrand.name})',
                      style: const TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/admin/attendance'),
                      child: const Text(
                        'Lihat Semua',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Attendance Feed List (Clickable -> Detail Page)
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
                      children: recentRecords.map((rec) => _buildFeedItem(context, rec)).toList(),
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

  Widget _buildCompactStat({
    required String label,
    required String valStr,
    required String subStr,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Container(width: 5, height: 5, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Space Mono',
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          valStr,
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          subStr,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 9,
            color: Colors.white54,
          ),
        ),
      ],
    );
  }

  Widget _buildFeedItem(BuildContext context, AttendanceRecord rec) {
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

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AdminAttendanceDetailPage(record: rec)),
        );
      },
      child: Container(
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
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, color: AppColors.muted, size: 18),
          ],
        ),
      ),
    );
  }
}

