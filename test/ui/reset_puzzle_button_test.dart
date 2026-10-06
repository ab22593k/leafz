import 'package:flutter/material.dart' hide DrawerButton;
import 'package:flutter_test/flutter_test.dart';
import 'package:checks/checks.dart';
import 'package:flutter_checks/flutter_checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leafz/data/services/storage_service.dart';
import 'package:leafz/generated/app_localizations.dart';
import 'package:leafz/ui/core/app_theme.dart';
import 'package:leafz/ui/features/puzzle/ui/reset_puzzle_button.dart';
import 'package:leafz/ui/features/puzzle/view_models/puzzle_notifier.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hugeicons/hugeicons.dart';

class _MockStorageService extends Mock implements StorageService {}

class _TestApp extends StatelessWidget {
  final Widget child;
  const _TestApp({required this.child});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light(),
      home: Scaffold(body: child),
    );
  }
}

Widget Function() buildTest({required double screenWidth}) {
  return () {
    final storage = _MockStorageService();
    when(() => storage.has(any())).thenReturn(false);
    when(() => storage.get<String>(any())).thenReturn(null);
    when(() => storage.get<int>(any())).thenReturn(null);
    when(() => storage.get<List>(any())).thenReturn(null);
    when(() => storage.get<Map>(any())).thenReturn(null);
    when(() => storage.set(any(), any())).thenAnswer((_) async {});
    when(() => storage.remove(any())).thenAnswer((_) async {});
    when(() => storage.clear()).thenAnswer((_) async {});

    return ProviderScope(
      overrides: [storageServiceProvider.overrideWithValue(storage)],
      child: _TestApp(
        child: MediaQuery(
          data: MediaQueryData(size: Size(screenWidth, 800)),
          child: const ResetPuzzleButton(),
        ),
      ),
    );
  };
}

extension on WidgetTester {
  Future<void> settle() => pump(const Duration(seconds: 2));
}

void main() {
  group('ResetPuzzleButton — desktop layout', () {
    testWidgets('uses extended FAB with no icon', (tester) async {
      await tester.pumpWidget(buildTest(screenWidth: 900)());
      await tester.settle();

      final fab = tester.widget<FloatingActionButton>(
        find.byKey(const ValueKey('reset_button')),
      );

      check(fab).isNotNull();
      check(find.byType(HugeIcon)).findsNothing();
      check(find.byIcon(Icons.refresh)).findsNothing();
    });

    testWidgets('has zero border radius', (tester) async {
      await tester.pumpWidget(buildTest(screenWidth: 900)());
      await tester.settle();

      final fab = tester.widget<FloatingActionButton>(
        find.byKey(const ValueKey('reset_button')),
      );
      final shape = fab.shape as RoundedRectangleBorder;
      check(shape.borderRadius).equals(BorderRadius.zero);
    });

    testWidgets('shows correct label text', (tester) async {
      await tester.pumpWidget(buildTest(screenWidth: 900)());
      await tester.settle();

      expect(find.text('Reset'), findsOneWidget);
    });

    testWidgets('uses primary as background and onPrimary as foreground', (
      tester,
    ) async {
      await tester.pumpWidget(buildTest(screenWidth: 900)());
      await tester.settle();

      final fab = tester.widget<FloatingActionButton>(
        find.byKey(const ValueKey('reset_button')),
      );
      final fabElement = tester.element(
        find.byKey(const ValueKey('reset_button')),
      );
      final theme = Theme.of(fabElement);

      check(fab.backgroundColor).equals(theme.colorScheme.primary);
      check(fab.foregroundColor).equals(theme.colorScheme.onPrimary);
    });

    testWidgets('uses AppTextStyles.button for label', (tester) async {
      await tester.pumpWidget(buildTest(screenWidth: 900)());
      await tester.settle();

      final text = tester.widget<Text>(
        find.descendant(
          of: find.byKey(const ValueKey('reset_button')),
          matching: find.byType(Text),
        ),
      );
      check(text.style?.fontFamily).equals('OpenDyslexic');
      check(text.style?.fontSize).equals(14.0);
      check(text.style?.fontWeight).equals(FontWeight.w600);
    });
  });
}
