import 'dart:math' show Random;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leafz/domain/models/puzzle.dart';
import 'package:leafz/ui/core/layout/bars.dart';
import 'package:leafz/ui/core/layout/puzzle_layout.dart';
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

  group('PuzzleLayout', () {
    PuzzleLayout layoutFor(double w, double h) =>
        PuzzleLayout(availableWidth: w, availableHeight: h);

    test('board never exceeds the axis it was given', () {
      // The regression: a 1440×600 window produced a 560dp board in 536dp of
      // height because only the width was consulted.
      const viewports = [
        Size(1440, 536),
        Size(1440, 300),
        Size(840, 600),
        Size(390, 702),
        Size(320, 400),
        Size(2560, 1376),
      ];
      for (final viewport in viewports) {
        final layout = layoutFor(viewport.width, viewport.height);
        expect(
          layout.boardSide,
          lessThanOrEqualTo(viewport.shortestSide),
          reason: '${viewport.width}×${viewport.height}',
        );
      }
    });

    test('board is square and bounded by the shorter axis', () {
      // Width-rich, height-poor: height must win.
      final short = layoutFor(1200, 400);
      expect(short.boardSide, lessThanOrEqualTo(400));

      // Height-rich, width-poor: width must win.
      final narrow = layoutFor(300, 1000);
      expect(narrow.boardSide, lessThanOrEqualTo(300));
    });

    test('board stops growing past the cap', () {
      final huge = layoutFor(3840, 2160);
      expect(huge.boardSide, lessThanOrEqualTo(PuzzleLayout.maxSide));
    });

    test('degenerate constraints yield a zero board, not NaN', () {
      expect(layoutFor(0, 0).boardSide, 0);
      expect(layoutFor(double.infinity, double.infinity).boardSide, 0);
      // An unbounded axis is not degenerate — the bounded one still decides.
      expect(layoutFor(double.infinity, 400).boardSide, 368);
    });

    test('tile type scales with the tile, not the viewport', () {
      // Small tiles get small type, large tiles get large type, and neither
      // escapes the clamp.
      expect(PuzzleLayout.tileTextSize(30), 13);
      expect(PuzzleLayout.tileTextSize(100), 30);
      expect(PuzzleLayout.tileTextSize(400), 56);
    });
  });

  group('PuzzleAppBar insets', () {
    testWidgets('claims the status bar inset in its own height', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              size: Size(400, 800),
              padding: EdgeInsets.only(top: 47),
            ),
            child: Scaffold(
              appBar: PuzzleAppBar(title: 'Leafz'),
              body: SizedBox(),
            ),
          ),
        ),
      );

      // Scaffold allows `preferredSize.height + topInset`; the bar must use
      // all of it, otherwise its content is squashed into 64dp including the
      // status bar.
      expect(tester.getSize(find.byType(PuzzleAppBar)).height, 64 + 47);
    });

    testWidgets('stays 64dp when there is no inset', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: Size(1024, 768)),
            child: Scaffold(
              appBar: PuzzleAppBar(title: 'Leafz'),
              body: SizedBox(),
            ),
          ),
        ),
      );

      expect(tester.getSize(find.byType(PuzzleAppBar)).height, 64);
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
