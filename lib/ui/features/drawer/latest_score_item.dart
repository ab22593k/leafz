import 'package:leafz/helpers/duration_helper.dart';
import 'package:leafz/domain/models/score.dart';
import 'package:leafz/domain/models/game_mode.dart';
import 'package:leafz/ui/core/layout/spacing.dart';
import 'package:leafz/ui/core/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class LatestScoreItem extends StatelessWidget {
  final Score score;
  final double paddingLeft;
  final int rank;
  final bool isBest;

  const LatestScoreItem(
    this.score, {
    super.key,
    required this.paddingLeft,
    required this.rank,
    required this.isBest,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.only(
        left: paddingLeft,
        right: Spacing.screenHPadding + 4,
        top: Spacing.sm + 2,
        bottom: Spacing.sm + 2,
      ),
      child: Row(
        children: [
          // Rank column: serif tabular figures so the column stays aligned.
          SizedBox(
            width: 22,
            child: isBest
                ? HugeIcon(
                    icon: HugeIcons.strokeRoundedStarAward01,
                    size: 12,
                    color: _medalColorFor(colorScheme),
                  )
                : Text(
                    '$rank'.padLeft(2, '0'),
                    style: AppTextStyles.statValueSmall.copyWith(
                      fontSize: 13,
                      color: colorScheme.onSurface.withValues(alpha: 0.35),
                    ),
                  ),
          ),
          const SizedBox(width: Spacing.xs),
          SizedBox(
            width: 38,
            child: Text(
              '${score.puzzleSize}\u00d7${score.puzzleSize}',
              style: AppTextStyles.statValueSmall.copyWith(
                fontSize: 14,
                color: colorScheme.onSurface.withValues(alpha: 0.85),
              ),
            ),
          ),
          // Mode tag for non-classic scores
          if (score.gameMode != GameMode.classic) ...[
            const SizedBox(width: Spacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: _modeTagColor(score.gameMode, colorScheme),
                borderRadius: BorderRadius.zero,
              ),
              child: Text(
                _modeTagLabel(score.gameMode),
                style: AppTextStyles.kicker.copyWith(
                  fontSize: 9,
                  letterSpacing: 1.2,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
          const Spacer(),
          _scoreDetails(colorScheme: colorScheme),
        ],
      ),
    );
  }

  /// Time and moves as a compact serif rule. Icons were removed: two glyphs
  /// at 11px added noise without disambiguating two numbers.
  Widget _scoreDetails({required ColorScheme colorScheme}) {
    final valueStyle = AppTextStyles.statValueSmall.copyWith(
      fontSize: 13,
      color: colorScheme.onSurface.withValues(alpha: 0.75),
    );
    final separatorStyle = valueStyle.copyWith(
      color: colorScheme.onSurface.withValues(alpha: 0.25),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          DurationHelper.toFormattedTime(
            Duration(seconds: score.secondsElapsed),
          ),
          style: valueStyle,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Text('\u00b7', style: separatorStyle),
        ),
        Text('${score.movesCount}', style: valueStyle),
      ],
    );
  }

  /// Best-score medal follows the monochrome ladder: exceptional runs get
  /// the full-strength primary tone, good runs secondary, everything else
  /// fades toward the surface.
  Color _medalColorFor(ColorScheme colorScheme) => switch (score.movesCount) {
    <= 30 => colorScheme.primary,
    <= 60 => colorScheme.secondary,
    _ => colorScheme.onSurface.withValues(alpha: 0.4),
  };

  String _modeTagLabel(GameMode mode) => switch (mode) {
    GameMode.speedrun => 'SR',
    GameMode.blind => 'BL',
    GameMode.marathon => 'MA',
    GameMode.classic => '',
  };

  Color _modeTagColor(GameMode mode, ColorScheme colorScheme) => switch (mode) {
    GameMode.speedrun => colorScheme.error.withValues(alpha: 0.15),
    GameMode.blind => colorScheme.secondary.withValues(alpha: 0.15),
    GameMode.marathon => colorScheme.tertiary.withValues(alpha: 0.15),
    GameMode.classic => Colors.transparent,
  };
}
