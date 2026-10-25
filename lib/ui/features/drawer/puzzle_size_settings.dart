import 'package:leafz/domain/models/puzzle.dart';
import 'package:leafz/helpers/localizations_ext.dart';
import 'package:leafz/ui/core/layout/section_heading.dart';
import 'package:leafz/ui/core/layout/spacing.dart';
import 'package:leafz/ui/core/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:leafz/ui/features/drawer/puzzle_size_item.dart';

class PuzzleSizeSettings extends StatelessWidget {
  const PuzzleSizeSettings({super.key});

  @override
  Widget build(BuildContext context) {
    // Start-aware like the header: padding.left misaligned Arabic content
    // against the end-aware masthead.
    final insets = MediaQuery.paddingOf(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final startInset = isRtl ? insets.right : insets.left;
    double drawerStartPadding = startInset == 0 ? Spacing.md : startInset;

    return Container(
      padding: EdgeInsetsDirectional.only(
        start: drawerStartPadding,
        end: Spacing.md,
        top: Spacing.md,
        bottom: Spacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _buildSizeSections(context),
      ),
    );
  }

  List<Widget> _buildSizeSections(BuildContext context) {
    return [
      SectionHeading(
        label: context.l10n.puzzleSize,
        title: context.l10n.chooseGrid,
        // Consequence stated on the same breath as the title: the old
        // error-tinted badge read as a second kicker competing for the
        // section's voice.
        trailing: Text(
          context.l10n.resetsProgress.toUpperCase(),
          style: AppTextStyles.kicker.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.45),
          ),
        ),
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
