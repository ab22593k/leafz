import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leafz/helpers/localizations_ext.dart';
import 'package:leafz/ui/core/app_text_styles.dart';
import 'package:leafz/ui/core/layout/screen_type_helper.dart';
import 'package:leafz/ui/core/layout/spacing.dart';
import 'package:leafz/ui/core/providers/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class DarkModeToggle extends ConsumerWidget {
  const DarkModeToggle({super.key});

  static const _themeOptions = [
    _ThemeOption(mode: ThemeMode.light),
    _ThemeOption(mode: ThemeMode.system),
    _ThemeOption(mode: ThemeMode.dark),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wc = context.windowClass;
    final padding = MediaQuery.paddingOf(context);
    final drawerStartPadding = padding.left == 0 ? Spacing.md : padding.left;
    final themeState = ref.watch(themeProvider);
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
                icon: HugeIcons.strokeRoundedMoon01,
                size: 16,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 6),
              Text(
                context.l10n.darkMode,
                style: AppTextStyles.titleAdaptive(wc),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.toggleDarkMode,
            style: AppTextStyles.bodyAdaptive(
              wc,
            ).copyWith(color: colorScheme.onSurface.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 10),
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
              iconBuilder: _iconFor(option.mode),
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

typedef _IconBuilder = Widget Function(Color color);

_IconBuilder _iconFor(ThemeMode mode) => switch (mode) {
  ThemeMode.light => (color) => HugeIcon(
    icon: HugeIcons.strokeRoundedSun01,
    size: 18,
    color: color,
  ),
  ThemeMode.system => (color) => HugeIcon(
    icon: HugeIcons.strokeRoundedComputerSettings,
    size: 18,
    color: color,
  ),
  ThemeMode.dark => (color) => HugeIcon(
    icon: HugeIcons.strokeRoundedMoon01,
    size: 18,
    color: color,
  ),
};

class _ThemeButton extends StatefulWidget {
  final _IconBuilder iconBuilder;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeButton({
    required this.iconBuilder,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_ThemeButton> createState() => _ThemeButtonState();
}

class _ThemeButtonState extends State<_ThemeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late CurvedAnimation _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOut,
    );
  }

  @override
  void didUpdateWidget(_ThemeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _scaleController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _scaleAnimation.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: widget.isSelected ? 1.0 : 0.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      builder: (_, value, _) => _buildAnimatedContent(value),
    );
  }

  Widget _buildAnimatedContent(double value) {
    final colorScheme = Theme.of(context).colorScheme;
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
    final iconScale = 1.0 + (1.0 - _scaleAnimation.value) * 0.15;

    return Material(
      color: background,
      borderRadius: BorderRadius.zero,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.zero,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: iconScale,
                    child: widget.iconBuilder(foreground),
                  );
                },
              ),
              const SizedBox(height: 4),
              Text(
                widget.label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: foreground,
                  fontVariations: const [FontVariation('wght', 600)],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
