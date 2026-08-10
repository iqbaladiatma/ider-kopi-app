import 'package:flutter_test/flutter_test.dart';
import 'package:iderkopi_absensi/features/admin/data/admin_user_model.dart';

void main() {
  test('parses mobile employee account state', () {
    final account = MobileEmployeeAccount.fromJson({
      'employee_id': 'employee-1',
      'user_id': 'user-1',
      'employee_code': 'IDR-001',
      'full_name': 'Employee Test',
      'email': 'employee@example.invalid',
      'brand': 'IDER KOPI',
      'department_name': 'Operasional',
      'position_name': 'Barista',
      'employee_active': true,
      'account_active': true,
      'must_change_password': true,
    });

    expect(account.employeeId, 'employee-1');
    expect(account.hasAccount, isTrue);
    expect(account.accountActive, isTrue);
    expect(account.mustChangePassword, isTrue);
  });

  test('missing user id represents an unprovisioned employee', () {
    final account = MobileEmployeeAccount.fromJson({
      'employee_id': 'employee-2',
      'employee_code': 'IDR-002',
      'full_name': 'Employee Without Account',
      'email': 'employee2@example.invalid',
      'brand': 'IDER KOPI',
      'employee_active': true,
    });

    expect(account.hasAccount, isFalse);
    expect(account.accountActive, isNull);
  });
}
