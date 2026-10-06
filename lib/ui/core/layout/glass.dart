import 'dart:ui' show ImageFilter;

/// Single DESIGN.md glass token.
///
/// All frosted-glass surfaces (puzzle board, tiles, panes, drawers,
/// dialogs, toolbars) blur at 20px with a ghost border
/// (`outlineVariant` at 15% opacity, never a solid line).
/// Reference this instead of inlining `ImageFilter.blur(...)`.
class AppGlass {
  /// Blur sigma applied on both axes.
  static const double blurSigma = 20;

  /// Shared blur filter for frosted-glass surfaces.
  static ImageFilter get filter =>
      ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma);
}
