import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leafz/domain/models/game_mode.dart';
import 'package:leafz/domain/models/puzzle.dart';
import 'package:leafz/helpers/localizations_ext.dart';
import 'package:leafz/ui/features/drawer/game_mode_item.dart';
import 'package:leafz/ui/core/layout/section_heading.dart';
import 'package:leafz/ui/core/layout/spacing.dart';
import 'package:leafz/ui/core/app_text_styles.dart';
import 'package:leafz/ui/features/puzzle/view_models/puzzle_notifier.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class GameModeSettings extends ConsumerWidget {
  const GameModeSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Drawer sections align to the *start* edge: padding.left here put
    // Arabic section content 22dp off the header's end-aware masthead.
    final insets = MediaQuery.paddingOf(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final startInset = isRtl ? insets.right : insets.left;
    final double drawerStartPadding = startInset == 0 ? Spacing.md : startInset;

    return Container(
      padding: EdgeInsetsDirectional.only(
        start: drawerStartPadding,
        end: Spacing.md,
        top: Spacing.md,
        bottom: Spacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeading(
            label: context.l10n.gameMode,
            title: context.l10n.chooseMode,
          ),
          const SizedBox(height: Spacing.sm),
          // Gaps live on the parent so items stay identical: the old
          // per-item bottom padding broke the last item's rhythm.
          Column(
            spacing: Spacing.xxs,
            children: [
              for (final mode in GameMode.values) GameModeItem(mode: mode),
            ],
          ),
          const _MarathonRangeSelector(),
        ],
      ),
    );
  }
}

class _MarathonRangeSelector extends ConsumerWidget {
  const _MarathonRangeSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final sizes = Puzzle.supportedPuzzleSizes;
    final puzzleState = ref.watch(puzzleProvider);

    if (puzzleState.gameMode != GameMode.marathon) {
      return const SizedBox.shrink();
    }

    int startSize = puzzleState.marathonStartSize ?? sizes.first;
    int endSize = puzzleState.marathonEndSize ?? sizes.last;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        // No start padding: the Range label locks to the same edge as the
        // mode titles above, so selecting Marathon doesn't shift the
        // column's left register.
        padding: const EdgeInsetsDirectional.only(top: 10, bottom: 10, end: 10),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.zero,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.range,
              style: AppTextStyles.labelSmall.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            _marathonRangeSliders(
              context,
              ref,
              colorScheme,
              startSize,
              endSize,
              sizes,
              puzzleState,
            ),
          ],
        ),
      ),
    );
  }

  Widget _marathonRangeSliders(
    BuildContext context,
    WidgetRef ref,
    ColorScheme colorScheme,
    int startSize,
    int endSize,
    List<int> sizes,
    PuzzleState puzzleState,
  ) {
    return Row(
      children: [
        Expanded(
          child: _SizeDropdown(
            label: context.l10n.from,
            value: startSize,
            sizes: sizes,
            onChanged: (v) {
              if (v > endSize) return;
              ref.read(puzzleProvider.notifier).setMarathonRange(v, endSize);
              if (puzzleState.n < v || puzzleState.n > endSize) {
                ref.read(puzzleProvider.notifier).resetPuzzleSize(v);
              }
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: HugeIcon(
            icon: HugeIcons.strokeRoundedArrowRight01,
            size: 16,
            color: colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
        Expanded(
          child: _SizeDropdown(
            label: context.l10n.to,
            value: endSize,
            sizes: sizes,
            onChanged: (v) {
              if (v < startSize) return;
              ref.read(puzzleProvider.notifier).setMarathonRange(startSize, v);
              if (puzzleState.n < startSize || puzzleState.n > v) {
                ref.read(puzzleProvider.notifier).resetPuzzleSize(startSize);
              }
            },
          ),
        ),
      ],
    );
  }
}

class _SizeDropdown extends StatelessWidget {
  final String label;
  final int value;
  final List<int> sizes;
  final ValueChanged<int> onChanged;

  const _SizeDropdown({
    required this.label,
    required this.value,
    required this.sizes,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const crossSymbol = '\u00d7';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.zero,
            border: Border(
              bottom: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: value,
              isExpanded: true,
              dropdownColor: colorScheme.surfaceContainer,
              style: AppTextStyles.labelLarge.copyWith(
                color: colorScheme.onSurface,
              ),
              items: sizes.map((s) {
                return DropdownMenuItem(
                  value: s,
                  child: Text('$s$crossSymbol$s'),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ),
      ],
    );
  }
}
