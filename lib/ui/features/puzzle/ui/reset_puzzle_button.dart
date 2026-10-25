import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leafz/helpers/localizations_ext.dart';
import 'package:leafz/ui/core/animations/animations_manager.dart';
import 'package:leafz/ui/core/animations/fade_in_transition.dart';
import 'package:leafz/ui/core/dialogs/app_alert_dialog.dart';
import 'package:leafz/ui/core/app_text_styles.dart';
import 'package:leafz/ui/core/layout/screen_type_helper.dart';
import 'package:leafz/ui/features/puzzle/view_models/puzzle_notifier.dart';
import 'package:leafz/ui/features/puzzle/view_models/stop_watch_notifier.dart';
import 'package:flutter/material.dart';

class ResetPuzzleButton extends ConsumerWidget {
  const ResetPuzzleButton({super.key});

  void initResetPuzzle(BuildContext context, WidgetRef ref) {
    final puzzle = ref.read(puzzleProvider);
    if (puzzle.hasStarted && !puzzle.puzzle.isSolved) {
      showDialog(
        context: context,
        builder: (context) {
          return AppAlertDialog(
            title: context.l10n.resetConfirm,
            onConfirm: () {
              ref.read(stopWatchProvider.notifier).stop();
              ref.read(puzzleProvider.notifier).generate(forceRefresh: true);
            },
          );
        },
      );
    } else {
      ref.read(stopWatchProvider.notifier).stop();
      ref.read(puzzleProvider.notifier).generate(forceRefresh: true);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpandedPlus = context.isExpandedPlus;
    final colorScheme = Theme.of(context).colorScheme;
    ref.watch(puzzleProvider); // trigger rebuild on state changes

    return FadeInTransition(
      delay: AnimationsManager.bgLayerAnimationDuration,
      child: _buildButtonContent(context, ref, isExpandedPlus, colorScheme),
    );
  }

  Widget _buildButtonContent(
    BuildContext context,
    WidgetRef ref,
    bool isExpandedPlus,
    ColorScheme colorScheme,
  ) {
    // One labelled primary action in both layouts: the old compact
    // icon-only button forced new players to guess the glyph. The text
    // label costs ~90dp and fits even at 320dp because the wordmark flexes.
    // No outer top padding — the bar's Row centers its children, and the
    // offset pushed the button off-axis.
    final label = Text(
      context.l10n.reset.toUpperCase(),
      style: AppTextStyles.button,
    );
    final tooltip = '${context.l10n.reset} (R)';

    if (isExpandedPlus) {
      // Full-bleed ink block for the side pane: the pane gives it 300dp+,
      // so the label's tracked caps read as a colophon rule, not a chip.
      // TextButton, not FAB — a floating action is the wrong voice inside
      // a static editorial column.
      return Tooltip(
        message: tooltip,
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: TextButton(
            key: const ValueKey('reset_button'),
            onPressed: () => initResetPuzzle(context, ref),
            style: TextButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              // Fixed size: the label must not reflow the column when the
              // locale changes the word length.
              fixedSize: const Size.fromHeight(48),
              minimumSize: const Size(0, 48),
            ),
            child: Align(alignment: Alignment.centerRight, child: label),
          ),
        ),
      );
    }

    return Tooltip(
      message: tooltip,
      preferBelow: false,
      child: FloatingActionButton.extended(
        key: const ValueKey('reset_button'),
        onPressed: () => initResetPuzzle(context, ref),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        label: label,
      ),
    );
  }
}
