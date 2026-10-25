import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leafz/domain/models/game_mode.dart';
import 'package:leafz/domain/models/puzzle.dart';
import 'package:leafz/generated/app_localizations.dart';
import 'package:leafz/helpers/game_mode_helper.dart';
import 'package:leafz/helpers/localizations_ext.dart';
import 'package:leafz/ui/core/animations/animations_manager.dart';
import 'package:leafz/ui/core/animations/fade_in_transition.dart';
import 'package:leafz/ui/core/layout/screen_type_helper.dart';
import 'package:leafz/ui/core/layout/spacing.dart';
import 'package:leafz/ui/features/puzzle/ui/correct_tiles_count.dart';
import 'package:leafz/ui/features/puzzle/ui/moves_count.dart';
import 'package:leafz/ui/features/puzzle/ui/puzzle_stop_watch.dart';
import 'package:leafz/ui/features/puzzle/view_models/puzzle_notifier.dart';
import 'package:leafz/ui/core/app_text_styles.dart';
import 'package:flutter/material.dart';

enum HeaderDisplay { bottomBar, sidePane }

/// The puzzle's stat readout, in two editorial registers:
///
/// * [HeaderDisplay.bottomBar] — compact/medium. Label above value, no
///   icons, values in serif tabular figures.
/// * [HeaderDisplay.sidePane] — expanded+. The same three stats as a
///   stacked, left-aligned colophon with generous leading.
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
          _compactLayout(colorScheme, l10n),
        _ => const SizedBox.shrink(),
      },
    );
  }

  // ---------------------------------------------------------------------
  // Marathon
  // ---------------------------------------------------------------------

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

    // Wrap, not Row: at 320dp a marathon run plus its route can exceed the
    // bar's width, and a Row would paint the overflow stripes instead of
    // continuing on a second line.
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: Spacing.xxs,
      runSpacing: 2,
      children: [
        _marathonLabel(colorScheme, l10n),
        Text(
          '\u2022',
          style: AppTextStyles.labelSmall.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.3),
          ),
        ),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _marathonLabel(colorScheme, l10n),
        const SizedBox(height: Spacing.sm),
        Wrap(
          spacing: Spacing.xxs,
          runSpacing: Spacing.xxs,
          children: _marathonChips(colorScheme, endIdx, currentIdx, sizes),
        ),
      ],
    );
  }

  Widget _marathonLabel(ColorScheme colorScheme, AppLocalizations l10n) {
    return Text(
      GameModeHelper.localizedName(GameMode.marathon, l10n).toUpperCase(),
      style: AppTextStyles.kicker.copyWith(
        color: colorScheme.onSurface.withValues(alpha: 0.55),
      ),
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
              padding: const EdgeInsets.symmetric(horizontal: 1),
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        // Selection is expressed through fill strength alone — no border,
        // per the no-line rule. The current stage reads as a stronger
        // primary fill than the done stages' tertiary wash.
        color: isCurrent
            ? cs.primary.withValues(alpha: 0.22)
            : isDone
            ? cs.tertiary.withValues(alpha: 0.15)
            : Colors.transparent,
      ),
      child: Text(
        '$size\u00d7$size',
        style: AppTextStyles.labelSmall.copyWith(
          letterSpacing: 0.4,
          color: isDone
              ? cs.tertiary
              : isCurrent
              ? cs.primary
              : cs.onSurface.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Stats
  // ---------------------------------------------------------------------

  Widget _compactLayout(ColorScheme colorScheme, AppLocalizations l10n) {
    final valueStyle = AppTextStyles.statValueSmall.copyWith(
      color: colorScheme.onSurface,
    );

    // Three peers, label above value. No icons: the label already names the
    // stat, and the serif numeral is the thing worth looking at. Each column
    // is [Expanded] so a long translation ellipsizes instead of overflowing a
    // 320dp window.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: _statColumn(
            label: l10n.time,
            colorScheme: colorScheme,
            value: PuzzleStopWatch(showIcon: false, textStyle: valueStyle),
          ),
        ),
        Expanded(
          child: _statColumn(
            label: l10n.moves,
            colorScheme: colorScheme,
            value: MovesCount(showLabel: false, textStyle: valueStyle),
          ),
        ),
        Expanded(
          child: _statColumn(
            label: l10n.correct,
            colorScheme: colorScheme,
            value: CorrectTilesCount(
              colorScheme: colorScheme,
              showIcon: false,
              textStyle: valueStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _statColumn({
    required String label,
    required ColorScheme colorScheme,
    required Widget value,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: AppTextStyles.labelSmall.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.45),
          ),
        ),
        const SizedBox(height: 3),
        value,
      ],
    );
  }

  Widget _sidePaneLayout(ColorScheme colorScheme, AppLocalizations l10n) {
    final valueStyle = AppTextStyles.statValue.copyWith(
      color: colorScheme.onSurface,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _labeledStatRow(
          label: l10n.time,
          colorScheme: colorScheme,
          child: PuzzleStopWatch(showIcon: false, textStyle: valueStyle),
        ),
        const SizedBox(height: Spacing.lg),
        _labeledStatRow(
          label: l10n.moves,
          colorScheme: colorScheme,
          child: MovesCount(showLabel: false, textStyle: valueStyle),
        ),
        const SizedBox(height: Spacing.lg),
        _labeledStatRow(
          label: l10n.correct,
          colorScheme: colorScheme,
          child: CorrectTilesCount(
            colorScheme: colorScheme,
            showIcon: false,
            textStyle: valueStyle,
          ),
        ),
      ],
    );
  }

  /// Rubric over numeral — the sidebar's typographic unit. Right-aligned:
  /// the eye locks the numerals to the board's leading edge instead of
  /// chasing three staggered left starts.
  Widget _labeledStatRow({
    required String label,
    required ColorScheme colorScheme,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label.toUpperCase(),
          textAlign: TextAlign.right,
          style: AppTextStyles.kicker.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.45),
          ),
        ),
        const SizedBox(height: Spacing.xs),
        DefaultTextStyle(
          style: AppTextStyles.statValue.copyWith(color: colorScheme.onSurface),
          textAlign: TextAlign.right,
          child: child,
        ),
      ],
    );
  }
}
