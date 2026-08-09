import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/empty_view.dart';
import '../../../shared/widgets/error_view.dart';
import '../../outlet/data/outlet_model.dart';
import '../../outlet/presentation/admin_outlet_edit_page.dart';
import '../../outlet/providers/outlet_providers.dart';
import '../data/admin_user_model.dart';
import '../providers/admin_providers.dart';
import 'admin_user_detail_page.dart';
import 'admin_user_form_page.dart';

class AdminUsersPage extends ConsumerStatefulWidget {
  const AdminUsersPage({super.key});

  @override
  ConsumerState<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends ConsumerState<AdminUsersPage> {
  int _activeTab = 0; // 0: Outlet, 1: Karyawan

  void _onAddPressed() {
    if (_activeTab == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdminOutletEditPage()),
      ).then((_) => ref.invalidate(outletsProvider));
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdminUserFormPage()),
      ).then((_) => ref.invalidate(usersProvider));
    }
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersProvider);
    final outletsAsync = ref.watch(outletsProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: RefreshIndicator(
        color: AppColors.ink,
        onRefresh: () async {
          ref.invalidate(usersProvider);
          ref.invalidate(outletsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Signature Block Header Dark Ink
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  22,
                  MediaQuery.of(context).padding.top + 18,
                  22,
                  20,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.ink,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Kelola Outlet & User',
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          onPressed: _onAddPressed,
                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.16),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Segmented Tab
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _activeTab = 0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 7),
                                decoration: BoxDecoration(
                                  color: _activeTab == 0 ? Colors.white : Colors.transparent,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Daftar Outlet',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: _activeTab == 0 ? AppColors.ink : Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _activeTab = 1),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 7),
                                decoration: BoxDecoration(
                                  color: _activeTab == 1 ? Colors.white : Colors.transparent,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Data Karyawan',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: _activeTab == 1 ? AppColors.ink : Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Tab View Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: _activeTab == 0
                    ? _buildOutletTab(outletsAsync)
                    : _buildUserTab(usersAsync),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOutletTab(AsyncValue<List<Outlet>> outletsAsync) {
    return outletsAsync.when(
      loading: () => const SizedBox(
        height: 150,
        child: Center(child: CircularProgressIndicator(color: AppColors.ink)),
      ),
      error: (e, _) => ErrorView(
        message: 'Gagal memuat outlet',
        onRetry: () => ref.invalidate(outletsProvider),
      ),
      data: (outlets) {
        if (outlets.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: EmptyView(
              icon: Icons.storefront_rounded,
              title: 'Belum ada outlet',
              subtitle: 'Tambah outlet baru melalui tombol + di atas',
            ),
          );
        }
        return Column(
          children: outlets.map((o) => _buildOutletCard(o)).toList(),
        );
      },
    );
  }

  Widget _buildOutletCard(Outlet outlet) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AdminOutletEditPage(outlet: outlet),
          ),
        ).then((_) => ref.invalidate(outletsProvider));
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  outlet.nama,
                  style: const TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: outlet.isActive ? AppColors.greenBg : AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        outlet.isActive ? 'AKTIF' : 'NONAKTIF',
                        style: TextStyle(
                          fontFamily: 'Space Mono',
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: outlet.isActive ? AppColors.green : AppColors.muted,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.muted, size: 18),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              outlet.alamat ?? '',
              style: const TextStyle(

                fontFamily: 'Inter',
                fontSize: 10.5,
                color: AppColors.muted,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 6,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(100),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.88,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.red,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 9),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'KOORDINAT: ${outlet.latitude.toStringAsFixed(4)}, ${outlet.longitude.toStringAsFixed(4)}',
                  style: const TextStyle(
                    fontFamily: 'Space Mono',
                    fontSize: 9,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'RADIUS ${outlet.radiusMeters.round()}M',
                  style: const TextStyle(
                    fontFamily: 'Space Mono',
                    fontSize: 9,
                    color: AppColors.red,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserTab(AsyncValue<List<AdminUser>> usersAsync) {
    return usersAsync.when(
      loading: () => const SizedBox(
        height: 150,
        child: Center(child: CircularProgressIndicator(color: AppColors.ink)),
      ),
      error: (e, _) => ErrorView(
        message: 'Gagal memuat data karyawan: $e',
        onRetry: () => ref.invalidate(usersProvider),
      ),
      data: (users) {
        if (users.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: EmptyView(
              icon: Icons.people_outline_rounded,
              title: 'Belum ada data karyawan',
              subtitle: 'Tambahkan karyawan baru dengan tombol + di atas',
            ),
          );
        }

        return Column(
          children: users.map((u) => _buildUserCard(u)).toList(),
        );
      },
    );
  }

  Widget _buildUserCard(AdminUser user) {
    final name = user.fullName;
    final initials = name.isNotEmpty
        ? name.trim().split(' ').map((e) => e[0]).take(2).join()
        : 'IK';
    final outlet = user.outlet ?? 'HQ';
    final role = user.roleName ?? 'Karyawan';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AdminUserDetailPage(user: user),
          ),
        ).then((_) => ref.invalidate(usersProvider));
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                initials.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '$role · $outlet',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.muted, size: 20),
          ],
        ),
      ),
    );
  }
}

