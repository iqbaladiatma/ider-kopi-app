import 'package:flutter_test/flutter_test.dart';
import 'package:iderkopi_absensi/features/auth/data/auth_model.dart';

void main() {
  group('UserProfile', () {
    test('parses must_change_password true', () {
      final user = UserProfile.fromJson({
        'id': 'user-1',
        'email': 'first.login@example.com',
        'must_change_password': true,
      });

      expect(user.mustChangePassword, isTrue);
    });

    test('defaults mustChangePassword to false when field is absent', () {
      final user = UserProfile.fromJson({
        'id': 'user-2',
        'email': 'existing@example.com',
      });

      expect(user.mustChangePassword, isFalse);
    });
  });

  test('LoginResult parses tokens and forced-password user', () {
    final result = LoginResult.fromJson({
      'data': {
        'access_token': 'access-token',
        'refresh_token': 'refresh-token',
        'user': {
          'id': 'user-1',
          'email': 'first.login@example.com',
          'role': 'employee',
          'must_change_password': true,
        },
      },
    });

    expect(result.tokens.accessToken, 'access-token');
    expect(result.tokens.refreshToken, 'refresh-token');
    expect(result.user.mustChangePassword, isTrue);
    expect(result.user.roleName, 'employee');
  });

  test('AuthTokens uses expires_at supplied by the issuer', () {
    final expiresAt = DateTime.utc(2026, 8, 11, 12, 30);

    final tokens = AuthTokens.fromJson({
      'access_token': 'access-token',
      'refresh_token': 'refresh-token',
      'expires_at': expiresAt.toIso8601String(),
    });

    expect(tokens.expiresAt, expiresAt);
  });
}
