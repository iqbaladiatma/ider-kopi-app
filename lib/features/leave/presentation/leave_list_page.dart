import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../data/leave_model.dart';
import '../providers/leave_providers.dart';

class LeaveListPage extends ConsumerWidget {
  const LeaveListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leavesAsync = ref.watch(myLeavesProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Pengajuan Izin',
            style: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.ink,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: leavesAsync.when(
        data: (leaves) => leaves.isEmpty
            ? _buildEmptyState(context)
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: leaves.length,
                itemBuilder: (_, i) => _LeaveCard(leave: leaves[i]),
              ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.red, strokeWidth: 2),
        ),
        error: (e, _) => Center(
          child: Text('Gagal memuat data: $e',
              style: const TextStyle(color: AppColors.red)),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/leave/form'),
        backgroundColor: AppColors.red,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy_rounded,
              size: 64, color: AppColors.ink.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          const Text('Belum ada pengajuan izin',
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              )),
          const SizedBox(height: 8),
          Text('Tap tombol + untuk ajukan izin/sakit/cuti',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.ink.withValues(alpha: 0.6),
              )),
        ],
      ),
    );
  }
}

class _LeaveCard extends StatelessWidget {
  final LeaveRequest leave;
  const _LeaveCard({required this.leave});

  Color get _statusColor {
    switch (leave.status) {
      case LeaveStatus.approved:
        return AppColors.green;
      case LeaveStatus.rejected:
        return AppColors.red;
      case LeaveStatus.pending:
        return AppColors.amber;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.ink.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(leave.type.icon, style: const TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(leave.type.label,
                        style: const TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        )),
                    const SizedBox(height: 2),
                    Text(
                      '${_formatDate(leave.startDate)} - ${_formatDate(leave.endDate)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.ink.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  leave.status.label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _statusColor,
                  ),
                ),
              ),
            ],
          ),
          if (leave.reason != null) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Text('Alasan: ${leave.reason!}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.ink.withValues(alpha: 0.7),
                  height: 1.4,
                )),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today_rounded,
                  size: 12, color: AppColors.ink.withValues(alpha: 0.5)),
              const SizedBox(width: 4),
              Text('${leave.days} hari',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink.withValues(alpha: 0.5),
                  )),
              const Spacer(),
              if (leave.approverNote != null)
                Expanded(
                  child: Text(
                    'Catatan: ${leave.approverNote}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: AppColors.ink.withValues(alpha: 0.5),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day}/${d.month}/${d.year}';
}
