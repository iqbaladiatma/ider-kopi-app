import 'package:flutter_test/flutter_test.dart';
import 'package:iderkopi_absensi/features/recap/data/recap_model.dart';

void main() {
  group('RecapStatus', () {
    test('label is correct', () {
      expect(RecapStatus.present.label, 'Tepat Waktu');
      expect(RecapStatus.late.label, 'Terlambat');
      expect(RecapStatus.absent.label, 'Alpha');
      expect(RecapStatus.leave.label, 'Cuti/Izin');
    });
  });

  group('RecapDay', () {
    test('fromJson parses correctly', () {
      final json = {
        'date': '2026-08-15',
        'status': 'present',
        'check_in_time': '07:45',
        'check_out_time': '17:10',
        'outlet_name': 'IderKopi - Head Office',
      };
      final day = RecapDay.fromJson(json);
      expect(day.date, DateTime(2026, 8, 15));
      expect(day.status, RecapStatus.present);
      expect(day.checkInTime, '07:45');
      expect(day.checkOutTime, '17:10');
      expect(day.outletName, 'IderKopi - Head Office');
    });

    test('fromJson handles missing fields', () {
      final day = RecapDay.fromJson({});
      expect(day.status, RecapStatus.noData);
      expect(day.checkInTime, isNull);
    });
  });

  group('RecapBuilder', () {
    test('build creates correct distribution', () {
      final days = [
        RecapDay(date: DateTime(2026, 8, 1), status: RecapStatus.present),
        RecapDay(date: DateTime(2026, 8, 2), status: RecapStatus.present),
        RecapDay(date: DateTime(2026, 8, 3), status: RecapStatus.late),
        RecapDay(date: DateTime(2026, 8, 4), status: RecapStatus.absent),
        RecapDay(date: DateTime(2026, 8, 5), status: RecapStatus.leave),
      ];

      final recap = RecapBuilder.build(year: 2026, month: 8, days: days);

      expect(recap.year, 2026);
      expect(recap.month, 8);
      expect(recap.totalDays, 5);
      expect(recap.presentCount, 2);
      expect(recap.lateCount, 1);
      expect(recap.absentCount, 1);
      expect(recap.leaveCount, 1);
    });

    test('build creates weekly summaries', () {
      final days = [
        RecapDay(date: DateTime(2026, 8, 1), status: RecapStatus.present),
        RecapDay(date: DateTime(2026, 8, 3), status: RecapStatus.late),
        RecapDay(date: DateTime(2026, 8, 8), status: RecapStatus.present),
      ];

      final recap = RecapBuilder.build(year: 2026, month: 8, days: days);

      expect(recap.weeklySummaries.length, greaterThan(0));
      final week1 = recap.weeklySummaries.first;
      expect(week1.presentDays, 1);
      expect(week1.lateDays, 1);
    });

    test('mockFor generates data for full month', () {
      final recap = RecapBuilder.mockFor(2026, 8);
      expect(recap.totalDays, 31); // August has 31 days
      expect(recap.statusDistribution.length, greaterThan(0));
    });
  });

  group('WeeklySummary', () {
    test('totalWorkingDays sums components', () {
      final week = WeeklySummary(
        weekNumber: 1,
        startDate: DateTime(2026, 8, 1),
        endDate: DateTime(2026, 8, 7),
        presentDays: 3,
        lateDays: 1,
        absentDays: 1,
      );
      expect(week.totalWorkingDays, 5);
    });
  });
}
