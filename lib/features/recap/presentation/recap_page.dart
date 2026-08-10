import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../data/recap_model.dart';
import '../providers/recap_providers.dart';
import 'widgets/attendance_bar_chart.dart';
import 'widgets/status_pie_chart.dart';

class RecapPage extends ConsumerStatefulWidget {
  const RecapPage({super.key});

  @override
  ConsumerState<RecapPage> createState() => _RecapPageState();
}

class _RecapPageState extends ConsumerState<RecapPage> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final recapAsync = ref.watch(monthlyRecapProvider(
      (year: _selectedMonth.year, month: _selectedMonth.month),
    ));

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Rekap Bulanan',
            style: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.ink,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/profile'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildMonthPicker(),
          const SizedBox(height: 20),
          recapAsync.when(
            data: (recap) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary stats
                _buildSummaryRow(recap),
                const SizedBox(height: 20),
                // Bar chart
                AttendanceBarChart(weeklySummaries: recap.weeklySummaries),
                const SizedBox(height: 16),
                // Pie chart
                StatusPieChart(distribution: recap.statusDistribution),
                const SizedBox(height: 20),
                // Detail table
                _buildDetailTable(recap),
              ],
            ),
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(
                    color: AppColors.red, strokeWidth: 2),
              ),
            ),
            error: (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Text('Gagal memuat recap: $e',
                    style: const TextStyle(color: AppColors.red)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthPicker() {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedMonth,
          firstDate: DateTime(2024, 1),
          lastDate: DateTime.now(),
          helpText: 'Pilih bulan',
          initialDatePickerMode: DatePickerMode.year,
        );
        if (picked != null) {
          setState(() => _selectedMonth = picked);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.ink.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month_rounded,
                color: AppColors.red, size: 18),
            const SizedBox(width: 12),
            Text(
              AppDateUtils.formatMonthYear(_selectedMonth),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.ink, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(RecapSummary recap) {
    return Row(
      children: [
        _StatCard(
          label: 'Hadir',
          value: recap.presentCount,
          color: AppColors.green,
        ),
        const SizedBox(width: 8),
        _StatCard(
          label: 'Terlambat',
          value: recap.lateCount,
          color: AppColors.amber,
        ),
        const SizedBox(width: 8),
        _StatCard(
          label: 'Alpha',
          value: recap.absentCount,
          color: AppColors.red,
        ),
        const SizedBox(width: 8),
        _StatCard(
          label: 'Cuti',
          value: recap.leaveCount,
          color: AppColors.ink,
        ),
      ],
    );
  }

  Widget _buildDetailTable(RecapSummary recap) {
    final workingDays = recap.days
        .where((d) =>
            d.status != RecapStatus.weekend &&
            d.status != RecapStatus.holiday &&
            d.status != RecapStatus.noData)
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.ink.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Detail per Hari',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                )),
          ),
          const Divider(height: 1),
          if (workingDays.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text('Tidak ada data absensi',
                    style: TextStyle(color: AppColors.ink)),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: workingDays.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: AppColors.ink.withValues(alpha: 0.05),
              ),
              itemBuilder: (_, i) {
                final day = workingDays[i];
                return _DetailRow(day: day);
              },
            ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text('$value',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: color,
                )),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                )),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final RecapDay day;
  const _DetailRow({required this.day});

  Color get _statusColor {
    switch (day.status) {
      case RecapStatus.present:
        return AppColors.green;
      case RecapStatus.late:
        return AppColors.amber;
      case RecapStatus.absent:
        return AppColors.red;
      case RecapStatus.leave:
        return AppColors.ink;
      case RecapStatus.holiday:
        return AppColors.ink;
      case RecapStatus.weekend:
        return AppColors.ink;
      case RecapStatus.noData:
        return AppColors.ink;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Date
          SizedBox(
            width: 50,
            child: Text(
              '${day.date.day}/${day.date.month}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
          ),
          // Times
          SizedBox(
            width: 100,
            child: Text(
              day.checkInTime != null
                  ? '${day.checkInTime} - ${day.checkOutTime ?? '-'}'
                  : '-',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.ink.withValues(alpha: 0.7),
              ),
            ),
          ),
          // Status
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  day.status.label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _statusColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
