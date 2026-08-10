import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';

class AdminExportRecapPage extends ConsumerStatefulWidget {
  const AdminExportRecapPage({super.key});

  @override
  ConsumerState<AdminExportRecapPage> createState() =>
      _AdminExportRecapPageState();
}

class _AdminExportRecapPageState extends ConsumerState<AdminExportRecapPage> {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  String _selectedFormat = 'Excel (.xlsx)';
  String _selectedOutlet = 'Semua Outlet';
  bool _isExporting = false;

  final months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember'
  ];

  final formats = ['Excel (.xlsx)', 'CSV (.csv)', 'Ringkasan PDF (.pdf)'];
  final outlets = [
    'Semua Outlet',
    'IderKopi - Malioboro',
    'IderKopi - Kotabaru',
    'IderKopi - Sudirman',
    'IderPoint'
  ];

  void _handleExport() {
    setState(() => _isExporting = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _isExporting = false);
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.check_circle_rounded,
                    color: AppColors.green, size: 28),
                SizedBox(width: 10),
                Text('Ekspor Berhasil!',
                    style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
              ],
            ),
            content: Text(
              'Laporan Rekap Absensi ${months[_selectedMonth - 1]} $_selectedYear '
              '($_selectedOutlet) berhasil di-generate ke format $_selectedFormat.',
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.pop();
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
                child: const Text('OK', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Ekspor Rekap Absensi Bulanan',
          style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.ink),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.ink),
          onPressed: () => Navigator.canPop(context)
              ? Navigator.pop(context)
              : context.go('/admin/profile'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PILIH PERIODE & FILTER EKSPOR',
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
                  child: DropdownButtonFormField<int>(
                    initialValue: _selectedMonth,
                    decoration: InputDecoration(
                      labelText: 'Bulan',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    items: List.generate(12, (index) {
                      return DropdownMenuItem(
                        value: index + 1,
                        child: Text(months[index]),
                      );
                    }),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedMonth = val);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: _selectedYear,
                    decoration: InputDecoration(
                      labelText: 'Tahun',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    items: [2025, 2026, 2027].map((y) {
                      return DropdownMenuItem(value: y, child: Text('$y'));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedYear = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _selectedOutlet,
              decoration: InputDecoration(
                labelText: 'Filter Outlet',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.storefront_rounded,
                    color: AppColors.muted),
              ),
              items: outlets
                  .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedOutlet = val);
              },
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _selectedFormat,
              decoration: InputDecoration(
                labelText: 'Format Berkas',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.file_present_rounded,
                    color: AppColors.muted),
              ),
              items: formats
                  .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedFormat = val);
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isExporting ? null : _handleExport,
                icon: const Icon(Icons.download_rounded, color: Colors.white),
                label: _isExporting
                    ? const CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2)
                    : const Text(
                        'Unduh Laporan Rekap',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.red,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
