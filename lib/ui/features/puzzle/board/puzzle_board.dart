import 'dart:ui' show ImageFilter;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leafz/domain/models/game_mode.dart';
import 'package:leafz/ui/core/animations/animations_manager.dart';
import 'package:leafz/ui/core/animations/pulse_transition.dart';
import 'package:leafz/ui/core/animations/scale_up_transition.dart';
import 'package:leafz/ui/core/layout/screen_type_helper.dart';
import 'package:leafz/ui/features/tile/tile_animated_positioned.dart';
import 'package:leafz/ui/features/tile/tile_content.dart';
import 'package:leafz/ui/features/tile/tile_gesture_detector.dart';
import 'package:leafz/ui/features/puzzle/view_models/puzzle_notifier.dart';
import 'package:leafz/ui/features/puzzle/view_models/stop_watch_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PuzzleBoard extends ConsumerStatefulWidget {
  final double containerWidth;
  final WindowClass windowClass;

  const PuzzleBoard({
    super.key,
    required this.containerWidth,
    this.windowClass = WindowClass.expanded,
  });

  @override
  ConsumerState<PuzzleBoard> createState() => _PuzzleBoardState();
}

class _PuzzleBoardState extends ConsumerState<PuzzleBoard> {
  final FocusNode keyboardListenerFocusNode = FocusNode();

  @override
  void dispose() {
    keyboardListenerFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final puzzleState = ref.watch(puzzleProvider);
    final tileWidth = widget.containerWidth / puzzleState.n;
    final isSolved = puzzleState.puzzle.isSolved;
    final isBlind = puzzleState.gameMode == GameMode.blind;
    final tilesBlinded = puzzleState.tilesBlinded;

    return ScaleUpTransition(
      delay: AnimationsManager.bgLayerAnimationDuration,
      child: KeyboardListener(
        onKeyEvent: (event) => _onKeyEvent(event, puzzleState),
        focusNode: keyboardListenerFocusNode,
        child: _buildBoardContent(
          puzzleState: puzzleState,
          colorScheme: colorScheme,
          tileWidth: tileWidth,
          isSolved: isSolved,
          isBlind: isBlind,
          tilesBlinded: tilesBlinded,
        ),
      ),
    );
  }

  void _onKeyEvent(KeyEvent event, PuzzleState puzzleState) {
    if (event case KeyDownEvent(:var physicalKey)) {
      if (physicalKey == PhysicalKeyboardKey.keyR) {
        ref.read(stopWatchProvider.notifier).stop();
        ref.read(puzzleProvider.notifier).generate(forceRefresh: true);
        return;
      }
      if (physicalKey == PhysicalKeyboardKey.keyD) {
        final scaffold = Scaffold.maybeOf(context);
        if (scaffold != null) {
          if (scaffold.isDrawerOpen) {
            Navigator.of(context).pop();
          } else {
            scaffold.openDrawer();
          }
        }
        return;
      }
    }
    ref.read(puzzleProvider.notifier).handleKeyboardEvent(event);
    if (event case KeyDownEvent()
        when puzzleState.movesCount == 1 &&
            keyboardListenerFocusNode.hasFocus) {
      ref.read(stopWatchProvider.notifier).start();
    }
  }

  Widget _buildBoardContent({
    required PuzzleState puzzleState,
    required ColorScheme colorScheme,
    required double tileWidth,
    required bool isSolved,
    required bool isBlind,
    required bool tilesBlinded,
  }) {
    return Builder(
      builder: (context) {
        if (!keyboardListenerFocusNode.hasFocus) {
          FocusScope.of(context).requestFocus(keyboardListenerFocusNode);
        }

        return Center(
          child: ClipRect(
            // Frosted-glass panel: a real GPU [BackdropFilter] blur softens the
            // animated aurora shader behind the board, and the translucent
            // surface lets that nebula glow through. This surfaces the
            // fragment-shader background inside the puzzle while a scrim of
            // surfaceContainer keeps the numbered tiles legible.
            child: BackdropFilter(
              // Per DESIGN.md: glass surfaces blur at 20px, and any required
              // boundary uses the "ghost border" fallback — outline-variant
              // at 15% opacity, never a solid line.
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                key: const ValueKey('puzzle_board'),
                width: widget.containerWidth,
                height: widget.containerWidth,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.zero,
                  color: colorScheme.surfaceContainer.withValues(alpha: 0.55),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Stack(
                  children: List.generate(
                    puzzleState.tilesWithoutWhitespace.length,
                    (index) {
                      final tile = puzzleState.tilesWithoutWhitespace[index];
                      final tileIsMovable = puzzleState.puzzle.tileIsMovable(
                        tile,
                      );
                      final isBlindContentHidden =
                          isBlind &&
                          tilesBlinded &&
                          !puzzleState.isTileRevealed(tile.currentLocation) &&
                          !isSolved;
                      return TileAnimatedPositioned(
                        tile: tile,
                        puzzleSize: puzzleState.n,
                        tileWidth: tileWidth,
                        tileGestureDetector: TileGestureDetector(
                          tile: tile,
                          tileContent: PulseTransition(
                            isActive: tileIsMovable && !isSolved,
                            child: TileContent(
                              tile: tile,
                              isPuzzleSolved: isSolved,
                              puzzleSize: puzzleState.n,
                              isBlindContentHidden: isBlindContentHidden,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
