import 'package:flutter_test/flutter_test.dart';
import 'package:iderkopi_absensi/features/leave/data/leave_model.dart';

void main() {
  group('LeaveType', () {
    test('fromString parses correctly', () {
      expect(LeaveType.fromString('izin'), LeaveType.izin);
      expect(LeaveType.fromString('sakit'), LeaveType.sakit);
      expect(LeaveType.fromString('cuti'), LeaveType.cuti);
      expect(LeaveType.fromString(null), LeaveType.izin);
      expect(LeaveType.fromString('unknown'), LeaveType.izin);
    });

    test('label is correct', () {
      expect(LeaveType.izin.label, 'Izin');
      expect(LeaveType.sakit.label, 'Sakit');
      expect(LeaveType.cuti.label, 'Cuti');
    });
  });

  group('LeaveStatus', () {
    test('fromString parses correctly', () {
      expect(LeaveStatus.fromString('pending'), LeaveStatus.pending);
      expect(LeaveStatus.fromString('approved'), LeaveStatus.approved);
      expect(LeaveStatus.fromString('rejected'), LeaveStatus.rejected);
      expect(LeaveStatus.fromString(null), LeaveStatus.pending);
    });
  });

  group('LeaveRequest', () {
    test('fromJson parses all fields', () {
      final json = {
        'id': 1,
        'user_id': 'usr-0012',
        'type': 'sakit',
        'start_date': '2026-08-03',
        'end_date': '2026-08-05',
        'reason': 'Demam',
        'status': 'approved',
        'approver_id': 'usr-admin',
        'approved_at': '2026-08-02T10:00:00Z',
        'approver_note': 'Semoga lekas sembuh',
        'created_at': '2026-08-01T09:00:00Z',
      };
      final leave = LeaveRequest.fromJson(json);
      expect(leave.id, 1);
      expect(leave.userId, 'usr-0012');
      expect(leave.type, LeaveType.sakit);
      expect(leave.startDate, DateTime(2026, 8, 3));
      expect(leave.endDate, DateTime(2026, 8, 5));
      expect(leave.reason, 'Demam');
      expect(leave.status, LeaveStatus.approved);
      expect(leave.approverId, 'usr-admin');
      expect(leave.approverNote, 'Semoga lekas sembuh');
    });

    test('days calculates inclusive count', () {
      final leave = LeaveRequest(
        userId: 'usr-0012',
        type: LeaveType.cuti,
        startDate: DateTime(2026, 8, 15),
        endDate: DateTime(2026, 8, 17),
      );
      expect(leave.days, 3);
    });

    test('days returns 1 for single day', () {
      final leave = LeaveRequest(
        userId: 'usr-0012',
        type: LeaveType.izin,
        startDate: DateTime(2026, 8, 10),
        endDate: DateTime(2026, 8, 10),
      );
      expect(leave.days, 1);
    });

    test('canEdit is true only when pending', () {
      final pending = LeaveRequest(
        userId: 'u', type: LeaveType.izin,
        startDate: DateTime.now(), endDate: DateTime.now(),
      );
      expect(pending.canEdit, isTrue);

      final approved = pending.copyWith(status: LeaveStatus.approved);
      expect(approved.canEdit, isFalse);
    });

    test('toJson round-trips', () {
      final leave = LeaveRequest(
        id: 5,
        userId: 'usr-0012',
        type: LeaveType.cuti,
        startDate: DateTime(2026, 8, 15),
        endDate: DateTime(2026, 8, 17),
        reason: 'Cuti tahunan',
      );
      final json = leave.toJson();
      expect(json['id'], 5);
      expect(json['user_id'], 'usr-0012');
      expect(json['type'], 'cuti');
      expect(json['start_date'], '2026-08-15');
      expect(json['end_date'], '2026-08-17');
      expect(json['status'], 'pending');
    });

    test('copyWith updates only specified fields', () {
      final original = LeaveRequest(
        userId: 'u', type: LeaveType.izin,
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 2),
      );
      final updated = original.copyWith(status: LeaveStatus.approved);
      expect(updated.status, LeaveStatus.approved);
      expect(updated.type, LeaveType.izin);
      expect(updated.startDate, DateTime(2026, 1, 1));
    });
  });
}
