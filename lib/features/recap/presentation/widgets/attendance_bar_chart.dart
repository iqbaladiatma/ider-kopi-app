import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/recap_model.dart';

/// Bar chart kehadiran per minggu.
class AttendanceBarChart extends StatelessWidget {
  final List<WeeklySummary> weeklySummaries;

  const AttendanceBarChart({super.key, required this.weeklySummaries});

  @override
  Widget build(BuildContext context) {
    if (weeklySummaries.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('Tidak ada data')),
      );
    }

    final maxY = weeklySummaries
        .map((w) => w.totalWorkingDays.toDouble())
        .fold(0.0, (a, b) => a > b ? a : b);

    return Container(
      height: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.ink.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Kehadiran per Minggu',
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              )),
          const SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (maxY + 1).clamp(5.0, 10.0),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIdx, rod, rodIdx) {
                      final week = weeklySummaries[groupIdx];
                      return BarTooltipItem(
                        'Minggu ${week.weekNumber}\n'
                        'Hadir: ${week.presentDays}\n'
                        'Terlambat: ${week.lateDays}\n'
                        'Alpha: ${week.absentDays}',
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= weeklySummaries.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text('W${weeklySummaries[idx].weekNumber}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink,
                              )),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        if (value % 1 != 0) return const SizedBox.shrink();
                        return Text('${value.toInt()}',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.ink.withValues(alpha: 0.5),
                            ));
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 2,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.ink.withValues(alpha: 0.05),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: weeklySummaries.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final week = entry.value;
                  return BarChartGroupData(
                    x: idx,
                    barRods: [
                      BarChartRodData(
                        toY: week.totalWorkingDays.toDouble(),
                        color: AppColors.red,
                        width: 22,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                        rodStackItems: [
                          BarChartRodStackItem(
                            0,
                            week.presentDays.toDouble(),
                            AppColors.green,
                          ),
                          BarChartRodStackItem(
                            week.presentDays.toDouble(),
                            (week.presentDays + week.lateDays).toDouble(),
                            AppColors.amber,
                          ),
                          BarChartRodStackItem(
                            (week.presentDays + week.lateDays).toDouble(),
                            week.totalWorkingDays.toDouble(),
                            AppColors.red,
                          ),
                        ],
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(color: AppColors.green, label: 'Tepat'),
              const SizedBox(width: 12),
              _LegendDot(color: AppColors.amber, label: 'Terlambat'),
              const SizedBox(width: 12),
              _LegendDot(color: AppColors.red, label: 'Alpha'),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            )),
      ],
    );
  }
}
