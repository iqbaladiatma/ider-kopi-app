import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static String formatDate(DateTime date) {
    return DateFormat('EEEE, dd MMM yyyy', 'id_ID').format(date);
  }

  static String formatDateShort(DateTime date) {
    return DateFormat('dd MMM yyyy', 'id_ID').format(date);
  }

  static String formatTime(DateTime time) {
    return DateFormat('HH:mm:ss').format(time);
  }

  static String formatTimeShort(String? time) {
    if (time == null || time.isEmpty) return '-';
    return time.substring(0, 5);
  }

  static String formatTimeWIB(String? time) {
    if (time == null || time.isEmpty) return '- WIB';
    return '${time.substring(0, 5)} WIB';
  }

  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy', 'id_ID').format(date);
  }

  static String todayDateString() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  static String greeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  static bool isLate(String checkInTime, {int thresholdHour = 8, int thresholdMinute = 0}) {
    final parts = checkInTime.split(':');
    if (parts.length < 2) return false;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    return hour > thresholdHour || (hour == thresholdHour && minute > thresholdMinute);
  }
}
