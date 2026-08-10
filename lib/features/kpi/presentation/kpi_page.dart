import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../data/kpi_model.dart';
import '../providers/kpi_providers.dart';

class KpiPage extends ConsumerStatefulWidget {
  const KpiPage({super.key});

  @override
  ConsumerState<KpiPage> createState() => _KpiPageState();
}

class _KpiPageState extends ConsumerState<KpiPage> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
  }

  Color get _scoreColor {
    final async = ref.watch(myKpiProvider(
      (year: _selectedMonth.year, month: _selectedMonth.month),
    ));
    final kpi = async.valueOrNull;
    if (kpi == null) return AppColors.ink;
    if (kpi.score >= 90) return AppColors.green;
    if (kpi.score >= 70) return AppColors.amber;
    return AppColors.red;
  }

  @override
  Widget build(BuildContext context) {
    final kpiAsync = ref.watch(myKpiProvider(
      (year: _selectedMonth.year, month: _selectedMonth.month),
    ));

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('KPI Saya',
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
          // Month picker
          _buildMonthPicker(),
          const SizedBox(height: 20),

          kpiAsync.when(
            data: (kpi) => Column(
              children: [
                _buildScoreCard(kpi),
                const SizedBox(height: 20),
                _buildBreakdown(kpi),
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
                child: Text('Gagal memuat KPI: $e',
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

  Widget _buildScoreCard(KpiSummary kpi) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _scoreColor.withValues(alpha: 0.1),
            _scoreColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _scoreColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          const Text('Skor KPI Bulan Ini',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              )),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                kpi.score.toStringAsFixed(1),
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 56,
                  fontWeight: FontWeight.w800,
                  color: _scoreColor,
                  height: 1,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text('/ 100',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.ink,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: _scoreColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              'Grade ${kpi.grade}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: _scoreColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdown(KpiSummary kpi) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Rincian',
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            )),
        const SizedBox(height: 12),
        _BreakdownItem(
          icon: Icons.work_rounded,
          color: AppColors.ink,
          label: 'Total Hari Kerja',
          value: '${kpi.totalWorkingDays} hari',
        ),
        _BreakdownItem(
          icon: Icons.check_circle_rounded,
          color: AppColors.green,
          label: 'Hadir',
          value: '${kpi.presentDays} hari',
        ),
        _BreakdownItem(
          icon: Icons.access_time_rounded,
          color: AppColors.amber,
          label: 'Terlambat',
          value: '${kpi.lateDays} hari',
        ),
        _BreakdownItem(
          icon: Icons.cancel_rounded,
          color: AppColors.red,
          label: 'Alpha',
          value: '${kpi.absentDays} hari',
        ),
        _BreakdownItem(
          icon: Icons.event_available_rounded,
          color: AppColors.ink,
          label: 'Cuti/Izin/Sakit',
          value: '${kpi.leaveDays} hari',
        ),
        const Divider(height: 32),
        _BreakdownItem(
          icon: Icons.trending_up_rounded,
          color: AppColors.green,
          label: 'Tingkat Kehadiran',
          value: '${kpi.attendanceRate.toStringAsFixed(1)}%',
        ),
        _BreakdownItem(
          icon: Icons.trending_down_rounded,
          color: AppColors.amber,
          label: 'Tingkat Keterlambatan',
          value: '${kpi.lateRate.toStringAsFixed(1)}%',
        ),
      ],
    );
  }
}

class _BreakdownItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _BreakdownItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.ink,
                )),
          ),
          Text(value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              )),
        ],
      ),
    );
  }
}
