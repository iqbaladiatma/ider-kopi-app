import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../providers/settings_providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notificationSettingsProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Pengaturan',
            style: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.ink,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Section: Reminder Absensi
          _SectionHeader(
            icon: Icons.notifications_active_rounded,
            title: 'Reminder Absensi',
            subtitle: 'Atur pengingat check-in & check-out harian',
          ),
          const SizedBox(height: 16),

          // Reminder Check-In
          _ReminderCard(
            title: 'Reminder Check-In',
            subtitle: 'Pengingat untuk absen masuk',
            icon: Icons.login_rounded,
            iconColor: AppColors.green,
            enabled: settings.checkInReminderEnabled,
            hour: settings.checkInReminderHour,
            minute: settings.checkInReminderMinute,
            onToggle: (v) => ref
                .read(notificationSettingsProvider.notifier)
                .toggleCheckInReminder(v),
            onTimeChanged: (h, m) => ref
                .read(notificationSettingsProvider.notifier)
                .setCheckInReminderTime(h, m),
          ),
          const SizedBox(height: 12),

          // Reminder Check-Out
          _ReminderCard(
            title: 'Reminder Check-Out',
            subtitle: 'Pengingat untuk absen pulang',
            icon: Icons.logout_rounded,
            iconColor: AppColors.red,
            enabled: settings.checkOutReminderEnabled,
            hour: settings.checkOutReminderHour,
            minute: settings.checkOutReminderMinute,
            onToggle: (v) => ref
                .read(notificationSettingsProvider.notifier)
                .toggleCheckOutReminder(v),
            onTimeChanged: (h, m) => ref
                .read(notificationSettingsProvider.notifier)
                .setCheckOutReminderTime(h, m),
          ),
          const SizedBox(height: 24),

          // Info card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: AppColors.amber, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Reminder otomatis diskip pada hari libur nasional. '
                    'Pastikan notifikasi diaktifkan di pengaturan sistem '
                    'untuk menerima pengingat.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.ink.withValues(alpha: 0.7),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.red, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  )),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.ink.withValues(alpha: 0.6),
                  )),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final bool enabled;
  final int hour;
  final int minute;
  final ValueChanged<bool> onToggle;
  final TimeChanged onTimeChanged;

  const _ReminderCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.enabled,
    required this.hour,
    required this.minute,
    required this.onToggle,
    required this.onTimeChanged,
  });

  String get _timeLabel {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m WIB';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.ink.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        )),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.ink.withValues(alpha: 0.6),
                        )),
                  ],
                ),
              ),
              Switch.adaptive(
                value: enabled,
                activeColor: AppColors.red,
                onChanged: onToggle,
              ),
            ],
          ),
          if (enabled) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(hour: hour, minute: minute),
                  helpText: 'Pilih waktu reminder',
                );
                if (picked != null) {
                  onTimeChanged(picked.hour, picked.minute);
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Row(
                  children: [
                    const Icon(Icons.access_time_rounded,
                        color: AppColors.ink, size: 18),
                    const SizedBox(width: 8),
                    const Text('Waktu reminder',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.ink,
                        )),
                    const Spacer(),
                    Text(_timeLabel,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.red,
                        )),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right_rounded,
                        color: AppColors.ink, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Type alias untuk callback time picker (hour, minute).
typedef TimeChanged = void Function(int hour, int minute);
