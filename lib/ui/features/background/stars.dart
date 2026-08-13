import 'package:leafz/ui/core/animations/animations_manager.dart';
import 'package:leafz/ui/core/layout/screen_type_helper.dart';
import 'package:leafz/ui/core/layout/stars_layout.dart';
import 'package:flutter/material.dart';

class Stars extends StatefulWidget {
  final Size size;

  const Stars({super.key, required this.size});

  @override
  _StarsState createState() => _StarsState();
}

class _StarsState extends State<Stars> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _opacity;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: AnimationsManager.stars.duration,
    );
    _animationController.repeat(reverse: true);

    _opacity = AnimationsManager.stars.tween.animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AnimationsManager.stars.curve,
      ),
    );

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final starsLayout = StarsLayout(
      screenTypeHelper: ScreenTypeHelper(widget.size.width, widget.size.height),
      starsMaxXOffset: widget.size.width,
      starsMaxYOffset: widget.size.height,
      starColor: colorScheme.onSurface,
    );

    return CustomPaint(painter: starsLayout.getPainter(opacity: _opacity));
  }
}
