import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leafz/generated/app_localizations.dart';
import 'package:leafz/helpers/localizations_ext.dart';
import 'package:leafz/ui/core/app_text_styles.dart';
import 'package:leafz/ui/core/layout/screen_type_helper.dart';
import 'package:leafz/ui/core/layout/spacing.dart';
import 'package:leafz/ui/core/providers/locale_notifier.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class LanguagePicker extends ConsumerWidget {
  const LanguagePicker({super.key});

  static const _languages = [
    _Language(code: 'en', label: 'English'),
    _Language(code: 'fr', label: 'Français'),
    _Language(code: 'ar', label: 'العربية'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wc = context.windowClass;
    final padding = MediaQuery.paddingOf(context);
    final drawerStartPadding = padding.left == 0 ? Spacing.md : padding.left;
    final localeState = ref.watch(localeProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.only(
        right: Spacing.md,
        left: drawerStartPadding,
        top: Spacing.md,
        bottom: Spacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              HugeIcon(
                icon: HugeIcons.strokeRoundedLanguageSquare,
                size: 16,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 6),
              Text(
                context.l10n.language,
                style: AppTextStyles.titleAdaptive(wc),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.switchLanguage,
            style: AppTextStyles.bodyAdaptive(
              wc,
            ).copyWith(color: colorScheme.onSurface.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 10),
          _languageOptions(context, ref, wc, colorScheme, localeState),
        ],
      ),
    );
  }

  Widget _languageOptions(
    BuildContext context,
    WidgetRef ref,
    WindowClass wc,
    ColorScheme colorScheme,
    LocaleState localeState,
  ) {
    return Row(
      children: [
        ...List.generate(_languages.length, (index) {
          final lang = _languages[index];
          final currentCode = localeState.locale?.languageCode;
          final isSelected =
              currentCode == lang.code ||
              (currentCode == null &&
                  AppLocalizations.of(context)?.localeName == lang.code);
          return Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                end: index < _languages.length - 1 ? Spacing.xs / 2 : 0,
                start: index > 0 ? Spacing.xs / 2 : 0,
              ),
              child: _LanguageButton(
                label: lang.label,
                isSelected: isSelected,
                onTap: () {
                  if (isSelected) return;
                  ref
                      .read(localeProvider.notifier)
                      .setLocale(Locale(lang.code));
                },
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _Language {
  final String code;
  final String label;
  const _Language({required this.code, required this.label});
}

class _LanguageButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: isSelected ? colorScheme.primary : Colors.transparent,
      borderRadius: BorderRadius.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.zero,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface,
                fontVariations: const [FontVariation('wght', 600)],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
