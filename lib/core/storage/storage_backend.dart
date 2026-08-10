import 'storage_backend_native.dart'
    if (dart.library.js_interop) 'storage_backend_web.dart';

abstract interface class StorageBackend {
  Future<void> write(String key, String value);
  Future<String?> read(String key);
  Future<void> deleteAll();
}

StorageBackend createStorageBackend() => createPlatformStorageBackend();
