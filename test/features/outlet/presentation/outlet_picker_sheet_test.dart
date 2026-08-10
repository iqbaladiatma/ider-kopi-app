import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iderkopi_absensi/features/outlet/data/outlet_model.dart';
import 'package:iderkopi_absensi/features/outlet/presentation/outlet_picker_sheet.dart';
import 'package:iderkopi_absensi/features/outlet/providers/outlet_providers.dart';

/// Mock outlets untuk widget test (tidak butuh SharedPreferences).
final _mockOutlets = <Outlet>[
  const Outlet(
    id: '1',
    nama: 'IderKopi - HQ',
    alamat: 'Jl. Kaliurang',
    latitude: -7.755,
    longitude: 110.408,
    radiusMeters: 100,
  ),
  const Outlet(
    id: '2',
    nama: 'IderKopi - Malioboro',
    alamat: 'Jl. Malioboro',
    latitude: -7.7928,
    longitude: 110.3658,
    radiusMeters: 100,
  ),
];

void main() {
  testWidgets('OutletPickerSheet renders header & outlet tiles',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          outletsProvider.overrideWith((ref) async => _mockOutlets),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: OutletPickerSheet(
              userLatitude: -7.7928,
              userLongitude: 110.3658,
            ),
          ),
        ),
      ),
    );

    // Pump a few frames to let async provider resolve
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Header text should be visible
    expect(find.text('Pilih Outlet'), findsOneWidget);
    expect(find.text('Outlet tempat kamu bekerja hari ini'), findsOneWidget);

    // Outlet tiles should render (InkWell for each outlet)
    expect(find.byType(InkWell), findsNWidgets(2));
    expect(find.text('HQ'), findsOneWidget);
    expect(find.text('Malioboro'), findsOneWidget);
  });

  testWidgets('outlet tile shows distance label', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          outletsProvider.overrideWith((ref) async => _mockOutlets),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: OutletPickerSheet(
              userLatitude: -7.7928,
              userLongitude: 110.3658,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Malioboro outlet is at user's location → "0 m dari kamu"
    // (terdekat dulu, jadi tile pertama = Malioboro)
    expect(find.textContaining('dari kamu'), findsWidgets);
  });
}
