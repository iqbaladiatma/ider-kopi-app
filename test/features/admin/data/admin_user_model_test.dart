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

  test('parses core employee detail and relation names', () {
    final employee = CoreEmployee.fromJson({
      'id': 'employee-1',
      'employee_code': 'IDR-001',
      'full_name': 'Employee Test',
      'email': 'employee@example.invalid',
      'phone': '0800000000',
      'brand': 'IDER KOPI',
      'department_id': 'department-1',
      'department': {'id': 'department-1', 'name': 'Operasional'},
      'position_id': 'position-1',
      'position': {'id': 'position-1', 'name': 'Barista'},
      'shift_id': 'shift-1',
      'shift': {'id': 'shift-1', 'name': 'Pagi'},
      'outlet_id': 'outlet-1',
      'outlet_name': 'IderKopi',
      'join_date': '2026-01-02T00:00:00Z',
      'is_active': true,
    });

    expect(employee.departmentName, 'Operasional');
    expect(employee.positionName, 'Barista');
    expect(employee.shiftName, 'Pagi');
    expect(employee.outletName, 'IderKopi');
    expect(employee.isActive, isTrue);
  });

  test('parses admin login and creation timestamps', () {
    final user = AdminUser.fromJson({
      'id': 'admin-1',
      'email': 'admin@example.invalid',
      'role_id': 'role-1',
      'role': {'id': 'role-1', 'name': 'super_admin'},
      'is_active': true,
      'last_login_at': '2026-08-11T10:00:00Z',
      'created_at': '2026-01-01T00:00:00Z',
    });

    expect(user.lastLoginAt, DateTime.utc(2026, 8, 11, 10));
    expect(user.createdAt, DateTime.utc(2026));
  });
}
