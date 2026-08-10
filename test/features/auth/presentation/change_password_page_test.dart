import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iderkopi_absensi/features/auth/presentation/change_password_page.dart';

void main() {
  group('validatePasswordChange', () {
    test('requires every field', () {
      expect(
        validatePasswordChange(
          currentPassword: '',
          newPassword: 'new-password',
          confirmation: 'new-password',
        ),
        isNotNull,
      );
    });

    test('requires at least eight characters', () {
      expect(
        validatePasswordChange(
          currentPassword: 'old-password',
          newPassword: 'short',
          confirmation: 'short',
        ),
        contains('8'),
      );
    });

    test('rejects reuse of current password', () {
      expect(
        validatePasswordChange(
          currentPassword: 'same-password',
          newPassword: 'same-password',
          confirmation: 'same-password',
        ),
        contains('berbeda'),
      );
    });

    test('requires matching confirmation', () {
      expect(
        validatePasswordChange(
          currentPassword: 'old-password',
          newPassword: 'new-password',
          confirmation: 'different-password',
        ),
        contains('tidak cocok'),
      );
    });

    test('accepts a valid password change', () {
      expect(
        validatePasswordChange(
          currentPassword: 'old-password',
          newPassword: 'new-password',
          confirmation: 'new-password',
        ),
        isNull,
      );
    });
  });

  testWidgets('password fields are empty and obscured by default',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: ChangePasswordPage()),
      ),
    );

    final fields =
        tester.widgetList<TextField>(find.byType(TextField)).toList();
    expect(fields, hasLength(3));
    expect(fields.every((field) => field.obscureText), isTrue);
    expect(fields.every((field) => field.controller!.text.isEmpty), isTrue);
    expect(fields.every((field) => field.autofillHints!.isEmpty), isTrue);
  });
}
