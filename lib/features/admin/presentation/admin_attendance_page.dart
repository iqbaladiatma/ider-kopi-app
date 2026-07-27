import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/empty_view.dart';
import '../../../shared/widgets/error_view.dart';
import '../../attendance/data/attendance_model.dart';
import '../../attendance/presentation/widgets/status_badge.dart';
import '../providers/admin_providers.dart';

class AdminAttendancePage extends ConsumerStatefulWidget {
  const AdminAttendancePage({super.key});

  @override
  ConsumerState<AdminAttendancePage> createState() =>
      _AdminAttendancePageState();
}

class _AdminAttendancePageState extends ConsumerState<AdminAttendancePage> {
  DateTime? _selectedDate;
  String _employeeSearch = '';

  @override
  Widget build(BuildContext context) {
    final dateStr = _selectedDate != null
        ? '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}'
        : null;
    final employeeFilter =
        _employeeSearch.isNotEmpty ? _employeeSearch : null;

    final attendanceAsync = ref.watch(adminAttendanceProvider(
      (date: dateStr, employee: employeeFilter),
    ));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Absensi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/admin'),
        ),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                ref.invalidate(adminAttendanceProvider(
                  (date: dateStr, employee: employeeFilter),
                ));
              },
              child: attendanceAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (e, _) => ErrorView(
                  message: 'Gagal memuat data absensi: $e',
                  onRetry: () => ref.invalidate(adminAttendanceProvider(
                    (date: dateStr, employee: employeeFilter),
                  )),
                ),
                data: (records) {
                  if (records.isEmpty) {
                    return const EmptyView(
                      icon: Icons.receipt_long_rounded,
                      title: 'Tidak ada data absensi',
                      subtitle: 'Belum ada riwayat absensi karyawan',
                    );
                  }
                  return _buildAttendanceList(records);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(bottom: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari nama karyawan...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => _employeeSearch = value);
                  },
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filled(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2024),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
                icon: const Icon(Icons.calendar_today_rounded, size: 18),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
              if (_selectedDate != null)
                IconButton(
                  onPressed: () => setState(() => _selectedDate = null),
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  style: IconButton.styleFrom(
                    foregroundColor: AppColors.textMuted,
                  ),
                ),
            ],
          ),
          if (_selectedDate != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.event_rounded, size: 14, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Filter: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAttendanceList(List<AttendanceRecord> records) {
    final grouped = <String, List<AttendanceRecord>>{};
    for (final r in records) {
      grouped.putIfAbsent(r.tanggalAbsensi, () => []).add(r);
    }
    final sortedDates = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final dateRecords = grouped[date]!;
        return _DateGroup(date: date, records: dateRecords);
      },
    );
  }
}

class _DateGroup extends StatelessWidget {
  const _DateGroup({required this.date, required this.records});

  final String date;
  final List<AttendanceRecord> records;

  String _formatDate(String dateStr) {
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return dateStr;
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${days[dt.weekday - 1]}, ${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10, top: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              _formatDate(date),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        ...records.map((r) => _AttendanceCard(record: r)),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _AttendanceCard extends StatelessWidget {
  const _AttendanceCard({required this.record});

  final AttendanceRecord record;

  String _formatTime(String? time) {
    if (time == null || time.isEmpty) return '--:--';
    final parts = time.split(':');
    if (parts.length >= 2) return '${parts[0]}:${parts[1]}';
    return time;
  }

  String _getEmployeeName(AttendanceRecord r) {
    if (r.kangider != null && r.kangider!.isNotEmpty) return r.kangider!;
    return 'Unknown';
  }

  Color _statusColor(AttendanceStatus status) {
    return switch (status) {
      AttendanceStatus.tepatWaktu => AppColors.success,
      AttendanceStatus.terlambat => AppColors.warning,
      AttendanceStatus.alpha => AppColors.error,
      AttendanceStatus.belumAbsen => AppColors.textMuted,
    };
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(record.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppTheme.softShadow,
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.surfaceAlt,
                      child: Icon(Icons.person_rounded, color: AppColors.textMuted, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getEmployeeName(record),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              _TimeChip(
                                icon: Icons.login_rounded,
                                time: _formatTime(record.masuk),
                                color: AppColors.success,
                              ),
                              _TimeChip(
                                icon: Icons.logout_rounded,
                                time: _formatTime(record.pulang),
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                          if (record.keterangan != null &&
                              record.keterangan!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              record.keterangan!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    StatusBadge(status: record.status, size: StatusBadgeSize.small),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({
    required this.icon,
    required this.time,
    required this.color,
  });

  final IconData icon;
  final String time;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isPlaceholder = time == '--:--';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isPlaceholder ? AppColors.surfaceAlt : color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: isPlaceholder ? AppColors.textMuted : color),
          const SizedBox(width: 4),
          Text(
            time,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isPlaceholder ? AppColors.textMuted : color,
            ),
          ),
        ],
      ),
    );
  }
}
