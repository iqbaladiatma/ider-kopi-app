import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../outlet/providers/outlet_providers.dart';
import '../data/admin_user_model.dart';
import '../providers/admin_providers.dart';

class AdminEmployeeDetailPage extends ConsumerWidget {
  const AdminEmployeeDetailPage({super.key, required this.employeeId});

  final String employeeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeeAsync = ref.watch(employeeDetailProvider(employeeId));
    final accounts = ref.watch(employeeAccountsProvider).asData?.value;
    final account =
        accounts?.where((item) => item.employeeId == employeeId).firstOrNull;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.ink,
        title: const Text('Detail Karyawan'),
        leading: IconButton(
          onPressed: () => context.go('/admin/users'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: employeeAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.ink),
        ),
        error: (error, _) => _ErrorState(
          message: 'Gagal memuat detail Karyawan: $error',
          onRetry: () => ref.invalidate(employeeDetailProvider(employeeId)),
        ),
        data: (employee) => _EmployeeContent(
          employee: employee,
          account: account,
          onEdit: () => _editEmployee(context, ref, employee),
          onToggleAccount: account?.hasAccount == true
              ? () => _toggleAccount(context, ref, account!)
              : null,
          onResetPassword: account?.hasAccount == true
              ? () => _resetPassword(context, ref, account!)
              : null,
        ),
      ),
    );
  }

  Future<void> _editEmployee(
    BuildContext context,
    WidgetRef ref,
    CoreEmployee employee,
  ) async {
    final nameController = TextEditingController(text: employee.fullName);
    final emailController = TextEditingController(text: employee.email ?? '');
    final phoneController = TextEditingController(text: employee.phone ?? '');
    var active = employee.isActive;
    var outletId = employee.outletId;
    final outlets = ref.read(outletsProvider).asData?.value ?? const [];

    final updates = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Data Karyawan'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nama lengkap'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email login'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Nomor telepon'),
                ),
                if (outlets.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String?>(
                    initialValue: outlets.any((item) => item.id == outletId)
                        ? outletId
                        : null,
                    decoration: const InputDecoration(labelText: 'Outlet'),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Tanpa outlet'),
                      ),
                      ...outlets.map(
                        (item) => DropdownMenuItem<String?>(
                          value: item.id,
                          child: Text(item.nama),
                        ),
                      ),
                    ],
                    onChanged: (value) =>
                        setDialogState(() => outletId = value),
                  ),
                ],
                const SizedBox(height: 8),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Karyawan aktif'),
                  value: active,
                  onChanged: (value) => setDialogState(() => active = value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                final email = emailController.text.trim();
                if (name.isEmpty || email.isEmpty || !email.contains('@')) {
                  return;
                }
                Navigator.pop(dialogContext, {
                  'full_name': name,
                  'email': email,
                  'phone': phoneController.text.trim(),
                  'outlet_id': outletId ?? '',
                  'is_active': active,
                });
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    if (updates == null || !context.mounted) return;

    try {
      await ref
          .read(adminRepositoryProvider)
          .updateEmployee(employee.id, updates);
      ref.invalidate(employeeDetailProvider(employee.id));
      ref.invalidate(employeeAccountsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data Karyawan dan profil login berhasil diperbarui'),
            backgroundColor: AppColors.green,
          ),
        );
      }
    } catch (error) {
      if (context.mounted) _showError(context, 'Gagal menyimpan: $error');
    }
  }

  Future<void> _toggleAccount(
    BuildContext context,
    WidgetRef ref,
    MobileEmployeeAccount account,
  ) async {
    try {
      await ref.read(adminRepositoryProvider).setEmployeeAccountActive(
            account.employeeId,
            active: account.accountActive != true,
          );
      ref.invalidate(employeeAccountsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Status akun login berhasil diperbarui')),
        );
      }
    } catch (error) {
      if (context.mounted) _showError(context, 'Gagal mengubah status: $error');
    }
  }

  Future<void> _resetPassword(
    BuildContext context,
    WidgetRef ref,
    MobileEmployeeAccount account,
  ) async {
    final controller = TextEditingController();
    var obscure = true;
    final password = await showDialog<String>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Set Password Baru'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Password lama tidak dapat dilihat. Masukkan password baru; Karyawan wajib menggantinya saat login.',
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                obscureText: obscure,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Password baru',
                  helperText: 'Minimal 8 karakter, maksimal 72 byte',
                  suffixIcon: IconButton(
                    tooltip:
                        obscure ? 'Lihat password' : 'Sembunyikan password',
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
          .resetEmployeePassword(account.employeeId, password);
      ref.invalidate(employeeAccountsProvider);
      if (context.mounted) {
        await _showOneTimePassword(context, password);
      }
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
              'Salin dan berikan melalui jalur aman. Password ini tidak dapat dilihat lagi setelah dialog ditutup.',
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

class _EmployeeContent extends StatelessWidget {
  const _EmployeeContent({
    required this.employee,
    required this.account,
    required this.onEdit,
    required this.onToggleAccount,
    required this.onResetPassword,
  });

  final CoreEmployee employee;
  final MobileEmployeeAccount? account;
  final VoidCallback onEdit;
  final VoidCallback? onToggleAccount;
  final VoidCallback? onResetPassword;

  @override
  Widget build(BuildContext context) {
    final date = employee.joinDate;
    final joined = date == null
        ? '-'
        : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
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
                child:
                    Icon(Icons.person_rounded, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                employee.fullName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Sora',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '${employee.employeeCode} · ${employee.brand}',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _DetailTile(label: 'Email login', value: employee.email ?? '-'),
        _DetailTile(label: 'Telepon', value: employee.phone ?? '-'),
        _DetailTile(
          label: 'Outlet',
          value: employee.outletName ?? 'Belum ditugaskan',
        ),
        _DetailTile(
          label: 'Departemen',
          value: employee.departmentName ?? '-',
        ),
        _DetailTile(label: 'Posisi', value: employee.positionName ?? '-'),
        _DetailTile(label: 'Shift', value: employee.shiftName ?? '-'),
        _DetailTile(label: 'Tanggal bergabung', value: joined),
        _DetailTile(
          label: 'Status Karyawan',
          value: employee.isActive ? 'Aktif' : 'Nonaktif',
        ),
        _DetailTile(
          label: 'Status akun login',
          value: account?.hasAccount != true
              ? 'Belum memiliki akun'
              : account!.accountActive == true
                  ? 'Aktif'
                  : 'Nonaktif',
        ),
        _DetailTile(
          label: 'Password',
          value: account?.mustChangePassword == true
              ? 'Password baru telah diset; wajib diganti saat login'
              : 'Tersimpan aman dan tidak dapat ditampilkan',
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: onEdit,
          icon: const Icon(Icons.edit_rounded),
          label: const Text('Edit Data Karyawan'),
        ),
        if (onResetPassword != null) ...[
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onResetPassword,
            icon: const Icon(Icons.key_rounded),
            label: const Text('Set / Reset Password Baru'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onToggleAccount,
            icon: Icon(
              account?.accountActive == true
                  ? Icons.block_rounded
                  : Icons.check_circle_outline_rounded,
            ),
            label: Text(
              account?.accountActive == true
                  ? 'Nonaktifkan Akun Login'
                  : 'Aktifkan Akun Login',
            ),
          ),
        ],
      ],
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({required this.label, required this.value});

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
          Text(
            value,
            style: const TextStyle(
              color: AppColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppColors.red, size: 40),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Coba Lagi')),
          ],
        ),
      ),
    );
  }
}
