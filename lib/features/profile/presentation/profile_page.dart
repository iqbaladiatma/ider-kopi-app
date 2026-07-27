import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/profile_providers.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileInfoProvider);
    final statsAsync = ref.watch(profileStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(profileAsync),
            const SizedBox(height: 24),
            _buildInfoSection(profileAsync),
            const SizedBox(height: 24),
            _buildStatsSection(statsAsync),
            const SizedBox(height: 24),
            _buildSettingsSection(context),
            const SizedBox(height: 24),
            CustomButton(
              label: 'KELUAR',
              variant: ButtonVariant.outlined,
              onPressed: () => _handleLogout(context, ref),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(AsyncValue profileAsync) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: const Icon(Icons.person, size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          profileAsync.when(
            loading: () => const SizedBox(
              height: 20,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            ),
            error: (_, __) => const Text(
              'Pengguna',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            data: (profile) => Column(
              children: [
                Text(
                  profile?.fullName ?? 'Pengguna',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile?.outlet ?? profile?.kangiderNama ?? '',
                  style: const TextStyle(color: AppColors.primaryLight, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(AsyncValue profileAsync) {
    return profileAsync.when(
      loading: () => const Card(
        child: SizedBox(
          height: 120,
          child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
        ),
      ),
      error: (_, __) => const Card(
        child: SizedBox(
          height: 120,
          child: Center(child: Text('Gagal memuat data')),
        ),
      ),
      data: (profile) {
        if (profile == null) return const SizedBox.shrink();
        return Card(
          child: Column(
            children: [
              _buildInfoRow(Icons.email, 'Email', profile.email),
              const Divider(height: 1),
              _buildInfoRow(Icons.store, 'Outlet', profile.outlet ?? '-'),
              const Divider(height: 1),
              _buildInfoRow(Icons.phone, 'Telepon', profile.phone ?? '-'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textMuted),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(AsyncValue statsAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statistik Bulan Ini',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: statsAsync.when(
            loading: () => const SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            ),
            error: (_, __) => const SizedBox(
              height: 120,
              child: Center(child: Text('Gagal memuat statistik')),
            ),
            data: (stats) => Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildStatRow('Hadir', stats.hadir, AppColors.success),
                  const Divider(height: 16),
                  _buildStatRow('Terlambat', stats.terlambat, AppColors.warning),
                  const Divider(height: 16),
                  _buildStatRow('Alpha', stats.alpha, AppColors.error),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontSize: 14)),
        const Spacer(),
        Text(
          '$count hari',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    final items = [
      _SettingsItem(icon: Icons.settings, label: 'Pengaturan'),
      _SettingsItem(icon: Icons.privacy_tip, label: 'Kebijakan Privasi'),
      _SettingsItem(icon: Icons.info, label: 'Tentang Aplikasi'),
    ];

    return Card(
      child: Column(
        children: items.map((item) {
          return Column(
            children: [
              ListTile(
                leading: Icon(item.icon, color: AppColors.textSecondary),
                title: Text(item.label),
                trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
                onTap: () {
                  if (item.label == 'Tentang Aplikasi') {
                    _showAboutDialog(context);
                  }
                },
              ),
              if (item != items.last) const Divider(height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tentang Aplikasi'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('IderKopi Absensi'),
            SizedBox(height: 4),
            Text('Versi 1.0.0'),
            SizedBox(height: 12),
            Text(
              'Aplikasi absensi karyawan IderKopi dengan GPS dan foto selfie.',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final repo = ref.read(authRepositoryProvider);
      await repo.logout();
      ref.read(authStateProvider.notifier).state = AuthStatus.unauthenticated;
      if (context.mounted) {
        context.go('/login');
      }
    }
  }
}

class _SettingsItem {
  final IconData icon;
  final String label;

  _SettingsItem({required this.icon, required this.label});
}
