import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../shared/widgets/empty_view.dart';
import '../../../shared/widgets/error_view.dart';
import '../data/attendance_model.dart';
import '../providers/attendance_providers.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final params = (year: _selectedMonth.year, month: _selectedMonth.month);
    final historyAsync = ref.watch(monthlyHistoryProvider(params));

    return Scaffold(
      backgroundColor: AppColors.white,
      body: RefreshIndicator(
        color: AppColors.red,
        onRefresh: () async {
          ref.invalidate(monthlyHistoryProvider(params));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Header Signature + Stats Card
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(
                      22,
                      MediaQuery.of(context).padding.top + 18,
                      22,
                      54,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.red,
                      borderRadius:
                          BorderRadius.vertical(bottom: Radius.circular(26)),
                    ),
                    child: const Text(
                      'Riwayat Absensi',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  // Floating Stats Card
                  Positioned(
                    left: 22,
                    right: 22,
                    bottom: -36,
                    child: _buildStatsCard(historyAsync),
                  ),
                ],
              ),

              const SizedBox(height: 52),

              // Record List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: historyAsync.when(
                  loading: () => const SizedBox(
                    height: 150,
                    child: Center(
                        child: CircularProgressIndicator(color: AppColors.red)),
                  ),
                  error: (e, _) => ErrorView(
                    message: 'Gagal memuat riwayat',
                    onRetry: () =>
                        ref.invalidate(monthlyHistoryProvider(params)),
                  ),
                  data: (records) {
                    if (records.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: EmptyView(
                          icon: Icons.receipt_long_rounded,
                          title: 'Belum ada riwayat absensi',
                          subtitle:
                              'Mulai absen hari ini untuk melihat riwayat',
                        ),
                      );
                    }

                    return Column(
                      children:
                          records.map((rec) => _buildRecordCard(rec)).toList(),
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

  Widget _buildStatsCard(AsyncValue<List<AttendanceRecord>> historyAsync) {
    int hadir = 0;
    int telat = 0;
    int absen = 0;

    historyAsync.whenData((records) {
      for (final r in records) {
        if (r.masuk != null) {
          final isLate = r.isLate;
          if (isLate) {
            telat++;
          } else {
            hadir++;
          }
        } else {
          absen++;
        }
      }
    });

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
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
          Expanded(
            child: _buildStatBlock(
              numStr: '$hadir',
              labelStr: 'HADIR',
              numColor: AppColors.green,
            ),
          ),
          Container(width: 1, height: 32, color: AppColors.line),
          Expanded(
            child: _buildStatBlock(
              numStr: '$telat',
              labelStr: 'TELAT',
              numColor: AppColors.amber,
            ),
          ),
          Container(width: 1, height: 32, color: AppColors.line),
          Expanded(
            child: _buildStatBlock(
              numStr: '$absen',
              labelStr: 'ABSEN',
              numColor: AppColors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBlock({
    required String numStr,
    required String labelStr,
    required Color numColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          numStr,
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: numColor,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          labelStr,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            color: AppColors.muted,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }

  Widget _buildRecordCard(AttendanceRecord record) {
    final isLate = record.isLate;
    final isAbsent = record.masuk == null;

    final Color stripColor;
    final String statusText;
    final Color statusTextColor;

    if (isAbsent) {
      stripColor = AppColors.red;
      statusText = 'Tidak Hadir';
      statusTextColor = AppColors.red;
    } else if (isLate) {
      stripColor = AppColors.amber;
      statusText = 'Terlambat';
      statusTextColor = AppColors.amber;
    } else {
      stripColor = AppColors.green;
      statusText = 'Hadir';
      statusTextColor = AppColors.green;
    }

    final formattedDate = AppDateUtils.formatDate(record.tanggalAbsensi);

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Left color strip
            Container(
              width: 4,
              color: stripColor,
            ),

            // Date & Status
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: statusTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Times (Check In)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    record.masuk ?? '—',
                    style: const TextStyle(
                      fontFamily: 'Space Mono',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  const Text(
                    'MASUK',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),

            // Times (Check Out)
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 12, 14, 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    record.keluar ?? '—',
                    style: const TextStyle(
                      fontFamily: 'Space Mono',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  const Text(
                    'PULANG',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.muted,
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
