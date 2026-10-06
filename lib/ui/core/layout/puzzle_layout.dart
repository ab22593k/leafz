import 'package:leafz/ui/core/layout/screen_type_helper.dart';
import 'package:leafz/ui/core/layout/spacing.dart';

class PuzzleLayout {
  final ScreenTypeHelper screenTypeHelper;

  PuzzleLayout({required this.screenTypeHelper});

  double get containerWidth {
    final screenWidth = screenTypeHelper.screenWidth;
    final margin = Spacing.puzzleMargin(screenTypeHelper.windowClass) * 2;
    final maxWidth = screenWidth - margin;
    final isVeryWide = screenWidth > 1400;

    return switch (screenTypeHelper.windowClass) {
      WindowClass.compact => maxWidth,
      WindowClass.medium => maxWidth.clamp(400, 560),
      WindowClass.expanded => maxWidth.clamp(420, isVeryWide ? 820 : 680),
      WindowClass.large => maxWidth.clamp(480, 900),
      WindowClass.extraLarge => maxWidth.clamp(540, 1000),
    };
  }

  static double? tileTextSize(WindowClass windowClass, int puzzleSize) {
    final desktop = windowClass != WindowClass.compact;
    return switch (puzzleSize) {
      > 5 => desktop ? 28 : 20,
      > 4 => desktop ? 36 : 25,
      > 3 => desktop ? 40 : 30,
      _ => null,
    };
  }
}
