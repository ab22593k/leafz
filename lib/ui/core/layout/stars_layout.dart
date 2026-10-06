import 'dart:math';

import 'package:leafz/ui/features/background/stars_painter.dart';
import 'package:leafz/ui/core/layout/layout_delegate.dart';
import 'package:leafz/ui/core/layout/screen_type_helper.dart';
import 'package:flutter/material.dart';

class StarsLayout implements LayoutDelegate {
  @override
  final ScreenTypeHelper screenTypeHelper;
  final double starsMaxXOffset;
  final double starsMaxYOffset;

  StarsLayout({
    required this.screenTypeHelper,
    required this.starsMaxXOffset,
    required this.starsMaxYOffset,
    required this.starColor,
    Random? random,
  }) : random = random ?? Random();

  /// Star color, always supplied by the caller (theme-aware `onSurface` in
  /// [Stars]); a required param so there is no silent unthemed default.
  final Color starColor;

  /// Random source — injectable for deterministic tests.
  /// Defaults to a non-seeded [Random].
  final Random random;

  int get totalStarsCount => switch (screenTypeHelper.windowClass) {
    WindowClass.compact => 300,
    WindowClass.medium => 600,
    WindowClass.expanded => 800,
    WindowClass.large => 1000,
    WindowClass.extraLarge => 1200,
  };

  List<int> get randomStarXOffsets => _getRandomStarsOffsetsList(
    starsMaxXOffset.ceil() <= 0 ? 1 : starsMaxXOffset.ceil(),
  );

  List<int> get randomStarYOffsets => _getRandomStarsOffsetsList(
    starsMaxYOffset.ceil() <= 0 ? 1 : starsMaxYOffset.ceil(),
  );

  List<int> _getRandomStarsOffsetsList(int max) {
    List<int> offsets = [];
    for (int i = 0; i < totalStarsCount; i++) {
      offsets.add(random.nextInt(max));
    }
    return offsets;
  }

  List<double> get randomStarSizes {
    List<double> sizes = [];
    for (int i = 0; i < totalStarsCount; i++) {
      sizes.add(random.nextDouble() + 0.7);
    }
    return sizes;
  }

  List<int> get fadeOutStarIndices {
    List<int> indices = [];
    for (int i = 0; i < totalStarsCount; i++) {
      if (i % 5 == 0) {
        indices.add(i);
      }
    }
    return indices;
  }

  List<int> get fadeInStarIndices {
    List<int> indices = [];
    for (int i = 0; i < totalStarsCount; i++) {
      if (i % 3 == 0) {
        indices.add(i);
      }
    }
    return indices;
  }

  CustomPainter getPainter({required Animation<double> opacity}) {
    return StarsPainter(
      xOffsets: randomStarXOffsets,
      yOffsets: randomStarYOffsets,
      sizes: randomStarSizes,
      fadeOutStarIndices: fadeOutStarIndices,
      fadeInStarIndices: fadeInStarIndices,
      totalStarsCount: totalStarsCount,
      opacityAnimation: opacity,
      starColor: starColor,
    );
  }
}
