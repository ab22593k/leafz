import 'dart:ui' show ImageFilter;

import 'package:leafz/domain/models/tile.dart';
import 'package:leafz/ui/core/animations/animations_manager.dart';
import 'package:leafz/ui/core/layout/puzzle_layout.dart';
import 'package:leafz/ui/core/layout/screen_type_helper.dart';
import 'package:leafz/ui/core/app_text_styles.dart';
import 'package:flutter/material.dart';

class TileContent extends StatefulWidget {
  final Tile tile;
  final bool isPuzzleSolved;
  final int puzzleSize;
  final bool isBlindContentHidden;

  const TileContent({
    super.key,
    required this.tile,
    required this.isPuzzleSolved,
    required this.puzzleSize,
    this.isBlindContentHidden = false,
  });

  @override
  State<TileContent> createState() => _TileContentState();
}

class _TileContentState extends State<TileContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late Animation<double> _scale;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: AnimationsManager.tileHover.duration,
    );

    _scale = AnimationsManager.tileHover.tween.animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AnimationsManager.tileHover.curve,
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _wrapWithHoverScale(
      // Mirror the board's frosted-glass treatment on each tile: a GPU
      // [BackdropFilter] blur softens whatever sits behind the piece and the
      // translucent surface lets the aurora shader glow through every tile.
      ClipRect(
        child: BackdropFilter(
          // Same 20px glass blur as the board, per DESIGN.md.
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: const EdgeInsets.all(1.5),
            child: Container(
              decoration: BoxDecoration(
                // Correctly-placed tiles get a slightly more opaque fill to
                // reinforce their locked-in state.
                color:
                    (widget.tile.isAtCorrectLocation
                            ? colorScheme.surfaceContainerHighest
                            : colorScheme.surfaceContainerLow)
                        .withValues(alpha: 0.72),
                borderRadius: BorderRadius.zero,
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.15),
                  width: 0.5,
                ),
              ),
              child: Center(child: _buildTileLabel(colorScheme)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _wrapWithHoverScale(Widget child) {
    return MouseRegion(
      onEnter: (_) {
        if (!widget.isPuzzleSolved) {
          _animationController.forward();
        }
      },
      onExit: (_) {
        if (!widget.isPuzzleSolved) {
          _animationController.reverse();
        }
      },
      child: ScaleTransition(scale: _scale, child: child),
    );
  }

  Widget _buildTileLabel(ColorScheme colorScheme) {
    final screenWidth = MediaQuery.of(context).size.width;
    final wc = ScreenTypeHelper(screenWidth, 0).windowClass;

    if (widget.isBlindContentHidden) {
      return Icon(
        Icons.help_outline,
        size: (PuzzleLayout.tileTextSize(wc, widget.puzzleSize) ?? 24) * 0.6,
        color: colorScheme.onSurface.withValues(alpha: 0.25),
      );
    }

    return Text(
      '${widget.tile.value}',
      style: AppTextStyles.tileAdaptive(wc).copyWith(
        fontSize: PuzzleLayout.tileTextSize(wc, widget.puzzleSize),
        fontWeight: FontWeight.w900,
        color: colorScheme.onSurface,
      ),
    );
  }
}
