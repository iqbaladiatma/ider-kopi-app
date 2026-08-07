/// Jenis pengajuan izin.
enum LeaveType {
  izin,
  sakit,
  cuti;

  String get label {
    switch (this) {
      case LeaveType.izin:
        return 'Izin';
      case LeaveType.sakit:
        return 'Sakit';
      case LeaveType.cuti:
        return 'Cuti';
    }
  }

  String get icon {
    switch (this) {
      case LeaveType.izin:
        return '📋';
      case LeaveType.sakit:
        return '🏥';
      case LeaveType.cuti:
        return '🏖️';
    }
  }

  static LeaveType fromString(String? s) {
    switch (s?.toLowerCase()) {
      case 'sakit':
        return LeaveType.sakit;
      case 'cuti':
        return LeaveType.cuti;
      default:
        return LeaveType.izin;
    }
  }
}

/// Status pengajuan izin.
enum LeaveStatus {
  pending,
  approved,
  rejected;

  String get label {
    switch (this) {
      case LeaveStatus.pending:
        return 'Menunggu Approval';
      case LeaveStatus.approved:
        return 'Disetujui';
      case LeaveStatus.rejected:
        return 'Ditolak';
    }
  }

  static LeaveStatus fromString(String? s) {
    switch (s?.toLowerCase()) {
      case 'approved':
        return LeaveStatus.approved;
      case 'rejected':
        return LeaveStatus.rejected;
      default:
        return LeaveStatus.pending;
    }
  }
}

/// Model pengajuan izin/sakit/cuti.
class LeaveRequest {
  final int? id;
  final String userId;
  final LeaveType type;
  final DateTime startDate;
  final DateTime endDate;
  final String? reason;
  final String? attachmentFileId;
  final LeaveStatus status;
  final String? approverId;
  final DateTime? approvedAt;
  final String? approverNote;
  final DateTime? createdAt;

  const LeaveRequest({
    this.id,
    required this.userId,
    required this.type,
    required this.startDate,
    required this.endDate,
    this.reason,
    this.attachmentFileId,
    this.status = LeaveStatus.pending,
    this.approverId,
    this.approvedAt,
    this.approverNote,
    this.createdAt,
  });

  /// Jumlah hari (inklusif start & end).
  int get days {
    return endDate.difference(startDate).inDays + 1;
  }

  /// Apakah pengajuan ini bisa di-edit/dihapus (hanya jika masih pending).
  bool get canEdit => status == LeaveStatus.pending;

  LeaveRequest copyWith({
    int? id,
    String? userId,
    LeaveType? type,
    DateTime? startDate,
    DateTime? endDate,
    String? reason,
    String? attachmentFileId,
    LeaveStatus? status,
    String? approverId,
    DateTime? approvedAt,
    String? approverNote,
    DateTime? createdAt,
  }) {
    return LeaveRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      reason: reason ?? this.reason,
      attachmentFileId: attachmentFileId ?? this.attachmentFileId,
      status: status ?? this.status,
      approverId: approverId ?? this.approverId,
      approvedAt: approvedAt ?? this.approvedAt,
      approverNote: approverNote ?? this.approverNote,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    return LeaveRequest(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      userId: json['user_id']?.toString() ?? '',
      type: LeaveType.fromString(json['type']?.toString()),
      startDate: DateTime.parse(json['start_date'].toString()),
      endDate: DateTime.parse(json['end_date'].toString()),
      reason: json['reason']?.toString(),
      attachmentFileId: json['attachment_file_id']?.toString(),
      status: LeaveStatus.fromString(json['status']?.toString()),
      approverId: json['approver_id']?.toString(),
      approvedAt: json['approved_at'] != null
          ? DateTime.tryParse(json['approved_at'].toString())
          : null,
      approverNote: json['approver_note']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'type': type.name,
      'start_date': _toIsoDate(startDate),
      'end_date': _toIsoDate(endDate),
      if (reason != null) 'reason': reason,
      if (attachmentFileId != null) 'attachment_file_id': attachmentFileId,
      'status': status.name,
      if (approverId != null) 'approver_id': approverId,
      if (approvedAt != null) 'approved_at': approvedAt!.toIso8601String(),
      if (approverNote != null) 'approver_note': approverNote,
    };
  }

  static String _toIsoDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  String toString() =>
      'LeaveRequest($id, ${type.label}, ${_toIsoDate(startDate)} → ${_toIsoDate(endDate)}, ${status.label})';
}
