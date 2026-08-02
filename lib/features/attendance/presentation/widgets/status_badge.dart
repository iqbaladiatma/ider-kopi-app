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
    final (bgColor, textColor, label, icon) = switch (status) {
      AttendanceStatus.tepatWaktu => (
        AppColors.successLight,
        AppColors.successDark,
        'Tepat Waktu',
        Icons.check_circle_rounded,
      ),
      AttendanceStatus.terlambat => (
        AppColors.warningLight,
        AppColors.warningDark,
        'Terlambat',
        Icons.schedule_rounded,
      ),
      AttendanceStatus.alpha => (
        AppColors.errorLight,
        AppColors.errorDark,
        'Alpha',
        Icons.cancel_rounded,
      ),
      AttendanceStatus.belumAbsen => (
        AppColors.surfaceAlt,
        AppColors.textMuted,
        'Belum Absen',
        Icons.radio_button_unchecked_rounded,
      ),
    };

    final (hPad, vPad, fontSize, radius, iconSize) = switch (size) {
      StatusBadgeSize.small => (6.0, 3.0, 10.0, 6.0, 9.0),
      StatusBadgeSize.normal => (10.0, 5.0, 12.0, 8.0, 11.0),
      StatusBadgeSize.large => (14.0, 7.0, 13.0, 10.0, 13.0),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: textColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: iconSize),
          SizedBox(width: hPad * 0.5),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

enum StatusBadgeSize { small, normal, large }
