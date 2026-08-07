import 'package:flutter_test/flutter_test.dart';
import 'package:iderkopi_absensi/features/kpi/data/kpi_model.dart';

void main() {
  group('KpiSummary', () {
    test('gradeFromScore returns correct grade', () {
      expect(KpiSummary.gradeFromScore(95), 'A');
      expect(KpiSummary.gradeFromScore(90), 'A');
      expect(KpiSummary.gradeFromScore(89.9), 'B');
      expect(KpiSummary.gradeFromScore(80), 'B');
      expect(KpiSummary.gradeFromScore(75), 'C');
      expect(KpiSummary.gradeFromScore(70), 'C');
      expect(KpiSummary.gradeFromScore(65), 'D');
      expect(KpiSummary.gradeFromScore(60), 'D');
      expect(KpiSummary.gradeFromScore(50), 'E');
    });

    test('calculateScore computes weighted score', () {
      final score = KpiSummary.calculateScore(
        attendanceRate: 100,
        lateRate: 0,
        totalWorkingDays: 22,
        leaveDays: 0,
      );
      // (100*0.6) + (100*0.3) + (100*0.1) = 100
      expect(score, closeTo(100, 0.01));
    });

    test('calculateScore with late & leave', () {
      final score = KpiSummary.calculateScore(
        attendanceRate: 90,    // 20/22 hadir
        lateRate: 15,          // 3/20 terlambat
        totalWorkingDays: 22,
        leaveDays: 2,
      );
      // (90*0.6) + (85*0.3) + (((22-2)/22)*100 * 0.1)
      // = 54 + 25.5 + (90.9 * 0.1) = 54 + 25.5 + 9.09 = 88.59
      expect(score, closeTo(88.59, 0.1));
    });

    test('calculateScore with zero working days', () {
      final score = KpiSummary.calculateScore(
        attendanceRate: 0,
        lateRate: 0,
        totalWorkingDays: 0,
        leaveDays: 0,
      );
      // (0*0.6) + (100*0.3) + (100*0.1) = 0 + 30 + 10 = 40
      expect(score, closeTo(40, 0.01));
    });

    test('fromJson parses all fields', () {
      final json = {
        'id': 1,
        'user_id': 'usr-0012',
        'year': 2026,
        'month': 8,
        'total_working_days': 22,
        'present_days': 20,
        'late_days': 3,
        'absent_days': 1,
        'leave_days': 1,
        'attendance_rate': 90.9,
        'late_rate': 15.0,
        'score': 85.5,
        'grade': 'B',
      };
      final kpi = KpiSummary.fromJson(json);
      expect(kpi.id, 1);
      expect(kpi.userId, 'usr-0012');
      expect(kpi.year, 2026);
      expect(kpi.month, 8);
      expect(kpi.totalWorkingDays, 22);
      expect(kpi.presentDays, 20);
      expect(kpi.lateDays, 3);
      expect(kpi.absentDays, 1);
      expect(kpi.leaveDays, 1);
      expect(kpi.attendanceRate, 90.9);
      expect(kpi.score, 85.5);
      expect(kpi.grade, 'B');
    });

    test('fromJson computes score if missing', () {
      final json = {
        'user_id': 'u',
        'year': 2026,
        'month': 8,
        'total_working_days': 22,
        'present_days': 22,
        'late_days': 0,
        'absent_days': 0,
        'leave_days': 0,
        'attendance_rate': 100.0,
        'late_rate': 0.0,
      };
      final kpi = KpiSummary.fromJson(json);
      expect(kpi.score, closeTo(100, 0.01));
      expect(kpi.grade, 'A');
    });

    test('toJson round-trips', () {
      const kpi = KpiSummary(
        id: 5,
        userId: 'usr-0012',
        year: 2026,
        month: 8,
        totalWorkingDays: 22,
        presentDays: 20,
        lateDays: 3,
        absentDays: 1,
        leaveDays: 1,
        attendanceRate: 90.9,
        lateRate: 15.0,
        score: 85.5,
        grade: 'B',
      );
      final json = kpi.toJson();
      expect(json['id'], 5);
      expect(json['user_id'], 'usr-0012');
      expect(json['year'], 2026);
      expect(json['score'], 85.5);
    });
  });
}
