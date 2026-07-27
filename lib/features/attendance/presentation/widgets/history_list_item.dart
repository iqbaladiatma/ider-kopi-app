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
                  const SizedBox(height: 8),
                  _buildTimeRow('Masuk', AppDateUtils.formatTimeShort(record.masuk),
                      record.hasCheckedIn),
                  const SizedBox(height: 4),
                  _buildTimeRow('Pulang', AppDateUtils.formatTimeShort(record.pulang),
                      record.hasCheckedOut),
                  const SizedBox(height: 8),
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
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: selfieUrl!,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(
            width: 40,
            height: 40,
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
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.person, size: 20, color: AppColors.textMuted),
    );
  }

  Widget _buildTimeRow(String label, String time, bool isDone) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ),
        Text(
          time,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDone ? AppColors.textPrimary : AppColors.textMuted,
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          isDone ? Icons.check_circle : Icons.remove_circle_outline,
          size: 14,
          color: isDone ? AppColors.success : AppColors.textMuted,
        ),
      ],
    );
  }
}
