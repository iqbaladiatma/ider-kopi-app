import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/attendance_model.dart';
import 'status_badge.dart';

class AttendanceSummaryCard extends StatelessWidget {
  const AttendanceSummaryCard({super.key, required this.record});

  final AttendanceRecord record;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.today_rounded,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                'Status Hari Ini',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.1,
                ),
              ),
              const Spacer(),
              StatusBadge(status: record.status),
            ],
          ),
          const SizedBox(height: 18),
          _buildTimeRow(
            label: 'Check In',
            time: record.hasCheckedIn ? record.masuk! : 'Belum',
            isDone: record.hasCheckedIn,
            icon: Icons.login_rounded,
          ),
          const Divider(height: 20, color: AppColors.borderLight),
          _buildTimeRow(
            label: 'Check Out',
            time: record.hasCheckedOut ? record.pulang! : 'Belum',
            isDone: record.hasCheckedOut,
            isWaiting: record.hasCheckedIn && !record.hasCheckedOut,
            icon: Icons.logout_rounded,
          ),
          if (record.keterangan != null && record.keterangan!.isNotEmpty) ...[
            const Divider(height: 20, color: AppColors.borderLight),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notes_rounded,
                      size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Keterangan: ${record.keterangan!}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeRow({
    required String label,
    required String time,
    required bool isDone,
    bool isWaiting = false,
    required IconData icon,
  }) {
    final color = isDone
        ? AppColors.success
        : isWaiting
            ? AppColors.warning
            : AppColors.textMuted;

    final bgColor = isDone
        ? AppColors.successLight
        : isWaiting
            ? AppColors.warningLight
            : AppColors.surfaceAlt;

    final actualIcon = isDone
        ? Icons.check_circle_rounded
        : isWaiting
            ? Icons.hourglass_empty_rounded
            : icon;

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(actualIcon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            time,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
