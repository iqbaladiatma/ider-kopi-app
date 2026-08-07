import 'package:flutter_test/flutter_test.dart';
import 'package:iderkopi_absensi/core/config/api_provider.dart';

void main() {
  group('ApiProviderX', () {
    test('fromString returns directus for null', () {
      expect(ApiProviderX.fromString(null), ApiProvider.directus);
    });

    test('fromString returns directus for empty', () {
      expect(ApiProviderX.fromString(''), ApiProvider.directus);
    });

    test('fromString returns directus for unknown', () {
      expect(ApiProviderX.fromString('unknown'), ApiProvider.directus);
    });

    test('fromString returns goBackend for "gobackend"', () {
      expect(ApiProviderX.fromString('gobackend'), ApiProvider.goBackend);
    });

    test('fromString returns goBackend for "GOBACKEND" (case insensitive)', () {
      expect(ApiProviderX.fromString('GOBACKEND'), ApiProvider.goBackend);
    });

    test('fromString returns goBackend for "go"', () {
      expect(ApiProviderX.fromString('go'), ApiProvider.goBackend);
    });
  });

  group('ApiProvider.label', () {
    test('directus label', () {
      expect(ApiProvider.directus.label, 'Directus');
    });

    test('goBackend label', () {
      expect(ApiProvider.goBackend.label, 'Go Backend');
    });
  });
}
