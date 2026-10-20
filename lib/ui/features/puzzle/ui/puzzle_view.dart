import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leafz/ui/core/layout/puzzle_layout.dart';
import 'package:leafz/ui/features/puzzle/board/puzzle_board.dart';
import 'package:leafz/ui/features/puzzle/view_models/puzzle_notifier.dart';
import 'package:leafz/ui/features/puzzle/view_models/stop_watch_notifier.dart';
import 'package:flutter/material.dart';

class PuzzleView extends ConsumerStatefulWidget {
  const PuzzleView({super.key});

  @override
  ConsumerState<PuzzleView> createState() => _PuzzleViewState();
}

class _PuzzleViewState extends ConsumerState<PuzzleView> {
  /// Cached notifier — accessing [ref] inside [dispose] is unsafe because the
  /// widget may already be unmounted. Stash the reference in [initState].
  late final StopWatchNotifier _stopWatchNotifier;

  @override
  void initState() {
    super.initState();
    _stopWatchNotifier = ref.read(stopWatchProvider.notifier);
    final puzzleState = ref.read(puzzleProvider);
    if (puzzleState.hasStarted) {
      Future(() => _stopWatchNotifier.start());
    }
  }

  @override
  void dispose() {
    _stopWatchNotifier.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Measure the space this view was given, not the window: the scaffold
        // has already deducted the app bar, the bottom bar and the panes.
        // Horizontal gutters belong to the scaffold's pane area, so adding
        // another margin here would double them.
        final layout = PuzzleLayout(
          availableWidth: constraints.maxWidth,
          availableHeight: constraints.maxHeight,
        );

        return Center(child: PuzzleBoard(boardSide: layout.boardSide));
      },
    );
  }
}
