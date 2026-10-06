import 'package:flutter/material.dart';

class StarsPainter extends CustomPainter {
  final List<int> xOffsets;
  final List<int> yOffsets;
  final List<int> fadeOutStarIndices;
  final List<int> fadeInStarIndices;
  final List<double> sizes;
  final Animation<double> opacityAnimation;
  final int totalStarsCount;
  final Color starColor;

  StarsPainter({
    required this.xOffsets,
    required this.yOffsets,
    required this.fadeOutStarIndices,
    required this.fadeInStarIndices,
    required this.sizes,
    required this.opacityAnimation,
    required this.totalStarsCount,
    required this.starColor,
  }) : super(repaint: opacityAnimation);

  final Paint _paint = Paint();

  double _getStarOpacity(int i) {
    if (fadeOutStarIndices.contains(i)) {
      return opacityAnimation.value * 0.3;
    } else if (fadeInStarIndices.contains(i)) {
      return (1 - opacityAnimation.value) * 0.3;
    } else {
      return 0.15;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Exclusive upper bound: offset/size lists hold exactly
    // [totalStarsCount] entries (indices 0..count-1).
    for (int i = 0; i < totalStarsCount; i++) {
      _paint.color = starColor.withValues(alpha: _getStarOpacity(i));
      canvas.drawCircle(
        Offset(xOffsets[i].toDouble(), yOffsets[i].toDouble()),
        sizes[i],
        _paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
