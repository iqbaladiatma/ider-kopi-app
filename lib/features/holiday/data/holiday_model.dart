/// Model hari libur (nasional atau perusahaan).
class Holiday {
  final String? id;
  final DateTime tanggal;
  final String nama;
  final bool isNasional;

  const Holiday({
    this.id,
    required this.tanggal,
    required this.nama,
    this.isNasional = true,
  });

  /// Cek apakah tanggal tertentu adalah hari libur.
  bool isSameDate(DateTime other) {
    return tanggal.year == other.year &&
        tanggal.month == other.month &&
        tanggal.day == other.day;
  }

  factory Holiday.fromJson(Map<String, dynamic> json) {
    return Holiday(
      id: json['id']?.toString(),
      tanggal: DateTime.parse(
        (json['tanggal'] ?? json['date']).toString(),
      ),
      nama: (json['nama'] ?? json['name']).toString(),
      isNasional: _parseBool(json['is_nasional'] ?? json['is_national']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'tanggal':
          '${tanggal.year}-${tanggal.month.toString().padLeft(2, '0')}-${tanggal.day.toString().padLeft(2, '0')}',
      'nama': nama,
      'is_nasional': isNasional,
    };
  }

  static bool _parseBool(dynamic v) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) {
      return v.toLowerCase() == 'true' || v == '1';
    }
    return true;
  }

  @override
  String toString() =>
      'Holiday($nama, ${tanggal.toIso8601String().split('T')[0]})';
}
