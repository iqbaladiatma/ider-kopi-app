import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iderkopi_absensi/features/attendance/presentation/widgets/attendance_camera_status.dart';

void main() {
  test('camera permission errors produce actionable messages', () {
    expect(
      attendanceCameraErrorMessage(
        CameraException('CameraAccessDenied', 'denied'),
      ),
      contains('Izinkan kamera pada browser'),
    );
    expect(
      attendanceCameraErrorMessage(
        CameraException('CameraAccessDeniedWithoutPrompt', 'blocked'),
      ),
      contains('pengaturan situs browser'),
    );
    expect(
      attendanceCameraErrorMessage(
        CameraException('CameraUnavailable', 'missing'),
      ),
      contains('tidak ditemukan'),
    );
  });

  testWidgets('camera status shows initialization progress', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AttendanceCameraStatus(
            isInitializing: true,
            errorMessage: null,
            onRetry: null,
          ),
        ),
      ),
    );

    expect(find.text('Menyiapkan kamera...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Coba Lagi / Izinkan Kamera'), findsNothing);
  });

  testWidgets('camera failure shows reason and retries', (tester) async {
    var retries = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AttendanceCameraStatus(
            isInitializing: false,
            errorMessage: 'Izin kamera ditolak.',
            onRetry: () => retries++,
          ),
        ),
      ),
    );

    expect(find.text('Izin kamera ditolak.'), findsOneWidget);
    await tester.tap(find.text('Coba Lagi / Izinkan Kamera'));
    expect(retries, 1);
  });
}
