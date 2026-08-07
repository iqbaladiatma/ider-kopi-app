/// Model KPI summary bulanan untuk karyawan (v2.0).
class KpiSummary {
  final int? id;
  final String userId;
  final int year;
  final int month;

  /// Total hari kerja di bulan tersebut (tidak termasuk hari libur & weekend).
  final int totalWorkingDays;

  /// Jumlah hari hadir (tepat waktu + terlambat).
  final int presentDays;

  /// Jumlah hari terlambat.
  final int lateDays;

  /// Jumlah hari alpha (tidak hadir tanpa izin).
  final int absentDays;

  /// Jumlah hari cuti/izin/sakit yang approved.
  final int leaveDays;

  /// Persentase kehadiran (0-100).
  final double attendanceRate;

  /// Persentase keterlambatan (0-100).
  final double lateRate;

  /// Skor KPI keseluruhan (0-100).
  /// Formula: (attendanceRate * 0.6) + ((100 - lateRate) * 0.3) + (leaveCompliance * 0.1)
  final double score;

  /// Performance grade berdasarkan score.
  final String grade;

  const KpiSummary({
    this.id,
    required this.userId,
    required this.year,
    required this.month,
    required this.totalWorkingDays,
    required this.presentDays,
    required this.lateDays,
    required this.absentDays,
    required this.leaveDays,
    required this.attendanceRate,
    required this.lateRate,
    required this.score,
    required this.grade,
  });

  /// Hitung grade dari score.
  static String gradeFromScore(double score) {
    if (score >= 90) return 'A';
    if (score >= 80) return 'B';
    if (score >= 70) return 'C';
    if (score >= 60) return 'D';
    return 'E';
  }

  /// Hitung score dari komponen.
  static double calculateScore({
    required double attendanceRate,
    required double lateRate,
    required int totalWorkingDays,
    required int leaveDays,
  }) {
    // Leave compliance: jika cuti ≤ 10% working days → 100, else proportional
    final leaveCompliance = totalWorkingDays == 0
        ? 100.0
        : ((totalWorkingDays - leaveDays) / totalWorkingDays * 100).clamp(0.0, 100.0).toDouble();

    return (attendanceRate * 0.6) + ((100 - lateRate) * 0.3) + (leaveCompliance * 0.1);
  }

  factory KpiSummary.fromJson(Map<String, dynamic> json) {
    final attendanceRate = (json['attendance_rate'] as num?)?.toDouble() ?? 0;
    final lateRate = (json['late_rate'] as num?)?.toDouble() ?? 0;
    final totalWorkingDays = (json['total_working_days'] as num?)?.toInt() ?? 0;
    final leaveDays = (json['leave_days'] as num?)?.toInt() ?? 0;
    final score = (json['score'] as num?)?.toDouble() ??
        calculateScore(
          attendanceRate: attendanceRate,
          lateRate: lateRate,
          totalWorkingDays: totalWorkingDays,
          leaveDays: leaveDays,
        );

    return KpiSummary(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      userId: json['user_id']?.toString() ?? '',
      year: (json['year'] as num?)?.toInt() ?? DateTime.now().year,
      month: (json['month'] as num?)?.toInt() ?? DateTime.now().month,
      totalWorkingDays: totalWorkingDays,
      presentDays: (json['present_days'] as num?)?.toInt() ?? 0,
      lateDays: (json['late_days'] as num?)?.toInt() ?? 0,
      absentDays: (json['absent_days'] as num?)?.toInt() ?? 0,
      leaveDays: leaveDays,
      attendanceRate: attendanceRate,
      lateRate: lateRate,
      score: score,
      grade: json['grade']?.toString() ?? gradeFromScore(score),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'year': year,
      'month': month,
      'total_working_days': totalWorkingDays,
      'present_days': presentDays,
      'late_days': lateDays,
      'absent_days': absentDays,
      'leave_days': leaveDays,
      'attendance_rate': attendanceRate,
      'late_rate': lateRate,
      'score': score,
      'grade': grade,
    };
  }

  @override
  String toString() =>
      'KpiSummary($userId, $year-$month, score=$score, grade=$grade)';
}
