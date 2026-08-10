import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../auth/providers/auth_providers.dart';
import '../data/leave_model.dart';
import '../providers/leave_providers.dart';

class LeaveFormPage extends ConsumerStatefulWidget {
  const LeaveFormPage({super.key});

  @override
  ConsumerState<LeaveFormPage> createState() => _LeaveFormPageState();
}

class _LeaveFormPageState extends ConsumerState<LeaveFormPage> {
  LeaveType _selectedType = LeaveType.izin;
  DateTime? _startDate;
  DateTime? _endDate;
  final _reasonController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1, 12, 31),
      helpText: isStart ? 'Pilih tanggal mulai' : 'Pilih tanggal selesai',
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          // Reset end date jika sebelum start
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (_startDate == null || _endDate == null) {
      _showError('Silakan pilih tanggal mulai dan selesai');
      return;
    }
    if (_endDate!.isBefore(_startDate!)) {
      _showError('Tanggal selesai tidak boleh sebelum tanggal mulai');
      return;
    }
    if (_reasonController.text.trim().isEmpty) {
      _showError('Silakan isi alasan pengajuan');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = await ref.read(currentUserProvider.future);
      if (user == null) {
        _showError('User tidak teridentifikasi');
        return;
      }

      final request = LeaveRequest(
        userId: user.id,
        type: _selectedType,
        startDate: _startDate!,
        endDate: _endDate!,
        reason: _reasonController.text.trim(),
      );

      await ref.read(submitLeaveProvider(request).future);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pengajuan izin berhasil dikirim'),
            backgroundColor: AppColors.green,
          ),
        );
        context.go('/leave');
      }
    } catch (e) {
      _showError('Gagal mengirim pengajuan: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Ajukan Izin',
            style: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.ink,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Jenis pengajuan
            const Text('Jenis Pengajuan',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                )),
            const SizedBox(height: 12),
            Row(
              children: LeaveType.values.map((t) {
                final selected = t == _selectedType;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text('${t.icon} ${t.label}'),
                      selected: selected,
                      selectedColor: AppColors.red.withValues(alpha: 0.15),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selected ? AppColors.red : AppColors.ink,
                      ),
                      onSelected: (_) => setState(() => _selectedType = t),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Tanggal mulai
            _DateField(
              label: 'Tanggal Mulai',
              value: _startDate,
              onTap: () => _pickDate(context, true),
            ),
            const SizedBox(height: 16),

            // Tanggal selesai
            _DateField(
              label: 'Tanggal Selesai',
              value: _endDate,
              onTap: () => _pickDate(context, false),
            ),
            const SizedBox(height: 24),

            // Alasan
            const Text('Alasan',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                )),
            const SizedBox(height: 8),
            TextField(
              controller: _reasonController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Jelaskan alasan pengajuan izin/sakit/cuti...',
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: AppColors.ink.withValues(alpha: 0.4),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.ink.withValues(alpha: 0.1),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.ink.withValues(alpha: 0.1),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.red, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Kirim Pengajuan',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
              fontFamily: 'Sora',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            )),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.ink.withValues(alpha: 0.1)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded,
                    color: value != null
                        ? AppColors.red
                        : AppColors.ink.withValues(alpha: 0.4),
                    size: 18),
                const SizedBox(width: 12),
                Text(
                  value != null
                      ? '${value!.day}/${value!.month}/${value!.year}'
                      : 'Pilih tanggal',
                  style: TextStyle(
                    fontSize: 13,
                    color: value != null
                        ? AppColors.ink
                        : AppColors.ink.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
