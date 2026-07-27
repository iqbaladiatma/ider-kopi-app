class AppDateUtils {
  AppDateUtils._();

  static const List<String> _days = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  static const List<String> _months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static String _two(int n) => n.toString().padLeft(2, '0');

  static String formatDate(DateTime date) {
    return '${_days[date.weekday - 1]}, ${_two(date.day)} ${_months[date.month - 1]} ${date.year}';
  }

  static String formatDateShort(DateTime date) {
    return '${_two(date.day)} ${_months[date.month - 1]} ${date.year}';
  }

  static String formatTime(DateTime time) {
    return '${_two(time.hour)}:${_two(time.minute)}:${_two(time.second)}';
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
    return '${_months[date.month - 1]} ${date.year}';
  }

  static String todayDateString() {
    final now = DateTime.now();
    return '${now.year}-${_two(now.month)}-${_two(now.day)}';
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
