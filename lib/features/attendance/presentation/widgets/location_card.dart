import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

class LocationCard extends StatefulWidget {
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
  State<LocationCard> createState() => _LocationCardState();
}

class _LocationCardState extends State<LocationCard> {
  int _zoom = 15;

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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(Icons.location_on_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lokasi Terdeteksi',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.1,
                      ),
                    ),
                    Text(
                      'GPS Real-time OpenStreetMap',
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              if (widget.latitude != null && widget.longitude != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.gps_fixed_rounded, size: 12, color: AppColors.primary),
                      SizedBox(width: 4),
                      Text(
                        'GPS Akurat',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (widget.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(28),
          child: Column(
            children: [
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 14),
              Text(
                'Mengambil lokasi GPS...',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    if (widget.error != null) {
      return Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: AppColors.errorLight,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.error.withValues(alpha: 0.15),
              ),
            ),
            child: const Icon(Icons.location_disabled_rounded,
                color: AppColors.error, size: 32),
          ),
          const SizedBox(height: 14),
          Text(
            widget.error!,
            style: const TextStyle(color: AppColors.error, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          if (widget.onRetry != null) ...[
            const SizedBox(height: 14),
            TextButton.icon(
              onPressed: widget.onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Coba Lagi'),
            ),
          ],
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Live OpenStreetMap Viewer
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.gray100,
              border: Border.all(color: AppColors.border),
            ),
            child: widget.latitude != null && widget.longitude != null
                ? _buildMapView(widget.latitude!, widget.longitude!)
                : _buildPlaceholderMap(),
          ),
        ),
        const SizedBox(height: 14),
        _buildCoordRow('Latitude', widget.latitude?.toStringAsFixed(6)),
        const SizedBox(height: 4),
        _buildCoordRow('Longitude', widget.longitude?.toStringAsFixed(6)),
        if (widget.isWithinRadius != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: (widget.isWithinRadius! ? AppColors.success : AppColors.warning)
                  .withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: (widget.isWithinRadius! ? AppColors.success : AppColors.warning)
                    .withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  widget.isWithinRadius!
                      ? Icons.check_circle_rounded
                      : Icons.warning_rounded,
                  size: 18,
                  color: widget.isWithinRadius!
                      ? AppColors.success
                      : AppColors.warning,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.isWithinRadius!
                        ? 'Lokasi Anda dalam radius kantor (Absensi Sah)'
                        : 'Di luar area kantor. Mohon berada di lokasi kantor.',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: widget.isWithinRadius!
                          ? AppColors.success
                          : AppColors.warningDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMapView(double lat, double lng) {
    // OpenStreetMap Tile Calculation
    final n = math.pow(2, _zoom).toDouble();
    final tileX = ((lng + 180.0) / 360.0 * n).floor();
    final latRad = lat * math.pi / 180.0;
    final tileY = ((1.0 - math.log(math.tan(latRad) + 1.0 / math.cos(latRad)) / math.pi) / 2.0 * n).floor();

    return Stack(
      children: [
        // 3x3 Tile Grid background for real map rendering
        Positioned.fill(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return OverflowBox(
                minWidth: constraints.maxWidth * 2,
                maxWidth: constraints.maxWidth * 2,
                minHeight: constraints.maxHeight * 2,
                maxHeight: constraints.maxHeight * 2,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                  ),
                  itemCount: 9,
                  itemBuilder: (context, index) {
                    final dx = (index % 3) - 1;
                    final dy = (index ~/ 3) - 1;
                    final x = tileX + dx;
                    final y = tileY + dy;
                    final tileUrl = 'https://tile.openstreetmap.org/$_zoom/$x/$y.png';

                    return Image.network(
                      tileUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.gray100,
                        child: const Center(
                          child: Icon(Icons.map_outlined, color: AppColors.gray300),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),

        // Semi-transparent overlay mask
        Container(
          color: Colors.black.withValues(alpha: 0.05),
        ),

        // Office Radius circle
        Center(
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (widget.isWithinRadius == true ? AppColors.success : AppColors.warning)
                  .withValues(alpha: 0.15),
              border: Border.all(
                color: widget.isWithinRadius == true ? AppColors.success : AppColors.warning,
                width: 2,
              ),
            ),
          ),
        ),

        // Glowing User Marker Pin at Center
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person_pin_circle_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Lokasi Anda',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),

        // Status Badge Top Right
        Positioned(
          top: 10,
          right: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.isWithinRadius == true
                      ? Icons.check_circle_rounded
                      : Icons.warning_rounded,
                  size: 14,
                  color: widget.isWithinRadius == true
                      ? AppColors.success
                      : AppColors.warning,
                ),
                const SizedBox(width: 4),
                Text(
                  widget.isWithinRadius == true ? 'Di Area Kantor' : 'Luar Area Kantor',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: widget.isWithinRadius == true
                        ? AppColors.success
                        : AppColors.warningDark,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Zoom Controls Bottom Right
        Positioned(
          bottom: 10,
          right: 10,
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  if (_zoom < 18) setState(() => _zoom++);
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.add, size: 18, color: AppColors.textPrimary),
                ),
              ),
              InkWell(
                onTap: () {
                  if (_zoom > 10) setState(() => _zoom--);
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(6)),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.remove, size: 18, color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderMap() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map_outlined, size: 48, color: AppColors.textMuted),
          SizedBox(height: 8),
          Text(
            'Mendapatkan peta lokasi...',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ],
      ),
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
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
