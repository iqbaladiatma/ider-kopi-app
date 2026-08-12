import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../data/admin_user_model.dart';
import '../providers/admin_providers.dart';

class AdminAccountDetailPage extends ConsumerWidget {
  const AdminAccountDetailPage({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(adminUserDetailProvider(userId));
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.ink,
        title: const Text('Detail Akun Admin'),
        leading: IconButton(
          onPressed: () => context.go('/admin/users'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: userAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.ink),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Gagal memuat akun: $error', textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () =>
                      ref.invalidate(adminUserDetailProvider(userId)),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
        data: (user) => _content(context, ref, user),
      ),
    );
  }

  Widget _content(BuildContext context, WidgetRef ref, AdminUser user) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.ink,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white24,
                child: Icon(
                  Icons.admin_panel_settings_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                user.email,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Sora',
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                user.roleName ?? 'Admin',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _AdminTile(label: 'Email login', value: user.email),
        _AdminTile(label: 'Role', value: user.roleName ?? '-'),
        _AdminTile(
          label: 'Status akun',
          value: user.isActive ? 'Aktif' : 'Nonaktif',
        ),
        _AdminTile(
          label: 'Terakhir login',
          value: _formatDateTime(user.lastLoginAt),
        ),
        _AdminTile(
          label: 'Akun dibuat',
          value: _formatDateTime(user.createdAt),
        ),
        const _AdminTile(
          label: 'Password',
          value: 'Tersimpan aman dan tidak dapat ditampilkan',
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => _editAccount(context, ref, user),
          icon: const Icon(Icons.edit_rounded),
          label: const Text('Edit Email, Role & Status'),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => _resetPassword(context, ref, user),
          icon: const Icon(Icons.key_rounded),
          label: const Text('Set / Reset Password Baru'),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) return 'Belum pernah';
    final local = value.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year} '
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _editAccount(
    BuildContext context,
    WidgetRef ref,
    AdminUser user,
  ) async {
    final emailController = TextEditingController(text: user.email);
    final roles = await ref.read(rolesProvider.future);
    if (!context.mounted) return;
    var roleId = user.roleId;
    var active = user.isActive;
    final updates = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Akun Admin'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email login'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue:
                    roles.any((role) => role['id']?.toString() == roleId)
                        ? roleId
                        : null,
                decoration: const InputDecoration(labelText: 'Role'),
                items: roles
                    .where((role) => role['name']?.toString() != 'employee')
                    .map(
                      (role) => DropdownMenuItem<String>(
                        value: role['id']?.toString(),
                        child: Text(role['name']?.toString() ?? 'Admin'),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setDialogState(() => roleId = value),
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Akun aktif'),
                value: active,
                onChanged: (value) => setDialogState(() => active = value),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                final email = emailController.text.trim();
                if (email.isEmpty || !email.contains('@') || roleId == null) {
                  return;
                }
                Navigator.pop(dialogContext, {
                  'email': email,
                  'role_id': roleId,
                  'is_active': active,
                });
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
    emailController.dispose();
    if (updates == null || !context.mounted) return;
    try {
      await ref.read(adminRepositoryProvider).updateUser(user.id, updates);
      ref.invalidate(adminUserDetailProvider(user.id));
      ref.invalidate(usersProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Akun Admin berhasil diperbarui'),
            backgroundColor: AppColors.green,
          ),
        );
      }
    } catch (error) {
      if (context.mounted) _showError(context, 'Gagal menyimpan: $error');
    }
  }

  Future<void> _resetPassword(
    BuildContext context,
    WidgetRef ref,
    AdminUser user,
  ) async {
    final controller = TextEditingController();
    var obscure = true;
    final password = await showDialog<String>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Set Password Admin Baru'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Password lama tidak dapat dilihat. Seluruh refresh token lama akan dicabut.',
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                obscureText: obscure,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Password baru',
                  helperText: 'Minimal 8 karakter, maksimal 72 byte',
                  suffixIcon: IconButton(
                    onPressed: () => setDialogState(() => obscure = !obscure),
                    icon:
                        Icon(obscure ? Icons.visibility : Icons.visibility_off),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                final value = controller.text;
                if (value.length >= 8 && value.codeUnits.length <= 72) {
                  Navigator.pop(dialogContext, value);
                }
              },
              child: const Text('Reset Password'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (password == null || !context.mounted) return;
    try {
      await ref
          .read(adminRepositoryProvider)
          .updateUser(user.id, {'password': password});
      if (context.mounted) await _showOneTimePassword(context, password);
    } catch (error) {
      if (context.mounted) _showError(context, 'Gagal reset password: $error');
    }
  }

  Future<void> _showOneTimePassword(
    BuildContext context,
    String password,
  ) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Password Baru — Tampil Sekali'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Salin sekarang. Password ini tidak dapat dilihat lagi setelah dialog ditutup.',
            ),
            const SizedBox(height: 12),
            SelectableText(
              password,
              style: const TextStyle(
                fontFamily: 'Space Mono',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: password));
              if (dialogContext.mounted) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('Password disalin')),
                );
              }
            },
            icon: const Icon(Icons.copy_rounded),
            label: const Text('Salin'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Sudah Disimpan'),
          ),
        ],
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.red),
    );
  }
}

class _AdminTile extends StatelessWidget {
  const _AdminTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: AppColors.muted, fontSize: 11)),
          const SizedBox(height: 3),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
