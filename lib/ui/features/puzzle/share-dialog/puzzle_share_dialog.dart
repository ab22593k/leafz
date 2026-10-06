import 'package:leafz/ui/core/dialogs/app_alert_dialog.dart';
import 'package:leafz/ui/core/layout/screen_type_helper.dart';
import 'package:leafz/ui/core/layout/spacing.dart';
import 'package:leafz/ui/features/puzzle/share-dialog/puzzle_score.dart';
import 'package:flutter/material.dart';

class PuzzleSolvedDialog extends StatelessWidget {
  final int puzzleSize;
  final Duration solvingDuration;
  final int movesCount;

  const PuzzleSolvedDialog({
    super.key,
    required this.puzzleSize,
    required this.solvingDuration,
    required this.movesCount,
  });

  @override
  Widget build(BuildContext context) {
    final useWideLayout = context.windowClass != WindowClass.compact;

    return AppAlertDialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: Spacing.screenHPadding,
        vertical: Spacing.md,
      ),
      content: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: useWideLayout ? _landscapeContent : _portraitContent,
        ),
      ),
    );
  }

  /// The celebration image, bundled under `assets/images/solved/` (see
  /// pubspec) and precached at startup — the earlier `puzzle-solved/`
  /// path pointed at a directory that doesn't exist and never rendered.
  Widget get _puzzleSolvedImage => ClipRRect(
    borderRadius: BorderRadius.zero,
    child: Image.asset('assets/images/solved/solved.jpg'),
  );

  Widget get _puzzleScoreWidget => PuzzleScore(
    duration: solvingDuration,
    movesCount: movesCount,
    puzzleSize: puzzleSize,
  );

  Widget get _portraitContent => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 500),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _puzzleSolvedImage,
        const SizedBox(height: Spacing.sm),
        _puzzleScoreWidget,
      ],
    ),
  );

  Widget get _landscapeContent => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(flex: 3, child: _puzzleSolvedImage),
      const SizedBox(width: Spacing.md),
      Expanded(flex: 4, child: _puzzleScoreWidget),
    ],
  );
}
