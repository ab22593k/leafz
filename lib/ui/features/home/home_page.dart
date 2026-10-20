import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leafz/helpers/game_mode_helper.dart';
import 'package:leafz/helpers/localizations_ext.dart';
import 'package:leafz/ui/core/app_text_styles.dart';
import 'package:leafz/ui/core/layout/bars.dart';
import 'package:leafz/ui/core/layout/scaffold.dart';
import 'package:leafz/ui/core/layout/panes.dart';
import 'package:leafz/ui/core/layout/spacing.dart';
import 'package:leafz/ui/features/background/background_stack.dart';
import 'package:leafz/ui/features/drawer/app_drawer.dart';
import 'package:leafz/ui/features/drawer/drawer_button.dart';
import 'package:leafz/ui/features/puzzle/ui/puzzle_header.dart';
import 'package:leafz/ui/features/puzzle/ui/puzzle_view.dart';
import 'package:leafz/ui/features/puzzle/ui/reset_puzzle_button.dart';
import 'package:leafz/ui/features/puzzle/view_models/puzzle_notifier.dart';
import 'package:flutter/material.dart' hide DrawerButton;

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // The Stack is the route root, so its constraints are the whole
        // window. The background must cover exactly that box — deriving it
        // from MediaQuery would ignore the space the route was actually
        // given.
        final size = constraints.biggest;

        // A fixed 460dp sidebar eats 55% of an 840dp window and leaves the
        // board cramped. Let the pane take a third of the width, bounded on
        // both ends, and the board keep the rest.
        final secondaryWidth = (size.width * 0.30).clamp(300.0, 440.0);

        return Stack(
          children: [
            BackgroundStack(size: size),
            LeafzScaffold(
              topBar: PuzzleAppBar(
                leading: const DrawerButton(),
                title: context.l10n.appTitle,
                actions: const [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: ResetPuzzleButton(),
                  ),
                ],
              ),
              bottomBar: const PuzzleToolbar(child: PuzzleHeader()),
              // On expanded+ the bottom bar is hidden and the stats live in
              // the co-planar pane below. A third surface is not needed; the
              // old `topRail` here rendered nothing but still reserved its
              // rail padding, stealing height from the board.
              // The puzzle stays single-pane (immersive) on compact/medium
              // per MD3: "single-pane layouts focus attention on one action
              // or view — playing a game."
              secondaryPane: const _StatsPane(),
              secondarySizing: PaneSizing.fixed,
              secondaryFixedWidth: secondaryWidth,
              drawer: const AppDrawer(),
              body: const PuzzleView(),
            ),
          ],
        );
      },
    );
  }
}

/// A co-planar supporting pane showing the puzzle's editorial masthead and
/// stats.
///
/// Per MD3: "Larger layouts can simultaneously display an inbox pane and a
/// pane containing a selected conversation. Additional space doesn't just
/// mean making the same thing bigger." This pane surfaces the rich labeled
/// stats that are hidden on compact/medium — and, because it has room, gives
/// them a rubric and a serif display line the compact bar cannot afford.
///
/// Everything shown is live state (mode, grid size, elapsed time, moves,
/// solved tiles). Nothing here is a decorative metric.
class _StatsPane extends ConsumerWidget {
  const _StatsPane();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final puzzleState = ref.watch(puzzleProvider);
    final modeName = GameModeHelper.localizedName(
      puzzleState.gameMode,
      context.l10n,
    );
    final size = puzzleState.n;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Rubric + display line: the pane reads as a magazine sidebar
          // rather than a metrics card. No border, no panel, no icon.
          Text(
            modeName.toUpperCase(),
            style: AppTextStyles.kicker.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.45),
            ),
          ),
          const SizedBox(height: Spacing.xxs),
          Text(
            '$size \u00d7 $size',
            style: AppTextStyles.displaySmall.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: Spacing.section),
          const PuzzleHeader(displayMode: HeaderDisplay.sidePane),
        ],
      ),
    );
  }
}
