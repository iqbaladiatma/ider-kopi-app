import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/map_constants.dart';
import '../data/outlet_model.dart';

/// Map preview interaktif dengan marker semua outlet + lokasi user.
///
/// Menggunakan Mapbox (via flutter_map) dengan fallback otomatis ke OpenStreetMap.
class OutletMapWidget extends StatefulWidget {
  const OutletMapWidget({
    super.key,
    required this.outlets,
    required this.userLatitude,
    required this.userLongitude,
    this.selectedOutlet,
    this.height = 200,
    this.onOutletTap,
  });

  final List<Outlet> outlets;
  final double userLatitude;
  final double userLongitude;
  final Outlet? selectedOutlet;
  final double height;
  final ValueChanged<Outlet>? onOutletTap;

  @override
  State<OutletMapWidget> createState() => _OutletMapWidgetState();
}

class _OutletMapWidgetState extends State<OutletMapWidget> {
  late final MapController _mapController;
  bool _tileError = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void didUpdateWidget(OutletMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.outlets != widget.outlets ||
        oldWidget.selectedOutlet != widget.selectedOutlet ||
        oldWidget.userLatitude != widget.userLatitude ||
        oldWidget.userLongitude != widget.userLongitude) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fitBounds();
      });
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _fitBounds() {
    if (widget.outlets.isEmpty) return;

    final points = <LatLng>[
      LatLng(widget.userLatitude, widget.userLongitude),
      ...widget.outlets.map((o) => LatLng(o.latitude, o.longitude)),
    ];

    if (points.isEmpty) return;

    final bounds = LatLngBounds.fromPoints(points);
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(36),
      ),
    );
  }

  bool _isWithinOutlet(Outlet outlet) {
    const earthRadius = 6371000.0;
    final dLat =
        (outlet.latitude - widget.userLatitude) * (pi / 180.0);
    final dLng =
        (outlet.longitude - widget.userLongitude) * (pi / 180.0);
    final lat1 = widget.userLatitude * (pi / 180.0);
    final x = dLng * earthRadius * cos(lat1);
    final y = dLat * earthRadius;
    final dist = sqrt(x * x + y * y);
    return dist <= outlet.radiusMeters;
  }

  @override
  Widget build(BuildContext context) {
    final userLatLng = LatLng(widget.userLatitude, widget.userLongitude);

    // Filter tile URL: gunakan Mapbox jika belum error, sebaliknya fallback ke OSM
    final tileUrl = _tileError
        ? MapConstants.osmTileUrl
        : MapConstants.mapboxTileUrl;

    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: userLatLng,
                initialZoom: 15.0,
                maxZoom: 18.0,
                minZoom: 3.0,
                onMapReady: () {
                  _fitBounds();
                },
              ),
              children: [
                // 1. Tile Layer (Mapbox / OSM Fallback)
                TileLayer(
                  urlTemplate: tileUrl,
                  userAgentPackageName: MapConstants.userAgentPackageName,
                  errorTileCallback: (tile, error, stackTrace) {
                    if (!_tileError) {
                      setState(() {
                        _tileError = true;
                      });
                    }
                  },
                ),

                // 2. Geofence Circles Layer
                CircleLayer(
                  circles: widget.outlets.map((outlet) {
                    final isWithin = _isWithinOutlet(outlet);
                    final circleColor = isWithin ? AppColors.success : AppColors.warning;

                    return CircleMarker(
                      point: LatLng(outlet.latitude, outlet.longitude),
                      radius: outlet.radiusMeters,
                      useRadiusInMeter: true,
                      color: circleColor.withValues(alpha: 0.15),
                      borderColor: circleColor.withValues(alpha: 0.7),
                      borderStrokeWidth: 1.5,
                    );
                  }).toList(),
                ),

                // 3. Markers Layer (User & Outlets)
                MarkerLayer(
                  markers: [
                    // Outlet Markers
                    ...widget.outlets.map((outlet) {
                      final isSelected = widget.selectedOutlet?.id == outlet.id;
                      final isWithin = _isWithinOutlet(outlet);

                      final markerColor = isSelected
                          ? AppColors.primary
                          : isWithin
                              ? AppColors.success
                              : AppColors.warning;

                      return Marker(
                        point: LatLng(outlet.latitude, outlet.longitude),
                        width: isSelected ? 48.0 : 40.0,
                        height: isSelected ? 48.0 : 40.0,
                        child: GestureDetector(
                          onTap: () => widget.onOutletTap?.call(outlet),
                          child: _buildOutletPin(
                            outlet: outlet,
                            color: markerColor,
                            isSelected: isSelected,
                          ),
                        ),
                      );
                    }),

                    // User Location Marker
                    Marker(
                      point: userLatLng,
                      width: 44.0,
                      height: 44.0,
                      child: _buildUserPin(),
                    ),
                  ],
                ),
              ],
            ),

            // Badge Indikator Provider Peta (Mapbox / OSM)
            Positioned(
              bottom: 6,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _tileError ? Icons.map_outlined : Icons.map_rounded,
                      size: 10,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _tileError ? 'OpenStreetMap' : 'Mapbox',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Marker Widget khusus untuk Outlet
  Widget _buildOutletPin({
    required Outlet outlet,
    required Color color,
    required bool isSelected,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: isSelected ? 10 : 6,
                spreadRadius: isSelected ? 3 : 1,
              ),
            ],
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Icon(
            Icons.storefront_rounded,
            color: Colors.white,
            size: isSelected ? 22 : 18,
          ),
        ),
      ],
    );
  }

  /// Marker Widget khusus untuk Lokasi User (Blue Pulse Pin)
  Widget _buildUserPin() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Pulse ring
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue.withValues(alpha: 0.25),
          ),
        ),
        // Inner blue dot
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue.shade600,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.my_location_rounded,
              color: Colors.white,
              size: 12,
            ),
          ),
        ),
      ],
    );
  }
}
