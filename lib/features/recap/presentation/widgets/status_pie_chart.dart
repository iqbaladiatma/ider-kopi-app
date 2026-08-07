import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/recap_model.dart';

/// Pie chart distribusi status absensi.
class StatusPieChart extends StatelessWidget {
  final Map<RecapStatus, int> distribution;

  const StatusPieChart({super.key, required this.distribution});

  @override
  Widget build(BuildContext context) {
    final segments = _buildSegments();
    if (segments.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('Tidak ada data')),
      );
    }

    final total = segments.fold(0, (a, s) => a + s.value);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.ink.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Distribusi Status',
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              )),
          const SizedBox(height: 16),
          Row(
            children: [
              // Pie chart
              SizedBox(
                height: 160,
                width: 160,
                child: PieChart(
                  PieChartData(
                    sections: segments
                        .map((s) => PieChartSectionData(
                              value: s.value.toDouble(),
                              color: s.color,
                              radius: 50,
                              title: s.value > 0
                                  ? '${(s.value / total * 100).round()}%'
                                  : '',
                              titleStyle: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ))
                        .toList(),
                    centerSpaceRadius: 30,
                    sectionsSpace: 2,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Legend
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: segments
                      .where((s) => s.value > 0)
                      .map((s) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: s.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(s.label,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.ink,
                                      )),
                                ),
                                Text('${s.value}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.ink,
                                    )),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<_Segment> _buildSegments() {
    return [
      _Segment(
        status: RecapStatus.present,
        label: RecapStatus.present.label,
        value: distribution[RecapStatus.present] ?? 0,
        color: AppColors.green,
      ),
      _Segment(
        status: RecapStatus.late,
        label: RecapStatus.late.label,
        value: distribution[RecapStatus.late] ?? 0,
        color: AppColors.amber,
      ),
      _Segment(
        status: RecapStatus.absent,
        label: RecapStatus.absent.label,
        value: distribution[RecapStatus.absent] ?? 0,
        color: AppColors.red,
      ),
      _Segment(
        status: RecapStatus.leave,
        label: RecapStatus.leave.label,
        value: distribution[RecapStatus.leave] ?? 0,
        color: AppColors.ink,
      ),
      _Segment(
        status: RecapStatus.holiday,
        label: RecapStatus.holiday.label,
        value: distribution[RecapStatus.holiday] ?? 0,
        color: AppColors.ink.withValues(alpha: 0.3),
      ),
    ];
  }
}

class _Segment {
  final RecapStatus status;
  final String label;
  final int value;
  final Color color;

  const _Segment({
    required this.status,
    required this.label,
    required this.value,
    required this.color,
  });
}
