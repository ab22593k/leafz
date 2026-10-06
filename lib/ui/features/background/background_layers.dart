import 'package:leafz/ui/core/layout/background_layer_layout.dart';
import 'package:leafz/ui/core/layout/screen_type_helper.dart';
import 'package:flutter/material.dart';

class BackgroundLayers {
  static List<BackgroundLayerType> types = [
    BackgroundLayerType.topBgPlanet,
    BackgroundLayerType.topRightPlanet,
    BackgroundLayerType.topLeftPlanet,
    BackgroundLayerType.bottomLeftPlanet,
    BackgroundLayerType.bottomRightPlanet,
    BackgroundLayerType.bottomBgPlanet,
  ];

  List<BackgroundLayerLayout> call(Size size) {
    final screenTypeHelper = ScreenTypeHelper(size.width, size.height);
    return List.generate(
      types.length,
      (i) => BackgroundLayerLayout(
        screenTypeHelper: screenTypeHelper,
        type: types[i],
      ),
    );
  }
}
