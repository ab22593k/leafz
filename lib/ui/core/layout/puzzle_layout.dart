import 'dart:math' as math;

/// Resolves the puzzle board's square side from the space actually available
/// to it.
///
/// The pane a board sits in is not the window: bars, rails and pane gutters
/// have already been subtracted by the time [PuzzleView] measures. Sizing
/// from the width alone (the previous behaviour) overflowed the viewport
/// whenever a wide window was also short — a 1440×600 window asked for a
/// 560dp board inside 536dp of height.
///
/// Breakpoints deliberately play no part here. The one pane that hosts the
/// board is narrower than the window on expanded-and-larger layouts, so a
/// window class (or a class derived from the pane) would cap the board by a
/// number that does not describe the space it is in.
class PuzzleLayout {
  /// Horizontal space the board may occupy.
  final double availableWidth;

  /// Vertical space the board may occupy.
  final double availableHeight;

  const PuzzleLayout({
    required this.availableWidth,
    required this.availableHeight,
  });

  /// Vertical breathing room, applied only when height is the binding axis.
  /// On a phone the width binds and the pane gutter already supplies the
  /// margin; taking another 8% off every side would be a third gutter.
  static const double _fill = 0.92;

  /// Upper bound on the board. Past this the numerals needed to stay
  /// proportional start to read as billboard type rather than a puzzle.
  static const double maxSide = 820;

  /// Boards are square, so the side is bounded by the shorter axis. When the
  /// height binds, leave an optical gutter; when the width binds, use all of
  /// it.
  double get boardSide {
    final shortAxis = math.min(availableWidth, availableHeight);
    if (!shortAxis.isFinite || shortAxis <= 0) return 0;

    final side = availableHeight < availableWidth
        ? shortAxis * _fill
        : shortAxis;
    return math.min(side, maxSide);
  }

  /// Tile numerals scale with the tile they sit in, not with the viewport.
  /// A 6×6 board at 820dp and a 6×6 board at 360dp need different type, and
  /// the window class cannot tell them apart.
  static double tileTextSize(double tileSide) =>
      (tileSide * 0.30).clamp(13.0, 56.0);
}
