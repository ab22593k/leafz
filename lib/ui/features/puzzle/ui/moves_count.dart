import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leafz/helpers/localizations_ext.dart';
import 'package:leafz/ui/core/app_text_styles.dart';
import 'package:leafz/ui/features/puzzle/view_models/puzzle_notifier.dart';
import 'package:flutter/material.dart';

class MovesCount extends ConsumerWidget {
  /// Value style. Null uses the widget's default [AppTextStyles.labelMedium]
  /// treatment; callers pass a shared style so the header stats render as
  /// consistent peers across layouts.
  final TextStyle? textStyle;

  const MovesCount({super.key, this.textStyle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final movesCount = ref.watch(puzzleProvider.select((s) => s.movesCount));
    final style = textStyle ?? AppTextStyles.labelMedium;

    return RichText(
      text: TextSpan(
        text: '${context.l10n.moves}: ',
        style: style.copyWith(color: colorScheme.onSurface),
        children: <TextSpan>[
          TextSpan(
            text: '$movesCount',
            style: style.copyWith(
              color: colorScheme.onSurface,
              fontVariations: const [FontVariation('wght', 700)],
            ),
          ),
        ],
      ),
    );
  }
}
