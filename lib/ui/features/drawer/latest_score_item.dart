import 'package:leafz/helpers/duration_helper.dart';
import 'package:leafz/domain/models/score.dart';
import 'package:leafz/domain/models/game_mode.dart';
import 'package:leafz/ui/core/layout/spacing.dart';
import 'package:leafz/ui/core/layout/screen_type_helper.dart';
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
    final wc = context.windowClass;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.only(
        left: paddingLeft,
        right: Spacing.screenHPadding + 4,
        top: Spacing.sm + 4,
        bottom: Spacing.sm + 4,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            child: isBest
                ? HugeIcon(
                    icon: HugeIcons.strokeRoundedStarAward01,
                    size: 14,
                    color: _medalColorFor(colorScheme),
                  )
                : Text(
                    '$rank',
                    style: AppTextStyles.labelAdaptive(wc).copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.3),
                      fontVariations: const [FontVariation('wght', 500)],
                    ),
                  ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 36,
            child: Text(
              '${score.puzzleSize}\u00d7${score.puzzleSize}',
              style: AppTextStyles.bodyAdaptive(wc).copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.8),
                fontVariations: const [FontVariation('wght', 500)],
              ),
            ),
          ),
          // Mode tag for non-classic scores
          if (score.gameMode != GameMode.classic) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: _modeTagColor(score.gameMode, colorScheme),
                borderRadius: BorderRadius.zero,
              ),
              child: Text(
                _modeTagLabel(score.gameMode),
                style: AppTextStyles.bodyXxs.copyWith(
                  color: colorScheme.onSurface,
                  fontVariations: const [FontVariation('wght', 600)],
                ),
              ),
            ),
          ],
          const Spacer(),
          _scoreDetails(wc: wc, colorScheme: colorScheme),
        ],
      ),
    );
  }

  Widget _scoreDetails({
    required WindowClass wc,
    required ColorScheme colorScheme,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedClock01,
              size: 11,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(width: 3),
            Text(
              DurationHelper.toFormattedTime(
                Duration(seconds: score.secondsElapsed),
              ),
              style: AppTextStyles.labelAdaptive(
                wc,
              ).copyWith(color: colorScheme.onSurface.withValues(alpha: 0.7)),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedArrowUpDown,
              size: 11,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(width: 3),
            Text(
              '${score.movesCount}',
              style: AppTextStyles.labelAdaptive(
                wc,
              ).copyWith(color: colorScheme.onSurface.withValues(alpha: 0.7)),
            ),
          ],
        ),
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
