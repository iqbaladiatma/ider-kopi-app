import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'storage_backend.dart';

StorageBackend createPlatformStorageBackend() => NativeStorageBackend();

class NativeStorageBackend implements StorageBackend {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> deleteAll() => _storage.deleteAll();
}
