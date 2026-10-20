import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leafz/helpers/localizations_ext.dart';
import 'package:leafz/ui/features/drawer/latest_score_item.dart';
import 'package:leafz/ui/core/layout/section_heading.dart';
import 'package:leafz/ui/core/layout/spacing.dart';
import 'package:leafz/ui/core/app_text_styles.dart';
import 'package:leafz/ui/features/puzzle/view_models/puzzle_notifier.dart';
import 'package:flutter/material.dart';

class LatestScores extends ConsumerWidget {
  const LatestScores({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final padding = MediaQuery.paddingOf(context);
    final double paddingLeft = padding.left == 0 ? Spacing.md : padding.left;
    final scores = ref.watch(
      puzzleProvider.select((s) => s.scores.reversed.toList()),
    );

    return Container(
      padding: const EdgeInsets.only(top: Spacing.md, bottom: Spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: paddingLeft,
              right: Spacing.screenHPadding,
              bottom: Spacing.sm,
            ),
            child: SectionHeading(label: context.l10n.latestScores),
          ),
          if (scores.isEmpty)
            _emptyState(context, paddingLeft)
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: scores.length,
              itemBuilder: (c, i) => LatestScoreItem(
                scores[i],
                paddingLeft: paddingLeft,
                rank: i + 1,
                isBest: i == 0,
              ),
            ),
        ],
      ),
    );
  }

  /// Typographic empty state.
  ///
  /// An illustration would be a second decorative voice next to the serif
  /// heading; here the section states what is missing and what will fill it.
  Widget _emptyState(BuildContext context, double paddingLeft) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.only(
        left: paddingLeft,
        right: Spacing.screenHPadding,
        top: Spacing.xs,
      ),
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.zero,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.solveFirstPuzzle,
            style: AppTextStyles.headlineSmall.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: Spacing.xxs),
          Text(
            context.l10n.scoresWillAppear,
            style: AppTextStyles.bodySmall.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
