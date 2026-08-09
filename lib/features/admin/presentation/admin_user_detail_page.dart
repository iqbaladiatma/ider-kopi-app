import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/mock_data.dart';
import '../data/admin_repository.dart';
import '../data/admin_user_model.dart';
import '../providers/admin_providers.dart';
import 'admin_user_form_page.dart';

class AdminUserDetailPage extends ConsumerStatefulWidget {
  const AdminUserDetailPage({
    super.key,
    required this.user,
  });

  final AdminUser user;

  @override
  ConsumerState<AdminUserDetailPage> createState() => _AdminUserDetailPageState();
}

class _AdminUserDetailPageState extends ConsumerState<AdminUserDetailPage> {
  bool _showPassword = false;
  late AdminUser _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
  }

  Future<void> _handleResetPassword() async {
    final passwordCtrl = TextEditingController(text: MockData.defaultPassword);

    final newPass = await showDialog<String>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset / Ubah Password', style: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ubah password untuk ${_currentUser.fullName}. Password ini akan dapat dilihat oleh Admin.',
              style: const TextStyle(fontSize: 12, color: AppColors.muted),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: passwordCtrl,
              decoration: InputDecoration(
                labelText: 'Password Baru',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogCtx, passwordCtrl.text.trim()),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (newPass != null && newPass.isNotEmpty) {
      try {
        final repo = ref.read(adminRepositoryProvider);
        await repo.updateUser(_currentUser.id, {'password': newPass});
        ref.invalidate(usersProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Password untuk ${_currentUser.fullName} berhasil diperbarui!'),
              backgroundColor: AppColors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal mengubah password: $e'), backgroundColor: AppColors.red),
          );
        }
      }
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Akun Karyawan'),
        content: Text('Apakah Anda yakin ingin menghapus akun ${_currentUser.fullName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              try {
                final repo = ref.read(adminRepositoryProvider);
                await repo.deleteUser(_currentUser.id);
                ref.invalidate(usersProvider);
                if (mounted) context.pop();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal menghapus: $e'), backgroundColor: AppColors.red),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            child: const Text('Hapus PERMANEN', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _navigateToEdit() async {
    final updated = await Navigator.push<AdminUser>(
      context,
      MaterialPageRoute(
        builder: (_) => AdminUserFormPage(user: _currentUser),
      ),
    );
    if (updated != null) {
      setState(() => _currentUser = updated);
    }
    ref.invalidate(usersProvider);
  }

  @override
  Widget build(BuildContext context) {
    final name = _currentUser.fullName;
    final initials = name.isNotEmpty
        ? name.trim().split(' ').map((e) => e[0]).take(2).join()
        : 'IK';
    final empId = _currentUser.kangiderId ?? 'IDR-0012';
    final outlet = _currentUser.outlet ?? 'Malioboro';
    final role = _currentUser.roleName ?? 'Karyawan';

    // Password credential (Admin-visible)
    final passwordDisplay = _showPassword ? MockData.defaultPassword : '••••••••••••';

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Detail Karyawan & Akun',
          style: TextStyle(fontFamily: 'Sora', fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.ink),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.ink),
          onPressed: () => Navigator.canPop(context) ? Navigator.pop(context) : context.go('/admin/users'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.red),
            tooltip: 'Edit Data Karyawan',
            onPressed: _navigateToEdit,
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dark Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
              decoration: const BoxDecoration(
                color: AppColors.ink,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initials.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 22,
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
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$role · Outlet $outlet',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Colors.white70,
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
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section: KREDENSIAL AKUN (ADMIN VISIBLE)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'KELOLA AKUN & KREDENSIAL',
                        style: TextStyle(
                          fontFamily: 'Space Mono',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.muted,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.greenBg,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: const Text(
                          'AKSES ADMIN',
                          style: TextStyle(
                            fontFamily: 'Space Mono',
                            fontSize: 8.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Column(
                      children: [
                        // Email Row
                        Row(
                          children: [
                            const Icon(Icons.email_outlined, size: 18, color: AppColors.muted),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Email Login / Username', style: TextStyle(fontSize: 10.5, color: AppColors.muted)),
                                  Text(
                                    _currentUser.email,
                                    style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(color: AppColors.line, height: 1),
                        ),

                        // Password Row (Admin Visible)
                        Row(
                          children: [
                            const Icon(Icons.lock_outline_rounded, size: 18, color: AppColors.muted),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Password Karyawan (Admin Only)', style: TextStyle(fontSize: 10.5, color: AppColors.muted)),
                                  Text(
                                    passwordDisplay,
                                    style: const TextStyle(fontFamily: 'Space Mono', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => setState(() => _showPassword = !_showPassword),
                              icon: Icon(
                                _showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: AppColors.muted,
                                size: 20,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Action Button Reset Password
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _handleResetPassword,
                            icon: const Icon(Icons.key_rounded, size: 16),
                            label: const Text('Reset / Ubah Kredensial Password'),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.red),
                              foregroundColor: AppColors.red,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Action Button Edit Karyawan
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _navigateToEdit,
                            icon: const Icon(Icons.edit_rounded, size: 16),
                            label: const Text('Edit Data Karyawan (Nama, Outlet, Role)'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.ink,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),


                  const SizedBox(height: 24),

                  // Section: DETAIL DATA PROFIL
                  const Text(
                    'DETAIL PROFIL & STATISTIK',
                    style: TextStyle(
                      fontFamily: 'Space Mono',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.muted,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),

                  _buildDetailTile(icon: Icons.badge_outlined, label: 'KangIder NIP ID', value: empId),
                  _buildDetailTile(icon: Icons.storefront_rounded, label: 'Penugasan Outlet', value: outlet),
                  _buildDetailTile(icon: Icons.work_outline_rounded, label: 'Posisi / Role', value: role),
                  _buildDetailTile(icon: Icons.check_circle_outline_rounded, label: 'Status Akun', value: _currentUser.status?.toUpperCase() ?? 'ACTIVE'),

                  const SizedBox(height: 24),

                  // Danger Zone Delete
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: _confirmDelete,
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      label: const Text('Hapus Akun Karyawan Ini'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.red,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.muted),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: AppColors.muted, fontFamily: 'Inter')),
              Text(value, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.ink, fontFamily: 'Inter')),
            ],
          ),
        ],
      ),
    );
  }
}
