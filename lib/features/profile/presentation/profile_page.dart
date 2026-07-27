import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
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
              icon: Icons.logout_rounded,
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
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.gradientShadow,
      ),
      child: Stack(
        children: [
          Positioned(
            top: -25,
            right: -10,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Column(
            children: [
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(Icons.person_rounded, size: 42, color: AppColors.primary),
              ),
              const SizedBox(height: 14),
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
                    const SizedBox(height: 6),
                    Text(
                      profile?.outlet ?? profile?.kangiderNama ?? '',
                      style: const TextStyle(color: AppColors.primaryLight, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
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
              _buildInfoRow(Icons.email_rounded, 'Email', profile.email),
              const Divider(height: 1),
              _buildInfoRow(Icons.store_rounded, 'Outlet', profile.outlet ?? '-'),
              const Divider(height: 1),
              _buildInfoRow(Icons.phone_rounded, 'Telepon', profile.phone ?? '-'),
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
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.textSecondary),
          ),
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
                    fontWeight: FontWeight.w600,
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
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
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
          height: 28,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const Spacer(),
        Text(
          '$count hari',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    final items = [
      _SettingsItem(icon: Icons.settings_rounded, label: 'Pengaturan'),
      _SettingsItem(icon: Icons.privacy_tip_rounded, label: 'Kebijakan Privasi'),
      _SettingsItem(icon: Icons.info_rounded, label: 'Tentang Aplikasi'),
    ];

    return Card(
      child: Column(
        children: items.map((item) {
          return Column(
            children: [
              ListTile(
                leading: Icon(item.icon, color: AppColors.textSecondary),
                title: Text(item.label),
                trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
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
