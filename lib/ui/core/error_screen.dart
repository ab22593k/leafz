import 'package:leafz/helpers/localizations_ext.dart';
import 'package:leafz/ui/core/app_text_styles.dart';
import 'package:leafz/ui/core/layout/spacing.dart';
import 'package:flutter/material.dart';

/// Full-page error state.
///
/// Set as an editorial page rather than an alert: a rubric, a serif headline,
/// and a measure-limited deck. No icon — the words carry the state, and a
/// 64px glyph above a headline is the most generic error layout there is.
class ErrorScreen extends StatelessWidget {
  final Object? error;

  const ErrorScreen({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      // This page has no app bar to claim the status-bar inset, so it must
      // claim it itself; the app no longer applies a global SafeArea.
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.lg,
                vertical: Spacing.section,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.appTitle.toUpperCase(),
                    style: AppTextStyles.kicker.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.45),
                    ),
                  ),
                  const SizedBox(height: Spacing.sm),
                  Text(
                    context.l10n.pageNotFound,
                    style: AppTextStyles.displayMedium.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: Spacing.sm),
                  Text(
                    context.l10n.pageNotFoundMessage,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
