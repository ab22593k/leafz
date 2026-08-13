import 'package:leafz/helpers/duration_helper.dart';
import 'package:leafz/helpers/localizations_ext.dart';
import 'package:leafz/helpers/share_score_helper.dart';
import 'package:leafz/ui/core/layout/spacing.dart';
import 'package:leafz/ui/core/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.congratsTitle, style: AppTextStyles.displaySmall),
            const SizedBox(height: Spacing.xs),
            Text(
              context.l10n.congratsSubtitle,
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: Spacing.sm),
            _statsRow(context, colorScheme),
            const SizedBox(height: Spacing.md),
          ],
        ),
        _actionButtons(context),
      ],
    );
  }

  Widget _statsRow(BuildContext context, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              const HugeIcon(icon: HugeIcons.strokeRoundedClock01),
              const SizedBox(width: 5),
              Text(
                DurationHelper.toFormattedTime(duration),
                style: AppTextStyles.titleLarge,
              ),
            ],
          ),
        ),
        Expanded(
          child: Text(
            context.l10n.movesCountLabel(movesCount),
            style: AppTextStyles.titleLarge,
          ),
        ),
      ],
    );
  }

  Widget _actionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            label: Text(context.l10n.restart),
            icon: const HugeIcon(icon: HugeIcons.strokeRoundedRefresh01),
          ),
        ),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              ShareScoreHelper.openLink(
                ShareScoreHelper.getTwitterShareLink(
                  movesCount,
                  duration,
                  tilesCount,
                ),
              );
            },
            label: Text(context.l10n.share),
            icon: const HugeIcon(icon: HugeIcons.strokeRoundedShare01),
          ),
        ),
      ],
    );
  }
}
