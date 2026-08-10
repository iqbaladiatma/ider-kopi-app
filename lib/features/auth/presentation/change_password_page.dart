import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../providers/auth_providers.dart';

String? validatePasswordChange({
  required String currentPassword,
  required String newPassword,
  required String confirmation,
}) {
  if (currentPassword.isEmpty || newPassword.isEmpty || confirmation.isEmpty) {
    return 'Semua kolom kata sandi wajib diisi';
  }
  if (newPassword.length < 8) {
    return 'Kata sandi baru minimal 8 karakter';
  }
  if (newPassword == currentPassword) {
    return 'Kata sandi baru harus berbeda dari kata sandi saat ini';
  }
  if (newPassword != confirmation) {
    return 'Konfirmasi kata sandi baru tidak cocok';
  }
  return null;
}

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmationController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirmation = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;
    final validationError = validatePasswordChange(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmation: _confirmationController.text,
    );
    if (validationError != null) {
      setState(() => _errorMessage = validationError);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      await repository.logout();
      ref.read(authStateProvider.notifier).state = AuthStatus.unauthenticated;
      ref.invalidate(currentUserProvider);
      ref.invalidate(userRoleProvider);

      if (mounted) {
        context.go('/login?passwordChanged=true');
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'Kata sandi tidak dapat diubah. Periksa kata sandi saat ini dan coba lagi.';
        });
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Ganti Kata Sandi'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLighter,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.lock_reset_rounded,
                        color: AppColors.primary,
                        size: 32,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Amankan akunmu',
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Ini adalah login pertamamu. Buat kata sandi baru sebelum melanjutkan.',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: AppColors.muted,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.redLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: AppColors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                _PasswordField(
                  key: const Key('currentPasswordField'),
                  controller: _currentPasswordController,
                  label: 'Kata sandi saat ini',
                  obscureText: _obscureCurrent,
                  onToggleVisibility: () => setState(
                    () => _obscureCurrent = !_obscureCurrent,
                  ),
                ),
                const SizedBox(height: 16),
                _PasswordField(
                  key: const Key('newPasswordField'),
                  controller: _newPasswordController,
                  label: 'Kata sandi baru',
                  helperText: 'Minimal 8 karakter',
                  obscureText: _obscureNew,
                  onToggleVisibility: () => setState(
                    () => _obscureNew = !_obscureNew,
                  ),
                ),
                const SizedBox(height: 16),
                _PasswordField(
                  key: const Key('confirmationPasswordField'),
                  controller: _confirmationController,
                  label: 'Konfirmasi kata sandi baru',
                  obscureText: _obscureConfirmation,
                  onToggleVisibility: () => setState(
                    () => _obscureConfirmation = !_obscureConfirmation,
                  ),
                  onSubmitted: (_) {
                    if (!_isSubmitting) _submit();
                  },
                ),
                const SizedBox(height: 28),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    key: const Key('changePasswordButton'),
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Simpan kata sandi baru',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    super.key,
    required this.controller,
    required this.label,
    required this.obscureText,
    required this.onToggleVisibility,
    this.helperText,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String? helperText;
  final bool obscureText;
  final VoidCallback onToggleVisibility;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      enableSuggestions: false,
      autocorrect: false,
      autofillHints: const <String>[],
      keyboardType: TextInputType.visiblePassword,
      textInputAction:
          onSubmitted == null ? TextInputAction.next : TextInputAction.done,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        filled: true,
        fillColor: AppColors.surfaceAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        suffixIcon: IconButton(
          tooltip:
              obscureText ? 'Tampilkan kata sandi' : 'Sembunyikan kata sandi',
          onPressed: onToggleVisibility,
          icon: Icon(
            obscureText
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
        ),
      ),
    );
  }
}
