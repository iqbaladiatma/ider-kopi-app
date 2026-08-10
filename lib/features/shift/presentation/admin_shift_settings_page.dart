import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';

class AdminShiftSettingsPage extends ConsumerStatefulWidget {
  const AdminShiftSettingsPage({super.key});

  @override
  ConsumerState<AdminShiftSettingsPage> createState() =>
      _AdminShiftSettingsPageState();
}

class _AdminShiftSettingsPageState
    extends ConsumerState<AdminShiftSettingsPage> {
  TimeOfDay _jamMasuk = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _jamPulang = const TimeOfDay(hour: 17, minute: 0);
  int _toleransiMenit = 15;
  bool _isSaving = false;

  Future<void> _selectTime(bool isMasuk) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isMasuk ? _jamMasuk : _jamPulang,
    );
    if (picked != null) {
      setState(() {
        if (isMasuk) {
          _jamMasuk = picked;
        } else {
          _jamPulang = picked;
        }
      });
    }
  }

  void _handleSave() {
    setState(() => _isSaving = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pengaturan Jam & Toleransi Shift berhasil disimpan'),
            backgroundColor: AppColors.green,
          ),
        );
        context.pop();
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
          'Jam & Toleransi Shift',
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
              'PENGATURAN JAM KERJA STANDAR',
              style: TextStyle(
                fontFamily: 'Space Mono',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.muted,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),

            // Jam Masuk Picker Tile
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: AppColors.line),
              ),
              tileColor: AppColors.surfaceAlt,
              leading: const Icon(Icons.login_rounded, color: AppColors.green),
              title: const Text('Jam Masuk Shift Standar',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
              trailing: Text(
                _jamMasuk.format(context),
                style: const TextStyle(
                    fontFamily: 'Space Mono',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink),
              ),
              onTap: () => _selectTime(true),
            ),

            const SizedBox(height: 10),

            // Jam Pulang Picker Tile
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: AppColors.line),
              ),
              tileColor: AppColors.surfaceAlt,
              leading: const Icon(Icons.logout_rounded, color: AppColors.red),
              title: const Text('Jam Pulang Shift Standar',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
              trailing: Text(
                _jamPulang.format(context),
                style: const TextStyle(
                    fontFamily: 'Space Mono',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink),
              ),
              onTap: () => _selectTime(false),
            ),

            const SizedBox(height: 24),

            const Text(
              'TOLERANSI KETERLAMBATAN',
              style: TextStyle(
                fontFamily: 'Space Mono',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.muted,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Toleransi Keterlambatan',
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              fontWeight: FontWeight.w700)),
                      Text(
                        '$_toleransiMenit Menit',
                        style: const TextStyle(
                            fontFamily: 'Space Mono',
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.amber),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Karyawan yang absen dalam batas toleransi tidak dihitung telat.',
                    style: TextStyle(fontSize: 11, color: AppColors.muted),
                  ),
                  const SizedBox(height: 12),
                  Slider(
                    value: _toleransiMenit.toDouble(),
                    min: 0,
                    max: 60,
                    divisions: 12,
                    activeColor: AppColors.amber,
                    label: '$_toleransiMenit Menit',
                    onChanged: (val) =>
                        setState(() => _toleransiMenit = val.round()),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

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
                    : const Text(
                        'Simpan Pengaturan Shift',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
