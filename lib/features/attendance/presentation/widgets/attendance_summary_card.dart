import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/attendance_model.dart';
import 'status_badge.dart';

class AttendanceSummaryCard extends StatelessWidget {
  const AttendanceSummaryCard({super.key, required this.record});

  final AttendanceRecord record;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status Hari Ini',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatusRow(
              'Check In',
              record.hasCheckedIn ? record.masuk! : 'Belum',
              record.hasCheckedIn,
            ),
            const Divider(height: 24),
            _buildStatusRow(
              'Check Out',
              record.hasCheckedOut ? record.pulang! : 'Belum',
              record.hasCheckedOut,
              isWaiting: record.hasCheckedIn && !record.hasCheckedOut,
            ),
            const SizedBox(height: 12),
            StatusBadge(status: record.status),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(
    String label,
    String value,
    bool isDone, {
    bool isWaiting = false,
  }) {
    final color = isDone
        ? AppColors.success
        : isWaiting
            ? AppColors.warning
            : AppColors.error;

    final icon = isDone
        ? Icons.check_circle
        : isWaiting
            ? Icons.hourglass_empty
            : Icons.radio_button_unchecked;

    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
