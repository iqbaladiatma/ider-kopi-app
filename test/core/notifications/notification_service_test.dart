import 'package:flutter_test/flutter_test.dart';
import 'package:iderkopi_absensi/core/notifications/notification_service.dart';

void main() {
  group('NotificationService', () {
    late NotificationService service;

    setUp(() {
      service = NotificationService();
      service.enableTestMode();
    });

    test('enableTestMode sets initialized flag', () {
      expect(service.isInitialized, isTrue);
    });

    test('checkInReminderId is a constant', () {
      expect(service.checkInReminderId, 1001);
    });

    test('checkOutReminderId is a constant', () {
      expect(service.checkOutReminderId, 1002);
    });

    test('channelId is attendance_reminders', () {
      expect(service.channelId, 'attendance_reminders');
    });

    test('scheduleCheckInReminder does not throw in test mode', () async {
      await service.scheduleCheckInReminder(hour: 8, minute: 0);
      // Tidak ada assertion — hanya verify tidak throw
    });

    test('scheduleCheckOutReminder does not throw in test mode', () async {
      await service.scheduleCheckOutReminder(hour: 17, minute: 0);
    });

    test('cancelCheckInReminder does not throw in test mode', () async {
      await service.cancelCheckInReminder();
    });

    test('cancelCheckOutReminder does not throw in test mode', () async {
      await service.cancelCheckOutReminder();
    });

    test('cancelAll does not throw in test mode', () async {
      await service.cancelAll();
    });

    test('showInstant does not throw in test mode', () async {
      await service.showInstant(
        id: 999,
        title: 'Test',
        body: 'Body',
        payload: 'test',
      );
    });

    test('requestPermissions returns true in test mode', () async {
      expect(await service.requestPermissions(), isTrue);
    });
  });
}
