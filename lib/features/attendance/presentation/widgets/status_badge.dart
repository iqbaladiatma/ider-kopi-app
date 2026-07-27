import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/attendance_model.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.status,
    this.size = StatusBadgeSize.normal,
  });

  final AttendanceStatus status;
  final StatusBadgeSize size;

  @override
  Widget build(BuildContext context) {
    final (bgColor, textColor, label) = switch (status) {
      AttendanceStatus.tepatWaktu =>
        (AppColors.successLight, AppColors.success, 'Tepat Waktu'),
      AttendanceStatus.terlambat =>
        (AppColors.warningLight, AppColors.warningDark, 'Terlambat'),
      AttendanceStatus.alpha =>
        (AppColors.errorLight, AppColors.error, 'Alpha'),
      AttendanceStatus.belumAbsen =>
        (AppColors.surfaceAlt, AppColors.textMuted, 'Belum Absen'),
    };

    final (hPad, vPad, fontSize, radius, dotSize) = switch (size) {
      StatusBadgeSize.small => (6.0, 2.0, 10.0, 4.0, 5.0),
      StatusBadgeSize.normal => (8.0, 4.0, 12.0, 6.0, 6.0),
      StatusBadgeSize.large => (12.0, 6.0, 14.0, 8.0, 7.0),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              color: textColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: hPad * 0.5),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

enum StatusBadgeSize { small, normal, large }
