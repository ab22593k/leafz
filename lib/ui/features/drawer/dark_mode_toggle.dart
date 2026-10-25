import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leafz/helpers/localizations_ext.dart';
import 'package:leafz/ui/core/app_text_styles.dart';
import 'package:leafz/ui/core/layout/section_heading.dart';
import 'package:leafz/ui/core/layout/spacing.dart';
import 'package:leafz/ui/core/providers/theme_notifier.dart';
import 'package:flutter/material.dart';

class DarkModeToggle extends ConsumerWidget {
  const DarkModeToggle({super.key});

  static const _themeOptions = [
    _ThemeOption(mode: ThemeMode.light),
    _ThemeOption(mode: ThemeMode.system),
    _ThemeOption(mode: ThemeMode.dark),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Start-aware like the header: padding.left misaligned Arabic content
    // against the end-aware masthead.
    final insets = MediaQuery.paddingOf(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final startInset = isRtl ? insets.right : insets.left;
    final drawerStartPadding = startInset == 0 ? Spacing.md : startInset;
    final themeState = ref.watch(themeProvider);

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
            label: context.l10n.darkMode,
            title: context.l10n.toggleDarkMode,
          ),
          const SizedBox(height: Spacing.sm),
          _buildThemeOptionsRow(context, themeState, ref),
        ],
      ),
    );
  }

  String _labelFor(BuildContext context, ThemeMode mode) => switch (mode) {
    ThemeMode.light => context.l10n.lightTheme,
    ThemeMode.dark => context.l10n.darkTheme,
    ThemeMode.system => context.l10n.systemTheme,
  };

  Widget _buildThemeOptionsRow(
    BuildContext context,
    ThemeState themeState,
    WidgetRef ref,
  ) {
    return Row(
      children: List.generate(_themeOptions.length, (index) {
        final option = _themeOptions[index];
        final isSelected = themeState.mode == option.mode;
        final label = _labelFor(context, option.mode);
        return Expanded(
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              end: index < _themeOptions.length - 1 ? Spacing.xs / 2 : 0,
              start: index > 0 ? Spacing.xs / 2 : 0,
            ),
            child: _ThemeButton(
              label: label,
              isSelected: isSelected,
              onTap: () {
                if (isSelected) return;
                ref.read(themeProvider.notifier).setMode(option.mode);
              },
            ),
          ),
        );
      }),
    );
  }
}

class _ThemeOption {
  final ThemeMode mode;
  const _ThemeOption({required this.mode});
}

/// Text-only segmented choice.
///
/// No icons: the three options are named, and the chosen one is stated by a
/// filled ink block against ghost-bordered neighbours. Icons for
/// sun/moon/monitor were decoration competing with the section heading.
/// Height is pinned to the 44dp minimum touch target.
class _ThemeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: isSelected ? 1.0 : 0.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      builder: (context, value, _) {
        final background = Color.lerp(
          Colors.transparent,
          colorScheme.primary,
          value,
        )!;
        final foreground = Color.lerp(
          colorScheme.onSurface,
          colorScheme.onPrimary,
          value,
        )!;
        final border = Color.lerp(
          colorScheme.outlineVariant.withValues(alpha: 0.15),
          colorScheme.primary,
          value,
        )!;

        return Material(
          color: background,
          borderRadius: BorderRadius.zero,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.zero,
            child: Container(
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.zero,
                border: Border.all(color: border, width: 0.5),
              ),
              child: Text(
                label.toUpperCase(),
                style: AppTextStyles.kicker.copyWith(color: foreground),
              ),
            ),
          ),
        );
      },
    );
  }
}
