import 'package:leafz/helpers/duration_helper.dart';
import 'package:leafz/helpers/localizations_ext.dart';
import 'package:leafz/helpers/share_score_helper.dart';
import 'package:leafz/ui/core/layout/spacing.dart';
import 'package:leafz/ui/core/app_text_styles.dart';
import 'package:flutter/material.dart';

/// The solved-state cover.
///
/// Structured like the closing page of a magazine feature: rubric, serif
/// headline, deck, then a two-column score rule. The only live numbers are
/// the player's own — grid, time, moves.
class PuzzleScore extends StatelessWidget {
  final Duration duration;
  final int movesCount;
  final int puzzleSize;

  const PuzzleScore({
    super.key,
    required this.duration,
    required this.movesCount,
    required this.puzzleSize,
  });

  int get tilesCount => (puzzleSize * puzzleSize) - 1;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$puzzleSize \u00d7 $puzzleSize',
          style: AppTextStyles.kicker.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.45),
          ),
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          context.l10n.congratsTitle,
          style: AppTextStyles.displaySmall.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          context.l10n.congratsSubtitle,
          style: AppTextStyles.bodySmall.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: Spacing.lg),
        _statsRow(context, colorScheme),
        const SizedBox(height: Spacing.xl),
        _actionButtons(context),
      ],
    );
  }

  Widget _statsRow(BuildContext context, ColorScheme colorScheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _scoreStat(
            label: context.l10n.time,
            value: DurationHelper.toFormattedTime(duration),
            colorScheme: colorScheme,
          ),
        ),
        Expanded(
          child: _scoreStat(
            label: context.l10n.moves,
            value: '$movesCount',
            colorScheme: colorScheme,
          ),
        ),
      ],
    );
  }

  /// Rubric over numeral, the same unit the sidebar uses.
  Widget _scoreStat({
    required String label,
    required String value,
    required ColorScheme colorScheme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTextStyles.kicker.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.45),
          ),
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          value,
          style: AppTextStyles.statValue.copyWith(color: colorScheme.onSurface),
        ),
      ],
    );
  }

  Widget _actionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              ShareScoreHelper.openLink(
                ShareScoreHelper.getTwitterShareLink(
                  movesCount,
                  duration,
                  tilesCount,
                ),
              );
            },
            child: Text(context.l10n.share.toUpperCase()),
          ),
        ),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            child: Text(context.l10n.restart.toUpperCase()),
          ),
        ),
      ],
    );
  }
}
