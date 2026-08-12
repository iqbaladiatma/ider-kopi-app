import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../data/admin_user_model.dart';
import '../providers/admin_providers.dart';

class AdminUserFormPage extends ConsumerStatefulWidget {
  const AdminUserFormPage({
    super.key,
    this.user,
  });

  final AdminUser? user;

  @override
  ConsumerState<AdminUserFormPage> createState() => _AdminUserFormPageState();
}

class _AdminUserFormPageState extends ConsumerState<AdminUserFormPage> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  String? _selectedRoleId;
  bool _isSaving = false;

  bool get isEditing => widget.user != null;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _passwordController = TextEditingController();

    _selectedRoleId = widget.user?.roleId;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      _showSnack('Email tidak boleh kosong');
      return;
    }
    if (!isEditing && password.isEmpty) {
      _showSnack('Password wajib diisi untuk Admin baru');
      return;
    }
    if (password.isNotEmpty && password.length < 8) {
      _showSnack('Password minimal 8 karakter');
      return;
    }
    if (_selectedRoleId == null) {
      _showSnack('Pilih role Admin');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(adminRepositoryProvider);

      AdminUser? updatedUser;
      if (isEditing) {
        final updateData = <String, dynamic>{
          'email': email,
          'role_id': _selectedRoleId,
        };
        if (password.isNotEmpty) {
          updateData['password'] = password;
        }
        await repo.updateUser(widget.user!.id, updateData);
        updatedUser = widget.user!.copyWith(
          email: email,
          roleId: _selectedRoleId,
        );
      } else {
        await repo.createUser(CreateUserData(
          email: email,
          password: password,
          roleId: _selectedRoleId!,
        ));
      }

      ref.invalidate(usersProvider);

      if (mounted) {
        _showSnack(
          isEditing
              ? 'Akun Admin berhasil diperbarui'
              : 'Admin baru berhasil ditambahkan',
          isError: false,
        );
        if (Navigator.canPop(context)) {
          Navigator.pop(context, updatedUser);
        } else {
          context.go('/admin/users');
        }
      }
    } catch (e) {
      if (mounted) _showSnack('Gagal menyimpan: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnack(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppColors.red : AppColors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roles = (ref.watch(rolesProvider).asData?.value ?? const [])
        .where((role) => role['name']?.toString() != 'employee')
        .toList();
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          isEditing ? 'Edit Akun Admin' : 'Tambah Admin Baru',
          style: const TextStyle(
              fontFamily: 'Sora',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.ink),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.ink),
          onPressed: () => Navigator.canPop(context)
              ? Navigator.pop(context)
              : context.go('/admin/users'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'INFORMASI AKUN ADMIN',
              style: TextStyle(
                fontFamily: 'Space Mono',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.muted,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email Akun / Username',
                hintText: 'karyawan@iderkopi.id',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon:
                    const Icon(Icons.email_outlined, color: AppColors.muted),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'PERAN ADMIN',
              style: TextStyle(
                fontFamily: 'Space Mono',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.muted,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue:
                  roles.any((role) => role['id']?.toString() == _selectedRoleId)
                      ? _selectedRoleId
                      : null,
              decoration: InputDecoration(
                labelText: 'Peran / Role',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.admin_panel_settings_outlined,
                    color: AppColors.muted),
              ),
              items: roles
                  .map((role) => DropdownMenuItem<String>(
                        value: role['id']?.toString(),
                        child: Text(role['name']?.toString() ?? 'Admin'),
                      ))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedRoleId = val);
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'KREDENSIAL KEAMANAN AKUN',
              style: TextStyle(
                fontFamily: 'Space Mono',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.muted,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText:
                    isEditing ? 'Password Baru (Opsional)' : 'Password Akun',
                hintText: isEditing
                    ? 'Biarkan kosong jika tidak diubah'
                    : 'Minimal 8 karakter',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.lock_outline_rounded,
                    color: AppColors.muted),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.red,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100)),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2)
                    : Text(
                        isEditing ? 'Simpan Perubahan' : 'Tambah Admin',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
