import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leafz/data/services/storage_service.dart';
import 'package:leafz/generated/app_localizations.dart';
import 'package:leafz/ui/core/app_theme.dart';
import 'package:leafz/ui/core/layout/bars.dart';
import 'package:leafz/ui/features/drawer/app_drawer.dart';
import 'package:leafz/ui/features/puzzle/view_models/puzzle_notifier.dart';
import 'package:mocktail/mocktail.dart';

class _MockStorageService extends Mock implements StorageService {}

/// Scaffold lays out the drawer slot with *tight* full-window constraints.
/// A width set on a descendant `Container` is therefore discarded, which is
/// how the drawer silently became full-bleed on phones and tablets. These
/// tests pin the sheet's width and the clearance under the app bar — both
/// were broken in ways no other test covered.
void main() {
  Future<void> pumpDrawer(WidgetTester tester, Size window) async {
    tester.view.physicalSize = window;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final storage = _MockStorageService();
    when(() => storage.has(any())).thenReturn(false);
    when(() => storage.get<String>(any())).thenReturn(null);
    when(() => storage.get<int>(any())).thenReturn(null);
    when(() => storage.get<List>(any())).thenReturn(null);
    when(() => storage.get<Map>(any())).thenReturn(null);
    when(() => storage.set(any(), any())).thenAnswer((_) async {});
    when(() => storage.remove(any())).thenAnswer((_) async {});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [storageServiceProvider.overrideWithValue(storage)],
        child: MaterialApp(
          theme: AppTheme.dark(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            appBar: const PuzzleAppBar(title: 'Leafz'),
            drawer: const AppDrawer(),
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('drawer is narrower than a compact window', (tester) async {
    await pumpDrawer(tester, const Size(390, 844));

    final sheet = tester.getSize(
      find
          .descendant(
            of: find.byType(AppDrawer),
            matching: find.byType(ClipRRect),
          )
          .first,
    );

    expect(sheet.width, lessThan(390));
    expect(sheet.width, lessThanOrEqualTo(400));
    expect(sheet.height, 844);
  });

  testWidgets('drawer stays bounded on a tablet-width window', (tester) async {
    await pumpDrawer(tester, const Size(834, 1000));

    final sheet = tester.getSize(
      find
          .descendant(
            of: find.byType(AppDrawer),
            matching: find.byType(ClipRRect),
          )
          .first,
    );

    // 0.86 × 834 would be 717; the 400dp ceiling is what keeps the sheet a
    // control surface instead of a second pane.
    expect(sheet.width, lessThanOrEqualTo(400));
  });

  testWidgets('masthead clears the app bar', (tester) async {
    await pumpDrawer(tester, const Size(390, 844));

    final kickerTop = tester
        .getTopLeft(find.text('Slide puzzle'.toUpperCase()))
        .dy;

    // The app bar paints above the drawer; content that starts at the sheet's
    // top edge disappears behind it.
    expect(
      kickerTop,
      greaterThanOrEqualTo(const PuzzleAppBar().preferredSize.height),
    );
  });
}
