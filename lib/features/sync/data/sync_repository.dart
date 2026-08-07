import 'dart:io';

import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/config/app_config.dart';
import '../../../core/database/daos/pending_sync_dao.dart';
import '../../../core/database/daos/sync_log_dao.dart';
import '../../../core/network/directus_client.dart';
import '../../attendance/data/attendance_model.dart';
import '../../attendance/data/attendance_repository.dart';
import 'conflict_resolver.dart';

/// Repository untuk mengelola antrian sync absensi offline.
///
/// Flow:
/// 1. Saat check-in/out: cek online → jika online, langsung kirim;
///    jika offline, enqueue ke `pending_sync`
/// 2. Background sync (workmanager) atau manual trigger: proses antrian
/// 3. Konflik ditangani oleh [ConflictResolver] & dicatat di `sync_log`
class SyncRepository {
  SyncRepository({
    required this.pendingDao,
    required this.syncLogDao,
    required this.attendanceRepo,
  });

  final PendingSyncDao pendingDao;
  final SyncLogDao syncLogDao;
  final AttendanceRepository attendanceRepo;

  /// Enqueue check-in untuk sync nanti.
  /// `selfiePath` = path file selfie lokal (XFile.path) untuk di-upload saat sync.
  Future<int> enqueueCheckIn({
    required CheckInRequest request,
    String? selfiePath,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    return pendingDao.enqueue(PendingSyncEntry(
      operation: PendingOperation.checkIn,
      payload: request.toJson(),
      selfiePath: selfiePath,
      createdAt: now,
      updatedAt: now,
    ));
  }

  /// Enqueue check-out untuk sync nanti.
  Future<int> enqueueCheckOut({
    required int recordId,
    required CheckOutRequest request,
    String? selfiePath,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    return pendingDao.enqueue(PendingSyncEntry(
      operation: PendingOperation.checkOut,
      recordId: recordId,
      payload: request.toJson(),
      selfiePath: selfiePath,
      createdAt: now,
      updatedAt: now,
    ));
  }

  /// Cek apakah ada koneksi internet (best-effort).
  Future<bool> isOnline() async {
    try {
      final dio = DirectusClient.instance.dio;
      await dio.get('/items/outlet_ider', queryParameters: {'limit': '1'}).timeout(
        const Duration(seconds: 4),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Proses semua entri pending. Return jumlah berhasil & gagal.
  Future<SyncResult> syncAll() async {
    int success = 0;
    int failed = 0;

    final pending = await pendingDao.getPending();
    if (pending.isEmpty) return SyncResult(success: 0, failed: 0, skipped: 0);

    final online = await isOnline();
    if (!online) {
      return SyncResult(success: 0, failed: 0, skipped: pending.length);
    }

    for (final entry in pending) {
      try {
        await pendingDao.updateStatus(
          entry.localId!,
          status: PendingStatus.syncing,
        );

        await _processEntry(entry);
        await pendingDao.updateStatus(
          entry.localId!,
          status: PendingStatus.synced,
        );
        success++;
      } catch (e) {
        await pendingDao.updateStatus(
          entry.localId!,
          status: PendingStatus.failed,
          error: e.toString(),
          incrementAttempts: true,
        );
        failed++;
        if (kDebugMode) {
          debugPrint('SyncRepository: gagal sync local_id=${entry.localId}: $e');
        }
      }
    }

    // Cleanup entri yang sudah synced (lebih dari 1 jam)
    await pendingDao.deleteSynced();

    return SyncResult(success: success, failed: failed, skipped: 0);
  }

  Future<void> _processEntry(PendingSyncEntry entry) async {
    switch (entry.operation) {
      case PendingOperation.checkIn:
        await _processCheckIn(entry);
        break;
      case PendingOperation.checkOut:
        await _processCheckOut(entry);
        break;
    }
  }

  Future<void> _processCheckIn(PendingSyncEntry entry) async {
    final request = CheckInRequest(
      tanggalAbsensi: entry.payload['tanggal_absensi']?.toString() ?? '',
      masuk: entry.payload['masuk']?.toString() ?? '',
      kangider: entry.payload['kangider']?.toString() ?? '',
      latitude: (entry.payload['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (entry.payload['longitude'] as num?)?.toDouble() ?? 0,
      selfieFileId: entry.payload['selfie_file_id']?.toString() ?? '',
      keterangan: entry.payload['keterangan']?.toString(),
      outletId: entry.payload['outlet_id'] != null
          ? int.tryParse(entry.payload['outlet_id'].toString())
          : null,
    );

    // Upload selfie jika ada path lokal
    String selfieFileId = request.selfieFileId;
    if (entry.selfiePath != null && !request.selfieFileId.startsWith('mock-')) {
      final xFile = XFile(entry.selfiePath!);
      selfieFileId = await attendanceRepo.uploadSelfie(xFile);
    }

    final actualRequest = CheckInRequest(
      tanggalAbsensi: request.tanggalAbsensi,
      masuk: request.masuk,
      kangider: request.kangider,
      latitude: request.latitude,
      longitude: request.longitude,
      selfieFileId: selfieFileId,
      keterangan: request.keterangan,
      outletId: request.outletId,
    );

    try {
      await attendanceRepo.checkIn(actualRequest);
    } on DioException catch (e) {
      // Cek apakah konflik (sudah ada absensi tanggal itu)
      if (e.response?.statusCode == 400 || e.response?.statusCode == 409) {
        final serverState = e.response?.data is Map
            ? (e.response!.data as Map).cast<String, dynamic>()
            : <String, dynamic>{};
        await ConflictResolver.resolveDuplicateCheckIn(
          syncLogDao: syncLogDao,
          localId: entry.localId,
          localState: entry.payload,
          serverState: serverState,
        );
        return; // Anggap selesai (server wins)
      }
      rethrow;
    }
  }

  Future<void> _processCheckOut(PendingSyncEntry entry) async {
    final recordId = entry.recordId;
    if (recordId == null) {
      throw Exception('record_id null untuk check_out sync');
    }

    final request = CheckOutRequest(
      pulang: entry.payload['pulang']?.toString() ?? '',
      latitudePulang: (entry.payload['latitude_pulang'] as num?)?.toDouble(),
      longitudePulang: (entry.payload['longitude_pulang'] as num?)?.toDouble(),
      selfiePulangFileId: entry.payload['selfie_pulang_file_id']?.toString(),
      keterangan: entry.payload['keterangan']?.toString(),
    );

    // Upload selfie pulang jika ada
    String? selfieId = request.selfiePulangFileId;
    if (entry.selfiePath != null &&
        selfieId != null &&
        !selfieId.startsWith('mock-')) {
      final xFile = XFile(entry.selfiePath!);
      selfieId = await attendanceRepo.uploadSelfie(xFile);
    }

    final actualRequest = CheckOutRequest(
      pulang: request.pulang,
      latitudePulang: request.latitudePulang,
      longitudePulang: request.longitudePulang,
      selfiePulangFileId: selfieId,
      keterangan: request.keterangan,
    );

    try {
      await attendanceRepo.checkOut(recordId, actualRequest);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 || e.response?.statusCode == 409) {
        final serverState = e.response?.data is Map
            ? (e.response!.data as Map).cast<String, dynamic>()
            : <String, dynamic>{};
        await ConflictResolver.resolveAlreadyCheckedOut(
          syncLogDao: syncLogDao,
          localId: entry.localId,
          localState: entry.payload,
          serverState: serverState,
        );
        return;
      }
      rethrow;
    }
  }

  /// Jumlah antrian pending (untuk badge UI).
  Future<int> pendingCount() async {
    return pendingDao.countPending();
  }
}

/// Hasil operasi sync.
class SyncResult {
  final int success;
  final int failed;
  final int skipped;

  const SyncResult({
    required this.success,
    required this.failed,
    required this.skipped,
  });

  int get total => success + failed + skipped;

  @override
  String toString() =>
      'SyncResult(success=$success, failed=$failed, skipped=$skipped)';
}
