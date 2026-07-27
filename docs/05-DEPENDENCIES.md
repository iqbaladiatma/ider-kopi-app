# Dependencies (pubspec.yaml)

## Core Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter

  # HTTP & Networking
  dio: ^5.4.0                      # HTTP client with interceptors

  # State Management
  flutter_riverpod: ^2.4.0         # State management
  riverpod_annotation: ^2.3.0      # Code generation for providers

  # Navigation
  go_router: ^13.0.0               # Declarative routing

  # Storage
  flutter_secure_storage: ^9.0.0   # Secure token storage (Keystore/Keychain)

  # Location
  geolocator: ^11.0.0              # GPS location
  geocoding: ^2.1.0                # Reverse geocoding (address from lat/lng)

  # Camera & Image
  camera: ^0.10.5                  # Camera access
  image: ^4.1.0                    # Image processing/compress
  path_provider: ^2.1.0            # File system paths

  # Maps (optional for MVP)
  google_maps_flutter: ^2.5.0      # Map preview

  # Utilities
  intl: ^0.18.0                    # Date/number formatting

  # Models
  freezed_annotation: ^2.4.0       # Immutable model annotations
  json_annotation: ^4.8.0          # JSON serialization annotations

  # UI
  cached_network_image: ^3.3.0     # Cached selfie thumbnails in history
  flutter_svg: ^2.0.9              # SVG icons/illustrations
```

## Dev Dependencies

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

  # Code Generation
  build_runner: ^2.4.0
  freezed: ^2.4.0
  json_serializable: ^6.7.0
  riverpod_generator: ^2.3.0

  # Testing
  mockito: ^5.4.0
  integration_test:
    sdk: flutter
```

## Full pubspec.yaml

```yaml
name: iderkopi_absensi
description: Aplikasi absensi IderKopi dengan GPS dan foto selfie
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: '>=3.13.0'

dependencies:
  flutter:
    sdk: flutter
  dio: ^5.4.0
  flutter_riverpod: ^2.4.0
  riverpod_annotation: ^2.3.0
  go_router: ^13.0.0
  flutter_secure_storage: ^9.0.0
  geolocator: ^11.0.0
  geocoding: ^2.1.0
  camera: ^0.10.5
  image: ^4.1.0
  path_provider: ^2.1.0
  google_maps_flutter: ^2.5.0
  intl: ^0.18.0
  freezed_annotation: ^2.4.0
  json_annotation: ^4.8.0
  cached_network_image: ^3.3.0
  flutter_svg: ^2.0.9

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  build_runner: ^2.4.0
  freezed: ^2.4.0
  json_serializable: ^6.7.0
  riverpod_generator: ^2.3.0
  mockito: ^5.4.0
  integration_test:
    sdk: flutter

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/icons/
  fonts:
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-Regular.ttf
        - asset: assets/fonts/Inter-Medium.ttf
          weight: 500
        - asset: assets/fonts/Inter-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Inter-Bold.ttf
          weight: 700
```

## Permissions

### Android (`android/app/src/main/AndroidManifest.xml`)

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-feature android:name="android.hardware.camera" android:required="true" />
<uses-feature android:name="android.hardware.location.gps" android:required="true" />
```

### iOS (`ios/Runner/Info.plist`)

```xml
<key>NSCameraUsageDescription</key>
<string>Aplikasi membutuhkan kamera untuk foto selfie saat absensi</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Aplikasi membutuhkan lokasi untuk mencatat posisi saat absensi</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>Aplikasi membutuhkan lokasi untuk mencatat posisi saat absensi</string>
```
