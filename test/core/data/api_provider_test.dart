import 'package:flutter_test/flutter_test.dart';
import 'package:iderkopi_absensi/core/config/app_config.dart';

void main() {
  test('core and auth API base URLs use separate services', () {
    expect(
      AppConfig.coreApiBaseUrl,
      'https://iderkopi.tailcbf3a3.ts.net:8443/core/api/v1/',
    );
    expect(
      AppConfig.authApiBaseUrl,
      'https://iderkopi.tailcbf3a3.ts.net:8443/employee-auth/api/v1/',
    );
    expect(AppConfig.apiBaseUrl, AppConfig.coreApiBaseUrl);
    expect('/api/v1'.allMatches(AppConfig.coreApiBaseUrl).length, 1);
    expect('/api/v1'.allMatches(AppConfig.authApiBaseUrl).length, 1);
  });
}
