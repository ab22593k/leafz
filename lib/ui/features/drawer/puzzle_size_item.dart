import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leafz/ui/core/layout/phrase_bubble_layout.dart';
import 'package:leafz/ui/core/app_text_styles.dart';
import 'package:leafz/ui/core/layout/spacing.dart';
import 'package:leafz/ui/features/phrases/view_models/phrases_notifier.dart';
import 'package:leafz/ui/features/puzzle/view_models/puzzle_notifier.dart';
import 'package:leafz/ui/features/puzzle/view_models/stop_watch_notifier.dart';
import 'package:flutter/material.dart';

class PuzzleSizeItem extends ConsumerWidget {
  final int size;

  const PuzzleSizeItem({required this.size, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final puzzleN = ref.watch(puzzleProvider.select((s) => s.n));
    final isSelected = puzzleN == size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _sizeButton(context, ref, isSelected, size, colorScheme),
        const SizedBox(height: Spacing.xs),
        Text(
          '${(size * size) - 1}',
          style: AppTextStyles.bodyXxs.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }

  Widget _sizeButton(
    BuildContext context,
    WidgetRef ref,
    bool isSelected,
    int size,
    ColorScheme colorScheme,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      child: ElevatedButton(
        key: ValueKey('puzzle_size_$size'),
        onPressed: () {
          if (!isSelected) {
            ref.read(puzzleProvider.notifier).resetPuzzleSize(size);
            ref.read(stopWatchProvider.notifier).stop();
            if (size > 4) {
              ref
                  .read(phrasesProvider.notifier)
                  .setPhraseState(PhraseState.hardPuzzleSelected);
            }
            Navigator.of(context).pop();
          }
        },
        style:
            ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
                // Unselected options keep the ghost border: it is affordance,
                // not decoration. Selected is stated by the ink fill alone.
                side: BorderSide(color: Colors.transparent, width: 0.5),
              ),
              minimumSize: const Size.fromHeight(48),
              backgroundColor: isSelected
                  ? colorScheme.primary
                  : Colors.transparent,
              elevation: 0,
            ).copyWith(
              elevation: WidgetStateProperty.resolveWith((_) => 0),
              shadowColor: WidgetStateProperty.all(Colors.transparent),
              side: WidgetStateProperty.resolveWith(
                (states) => BorderSide(
                  color: isSelected
                      ? Colors.transparent
                      : colorScheme.outlineVariant.withValues(alpha: 0.15),
                  width: 0.5,
                ),
              ),
            ),
        // Serif numerals: the grid size is the value being chosen, so it
        // belongs to the display voice, not the label voice.
        child: Text(
          '$size\u00d7$size',
          style: AppTextStyles.statValueSmall.copyWith(
            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
