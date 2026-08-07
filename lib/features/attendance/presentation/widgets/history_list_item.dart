import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_utils.dart';
import '../../data/attendance_model.dart';
import 'status_badge.dart';

class HistoryListItem extends StatelessWidget {
  const HistoryListItem({super.key, required this.record, this.selfieUrl});

  final AttendanceRecord record;
  final String? selfieUrl;

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(record.tanggalAbsensi);
    final dateLabel = date != null ? AppDateUtils.formatDate(date) : record.tanggalAbsensi;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildSelfieThumbnail(),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        dateLabel,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ),
                    StatusBadge(status: record.status, size: StatusBadgeSize.small),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildTimeChip(
                      Icons.login_rounded,
                      AppDateUtils.formatTimeShort(record.masuk),
                      record.hasCheckedIn,
                      isCheckIn: true,
                    ),
                    const SizedBox(width: 8),
                    _buildTimeChip(
                      Icons.logout_rounded,
                      AppDateUtils.formatTimeShort(record.pulang),
                      record.hasCheckedOut,
                      isCheckIn: false,
                    ),
                  ],
                ),
                if (record.keterangan != null && record.keterangan!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.notes_rounded, size: 13, color: AppColors.primary),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          record.keterangan!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeChip(IconData icon, String time, bool isDone, {required bool isCheckIn}) {
    final color = isDone ? AppColors.success : AppColors.textMuted;
    final bgColor = isDone
        ? AppColors.successLight
        : AppColors.surfaceAlt;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            time,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelfieThumbnail() {
    if (selfieUrl != null && selfieUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: CachedNetworkImage(
          imageUrl: selfieUrl!,
          width: 52,
          height: 52,
          fit: BoxFit.cover,
          placeholder: (_, __) => _buildPlaceholder(),
          errorWidget: (_, __, ___) => _buildPlaceholder(),
        ),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.surfaceAlt, AppColors.gray100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: const Icon(Icons.person_rounded, size: 24, color: AppColors.textLight),
    );
  }
}
