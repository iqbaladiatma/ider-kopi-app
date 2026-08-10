import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../data/outlet_model.dart';
import '../providers/outlet_providers.dart';

/// Bottom sheet untuk pilih outlet saat check-in.
///
/// Menampilkan list outlet dengan jarak ke posisi user.
/// Outlet terdekat & dalam radius ditandai hijau.
class OutletPickerSheet extends ConsumerStatefulWidget {
  const OutletPickerSheet({
    super.key,
    required this.userLatitude,
    required this.userLongitude,
    this.selectedOutletId,
  });

  final double userLatitude;
  final double userLongitude;
  final String? selectedOutletId;

  @override
  ConsumerState<OutletPickerSheet> createState() => _OutletPickerSheetState();
}

class _OutletPickerSheetState extends ConsumerState<OutletPickerSheet> {
  @override
  Widget build(BuildContext context) {
    final distancesAsync = ref.watch(outletDistancesProvider(
      (lat: widget.userLatitude, lng: widget.userLongitude),
    ));

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Grabber
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.gray300,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.storefront_rounded,
                          color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pilih Outlet',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Outlet tempat kamu bekerja hari ini',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // List
              Expanded(
                child: distancesAsync.when(
                  data: (distances) => ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    itemCount: distances.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final d = distances[index];
                      final isSelected = widget.selectedOutletId == d.outlet.id;
                      return _OutletTile(
                        distance: d,
                        isSelected: isSelected,
                        onTap: () => Navigator.of(context).pop(d.outlet),
                      );
                    },
                  ),
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                  error: (e, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Gagal memuat outlet: $e',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OutletTile extends StatelessWidget {
  const _OutletTile({
    required this.distance,
    required this.isSelected,
    required this.onTap,
  });

  final OutletDistance distance;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final inRadius = distance.isWithinRadius;
    final accent = inRadius ? AppColors.success : AppColors.warning;
    final accentBg = inRadius ? AppColors.successLight : AppColors.warningLight;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryLight : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.4)
                  : AppColors.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accentBg,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  inRadius ? Icons.check_circle_rounded : Icons.store_outlined,
                  color: accent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      distance.outlet.shortName,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (distance.outlet.alamat != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        distance.outlet.alamat!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.directions_walk_rounded,
                            size: 12, color: accent),
                        const SizedBox(width: 4),
                        Text(
                          '${distance.distanceLabel} dari kamu',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: accent,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '· radius ${distance.outlet.radiusMeters.round()}m',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(Icons.radio_button_checked_rounded,
                    color: AppColors.primary, size: 22)
              else
                const Icon(Icons.radio_button_off_rounded,
                    color: AppColors.textMuted, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper untuk menampilkan sheet & dapatkan outlet terpilih.
Future<Outlet?> showOutletPickerSheet(
  BuildContext context, {
  required double userLatitude,
  required double userLongitude,
  String? selectedOutletId,
}) {
  return showModalBottomSheet<Outlet>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => OutletPickerSheet(
      userLatitude: userLatitude,
      userLongitude: userLongitude,
      selectedOutletId: selectedOutletId,
    ),
  );
}
