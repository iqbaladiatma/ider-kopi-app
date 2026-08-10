import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iderkopi_absensi/features/sync/data/sync_repository.dart';
import 'package:iderkopi_absensi/features/sync/presentation/widgets/pending_sync_badge.dart';
import 'package:iderkopi_absensi/features/sync/providers/sync_providers.dart';

/// Fake SyncRepository yang return count tertentu tanpa benar-benar query DB.
class _FakeSyncRepository extends Fake implements SyncRepository {
  final int count;
  _FakeSyncRepository(this.count);

  @override
  Future<int> pendingCount() async => count;
}

void main() {
  testWidgets('PendingSyncBadge hidden when count is 0',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          syncRepositoryProvider.overrideWithValue(_FakeSyncRepository(0)),
        ],
        child: const MaterialApp(
          home: Scaffold(body: PendingSyncBadge()),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byIcon(Icons.sync_rounded), findsNothing);
    expect(find.textContaining('pending'), findsNothing);
  });

  testWidgets('PendingSyncBadge visible when count > 0',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          syncRepositoryProvider.overrideWithValue(_FakeSyncRepository(3)),
        ],
        child: const MaterialApp(
          home: Scaffold(body: PendingSyncBadge()),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byIcon(Icons.sync_rounded), findsOneWidget);
    expect(find.textContaining('3 absensi pending'), findsOneWidget);
  });
}
