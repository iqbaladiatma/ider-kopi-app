import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../data/shift_model.dart';
import '../providers/shift_providers.dart';

class ShiftSchedulePage extends ConsumerStatefulWidget {
  const ShiftSchedulePage({super.key});

  @override
  ConsumerState<ShiftSchedulePage> createState() => _ShiftSchedulePageState();
}

class _ShiftSchedulePageState extends ConsumerState<ShiftSchedulePage> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final shiftsAsync = ref.watch(myShiftsProvider(
      (year: _selectedMonth.year, month: _selectedMonth.month),
    ));

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Jadwal Shift',
            style: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.ink,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildMonthPicker(),
          const SizedBox(height: 20),
          shiftsAsync.when(
            data: (shifts) => _buildCalendar(shifts),
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
                child: Text('Gagal memuat jadwal: $e',
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
          lastDate: DateTime.now().add(const Duration(days: 90)),
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

  Widget _buildCalendar(List<UserShift> shifts) {
    final daysInMonth = AppDateUtils.daysInMonth(
        _selectedMonth.year, _selectedMonth.month);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Map: day -> UserShift
    final shiftMap = <int, UserShift>{};
    for (final s in shifts) {
      if (s.date.year == _selectedMonth.year &&
          s.date.month == _selectedMonth.month) {
        shiftMap[s.date.day] = s;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day headers
        Row(
          children: ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min']
              .map((d) => Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(d,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink.withValues(alpha: 0.5),
                            )),
                      ),
                    ),
                  ))
              .toList(),
        ),
        // Calendar grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 0.85,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemCount: daysInMonth + _firstWeekdayOffset(),
          itemBuilder: (_, index) {
            if (index < _firstWeekdayOffset()) {
              return const SizedBox.shrink();
            }
            final day = index - _firstWeekdayOffset() + 1;
            final date = DateTime(_selectedMonth.year, _selectedMonth.month, day);
            final isToday = date == today;
            final isPast = date.isBefore(today);
            final isWeekend = date.weekday == DateTime.saturday ||
                date.weekday == DateTime.sunday;
            final shift = shiftMap[day];

            return _CalendarCell(
              day: day,
              isToday: isToday,
              isPast: isPast,
              isWeekend: isWeekend,
              shift: shift,
            );
          },
        ),
        const SizedBox(height: 20),
        // Legend
        _buildLegend(),
        const SizedBox(height: 16),
        // Upcoming shifts list
        _buildUpcomingShifts(shifts, today),
      ],
    );
  }

  int _firstWeekdayOffset() {
    // Monday = 1, Sunday = 7 → offset = weekday - 1
    final firstDay = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    return firstDay.weekday - 1;
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _LegendItem(color: AppColors.green, label: 'Pagi'),
        _LegendItem(color: AppColors.amber, label: 'Siang'),
        _LegendItem(color: AppColors.ink, label: 'Malam'),
        _LegendItem(color: AppColors.ink.withValues(alpha: 0.1), label: 'Libur'),
      ],
    );
  }

  Widget _buildUpcomingShifts(List<UserShift> shifts, DateTime today) {
    final upcoming = shifts
        .where((s) =>
            s.date.isAfter(today.subtract(const Duration(days: 1))) &&
            s.shift != null)
        .take(5)
        .toList();

    if (upcoming.isEmpty) {
      return const SizedBox.shrink();
    }

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
          const Text('Shift Mendatang',
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              )),
          const SizedBox(height: 12),
          ...upcoming.map((s) => _UpcomingShiftItem(shift: s)),
        ],
      ),
    );
  }
}

class _CalendarCell extends StatelessWidget {
  final int day;
  final bool isToday;
  final bool isPast;
  final bool isWeekend;
  final UserShift? shift;

  const _CalendarCell({
    required this.day,
    required this.isToday,
    required this.isPast,
    required this.isWeekend,
    this.shift,
  });

  Color get _shiftColor {
    if (shift?.shift == null) return AppColors.ink.withValues(alpha: 0.05);
    final name = shift!.shift!.name.toLowerCase();
    if (name.contains('pagi')) return AppColors.green;
    if (name.contains('siang')) return AppColors.amber;
    if (name.contains('malam')) return AppColors.ink;
    return AppColors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: shift != null ? _shiftColor.withValues(alpha: 0.1) : null,
        borderRadius: BorderRadius.circular(8),
        border: isToday
            ? Border.all(color: AppColors.red, width: 2)
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$day',
            style: TextStyle(
              fontSize: 12,
              fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
              color: isToday
                  ? AppColors.red
                  : isWeekend
                      ? AppColors.ink.withValues(alpha: 0.4)
                      : isPast
                          ? AppColors.ink.withValues(alpha: 0.5)
                          : AppColors.ink,
            ),
          ),
          if (shift != null && shift!.shift != null) ...[
            const SizedBox(height: 2),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: _shiftColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              shift!.shift!.name.substring(0, 1),
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: _shiftColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

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

class _UpcomingShiftItem extends StatelessWidget {
  final UserShift shift;
  const _UpcomingShiftItem({required this.shift});

  @override
  Widget build(BuildContext context) {
    final s = shift.shift!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.access_time_rounded,
                color: AppColors.red, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    )),
                Text(
                  '${shift.date.day}/${shift.date.month}/${shift.date.year}',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.ink.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${s.startTime.hour.toString().padLeft(2, '0')}:${s.startTime.minute.toString().padLeft(2, '0')} - '
            '${s.endTime.hour.toString().padLeft(2, '0')}:${s.endTime.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
