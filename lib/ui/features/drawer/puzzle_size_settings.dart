import 'package:leafz/domain/models/puzzle.dart';
import 'package:leafz/helpers/localizations_ext.dart';
import 'package:leafz/ui/features/drawer/puzzle_size_item.dart';
import 'package:leafz/ui/core/layout/spacing.dart';
import 'package:leafz/ui/core/layout/screen_type_helper.dart';
import 'package:leafz/ui/core/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class PuzzleSizeSettings extends StatelessWidget {
  const PuzzleSizeSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    final wc = context.windowClass;
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
        children: _buildSizeSections(context, wc, colorScheme),
      ),
    );
  }

  List<Widget> _buildSizeSections(
    BuildContext context,
    WindowClass wc,
    ColorScheme colorScheme,
  ) {
    return [
      Row(
        children: [
          HugeIcon(
            icon: HugeIcons.strokeRoundedGrid02,
            size: 16,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 6),
          Text(context.l10n.puzzleSize, style: AppTextStyles.titleAdaptive(wc)),
        ],
      ),
      const SizedBox(height: 4),
      Row(
        spacing: 4.0,
        children: [
          Text(
            context.l10n.chooseGrid,
            style: AppTextStyles.bodyAdaptive(
              wc,
            ).copyWith(color: colorScheme.onSurface.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.zero,
            ),
            child: Text(
              context.l10n.resetsProgress,
              style: AppTextStyles.labelAdaptive(wc).copyWith(
                color: colorScheme.error.withValues(alpha: 0.8),
                fontStyle: FontStyle.italic,
                fontVariations: const [FontVariation('wght', 600)],
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
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
