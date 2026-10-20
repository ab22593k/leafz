import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leafz/helpers/localizations_ext.dart';
import 'package:leafz/ui/core/layout/phrase_bubble_layout.dart';
import 'package:leafz/ui/core/layout/spacing.dart';
import 'package:leafz/ui/core/app_text_styles.dart';
import 'package:leafz/ui/features/phrases/view_models/phrases_notifier.dart';
import 'package:flutter/material.dart';

class PhraseBubble extends ConsumerWidget {
  final PhraseState state;

  const PhraseBubble({super.key, required this.state})
    : assert(state is! PhraseStateNone);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final phrasesNotifier = ref.read(phrasesProvider.notifier);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        _cornerSquare(
          right: -12,
          top: -4,
          size: 12,
          color: colorScheme.primary,
        ),
        _cornerSquare(right: -21, top: -8, size: 8, color: colorScheme.primary),
        _cornerSquare(
          right: -28,
          top: -11,
          size: 4,
          color: colorScheme.primary,
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.sm,
          ),
          constraints: const BoxConstraints(maxWidth: 180),
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.zero,
            boxShadow: [
              BoxShadow(
                color: colorScheme.onSurface.withValues(alpha: 0.04),
                blurRadius: 40,
                spreadRadius: 0,
              ),
            ],
          ),
          child: ref.watch(phrasesProvider).phraseState is! PhraseStateNone
              ? Text(
                  phrasesNotifier.getPhrase(state, context.l10n),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.quote.copyWith(
                    color: colorScheme.onPrimary,
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _cornerSquare({
    required double right,
    required double top,
    required double size,
    required Color color,
  }) {
    return Positioned(
      right: right,
      top: top,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.zero,
        ),
      ),
    );
  }
}
