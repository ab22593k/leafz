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
import 'package:flutter/material.dart' hide DrawerButton;

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(
          constraints.maxWidth,
          constraints.maxHeight.isFinite
              ? constraints.maxHeight
              : MediaQuery.sizeOf(context).height,
        );
        return Stack(
          children: [
            BackgroundStack(size: size),
            const LeafzScaffold(
              topBar: PuzzleAppBar(
                leading: DrawerButton(),
                actions: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: ResetPuzzleButton(),
                  ),
                ],
              ),
              bottomBar: PuzzleToolbar(child: PuzzleHeader()),
              // On expanded+ breakpoints the bottom bar is hidden, so the stats
              // reflow into the top rail region — same information, new surface.
              topRail: PuzzleHeader(displayMode: HeaderDisplay.topRail),
              // On expanded+ a co-planar stats panel surfaces the labeled stats
              // alongside the focused puzzle board. The puzzle stays single-pane
              // (immersive) on compact/medium per MD3 "single-pane layouts focus
              // attention on one action or view — playing a game."
              secondaryPane: _StatsPane(),
              secondarySizing: PaneSizing.fixed,
              secondaryFixedWidth: PaneSnapPoints.narrow,
              drawer: AppDrawer(),
              body: PuzzleView(),
            ),
          ],
        );
      },
    );
  }
}

/// A co-planar supporting pane showing the puzzle stats.
///
/// Per MD3: "Larger layouts can simultaneously display an inbox pane and a
/// pane containing a selected conversation. Additional space doesn't just
/// mean making the same thing bigger." This pane surfaces the rich labeled
/// stats that are hidden on compact/medium.
class _StatsPane extends StatelessWidget {
  const _StatsPane();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.progress,
            style: TextStyle(
              fontFamily: AppTextStyles.primaryFontFamily,
              fontSize: 32,
              fontWeight: FontWeight.w400,
              height: 1.2,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: Spacing.lg),
          const PuzzleHeader(displayMode: HeaderDisplay.sidePane),
        ],
      ),
    );
  }
}
