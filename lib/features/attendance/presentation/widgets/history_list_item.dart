import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSelfieThumbnail(),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateLabel,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildTimeRow('Masuk', AppDateUtils.formatTimeShort(record.masuk),
                      record.hasCheckedIn, Icons.login_rounded),
                  const SizedBox(height: 6),
                  _buildTimeRow('Pulang', AppDateUtils.formatTimeShort(record.pulang),
                      record.hasCheckedOut, Icons.logout_rounded),
                  const SizedBox(height: 10),
                  StatusBadge(status: record.status),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelfieThumbnail() {
    if (selfieUrl != null && selfieUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: selfieUrl!,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(
            width: 44,
            height: 44,
            color: AppColors.surfaceAlt,
          ),
          errorWidget: (_, __, ___) => _buildPlaceholder(),
        ),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: const Icon(Icons.person, size: 22, color: AppColors.textMuted),
    );
  }

  Widget _buildTimeRow(String label, String time, bool isDone, IconData icon) {
    final color = isDone ? AppColors.success : AppColors.textMuted;
    return Row(
      children: [
        SizedBox(
          width: 56,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ),
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          time,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDone ? AppColors.textPrimary : AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
