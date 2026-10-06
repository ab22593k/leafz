import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leafz/helpers/localizations_ext.dart';
import 'package:leafz/ui/features/drawer/latest_score_item.dart';
import 'package:leafz/ui/core/layout/spacing.dart';
import 'package:leafz/ui/core/layout/screen_type_helper.dart';
import 'package:leafz/ui/core/app_text_styles.dart';
import 'package:leafz/ui/features/puzzle/view_models/puzzle_notifier.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class LatestScores extends ConsumerWidget {
  const LatestScores({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final padding = MediaQuery.paddingOf(context);
    final wc = context.windowClass;
    final colorScheme = Theme.of(context).colorScheme;
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
            child: Row(
              children: [
                Icon(
                  Icons.emoji_events_outlined,
                  size: 16,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 6),
                Text(
                  context.l10n.latestScores,
                  style: AppTextStyles.titleAdaptive(wc).copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          if (scores.isEmpty)
            _emptyState(context, paddingLeft, wc, colorScheme)
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

  Widget _emptyState(
    BuildContext context,
    double paddingLeft,
    WindowClass wc,
    ColorScheme colorScheme,
  ) {
    return Container(
      margin: EdgeInsets.only(
        left: paddingLeft,
        right: Spacing.screenHPadding,
        top: Spacing.sm,
      ),
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.zero,
      ),
      child: Column(
        children: [
          HugeIcon(
            icon: HugeIcons.strokeRoundedRocket01,
            size: 28,
            color: colorScheme.onSurface.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.solveFirstPuzzle,
            style: AppTextStyles.bodyAdaptive(wc).copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.4),
              fontVariations: const [FontVariation('wght', 380)],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            context.l10n.scoresWillAppear,
            style: AppTextStyles.bodyAdaptive(wc).copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.25),
              fontVariations: const [FontVariation('wght', 360)],
            ),
          ),
        ],
      ),
    );
  }
}
