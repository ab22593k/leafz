import 'package:leafz/domain/models/position.dart';
import 'package:leafz/ui/core/layout/layout_delegate.dart';
import 'package:leafz/ui/core/layout/screen_type_helper.dart';
import 'package:flutter/cupertino.dart';

enum BackgroundLayerType {
  topRightPlanet,
  topLeftPlanet,
  topBgPlanet,
  bottomLeftPlanet,
  bottomRightPlanet,
  bottomBgPlanet,
}

class BackgroundLayerLayout implements LayoutDelegate {
  @override
  final ScreenTypeHelper screenTypeHelper;

  final BackgroundLayerType type;

  const BackgroundLayerLayout({
    required this.screenTypeHelper,
    required this.type,
  });

  String get assetUrl => 'assets/images/background/${type.name}.png';

  Size get size {
    final baseSize = _baseSize;
    final scale = _scaleForWindowClass;
    return baseSize * scale;
  }

  Size get _baseSize => switch (type) {
    BackgroundLayerType.topRightPlanet => const Size(356, 241),
    BackgroundLayerType.topLeftPlanet => const Size(144, 142),
    BackgroundLayerType.topBgPlanet => const Size(63, 63),
    BackgroundLayerType.bottomLeftPlanet => const Size(276, 196),
    BackgroundLayerType.bottomRightPlanet => const Size(275, 216),
    BackgroundLayerType.bottomBgPlanet => const Size(112, 104),
  };

  double get _scaleForWindowClass {
    final isWideLayout = screenTypeHelper.isWideLayout;
    return switch (screenTypeHelper.windowClass) {
      WindowClass.compact => 0.8,
      WindowClass.medium => isWideLayout ? 1.0 : 1.2,
      WindowClass.expanded => isWideLayout ? 0.9 : 1.4,
      WindowClass.large => isWideLayout ? 1.0 : 1.7,
      WindowClass.extraLarge => isWideLayout ? 1.1 : 2.0,
    };
  }

  Position get outOfViewPosition {
    const extraSpace = 10.0;

    return switch (type) {
      BackgroundLayerType.topRightPlanet ||
      BackgroundLayerType.topBgPlanet => Position(
        right: -(size.width + extraSpace),
        top: -(size.height + extraSpace),
      ),
      BackgroundLayerType.topLeftPlanet => Position(
        left: -(size.width + extraSpace),
        top: -(size.height + extraSpace),
      ),
      BackgroundLayerType.bottomLeftPlanet ||
      BackgroundLayerType.bottomBgPlanet => Position(
        left: -(size.width + extraSpace),
        bottom: -(size.height + extraSpace),
      ),
      BackgroundLayerType.bottomRightPlanet => Position(
        right: -(size.width + extraSpace),
        bottom: -(size.height + extraSpace),
      ),
    };
  }

  Position get position => switch (type) {
    BackgroundLayerType.topRightPlanet => Position(
      right: -size.width * 0.36,
      top: -size.height * 0.08,
    ),
    BackgroundLayerType.topLeftPlanet => Position(
      left: -size.width * 0.28,
      top: -size.height * 0.2,
    ),
    BackgroundLayerType.topBgPlanet => Position(
      right: size.width * 2.08,
      top: size.height * 1.74,
    ),
    BackgroundLayerType.bottomLeftPlanet => Position(
      left: -size.width * 0.42,
      bottom: 0,
    ),
    BackgroundLayerType.bottomRightPlanet => Position(
      right: -size.width * 0.45,
      bottom: -size.height * 0.45,
    ),
    BackgroundLayerType.bottomBgPlanet => Position(
      left: size.width * 0.6,
      bottom: size.height * 0.8,
    ),
  };

  @override
  String toString() =>
      'BackgroundLayerLayout(type: ${type.name}, size: $size, position: $position, assetUrl: $assetUrl)';
}
