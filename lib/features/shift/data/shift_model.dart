import 'package:flutter/material.dart';

/// Model shift kerja (v2.0).
class Shift {
  final int? id;
  final String name;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final int? outletId;
  final String? outletName;
  final bool isActive;

  const Shift({
    this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    this.outletId,
    this.outletName,
    this.isActive = true,
  });

  /// Durasi shift dalam jam.
  double get durationHours {
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    var diff = endMinutes - startMinutes;
    if (diff < 0) diff += 24 * 60; // shift malam lintas hari
    return diff / 60.0;
  }

  /// Cek apakah [time] berada dalam jam shift.
  bool isWithinShift(TimeOfDay time) {
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    final timeMinutes = time.hour * 60 + time.minute;

    if (startMinutes <= endMinutes) {
      return timeMinutes >= startMinutes && timeMinutes <= endMinutes;
    } else {
      // Shift malam (lintas hari)
      return timeMinutes >= startMinutes || timeMinutes <= endMinutes;
    }
  }

  Shift copyWith({
    int? id,
    String? name,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    int? outletId,
    String? outletName,
    bool? isActive,
  }) {
    return Shift(
      id: id ?? this.id,
      name: name ?? this.name,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      outletId: outletId ?? this.outletId,
      outletName: outletName ?? this.outletName,
      isActive: isActive ?? this.isActive,
    );
  }

  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      name: json['name']?.toString() ?? '',
      startTime: _parseTime(json['start_time']?.toString()),
      endTime: _parseTime(json['end_time']?.toString()),
      outletId: json['outlet_id'] != null
          ? int.tryParse(json['outlet_id'].toString())
          : null,
      outletName: json['outlet_name']?.toString(),
      isActive: json['is_active'] != false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'start_time': _formatTime(startTime),
      'end_time': _formatTime(endTime),
      if (outletId != null) 'outlet_id': outletId,
      'is_active': isActive,
    };
  }

  static TimeOfDay _parseTime(String? s) {
    if (s == null || s.isEmpty) return const TimeOfDay(hour: 0, minute: 0);
    final parts = s.split(':');
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 0,
      minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
    );
  }

  static String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  String toString() => 'Shift($name, ${_formatTime(startTime)}-${_formatTime(endTime)})';
}

/// Penugasan shift ke user untuk tanggal tertentu.
class UserShift {
  final int? id;
  final String userId;
  final String? userName;
  final int shiftId;
  final Shift? shift;
  final DateTime date;

  const UserShift({
    this.id,
    required this.userId,
    this.userName,
    required this.shiftId,
    this.shift,
    required this.date,
  });

  factory UserShift.fromJson(Map<String, dynamic> json) {
    return UserShift(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      userId: json['user_id']?.toString() ?? '',
      userName: json['user_name']?.toString(),
      shiftId: int.tryParse(json['shift_id']?.toString() ?? '0') ?? 0,
      shift: json['shift'] != null
          ? Shift.fromJson(json['shift'] as Map<String, dynamic>)
          : null,
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'shift_id': shiftId,
      'date': '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
    };
  }

  @override
  String toString() =>
      'UserShift($userName, ${shift?.name ?? 'shift#$shiftId'}, ${date.day}/${date.month}/${date.year})';
}
