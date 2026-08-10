import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../auth/providers/auth_providers.dart';
import '../data/leave_model.dart';
import '../providers/leave_providers.dart';

class LeaveApprovalPage extends ConsumerWidget {
  const LeaveApprovalPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingLeavesProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Approval Izin',
            style: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.ink,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: pendingAsync.when(
        data: (leaves) => leaves.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: leaves.length,
                itemBuilder: (_, i) => _PendingLeaveCard(leave: leaves[i]),
              ),
        loading: () => const Center(
          child:
              CircularProgressIndicator(color: AppColors.red, strokeWidth: 2),
        ),
        error: (e, _) => Center(
          child: Text('Gagal memuat data: $e',
              style: const TextStyle(color: AppColors.red)),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline_rounded,
              size: 64, color: AppColors.green.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          const Text('Tidak ada pengajuan pending',
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              )),
        ],
      ),
    );
  }
}

class _PendingLeaveCard extends ConsumerWidget {
  final LeaveRequest leave;
  const _PendingLeaveCard({required this.leave});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.amber.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                    Text(leave.type.icon, style: const TextStyle(fontSize: 20)),
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
                      '${_formatDate(leave.startDate)} - ${_formatDate(leave.endDate)} (${leave.days} hari)',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.ink.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
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
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _handleReject(context, ref),
                  icon: const Icon(Icons.close_rounded, size: 16),
                  label: const Text('Tolak'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.red,
                    side:
                        BorderSide(color: AppColors.red.withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _handleApprove(context, ref),
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: const Text('Setujui'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleApprove(BuildContext context, WidgetRef ref) async {
    final user = await ref.read(currentUserProvider.future);
    if (user == null) return;

    try {
      await ref.read(approveLeaveProvider(
        (leaveId: leave.id!, approverId: user.id, note: null),
      ).future);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pengajuan disetujui'),
            backgroundColor: AppColors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: AppColors.red),
        );
      }
    }
  }

  Future<void> _handleReject(BuildContext context, WidgetRef ref) async {
    final user = await ref.read(currentUserProvider.future);
    if (user == null) return;

    try {
      await ref.read(rejectLeaveProvider(
        (leaveId: leave.id!, approverId: user.id, note: null),
      ).future);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pengajuan ditolak'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: AppColors.red),
        );
      }
    }
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
}
