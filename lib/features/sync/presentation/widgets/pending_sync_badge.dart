import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../providers/sync_providers.dart';

/// Badge yang menampilkan jumlah absensi pending sync.
/// Tap untuk trigger sync manual.
class PendingSyncBadge extends ConsumerWidget {
  const PendingSyncBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countAsync = ref.watch(pendingSyncCountProvider);
    final syncAsync = ref.watch(manualSyncProvider);

    return countAsync.when(
      data: (count) {
        if (count == 0) return const SizedBox.shrink();

        final isSyncing = syncAsync.isLoading;

        return GestureDetector(
          onTap: isSyncing ? null : () => ref.invalidate(manualSyncProvider),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.amber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: AppColors.amber.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSyncing)
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: AppColors.amber,
                    ),
                  )
                else
                  const Icon(Icons.sync_rounded,
                      color: AppColors.amber, size: 14),
                const SizedBox(width: 6),
                Text(
                  isSyncing
                      ? 'Syncing...'
                      : '$count absensi pending — tap untuk sync',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.amber,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
