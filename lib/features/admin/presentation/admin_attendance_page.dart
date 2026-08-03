import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/empty_view.dart';
import '../../../shared/widgets/error_view.dart';
import '../../attendance/data/attendance_model.dart';
import '../providers/admin_providers.dart';

class AdminAttendancePage extends ConsumerStatefulWidget {
  const AdminAttendancePage({super.key});

  @override
  ConsumerState<AdminAttendancePage> createState() => _AdminAttendancePageState();
}

class _AdminAttendancePageState extends ConsumerState<AdminAttendancePage> {
  int _selectedFilterIndex = 0; // 0: Semua, 1: Hadir, 2: Telat, 3: Absen

  @override
  Widget build(BuildContext context) {
    final attendanceAsync = ref.watch(adminAttendanceProvider(
      (date: null, employee: null),
    ));

    return Scaffold(
      backgroundColor: AppColors.white,
      body: RefreshIndicator(
        color: AppColors.ink,
        onRefresh: () async {
          ref.invalidate(adminAttendanceProvider((date: null, employee: null)));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Signature Header Dark Ink
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  22,
                  MediaQuery.of(context).padding.top + 18,
                  22,
                  20,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.ink,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Daftar Absensi',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Filter Chips Row
                    attendanceAsync.when(
                      data: (records) {
                        final totalCount = records.length;
                        final hadirCount = records.where((r) => r.masuk != null && !(r.isLate ?? false)).length;
                        final telatCount = records.where((r) => r.masuk != null && (r.isLate ?? false)).length;
                        final absenCount = records.where((r) => r.masuk == null).length;

                        final chips = [
                          'Semua · $totalCount',
                          'Hadir · $hadirCount',
                          'Telat · $telatCount',
                          'Absen · $absenCount',
                        ];

                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: chips.asMap().entries.map((entry) {
                              final index = entry.key;
                              final label = entry.value;
                              final isActive = _selectedFilterIndex == index;

                              return GestureDetector(
                                onTap: () => setState(() => _selectedFilterIndex = index),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Text(
                                    label,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: isActive ? AppColors.ink : Colors.white,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
                      loading: () => const SizedBox(height: 36),
                      error: (_, __) => const SizedBox(height: 36),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Attendance List Items
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: attendanceAsync.when(
                  loading: () => const SizedBox(
                    height: 150,
                    child: Center(child: CircularProgressIndicator(color: AppColors.ink)),
                  ),
                  error: (e, _) => ErrorView(
                    message: 'Gagal memuat data absensi',
                    onRetry: () => ref.invalidate(adminAttendanceProvider((date: null, employee: null))),
                  ),
                  data: (records) {
                    final filteredRecords = records.where((r) {
                      if (_selectedFilterIndex == 1) return r.masuk != null && !(r.isLate ?? false);
                      if (_selectedFilterIndex == 2) return r.masuk != null && (r.isLate ?? false);
                      if (_selectedFilterIndex == 3) return r.masuk == null;
                      return true;
                    }).toList();

                    if (filteredRecords.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: EmptyView(
                          icon: Icons.assignment_outlined,
                          title: 'Tidak ada data absensi',
                          subtitle: 'Belum ada riwayat absensi karyawan untuk filter ini',
                        ),
                      );
                    }

                    return Column(
                      children: filteredRecords.map((rec) => _buildListItem(rec)).toList(),
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

  Widget _buildListItem(AttendanceRecord record) {
    final name = record.kangiderNama ?? 'Karyawan';
    final initials = name.isNotEmpty
        ? name.trim().split(' ').map((e) => e[0]).take(2).join()
        : 'IK';
    final outlet = record.outlet ?? 'Malioboro';
    final timeStr = record.masuk ?? '—';
    final isAbsent = record.masuk == null;
    final isLate = record.isLate ?? false;

    final String geoText;
    final Color geoColor;

    if (isAbsent) {
      geoText = 'Tidak lapor';
      geoColor = AppColors.red;
    } else if (isLate) {
      geoText = '164m ⚠';
      geoColor = AppColors.amber;
    } else {
      geoText = '12m ✓';
      geoColor = AppColors.green;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              initials.toUpperCase(),
              style: const TextStyle(
                fontFamily: 'Sora',
                fontSize: 14,
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
                  outlet,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                timeStr,
                style: const TextStyle(
                  fontFamily: 'Space Mono',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                geoText,
                style: TextStyle(
                  fontFamily: 'Space Mono',
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: geoColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
