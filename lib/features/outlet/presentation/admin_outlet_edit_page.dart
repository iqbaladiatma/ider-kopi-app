import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../data/outlet_model.dart';
import '../providers/outlet_providers.dart';
import 'outlet_map_widget.dart';

class AdminOutletEditPage extends ConsumerStatefulWidget {
  const AdminOutletEditPage({
    super.key,
    this.outlet,
  });

  final Outlet? outlet;

  @override
  ConsumerState<AdminOutletEditPage> createState() =>
      _AdminOutletEditPageState();
}

class _AdminOutletEditPageState extends ConsumerState<AdminOutletEditPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _latController;
  late final TextEditingController _lngController;
  late final TextEditingController _radiusController;
  bool _isActive = true;
  bool _isSaving = false;

  bool get isEditing => widget.outlet != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.outlet?.nama ?? '');
    _addressController =
        TextEditingController(text: widget.outlet?.alamat ?? '');
    _latController = TextEditingController(
      text: widget.outlet?.latitude.toString() ?? '',
    );
    _lngController = TextEditingController(
      text: widget.outlet?.longitude.toString() ?? '',
    );
    _radiusController = TextEditingController(
      text: (widget.outlet?.radiusMeters ?? 100.0).toStringAsFixed(0),
    );
    _isActive = widget.outlet?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    final address = _addressController.text.trim();
    final lat = double.tryParse(_latController.text.trim());
    final lng = double.tryParse(_lngController.text.trim());
    final radius = double.tryParse(_radiusController.text.trim()) ?? 100.0;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama outlet tidak boleh kosong')),
      );
      return;
    }
    if (lat == null ||
        lng == null ||
        lat < -90 ||
        lat > 90 ||
        lng < -180 ||
        lng > 180 ||
        (lat == 0 && lng == 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan koordinat outlet yang valid')),
      );
      return;
    }
    if (radius <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Radius geofence harus lebih dari 0')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(outletRepositoryProvider);
      final newOutlet = Outlet(
        id: widget.outlet?.id ?? 'new',
        nama: name,
        alamat: address.isNotEmpty ? address : null,
        latitude: lat,
        longitude: lng,
        radiusMeters: radius,
        isActive: _isActive,
      );

      if (isEditing) {
        await repo.updateOutlet(newOutlet);
      } else {
        await repo.addOutlet(newOutlet);
      }

      ref.invalidate(outletsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing
                ? 'Outlet berhasil diperbarui'
                : 'Outlet baru berhasil ditambahkan'),
            backgroundColor: AppColors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Gagal menyimpan outlet: $e'),
              backgroundColor: AppColors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lat = double.tryParse(_latController.text.trim());
    final lng = double.tryParse(_lngController.text.trim());
    final radius = double.tryParse(_radiusController.text.trim()) ?? 100.0;
    final hasValidCoordinates = lat != null &&
        lng != null &&
        lat >= -90 &&
        lat <= 90 &&
        lng >= -180 &&
        lng <= 180 &&
        !(lat == 0 && lng == 0);

    final previewOutlet = Outlet(
      id: widget.outlet?.id ?? 'preview',
      nama: _nameController.text.isEmpty
          ? 'Pratinjau Outlet'
          : _nameController.text,
      alamat: _addressController.text,
      latitude: lat ?? 0,
      longitude: lng ?? 0,
      radiusMeters: radius,
      isActive: _isActive,
    );

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          isEditing ? 'Edit Informasi Outlet' : 'Tambah Outlet Baru',
          style: const TextStyle(
              fontFamily: 'Sora',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.ink),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.ink),
          onPressed: () => Navigator.canPop(context)
              ? Navigator.pop(context)
              : context.go('/admin/outlets'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map Location Preview Card
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.line),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasValidCoordinates)
                    OutletMapWidget(
                      outlets: [previewOutlet],
                      userLatitude: lat,
                      userLongitude: lng,
                      selectedOutlet: previewOutlet,
                      height: 160,
                    )
                  else
                    const SizedBox(
                      height: 160,
                      child: Center(
                        child: Text(
                          'Masukkan koordinat valid untuk melihat peta',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    color: AppColors.surfaceAlt,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'PETA GEOFENCE OUTLET',
                          style: TextStyle(
                            fontFamily: 'Space Mono',
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.muted,
                          ),
                        ),
                        Text(
                          'RADIUS ${radius.round()}M',
                          style: const TextStyle(
                            fontFamily: 'Space Mono',
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Form Inputs
            const Text(
              'INFORMASI DASAR OUTLET',
              style: TextStyle(
                fontFamily: 'Space Mono',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.muted,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _nameController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Nama Outlet',
                hintText: 'misal: IderKopi - Malioboro',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.storefront_rounded,
                    color: AppColors.muted),
              ),
            ),

            const SizedBox(height: 14),

            TextField(
              controller: _addressController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Alamat Lengkap',
                hintText: 'Jl. Malioboro No. 52, Yogyakarta',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon:
                    const Icon(Icons.place_rounded, color: AppColors.muted),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'LOKASI GPS & GEOFENCE',
              style: TextStyle(
                fontFamily: 'Space Mono',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.muted,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _latController,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true, signed: true),
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Latitude',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _lngController,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true, signed: true),
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Longitude',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            TextField(
              controller: _radiusController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Radius Geofence (Meter)',
                hintText: '100',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon:
                    const Icon(Icons.radar_rounded, color: AppColors.muted),
                suffixText: 'Meter',
              ),
            ),

            const SizedBox(height: 20),

            // Status Switcher
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.line),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status Outlet Aktif',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      Text(
                        'Outlet aktif dapat dipilih karyawan untuk absen',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10.5,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: _isActive,
                    activeThumbColor: AppColors.red,
                    onChanged: (val) => setState(() => _isActive = val),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.red,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100)),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2)
                    : Text(
                        isEditing
                            ? 'Simpan Perubahan Outlet'
                            : 'Tambah Outlet Sekarang',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
