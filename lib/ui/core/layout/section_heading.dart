import 'package:leafz/ui/core/app_text_styles.dart';
import 'package:leafz/ui/core/layout/spacing.dart';
import 'package:flutter/material.dart';

/// Editorial section heading: a tracked uppercase kicker over a serif title.
///
/// This is the one place that decides what a section header looks like, so
/// drawer sections cannot drift into five different treatments. There is no
/// icon slot and no rule: grouping is carried by the kicker and by space,
/// per the no-line rule.
///
/// The [label] is uppercased here rather than at each call site; locales
/// without case are unaffected because `toUpperCase` is a no-op for them.
class SectionHeading extends StatelessWidget {
  /// Small tracked line above the title. Pass the plain string.
  final String label;

  /// Serif section title. When null the heading is the kicker alone — used
  /// for lighter divider-style headings in the drawer footer.
  final String? title;

  /// Optional trailing widget, aligned to the title's baseline row.
  final Widget? trailing;

  const SectionHeading({
    super.key,
    required this.label,
    this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTextStyles.kicker.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.45),
          ),
        ),
        if (title != null) ...[
          const SizedBox(height: Spacing.xxs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  title!,
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
        ],
      ],
    );
  }
}
