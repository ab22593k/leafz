import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leafz/domain/models/game_mode.dart';
import 'package:leafz/helpers/game_mode_helper.dart';
import 'package:leafz/helpers/localizations_ext.dart';
import 'package:leafz/ui/core/app_text_styles.dart';
import 'package:leafz/ui/features/puzzle/view_models/puzzle_notifier.dart';
import 'package:leafz/ui/features/puzzle/view_models/stop_watch_notifier.dart';
import 'package:flutter/material.dart';

class GameModeItem extends ConsumerWidget {
  final GameMode mode;

  const GameModeItem({required this.mode, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final puzzleState = ref.watch(puzzleProvider);
    final isSelected = puzzleState.gameMode == mode;
    final isLocked = puzzleState.isModeLocked && !isSelected;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        key: ValueKey('game_mode_${mode.name}'),
        onPressed: isLocked
            ? null
            : () {
                if (!isSelected) {
                  ref.read(stopWatchProvider.notifier).stop();
                  ref.read(puzzleProvider.notifier).setGameMode(mode);
                  // setGameMode triggers a state rebuild that may close
                  // the drawer/dialog and unmount this widget.
                  if (!context.mounted) return;
                  // Use maybePop to safely close either a drawer or a
                  // dialog — the drawer button uses showDialog (not
                  // Scaffold.drawer) on expanded+ breakpoints, so
                  // Scaffold.of() would fail on those screen sizes.
                  Navigator.maybeOf(context)?.pop();
                }
              },
        style:
            ElevatedButton.styleFrom(
              // No start padding: the title locks to the section heading's
              // edge instead of floating 12dp inside its own border. The
              // ghost border is 0.5dp, so the text sits ~0.5dp off the
              // heading — imperceptible, and the alternative (insetting
              // the heading to match the button) would break the masthead
              // register the whole drawer shares.
              padding: const EdgeInsetsDirectional.only(
                top: 10,
                bottom: 10,
                end: 12,
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              minimumSize: const Size.fromHeight(48),
              backgroundColor: isSelected
                  ? colorScheme.primary
                  : Colors.transparent,
              foregroundColor: isSelected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurface,
              // Locked options keep the editorial treatment: the
              // framework's default disabled wash would break the ink
              // register, so disabled states reuse the resting ghost.
              disabledBackgroundColor: Colors.transparent,
              disabledForegroundColor: colorScheme.onSurface.withValues(
                alpha: 0.45,
              ),
              elevation: 0,
            ).copyWith(
              elevation: WidgetStateProperty.resolveWith((_) => 0),
              shadowColor: WidgetStateProperty.all(Colors.transparent),
              side: WidgetStateProperty.resolveWith(
                (_) => BorderSide(
                  color: isSelected
                      ? Colors.transparent
                      : colorScheme.outlineVariant.withValues(alpha: 0.15),
                  width: 0.5,
                ),
              ),
              overlayColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.hovered)) {
                  return (isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface)
                      .withValues(alpha: 0.08);
                }
                return null;
              }),
            ),
        child: _buildItemBody(context, isSelected, colorScheme),
      ),
    );
  }

  /// Name over description, both start-aligned with the drawer register —
  /// the section heading, the mode titles, and the marathon Range label
  /// all share one edge; the old start padding floated them 12dp inside.
  /// No mode icon and no trailing checkmark: the ink fill already states
  /// selection, and the fill is a luminance change rather than a hue
  /// change, so it survives both themes and colour-vision differences.
  /// A locked option is stated by the same lowered contrast the rest of
  /// the system uses for secondary text, not by the framework's
  /// washed-out disabled treatment.
  Widget _buildItemBody(
    BuildContext context,
    bool isSelected,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          GameModeHelper.localizedName(mode, context.l10n),
          style: AppTextStyles.listTitle.copyWith(
            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          GameModeHelper.localizedDescription(mode, context.l10n),
          style: AppTextStyles.bodySmall.copyWith(
            color: isSelected
                ? colorScheme.onPrimary.withValues(alpha: 0.7)
                : colorScheme.onSurface.withValues(alpha: 0.45),
          ),
        ),
      ],
    );
  }
}
