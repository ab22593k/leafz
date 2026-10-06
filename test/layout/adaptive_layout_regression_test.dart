import 'dart:math' show Random;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leafz/domain/models/puzzle.dart';
import 'package:leafz/ui/core/layout/screen_type_helper.dart';
import 'package:leafz/ui/core/layout/stars_layout.dart';

void main() {
  group('ScreenTypeHelper', () {
    test('classifies widths at documented boundaries', () {
      expect(const ScreenTypeHelper(599, 800).windowClass, WindowClass.compact);
      expect(const ScreenTypeHelper(600, 800).windowClass, WindowClass.medium);
      expect(const ScreenTypeHelper(839, 800).windowClass, WindowClass.medium);
      expect(
        const ScreenTypeHelper(840, 800).windowClass,
        WindowClass.expanded,
      );
      expect(
        const ScreenTypeHelper(1199, 800).windowClass,
        WindowClass.expanded,
      );
      expect(const ScreenTypeHelper(1200, 800).windowClass, WindowClass.large);
      expect(const ScreenTypeHelper(1599, 800).windowClass, WindowClass.large);
      expect(
        const ScreenTypeHelper(1600, 800).windowClass,
        WindowClass.extraLarge,
      );
    });

    test('isWideLayout compares width against height', () {
      expect(const ScreenTypeHelper(800, 600).isWideLayout, isTrue);
      expect(const ScreenTypeHelper(600, 800).isWideLayout, isFalse);
    });

    test('isExpandedPlus is true on expanded and larger', () {
      expect(const ScreenTypeHelper(500, 800).isExpandedPlus, isFalse);
      expect(const ScreenTypeHelper(700, 800).isExpandedPlus, isFalse);
      expect(const ScreenTypeHelper(900, 800).isExpandedPlus, isTrue);
      expect(const ScreenTypeHelper(1300, 800).isExpandedPlus, isTrue);
      expect(const ScreenTypeHelper(1700, 800).isExpandedPlus, isTrue);
    });
  });

  group('WindowClassContext', () {
    testWidgets('reads full window size (height preserved)', (tester) async {
      WindowClass? seen;
      bool? wide;
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(900, 400)),
            child: Builder(
              builder: (context) {
                seen = context.windowClass;
                wide = context.screenTypeHelper.isWideLayout;
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      // 900dp wide with height preserved -> expanded (not compact).
      // The old `MediaQuery.sizeOf(context).width, 0` pattern discarded
      // height and broke isWideLayout consumers.
      expect(seen, WindowClass.expanded);
      expect(wide, isTrue);
    });
  });

  group('Puzzle.generateSolvableTiles', () {
    test('returns a solvable board with zero correct tiles', () {
      for (final n in [3, 4, 5, 6]) {
        final tiles = Puzzle.generateSolvableTiles(n, Random(42));
        expect(tiles.length, n * n);
        final puzzle = Puzzle(n: n, tiles: tiles);
        expect(puzzle.isSolvable(), isTrue);
        expect(puzzle.getNumberOfCorrectTiles(), 0);
      }
    });
  });

  group('StarsLayout', () {
    StarsLayout layoutFor(double width) => StarsLayout(
      screenTypeHelper: ScreenTypeHelper(width, 800),
      starsMaxXOffset: 800,
      starsMaxYOffset: 600,
      starColor: const Color(0xFFFFFFFF),
      random: Random(7),
    );

    test('star counts match spec per breakpoint (no off-by-one)', () {
      expect(layoutFor(500).totalStarsCount, 300);
      expect(layoutFor(700).totalStarsCount, 600);
      expect(layoutFor(900).totalStarsCount, 800);
      expect(layoutFor(1300).totalStarsCount, 1000);
      expect(layoutFor(1700).totalStarsCount, 1200);
    });

    test('generated lists have exactly totalStarsCount entries', () {
      final layout = layoutFor(500);
      expect(layout.randomStarXOffsets.length, layout.totalStarsCount);
      expect(layout.randomStarYOffsets.length, layout.totalStarsCount);
      expect(layout.randomStarSizes.length, layout.totalStarsCount);
      // Index lists only contain in-range indices.
      expect(
        layout.fadeOutStarIndices.every((i) => i < layout.totalStarsCount),
        isTrue,
      );
      expect(
        layout.fadeInStarIndices.every((i) => i < layout.totalStarsCount),
        isTrue,
      );
    });

    test('seeded random is deterministic', () {
      final a = layoutFor(500).randomStarXOffsets;
      final b = layoutFor(500).randomStarXOffsets;
      expect(a, b);
    });
  });
}
