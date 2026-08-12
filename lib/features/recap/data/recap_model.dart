import '../../../core/utils/date_utils.dart';

/// Status harian untuk recap.
enum RecapStatus {
  present, // hadir tepat waktu
  late, // hadir terlambat
  absent, // alpha (tidak hadir tanpa izin)
  leave, // cuti/izin/sakit
  holiday, // hari libur
  weekend, // weekend (Sabtu/Minggu)
  noData; // tidak ada data (future date atau belum check-in)

  String get label {
    switch (this) {
      case RecapStatus.present:
        return 'Tepat Waktu';
      case RecapStatus.late:
        return 'Terlambat';
      case RecapStatus.absent:
        return 'Alpha';
      case RecapStatus.leave:
        return 'Cuti/Izin';
      case RecapStatus.holiday:
        return 'Libur';
      case RecapStatus.weekend:
        return 'Weekend';
      case RecapStatus.noData:
        return 'Belum Absen';
    }
  }
}

/// Data recap harian untuk satu tanggal.
class RecapDay {
  final DateTime date;
  final RecapStatus status;
  final String? checkInTime;
  final String? checkOutTime;
  final String? outletName;

  const RecapDay({
    required this.date,
    required this.status,
    this.checkInTime,
    this.checkOutTime,
    this.outletName,
  });

  factory RecapDay.fromJson(Map<String, dynamic> json) {
    final dateStr = json['date']?.toString() ?? '';
    return RecapDay(
      date: dateStr.isNotEmpty ? DateTime.parse(dateStr) : DateTime.now(),
      status: _statusFromString(json['status']?.toString()),
      checkInTime: json['check_in_time']?.toString(),
      checkOutTime: json['check_out_time']?.toString(),
      outletName: json['outlet_name']?.toString(),
    );
  }

  static RecapStatus _statusFromString(String? s) {
    switch (s?.toLowerCase()) {
      case 'present':
      case 'tepat':
        return RecapStatus.present;
      case 'late':
      case 'terlambat':
        return RecapStatus.late;
      case 'absent':
      case 'alpha':
        return RecapStatus.absent;
      case 'leave':
      case 'cuti':
      case 'izin':
      case 'sakit':
        return RecapStatus.leave;
      case 'holiday':
      case 'libur':
        return RecapStatus.holiday;
      case 'weekend':
        return RecapStatus.weekend;
      default:
        return RecapStatus.noData;
    }
  }
}

/// Recap summary bulanan dengan agregasi.
class RecapSummary {
  final int year;
  final int month;
  final List<RecapDay> days;

  /// Agregat per minggu (4-5 minggu per bulan).
  final List<WeeklySummary> weeklySummaries;

  /// Distribusi status untuk pie chart.
  final Map<RecapStatus, int> statusDistribution;

  const RecapSummary({
    required this.year,
    required this.month,
    required this.days,
    required this.weeklySummaries,
    required this.statusDistribution,
  });

  int get totalDays => days.length;
  int get presentCount => statusDistribution[RecapStatus.present] ?? 0;
  int get lateCount => statusDistribution[RecapStatus.late] ?? 0;
  int get absentCount => statusDistribution[RecapStatus.absent] ?? 0;
  int get leaveCount => statusDistribution[RecapStatus.leave] ?? 0;
  int get holidayCount => statusDistribution[RecapStatus.holiday] ?? 0;
}

/// Summary per minggu.
class WeeklySummary {
  final int weekNumber;
  final DateTime startDate;
  final DateTime endDate;
  final int presentDays;
  final int lateDays;
  final int absentDays;

  const WeeklySummary({
    required this.weekNumber,
    required this.startDate,
    required this.endDate,
    required this.presentDays,
    required this.lateDays,
    required this.absentDays,
  });

  int get totalWorkingDays => presentDays + lateDays + absentDays;
}

/// Helper untuk build recap dari list record absensi.
class RecapBuilder {
  /// Build RecapSummary dari list harian untuk bulan tertentu.
  static RecapSummary build({
    required int year,
    required int month,
    required List<RecapDay> days,
  }) {
    // Sort by date
    final sorted = List<RecapDay>.from(days)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Build status distribution
    final distribution = <RecapStatus, int>{};
    for (final d in sorted) {
      distribution[d.status] = (distribution[d.status] ?? 0) + 1;
    }

    // Build weekly summaries (week 1 = day 1-7, week 2 = day 8-14, etc.)
    final weeklySummaries = <WeeklySummary>[];
    for (int weekStart = 1; weekStart <= 31; weekStart += 7) {
      final weekEnd = (weekStart + 6).clamp(1, 31);
      final weekDays = sorted
          .where((d) => d.date.day >= weekStart && d.date.day <= weekEnd)
          .toList();
      if (weekDays.isEmpty) continue;

      final weekNum = (weekStart / 7).ceil() + 1;
      weeklySummaries.add(WeeklySummary(
        weekNumber: weekNum,
        startDate: DateTime(year, month, weekStart),
        endDate: DateTime(year, month, weekEnd),
        presentDays:
            weekDays.where((d) => d.status == RecapStatus.present).length,
        lateDays: weekDays.where((d) => d.status == RecapStatus.late).length,
        absentDays:
            weekDays.where((d) => d.status == RecapStatus.absent).length,
      ));
    }

    return RecapSummary(
      year: year,
      month: month,
      days: sorted,
      weeklySummaries: weeklySummaries,
      statusDistribution: distribution,
    );
  }

  /// Generate mock recap untuk development.
  static RecapSummary mockFor(int year, int month) {
    final daysInMonth = AppDateUtils.daysInMonth(year, month);
    final now = DateTime.now();
    final days = <RecapDay>[];

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final isFuture = date.isAfter(now);
      final weekday = date.weekday;

      if (isFuture) {
        days.add(RecapDay(date: date, status: RecapStatus.noData));
      } else if (weekday == DateTime.saturday || weekday == DateTime.sunday) {
        days.add(RecapDay(date: date, status: RecapStatus.weekend));
      } else if (day == 17) {
        // Hari Kemerdekaan
        days.add(RecapDay(date: date, status: RecapStatus.holiday));
      } else if (day % 7 == 0) {
        days.add(RecapDay(
          date: date,
          status: RecapStatus.late,
          checkInTime: '09:15',
          checkOutTime: '17:05',
          outletName: 'IderKopi',
        ));
      } else if (day == 10) {
        days.add(RecapDay(date: date, status: RecapStatus.leave));
      } else if (day % 13 == 0 && day > 1) {
        days.add(RecapDay(date: date, status: RecapStatus.absent));
      } else {
        days.add(RecapDay(
          date: date,
          status: RecapStatus.present,
          checkInTime: '07:45',
          checkOutTime: '17:10',
          outletName: 'IderKopi',
        ));
      }
    }

    return build(year: year, month: month, days: days);
  }
}
