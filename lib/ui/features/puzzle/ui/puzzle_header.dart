import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leafz/domain/models/game_mode.dart';
import 'package:leafz/domain/models/puzzle.dart';
import 'package:leafz/generated/app_localizations.dart';
import 'package:leafz/helpers/game_mode_helper.dart';
import 'package:leafz/helpers/localizations_ext.dart';
import 'package:leafz/ui/core/animations/animations_manager.dart';
import 'package:leafz/ui/core/animations/fade_in_transition.dart';
import 'package:leafz/ui/core/layout/screen_type_helper.dart';
import 'package:leafz/ui/features/puzzle/ui/correct_tiles_count.dart';
import 'package:leafz/ui/features/puzzle/ui/moves_count.dart';
import 'package:leafz/ui/features/puzzle/ui/puzzle_stop_watch.dart';
import 'package:leafz/ui/features/puzzle/view_models/puzzle_notifier.dart';
import 'package:leafz/ui/core/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

enum HeaderDisplay { bottomBar, topRail, sidePane }

class PuzzleHeader extends ConsumerWidget {
  final HeaderDisplay displayMode;

  const PuzzleHeader({super.key, this.displayMode = HeaderDisplay.bottomBar});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wc = context.windowClass;
    final colorScheme = Theme.of(context).colorScheme;
    final puzzleState = ref.watch(puzzleProvider);
    final l10n = context.l10n;

