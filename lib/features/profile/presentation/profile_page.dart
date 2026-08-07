import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/providers/brand_provider.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/profile_providers.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Konfirmasi Keluar',
          style: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w700),
        ),
        content: const Text('Apakah kamu yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Batal', style: TextStyle(color: AppColors.muted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
            ),
            child: const Text('Keluar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(authRepositoryProvider).logout();
      ref.read(authStateProvider.notifier).state = AuthStatus.unauthenticated;
      if (context.mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileInfoProvider);
    final statsAsync = ref.watch(profileStatsProvider);
    final activeBrand = ref.watch(activeBrandProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Block Header Signature + Profile Info
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(
                    24,
                    MediaQuery.of(context).padding.top + 24,
                    24,
                    56,
                  ),
                  decoration: BoxDecoration(
                    color: activeBrand.primaryColor,
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(26)),
                  ),
                  child: profileAsync.when(
                    data: (profile) {
                      final name = profile?.fullName ?? 'Karyawan';
                      final initials = name.isNotEmpty
                          ? name.trim().split(' ').map((e) => e[0]).take(2).join()
                          : 'DA';
                      final outlet = profile?.outlet ?? 'Outlet Malioboro';
                      final role = profile?.kangiderNama ?? 'Barista';
                      final empId = profile?.kangiderId ?? profile?.id ?? 'IDR-0012';

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Mode Pill Top
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(color: Colors.white30),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(activeBrand.iconData, size: 12, color: Colors.white),
                                const SizedBox(width: 5),
                                Text(
                                  activeBrand.badgeText,
                                  style: const TextStyle(
                                    fontFamily: 'Space Mono',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Avatar
                          Container(
                            width: 66,
                            height: 66,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              initials.toUpperCase(),
                              style: const TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 23,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            name,
                            style: const TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$role · $outlet',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11.5,
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              empId,
                              style: const TextStyle(
                                fontFamily: 'Space Mono',
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                    loading: () => const SizedBox(
                      height: 160,
                      child: Center(child: CircularProgressIndicator(color: Colors.white)),
                    ),
                    error: (_, __) => const Column(
                      children: [
                        Text('Profil Karyawan', style: TextStyle(color: Colors.white, fontSize: 18)),
                      ],
                    ),
                  ),
                ),

                // Floating Stats Card 2
                Positioned(
                  left: 22,
                  right: 22,
                  bottom: -36,
                  child: _buildStatsCard2(statsAsync),
                ),
              ],
            ),

            const SizedBox(height: 52),

            // Menu List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                children: [
                  _buildMenuItem(
                    iconData: activeBrand.iconData,
                    label: 'Ganti Mode Outlet (${activeBrand.name})',
                    onTap: () {
                      ref.read(activeBrandProvider.notifier).toggleBrand();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Mode berhasil diubah ke ${ref.read(activeBrandProvider).name}'),
                          backgroundColor: ref.read(activeBrandProvider).primaryColor,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    iconData: Icons.person_outline_rounded,
                    label: 'Data Diri',
                    onTap: () {},
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    iconData: Icons.notifications_none_rounded,
                    label: 'Pengaturan Notifikasi',
                    onTap: () => context.push('/settings'),
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    iconData: Icons.event_available_rounded,
                    label: 'Pengajuan Izin',
                    onTap: () => context.push('/leave'),
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    iconData: Icons.insights_rounded,
                    label: 'KPI Saya',
                    onTap: () => context.push('/kpi'),
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    iconData: Icons.bar_chart_rounded,
                    label: 'Rekap Bulanan',
                    onTap: () => context.push('/recap'),
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    iconData: Icons.schedule_rounded,
                    label: 'Jadwal Shift',
                    onTap: () => context.push('/shift'),
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    iconData: Icons.lock_outline_rounded,
                    label: 'Ubah Kata Sandi',
                    onTap: () {},
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    iconData: Icons.logout_rounded,
                    label: 'Keluar',
                    labelColor: AppColors.red,
                    onTap: () => _handleLogout(context, ref),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard2(AsyncValue statsAsync) {
    String m1Num = '21';
    String m2Num = '96%';
    String m3Num = '2';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2E101012),
            blurRadius: 30,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildMstat(numStr: m1Num, labelStr: 'HARI HADIR'),
          ),
          Container(width: 1, height: 32, color: AppColors.line),
          Expanded(
            child: _buildMstat(numStr: m2Num, labelStr: 'KETEPATAN'),
          ),
          Container(width: 1, height: 32, color: AppColors.line),
          Expanded(
            child: _buildMstat(numStr: m3Num, labelStr: 'TERLAMBAT'),
          ),
        ],
      ),
    );
  }

  Widget _buildMstat({required String numStr, required String labelStr}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          numStr,
          style: const TextStyle(
            fontFamily: 'Sora',
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          labelStr,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: AppColors.muted,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData iconData,
    required String label,
    Color labelColor = AppColors.ink,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(9),
              ),
              alignment: Alignment.center,
              child: Icon(iconData, color: labelColor == AppColors.red ? AppColors.red : AppColors.ink, size: 17),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: labelColor,
                ),
              ),
            ),
            const Text(
              '›',
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
