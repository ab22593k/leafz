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
    // Start-aware like the header: padding.left misaligned Arabic content
    // against the end-aware masthead.
    final insets = MediaQuery.paddingOf(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final startInset = isRtl ? insets.right : insets.left;
    final double paddingLeft = startInset == 0 ? Spacing.md : startInset;
    final scores = ref.watch(
      puzzleProvider.select((s) => s.scores.reversed.toList()),
    );

    return Container(
      padding: const EdgeInsets.only(top: Spacing.md, bottom: Spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.only(
              start: paddingLeft,
              end: Spacing.screenHPadding,
              bottom: Spacing.sm,
            ),
            child: SectionHeading(label: context.l10n.latestScores),
          ),
          if (scores.isEmpty)
            _emptyState(context)
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
  /// heading; here the section states what is missing and what will fill
  /// it. A ghost rule and a gutter inset make it a margin note, not a card
  /// competing with the sections above.
  Widget _emptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsetsDirectional.only(
        end: Spacing.screenHPadding,
        top: Spacing.xs,
      ),
      padding: const EdgeInsetsDirectional.only(
        start: Spacing.md,
        top: Spacing.sm,
        bottom: Spacing.sm,
      ),
      decoration: BoxDecoration(
        border: BorderDirectional(
          start: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.15),
            width: 0.5,
          ),
        ),
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
