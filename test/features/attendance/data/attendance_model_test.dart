import 'package:flutter_test/flutter_test.dart';
import 'package:iderkopi_absensi/features/attendance/data/attendance_model.dart';

void main() {
  group('AttendanceRecord', () {
    test('fromJson parses outletId when present', () {
      final json = {
        'id': 1,
        'tanggal_absensi': '2026-08-05',
        'masuk': '08:00:00',
        'pulang': null,
        'kangider': 'IDR-0012',
        'outlet_id': 2,
      };
      final r = AttendanceRecord.fromJson(json);
      expect(r.outletId, '2');
    });

    test('fromJson returns null outletId when absent', () {
      final json = {
        'id': 1,
        'tanggal_absensi': '2026-08-05',
        'masuk': '08:00:00',
        'pulang': null,
        'kangider': 'IDR-0012',
      };
      final r = AttendanceRecord.fromJson(json);
      expect(r.outletId, isNull);
    });

    test('fromJson parses nested employee and backend outlet name', () {
      final r = AttendanceRecord.fromJson({
        'id': 'attendance-1',
        'employee_id': 'employee-uuid',
        'attendance_date': '2026-08-10',
        'outlet_id': 'outlet-uuid',
        'outlet_name': 'IDER KOPI Gejayan',
        'employee': {
          'employee_code': 'IKI0033',
          'full_name': 'Nama Karyawan Aktual',
        },
      });

      expect(r.kangider, 'IKI0033');
      expect(r.kangiderNama, 'Nama Karyawan Aktual');
      expect(r.outletId, 'outlet-uuid');
      expect(r.outlet, 'IDER KOPI Gejayan');
    });

    test('toJson includes outlet_id only when not null', () {
      final r = AttendanceRecord(
        tanggalAbsensi: '2026-08-05',
        masuk: '08:00:00',
        kangider: 'IDR-0012',
        outletId: '3',
      );
      final json = r.toJson();
      expect(json['outlet_id'], '3');
    });

    test('toJson omits outlet_id when null', () {
      final r = AttendanceRecord(
        tanggalAbsensi: '2026-08-05',
        masuk: '08:00:00',
        kangider: 'IDR-0012',
      );
      final json = r.toJson();
      expect(json.containsKey('outlet_id'), isFalse);
    });

    test('status returns tepatWaktu when masuk at 08:00', () {
      final r = AttendanceRecord(
        tanggalAbsensi: '2026-08-05',
        masuk: '08:00:00',
        kangider: 'IDR-0012',
      );
      expect(r.status, AttendanceStatus.tepatWaktu);
    });

    test('status returns terlambat when masuk at 08:01', () {
      final r = AttendanceRecord(
        tanggalAbsensi: '2026-08-05',
        masuk: '08:01:00',
        kangider: 'IDR-0012',
      );
      expect(r.status, AttendanceStatus.terlambat);
    });

    test('status returns alpha when masuk null', () {
      final r = AttendanceRecord(
        tanggalAbsensi: '2026-08-05',
        kangider: 'IDR-0012',
      );
      expect(r.status, AttendanceStatus.alpha);
    });

    test('hasCheckedIn / hasCheckedOut flags', () {
      final checkedIn = AttendanceRecord(
        tanggalAbsensi: '2026-08-05',
        masuk: '08:00:00',
        kangider: 'IDR-0012',
      );
      expect(checkedIn.hasCheckedIn, isTrue);
      expect(checkedIn.hasCheckedOut, isFalse);

      final checkedOut = AttendanceRecord(
        tanggalAbsensi: '2026-08-05',
        masuk: '08:00:00',
        pulang: '17:00:00',
        kangider: 'IDR-0012',
      );
      expect(checkedOut.hasCheckedOut, isTrue);
    });
  });

  group('CheckInRequest', () {
    test('toJson includes outlet_id when set', () {
      final req = CheckInRequest(
        tanggalAbsensi: '2026-08-05',
        masuk: '08:00:00',
        kangider: 'IDR-0012',
        latitude: -7.79,
        longitude: 110.36,
        selfieFileId: 'file-123',
        outletId: '2',
      );
      final json = req.toJson();
      expect(json['outlet_id'], '2');
      expect(json['check_in_source'], 'app');
      expect(json['selfie_file_id'], 'file-123');
    });

    test('toJson omits outlet_id when null', () {
      final req = CheckInRequest(
        tanggalAbsensi: '2026-08-05',
        masuk: '08:00:00',
        kangider: 'IDR-0012',
        latitude: -7.79,
        longitude: 110.36,
        selfieFileId: 'file-123',
      );
      final json = req.toJson();
      expect(json.containsKey('outlet_id'), isFalse);
    });
  });

  group('CheckOutRequest', () {
    test('toJson includes optional fields when set', () {
      final req = CheckOutRequest(
        pulang: '17:00:00',
        latitudePulang: -7.79,
        longitudePulang: 110.36,
        selfiePulangFileId: 'file-456',
        keterangan: 'Pulang tepat waktu',
      );
      final json = req.toJson();
      expect(json['pulang'], '17:00:00');
      expect(json['latitude_pulang'], -7.79);
      expect(json['selfie_pulang_file_id'], 'file-456');
      expect(json['keterangan'], 'Pulang tepat waktu');
    });

    test('toJson omits null optional fields', () {
      final req = CheckOutRequest(pulang: '17:00:00');
      final json = req.toJson();
      expect(json['pulang'], '17:00:00');
      expect(json.containsKey('latitude_pulang'), isFalse);
      expect(json.containsKey('keterangan'), isFalse);
    });
  });
}
