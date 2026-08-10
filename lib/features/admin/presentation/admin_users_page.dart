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
  int _activeTab = 0; // 0: Outlet, 1: Karyawan, 2: Admin

  void _onAddPressed() {
    if (_activeTab == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdminOutletEditPage()),
      ).then((_) => ref.invalidate(outletsProvider));
    } else if (_activeTab == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdminUserFormPage()),
      ).then((_) => ref.invalidate(usersProvider));
    }
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersProvider);
    final employeeAccountsAsync = ref.watch(employeeAccountsProvider);
    final outletsAsync = ref.watch(outletsProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: RefreshIndicator(
        color: AppColors.ink,
        onRefresh: () async {
          ref.invalidate(usersProvider);
          ref.invalidate(employeeAccountsProvider);
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
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(26)),
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
                        if (_activeTab != 1)
                          IconButton(
                            onPressed: _onAddPressed,
                            icon: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.16),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add_rounded,
                                  color: Colors.white, size: 20),
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 7),
                                decoration: BoxDecoration(
                                  color: _activeTab == 0
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Daftar Outlet',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: _activeTab == 0
                                        ? AppColors.ink
                                        : Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _activeTab = 1),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 7),
                                decoration: BoxDecoration(
                                  color: _activeTab == 1
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Data Karyawan',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: _activeTab == 1
                                        ? AppColors.ink
                                        : Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _activeTab = 2),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 7),
                                decoration: BoxDecoration(
                                  color: _activeTab == 2
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Akun Admin',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: _activeTab == 2
                                        ? AppColors.ink
                                        : Colors.white,
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
                    : _activeTab == 1
                        ? _buildEmployeeTab(employeeAccountsAsync)
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: outlet.isActive
                            ? AppColors.greenBg
                            : AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        outlet.isActive ? 'AKTIF' : 'NONAKTIF',
                        style: TextStyle(
                          fontFamily: 'Space Mono',
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: outlet.isActive
                              ? AppColors.green
                              : AppColors.muted,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.chevron_right_rounded,
                        color: AppColors.muted, size: 18),
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
        message: 'Gagal memuat akun Admin: $e',
        onRetry: () => ref.invalidate(usersProvider),
      ),
      data: (users) {
        if (users.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: EmptyView(
              icon: Icons.people_outline_rounded,
              title: 'Belum ada akun Admin',
              subtitle: 'Tambahkan Admin baru dengan tombol + di atas',
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
    final role = user.roleName ?? 'Admin';

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
                    '$role · ${user.isActive ? 'Aktif' : 'Nonaktif'}',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.muted, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeTab(
    AsyncValue<List<MobileEmployeeAccount>> accountsAsync,
  ) {
    return accountsAsync.when(
      loading: () => const SizedBox(
        height: 150,
        child: Center(child: CircularProgressIndicator(color: AppColors.ink)),
      ),
      error: (e, _) => ErrorView(
        message: 'Gagal memuat akun Karyawan: $e',
        onRetry: () => ref.invalidate(employeeAccountsProvider),
      ),
      data: (accounts) {
        if (accounts.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: EmptyView(
              icon: Icons.badge_outlined,
              title: 'Belum ada akun Karyawan',
              subtitle: 'Sinkronkan dan provision akun dari API Karyawan',
            ),
          );
        }
        return Column(children: accounts.map(_buildEmployeeCard).toList());
      },
    );
  }

  Widget _buildEmployeeCard(MobileEmployeeAccount account) {
    final initials = account.fullName.isEmpty
        ? 'IK'
        : account.fullName
            .trim()
            .split(RegExp(r'\s+'))
            .map((part) => part[0])
            .take(2)
            .join();
    final active = account.accountActive == true;
    return InkWell(
      onTap: account.hasAccount ? () => _showEmployeeActions(account) : null,
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
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? AppColors.greenBg : AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                initials.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'Sora',
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
                  Text(account.fullName,
                      style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink)),
                  const SizedBox(height: 2),
                  Text(
                    '${account.employeeCode} · ${account.brand} · ${active ? 'Aktif' : 'Nonaktif'}',
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        color: AppColors.muted),
                  ),
                  if (account.mustChangePassword == true)
                    const Text('Wajib ganti password saat login',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 9.5,
                            color: AppColors.red)),
                ],
              ),
            ),
            if (account.hasAccount)
              const Icon(Icons.more_vert_rounded,
                  color: AppColors.muted, size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _showEmployeeActions(MobileEmployeeAccount account) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(account.accountActive == true
                  ? Icons.block_rounded
                  : Icons.check_circle_outline_rounded),
              title: Text(account.accountActive == true
                  ? 'Nonaktifkan akun login'
                  : 'Aktifkan akun login'),
              onTap: () => Navigator.pop(context, 'toggle'),
            ),
            ListTile(
              leading: const Icon(Icons.password_rounded),
              title: const Text('Reset password'),
              onTap: () => Navigator.pop(context, 'reset'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;
    try {
      final repo = ref.read(adminRepositoryProvider);
      if (action == 'toggle') {
        await repo.setEmployeeAccountActive(
          account.employeeId,
          active: account.accountActive != true,
        );
      } else {
        final password = await _requestNewPassword();
        if (password == null) return;
        await repo.resetEmployeePassword(account.employeeId, password);
      }
      ref.invalidate(employeeAccountsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Akun Karyawan berhasil diperbarui'),
          backgroundColor: AppColors.green,
        ));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal memperbarui akun: $error'),
          backgroundColor: AppColors.red,
        ));
      }
    }
  }

  Future<String?> _requestNewPassword() async {
    final controller = TextEditingController();
    final password = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password Karyawan'),
        content: TextField(
          controller: controller,
          obscureText: true,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Password awal baru',
            helperText: 'Minimal 8 karakter; Karyawan wajib menggantinya',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.length >= 8) {
                Navigator.pop(context, controller.text);
              }
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    controller.dispose();
    return password;
  }
}
