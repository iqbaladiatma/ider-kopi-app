import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../data/admin_repository.dart';
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
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _kangiderIdController;
  
  String _selectedOutlet = 'IderKopi - Malioboro';
  String _selectedRole = 'Karyawan';
  bool _isSaving = false;

  bool get isEditing => widget.user != null;

  final outletsList = [
    'IderKopi - Malioboro',
    'IderKopi - Kotabaru',
    'IderKopi - Sudirman',
    'IderKopi - Seturan',
    'IderPoint',
  ];

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.user?.firstName ?? '');
    _lastNameController = TextEditingController(text: widget.user?.lastName ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _passwordController = TextEditingController();
    _kangiderIdController = TextEditingController(text: widget.user?.kangiderId ?? '');

    if (widget.user?.outlet != null && widget.user!.outlet!.isNotEmpty) {
      if (outletsList.contains(widget.user!.outlet)) {
        _selectedOutlet = widget.user!.outlet!;
      }
    }
    _selectedRole = widget.user?.roleName ?? 'Karyawan';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _kangiderIdController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final email = _emailController.text.trim();
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final password = _passwordController.text;
    final kangiderId = _kangiderIdController.text.trim();

    if (firstName.isEmpty) {
      _showSnack('Nama depan tidak boleh kosong');
      return;
    }
    if (email.isEmpty) {
      _showSnack('Email tidak boleh kosong');
      return;
    }
    if (!isEditing && password.isEmpty) {
      _showSnack('Password wajib diisi untuk karyawan baru');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(adminRepositoryProvider);

      AdminUser? updatedUser;
      if (isEditing) {
        final updateData = <String, dynamic>{
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'outlet': _selectedOutlet,
          'role': {'name': _selectedRole},
          if (kangiderId.isNotEmpty) 'kangider_id': kangiderId,
        };
        if (password.isNotEmpty) {
          updateData['password'] = password;
        }
        await repo.updateUser(widget.user!.id, updateData);
        updatedUser = widget.user!.copyWith(
          firstName: firstName,
          lastName: lastName,
          email: email,
          outlet: _selectedOutlet,
          roleName: _selectedRole,
          kangiderId: kangiderId.isNotEmpty ? kangiderId : widget.user!.kangiderId,
        );
      } else {
        await repo.createUser(CreateUserData(
          email: email,
          password: password,
          firstName: firstName,
          lastName: lastName,
          kangiderNama: '$firstName $lastName'.trim(),
          outlet: _selectedOutlet,
          roleId: _selectedRole.toLowerCase() == 'admin' ? 'role-admin' : 'role-user',
        ));
      }

      ref.invalidate(usersProvider);

      if (mounted) {
        _showSnack(
          isEditing ? 'Data karyawan berhasil diperbarui' : 'Karyawan baru berhasil ditambahkan',
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
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          isEditing ? 'Edit Data Karyawan' : 'Tambah Karyawan Baru',
          style: const TextStyle(fontFamily: 'Sora', fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.ink),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.ink),
          onPressed: () => Navigator.canPop(context) ? Navigator.pop(context) : context.go('/admin/users'),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'INFORMASI PROFIL KARYAWAN',
              style: TextStyle(
                fontFamily: 'Space Mono',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.muted,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      labelText: 'Nama Depan',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      labelText: 'Nama Belakang',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email Akun / Username',
                hintText: 'karyawan@iderkopi.id',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.email_outlined, color: AppColors.muted),
              ),
            ),

            const SizedBox(height: 14),

            TextField(
              controller: _kangiderIdController,
              decoration: InputDecoration(
                labelText: 'NIP / KangIder ID',
                hintText: 'IDR-0025',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.muted),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'PENUGASAN OUTLET & JABATAN',
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
              value: _selectedOutlet,
              decoration: InputDecoration(
                labelText: 'Penugasan Outlet',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.storefront_rounded, color: AppColors.muted),
              ),
              items: outletsList.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedOutlet = val);
              },
            ),

            const SizedBox(height: 14),

            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: InputDecoration(
                labelText: 'Peran / Role',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.admin_panel_settings_outlined, color: AppColors.muted),
              ),
              items: const [
                DropdownMenuItem(value: 'Karyawan', child: Text('Karyawan / Barista')),
                DropdownMenuItem(value: 'Admin', child: Text('Admin Manager')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedRole = val);
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
                labelText: isEditing ? 'Password Baru (Opsional)' : 'Password Akun',
                hintText: isEditing ? 'Biarkan kosong jika tidak diubah' : 'iderkopiku123',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.muted),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    : Text(
                        isEditing ? 'Simpan Perubahan Data' : 'Tambah Karyawan',
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
