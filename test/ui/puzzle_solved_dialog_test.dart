import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:leafz/generated/app_localizations.dart';
import 'package:leafz/ui/core/app_theme.dart';
import 'package:leafz/ui/features/puzzle/share-dialog/puzzle_share_dialog.dart';

void main() {
  group('PuzzleSolvedDialog celebration image', () {
    test('solved.jpg is bundled and loadable', () async {
      // Guards the dialog's asset path against regressions like the
      // former `assets/images/puzzle-solved/` typo, which pointed at a
      // directory that is neither registered in pubspec nor on disk.
      final data = await rootBundle.load('assets/images/solved/solved.jpg');
      check(data.lengthInBytes).isGreaterThan(0);
    });

    testWidgets('dialog renders the celebration image without error', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.light(),
          home: const Scaffold(
            body: PuzzleSolvedDialog(
              puzzleSize: 4,
              solvingDuration: Duration(minutes: 1),
              movesCount: 12,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(Image), findsOneWidget);
    });
  });
}
