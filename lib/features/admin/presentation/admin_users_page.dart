import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/empty_view.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../data/admin_user_model.dart';
import '../providers/admin_providers.dart';

class AdminUsersPage extends ConsumerStatefulWidget {
  const AdminUsersPage({super.key});

  @override
  ConsumerState<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends ConsumerState<AdminUsersPage> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola User'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _showAddUserDialog(context),
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isDeleting,
        message: 'Menghapus user...',
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async => ref.invalidate(usersProvider),
          child: usersAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (e, _) => ErrorView(
              message: 'Gagal memuat data user: $e',
              onRetry: () => ref.invalidate(usersProvider),
            ),
            data: (users) {
              if (users.isEmpty) {
                return const EmptyView(
                  icon: Icons.people_outline,
                  title: 'Belum ada user',
                  subtitle: 'Tambahkan user baru dengan tombol + di atas',
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: users.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final user = users[index];
                  return _UserCard(
                    user: user,
                    onEdit: () => _showEditUserDialog(context, user),
                    onDelete: () => _confirmDelete(context, user),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final firstNameCtrl = TextEditingController();
    final lastNameCtrl = TextEditingController();
    final kangiderNamaCtrl = TextEditingController();
    final outletCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => _FormDialog(
        title: 'Tambah User',
        formKey: formKey,
        fields: [
          _FormField(
            controller: emailCtrl,
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
            validator: (v) => v!.trim().isEmpty ? 'Email wajib diisi' : null,
          ),
          _FormField(
            controller: passwordCtrl,
            label: 'Password',
            obscure: true,
            validator: (v) => v!.isEmpty ? 'Password wajib diisi' : null,
          ),
          _FormField(controller: firstNameCtrl, label: 'Nama Depan'),
          _FormField(controller: lastNameCtrl, label: 'Nama Belakang'),
          _FormField(controller: kangiderNamaCtrl, label: 'Nama Kangider'),
          _FormField(controller: outletCtrl, label: 'Outlet'),
        ],
        submitLabel: 'Simpan',
        onSubmit: () async {
          if (!formKey.currentState!.validate()) return;
          Navigator.pop(dialogContext);

          final roles = await ref.read(rolesProvider.future);
          final userRole = roles
              .where((r) => r['name']?.toString().toLowerCase() != 'admin')
              .toList();

          if (userRole.isEmpty) {
            if (mounted) {
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Role user tidak ditemukan')),
              );
            }
            return;
          }

          try {
            final repo = ref.read(adminRepositoryProvider);
            await repo.createUser(CreateUserData(
              email: emailCtrl.text.trim(),
              password: passwordCtrl.text,
              firstName: firstNameCtrl.text.trim().isEmpty
                  ? null
                  : firstNameCtrl.text.trim(),
              lastName: lastNameCtrl.text.trim().isEmpty
                  ? null
                  : lastNameCtrl.text.trim(),
              kangiderNama: kangiderNamaCtrl.text.trim().isEmpty
                  ? null
                  : kangiderNamaCtrl.text.trim(),
              outlet: outletCtrl.text.trim().isEmpty
                  ? null
                  : outletCtrl.text.trim(),
              roleId: userRole.first['id'],
            ));
            ref.invalidate(usersProvider);
            if (mounted) {
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User berhasil ditambahkan')),
              );
            }
          } catch (e) {
            if (mounted) {
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Gagal menambah user: $e')),
              );
            }
          }
        },
      ),
    );
  }

  void _showEditUserDialog(BuildContext context, AdminUser user) {
    final firstNameCtrl = TextEditingController(text: user.firstName ?? '');
    final lastNameCtrl = TextEditingController(text: user.lastName ?? '');
    final kangiderNamaCtrl =
        TextEditingController(text: user.kangiderNama ?? '');
    final outletCtrl = TextEditingController(text: user.outlet ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => _FormDialog(
        title: 'Edit User',
        subtitle: user.email,
        fields: [
          _FormField(controller: firstNameCtrl, label: 'Nama Depan'),
          _FormField(controller: lastNameCtrl, label: 'Nama Belakang'),
          _FormField(controller: kangiderNamaCtrl, label: 'Nama Kangider'),
          _FormField(controller: outletCtrl, label: 'Outlet'),
        ],
        submitLabel: 'Simpan',
        onSubmit: () async {
          Navigator.pop(dialogContext);
          try {
            final repo = ref.read(adminRepositoryProvider);
            await repo.updateUser(user.id, {
              'first_name': firstNameCtrl.text.trim(),
              'last_name': lastNameCtrl.text.trim(),
              'kangider_nama': kangiderNamaCtrl.text.trim(),
              'outlet': outletCtrl.text.trim(),
            });
            ref.invalidate(usersProvider);
            if (mounted) {
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User berhasil diperbarui')),
              );
            }
          } catch (e) {
            if (mounted) {
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Gagal memperbarui: $e')),
              );
            }
          }
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, AdminUser user) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 28),
            SizedBox(width: 8),
            Text('Hapus User'),
          ],
        ),
        content: Text('Yakin ingin menghapus ${user.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);
              setState(() => _isDeleting = true);
              try {
                final repo = ref.read(adminRepositoryProvider);
                await repo.deleteUser(user.id);
                ref.invalidate(usersProvider);
                if (mounted) {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User berhasil dihapus')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal menghapus: $e')),
                  );
                }
              } finally {
                if (mounted) setState(() => _isDeleting = false);
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

class _FormField {
  final TextEditingController controller;
  final String label;
  final bool obscure;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  _FormField({
    required this.controller,
    required this.label,
    this.obscure = false,
    this.keyboardType,
    this.validator,
  });
}

class _FormDialog extends StatelessWidget {
  const _FormDialog({
    required this.title,
    this.subtitle,
    required this.fields,
    required this.submitLabel,
    required this.onSubmit,
    this.formKey,
  });

  final String title;
  final String? subtitle;
  final List<_FormField> fields;
  final String submitLabel;
  final Future<void> Function() onSubmit;
  final GlobalKey<FormState>? formKey;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                ...fields.map((f) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TextFormField(
                        controller: f.controller,
                        decoration: InputDecoration(
                          labelText: f.label,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 14),
                        ),
                        obscureText: f.obscure,
                        keyboardType: f.keyboardType,
                        validator: f.validator,
                      ),
                    )),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                      onPressed: () => onSubmit(),
                      child: Text(submitLabel),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.user,
    required this.onEdit,
    required this.onDelete,
  });

  final AdminUser user;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(user.fullName);
    final isAdmin = user.roleName?.toLowerCase() == 'admin';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor:
                  isAdmin ? AppColors.primaryLight : AppColors.surfaceAlt,
              child: Text(
                initials,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isAdmin ? AppColors.primary : AppColors.gray600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.email,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (user.outlet != null) ...[
                        const Icon(Icons.store, size: 12, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          user.outlet!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isAdmin
                              ? AppColors.primaryLight
                              : AppColors.successLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          user.roleName ?? 'User',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isAdmin
                                ? AppColors.primary
                                : AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppColors.textMuted),
              onSelected: (value) {
                if (value == 'edit') onEdit();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Hapus',
                      style: TextStyle(color: AppColors.error)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }
}