    return FadeInTransition(
      delay: AnimationsManager.bgLayerAnimationDuration,
      child: switch ((puzzleState.gameMode, displayMode, wc)) {
        (GameMode.marathon, HeaderDisplay.sidePane, _) => _marathonPane(
          colorScheme,
          puzzleState,
          l10n,
        ),
        (GameMode.marathon, _, _) => _marathonHeader(
          colorScheme,
          puzzleState,
          l10n,
        ),
        (_, HeaderDisplay.sidePane, _) => _sidePaneLayout(colorScheme, l10n),
        (
          _,
          HeaderDisplay.bottomBar,
          WindowClass.compact || WindowClass.medium,
        ) =>
          _compactLayout(colorScheme),
        _ => const SizedBox.shrink(),
      },
    );
  }

  Widget _marathonHeader(
    ColorScheme colorScheme,
    PuzzleState puzzleState,
    AppLocalizations l10n,
  ) {
    final currentSize = puzzleState.n;
    final endSize = puzzleState.marathonEndSize ?? currentSize;
    final sizes = Puzzle.supportedPuzzleSizes;
    final currentIdx = sizes.indexOf(currentSize);
    final endIdx = sizes.indexOf(endSize);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _marathonLabel(colorScheme, l10n),
        const SizedBox(width: 4),
        Text(
          '\u2022',
          style: AppTextStyles.labelSmall.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.3),
          ),
        ),
        const SizedBox(width: 4),
        ..._marathonChips(colorScheme, endIdx, currentIdx, sizes),
      ],
    );
  }

  Widget _marathonPane(
    ColorScheme colorScheme,
    PuzzleState puzzleState,
    AppLocalizations l10n,
  ) {
    final currentSize = puzzleState.n;
    final endSize = puzzleState.marathonEndSize ?? currentSize;
    final sizes = Puzzle.supportedPuzzleSizes;
    final currentIdx = sizes.indexOf(currentSize);
    final endIdx = sizes.indexOf(endSize);

    return Wrap(
      spacing: 4,
      runSpacing: 6,
      children: [
        _marathonLabel(colorScheme, l10n),
        ..._marathonChips(colorScheme, endIdx, currentIdx, sizes),
      ],
    );
  }

  Widget _marathonLabel(ColorScheme colorScheme, AppLocalizations l10n) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        HugeIcon(
          icon: HugeIcons.strokeRoundedLink01,
          size: 16,
          color: colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 6),
        Text(
          GameModeHelper.localizedName(GameMode.marathon, l10n),
          style: AppTextStyles.labelSmall.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
            fontVariations: const [FontVariation('wght', 600)],
          ),
        ),
      ],
    );
  }

  List<Widget> _marathonChips(
    ColorScheme colorScheme,
    int endIdx,
    int currentIdx,
    List<int> sizes,
  ) {
    return List.generate(endIdx + 1, (i) {
      final size = sizes[i];
      final isDone = i < currentIdx;
      final isCurrent = i == currentIdx;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (i > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                '\u2192',
                style: AppTextStyles.labelSmall.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.2),
                ),
              ),
            ),
          _marathonChip(size, isDone, isCurrent, colorScheme),
        ],
      );
    });
  }

  Widget _marathonChip(int size, bool isDone, bool isCurrent, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        // Selection is expressed through fill strength alone — no border,
        // per DESIGN.md's no-line rule. The current stage reads as a
        // stronger primary fill than the done stages' tertiary wash.
        color: isCurrent
            ? cs.primary.withValues(alpha: 0.22)
            : isDone
            ? cs.tertiary.withValues(alpha: 0.15)
            : Colors.transparent,
      ),
      child: Text(
        '$size\u00d7$size',
        style: AppTextStyles.labelSmall.copyWith(
          color: isDone
              ? cs.tertiary
              : isCurrent
              ? cs.primary
              : cs.onSurface.withValues(alpha: 0.3),
          fontVariations: const [FontVariation('wght', 700)],
        ),
      ),
    );
  }

  Widget _compactLayout(ColorScheme colorScheme) {
    // All three stats render as peers: one shared value style and one icon
    // size, so the timer no longer towers over moves/correct. The value
    // style keeps color semantics (progress tint on correct tiles, error
    // on a critical countdown) intact.
    final statStyle = AppTextStyles.labelLarge.copyWith(
      color: colorScheme.onSurface,
      fontVariations: const [FontVariation('wght', 700)],
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        PuzzleStopWatch(textStyle: statStyle, iconSize: 14),
        _statChip(
          HugeIcon(
            icon: HugeIcons.strokeRoundedArrowUpDown,
            size: 14,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          MovesCount(textStyle: statStyle),
          colorScheme,
        ),
        CorrectTilesCount(colorScheme: colorScheme, textStyle: statStyle),
      ],
    );
  }

  Widget _sidePaneLayout(ColorScheme colorScheme, AppLocalizations l10n) {
    // The pane's labeled rows already claim a shared value style via
    // DefaultTextStyle, but the stat widgets set explicit styles internally
    // — so pass it down explicitly to make the 18px treatment actually
    // render for all three stats.
    final statStyle = AppTextStyles.titleMedium.copyWith(
      color: colorScheme.onSurface,
      fontVariations: const [FontVariation('wght', 700)],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _labeledStatRow(
          icon: const HugeIcon(icon: HugeIcons.strokeRoundedClock01, size: 16),
          label: l10n.time,
          child: PuzzleStopWatch(showIcon: false, textStyle: statStyle),
          colorScheme: colorScheme,
        ),
        const SizedBox(height: 16),
        _labeledStatRow(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedArrowUpDown,
            size: 16,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          label: l10n.moves,
          child: MovesCount(textStyle: statStyle),
          colorScheme: colorScheme,
        ),
        const SizedBox(height: 16),
        _labeledStatRow(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedCheckmarkCircle01,
            size: 16,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          label: l10n.correct,
          child: CorrectTilesCount(
            colorScheme: colorScheme,
            showIcon: false,
            textStyle: statStyle,
          ),
          colorScheme: colorScheme,
        ),
      ],
    );
  }

  Widget _labeledStatRow({
    required Widget icon,
    required String label,
    required Widget child,
    required ColorScheme colorScheme,
  }) {
    return Row(
      children: [
        icon,
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                  fontVariations: const [FontVariation('wght', 600)],
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 1),
              DefaultTextStyle(
                style: AppTextStyles.titleMedium.copyWith(
                  color: colorScheme.onSurface,
                  fontVariations: const [FontVariation('wght', 700)],
                ),
                child: child,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statChip(Widget iconWidget, Widget text, ColorScheme colorScheme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        iconWidget,
        const SizedBox(width: 4),
        DefaultTextStyle(
          style: AppTextStyles.labelSmall.copyWith(
            color: colorScheme.onSurface,
          ),
          child: text,
        ),
      ],
    );
  }
}
