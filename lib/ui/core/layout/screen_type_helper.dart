import 'package:flutter/widgets.dart';

enum WindowClass { compact, medium, expanded, large, extraLarge }

class ScreenTypeHelper {
  final double screenWidth;
  final double screenHeight;

  const ScreenTypeHelper(this.screenWidth, this.screenHeight);

  static const double compactMaxWidth = 599;
  static const double mediumMaxWidth = 839;
  static const double expandedMaxWidth = 1199;
  static const double largeMaxWidth = 1599;

  bool get isWideLayout => screenWidth > screenHeight;

  WindowClass get windowClass => switch (screenWidth) {
    <= compactMaxWidth => WindowClass.compact,
    <= mediumMaxWidth => WindowClass.medium,
    <= expandedMaxWidth => WindowClass.expanded,
    <= largeMaxWidth => WindowClass.large,
    _ => WindowClass.extraLarge,
  };

  bool get isSinglePanePreferred => switch (windowClass) {
    WindowClass.compact || WindowClass.medium => true,
    _ => false,
  };

  int get recommendedPaneCount => switch (windowClass) {
    WindowClass.compact => 1,
    WindowClass.medium => 1,
    WindowClass.expanded || WindowClass.large => 2,
    WindowClass.extraLarge => 2,
  };

  int get maximumPaneCount => switch (windowClass) {
    WindowClass.compact => 1,
    WindowClass.medium => 2,
    WindowClass.expanded || WindowClass.large => 2,
    WindowClass.extraLarge => 3,
  };

  bool get railsVisible => switch (windowClass) {
    WindowClass.expanded || WindowClass.large || WindowClass.extraLarge => true,
    _ => false,
  };

  /// True on expanded and larger breakpoints where co-planar panes,
  /// leading/trailing rails, and extended navigation replace the
  /// compact bottom bar.
  bool get isExpandedPlus => switch (windowClass) {
    WindowClass.expanded || WindowClass.large || WindowClass.extraLarge => true,
    _ => false,
  };
}

/// Single source of truth for breakpoint lookups from a [BuildContext].
///
/// Replaces the copy-pasted
/// `ScreenTypeHelper(MediaQuery.sizeOf(context).width, 0).windowClass`
/// pattern (which discarded height and therefore broke [ScreenTypeHelper.isWideLayout]).
/// Uses the full app-window size so [ScreenTypeHelper.isWideLayout] works.
extension WindowClassContext on BuildContext {
  ScreenTypeHelper get screenTypeHelper {
    final size = MediaQuery.sizeOf(this);
    return ScreenTypeHelper(size.width, size.height);
  }

  WindowClass get windowClass => screenTypeHelper.windowClass;

  bool get isExpandedPlus => screenTypeHelper.isExpandedPlus;
}
