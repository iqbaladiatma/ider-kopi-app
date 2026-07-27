import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class LocationCard extends StatelessWidget {
  const LocationCard({
    super.key,
    required this.latitude,
    required this.longitude,
    this.isWithinRadius,
    this.isLoading = false,
    this.error,
    this.onRetry,
  });

  final double? latitude;
  final double? longitude;
  final bool? isWithinRadius;
  final bool isLoading;
  final String? error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.location_on, color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Lokasi Terdeteksi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 12),
              Text(
                'Mengambil lokasi...',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    if (error != null) {
      return Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.errorLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_disabled, color: AppColors.error, size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            error!,
            style: const TextStyle(color: AppColors.error, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: onRetry,
              child: const Text('Coba Lagi'),
            ),
          ],
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 180,
            width: double.infinity,
            color: AppColors.gray100,
            child: Stack(
              children: [
                const Center(
                  child: Icon(Icons.map_outlined, size: 56, color: AppColors.gray300),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isWithinRadius == true
                              ? Icons.check_circle
                              : Icons.warning,
                          size: 14,
                          color: isWithinRadius == true
                              ? AppColors.success
                              : AppColors.warning,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isWithinRadius == true ? 'Di area' : 'Luar area',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isWithinRadius == true
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildCoordRow('Latitude', latitude?.toStringAsFixed(6)),
        const SizedBox(height: 4),
        _buildCoordRow('Longitude', longitude?.toStringAsFixed(6)),
        if (isWithinRadius != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                isWithinRadius! ? Icons.check_circle : Icons.warning,
                size: 16,
                color: isWithinRadius! ? AppColors.success : AppColors.warning,
              ),
              const SizedBox(width: 6),
              Text(
                isWithinRadius!
                    ? 'Dalam area kantor'
                    : 'Di luar area kantor',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isWithinRadius! ? AppColors.success : AppColors.warning,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildCoordRow(String label, String? value) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ),
        Text(
          value ?? '-',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.gray600,
          ),
        ),
      ],
    );
  }
}
