import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leafz/ui/core/layout/puzzle_layout.dart';
import 'package:leafz/ui/core/layout/screen_type_helper.dart';
import 'package:leafz/ui/core/layout/spacing.dart';
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
        final windowWidth = constraints.maxWidth;
        final windowHeight = constraints.maxHeight;
        final screenTypeHelper = ScreenTypeHelper(windowWidth, windowHeight);
        final puzzleLayout = PuzzleLayout(screenTypeHelper: screenTypeHelper);
        final containerWidth = puzzleLayout.containerWidth;

        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.puzzleMargin(screenTypeHelper.windowClass),
            ),
            child:
                screenTypeHelper.windowClass == WindowClass.compact ||
                    screenTypeHelper.windowClass == WindowClass.medium
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      PuzzleBoard(
                        containerWidth: containerWidth,
                        windowClass: screenTypeHelper.windowClass,
                      ),
                      const Spacer(),
                    ],
                  )
                : Align(
                    alignment: const Alignment(0, -0.45),
                    child: PuzzleBoard(
                      containerWidth: containerWidth,
                      windowClass: screenTypeHelper.windowClass,
                    ),
                  ),
          ),
        );
      },
    );
  }
}
