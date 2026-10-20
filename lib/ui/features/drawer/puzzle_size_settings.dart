import 'package:leafz/domain/models/puzzle.dart';
import 'package:leafz/helpers/localizations_ext.dart';
import 'package:leafz/ui/features/drawer/puzzle_size_item.dart';
import 'package:leafz/ui/core/layout/section_heading.dart';
import 'package:leafz/ui/core/layout/spacing.dart';
import 'package:leafz/ui/core/app_text_styles.dart';
import 'package:flutter/material.dart';

class PuzzleSizeSettings extends StatelessWidget {
  const PuzzleSizeSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    final colorScheme = Theme.of(context).colorScheme;
    double drawerStartPadding = padding.left == 0 ? Spacing.md : padding.left;

    return Container(
      padding: EdgeInsets.only(
        right: Spacing.md,
        left: drawerStartPadding,
        top: Spacing.md,
        bottom: Spacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _buildSizeSections(context, colorScheme),
      ),
    );
  }

  List<Widget> _buildSizeSections(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    return [
      SectionHeading(
        label: context.l10n.puzzleSize,
        title: context.l10n.chooseGrid,
      ),
      const SizedBox(height: Spacing.xxs),
      Row(
        spacing: 4.0,
        children: [
          // Destructive side effect stated as a badge, not as a sentence
          // fragment competing with the section deck.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.zero,
            ),
            child: Text(
              context.l10n.resetsProgress.toUpperCase(),
              style: AppTextStyles.kicker.copyWith(
                color: colorScheme.error.withValues(alpha: 0.9),
                fontSize: 9,
                letterSpacing: 1.4,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: Spacing.sm),
      Row(
        children: List.generate(
          Puzzle.supportedPuzzleSizes.length,
          (index) => Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                end: index < Puzzle.supportedPuzzleSizes.length - 1
                    ? Spacing.xs / 2
                    : 0,
                start: index > 0 ? Spacing.xs / 2 : 0,
              ),
              child: PuzzleSizeItem(size: Puzzle.supportedPuzzleSizes[index]),
            ),
          ),
        ),
      ),
    ];
  }
}
