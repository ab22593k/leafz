import 'package:leafz/ui/core/app_text_styles.dart';
import 'package:leafz/ui/core/layout/glass.dart';
import 'package:leafz/ui/core/layout/screen_type_helper.dart';
import 'package:flutter/material.dart';

/// MD3 small app bar (64dp) following spec tokens:
///
/// | Token | Value |
/// |---|---|
/// | `container.height` | 64dp |
/// | `title.font` | title-large |
/// | `leading-space` | 4dp |
/// | `trailing-space` | 4dp |
/// | `container.color` | `surface` |
/// | `container.elevation` | `level0` |
/// | `title.color` | `on-surface` |
/// | `leading-icon.color` | `on-surface` |
/// | `trailing-icon.color` | `on-surface-variant` |
class PuzzleAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? leading;
  final String? title;
  final String? subtitle;
  final List<Widget> actions;

  const PuzzleAppBar({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.actions = const [],
  });

  @override
  Size get preferredSize {
    if (subtitle != null) return const Size.fromHeight(88);
    return const Size.fromHeight(64);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final wc = context.windowClass;
    final isWide = wc != WindowClass.compact;

    return Container(
      height: preferredSize.height,
      padding: EdgeInsets.only(
        left: 4,
        right: 4,
        top: MediaQuery.paddingOf(context).top,
      ),
      child: Row(
        children: [
          ?leading,
          SizedBox(width: isWide ? 16 : 8),
          Expanded(
            child: subtitle == null
                ? _AppBarTitle(title: title ?? '', color: colorScheme.onSurface)
                : _AppBarTitleSubtitle(
                    title: title ?? '',
                    subtitle: subtitle!,
                    titleColor: colorScheme.onSurface,
                    subtitleColor: colorScheme.onSurfaceVariant,
                  ),
          ),
          if (actions.isNotEmpty) ...actions,
        ],
      ),
    );
  }
}

class _AppBarTitle extends StatelessWidget {
  final String title;
  final Color color;

  const _AppBarTitle({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontFamily: AppTextStyles.primaryFontFamily,
        color: color,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _AppBarTitleSubtitle extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color titleColor;
  final Color subtitleColor;

  const _AppBarTitleSubtitle({
    required this.title,
    required this.subtitle,
    required this.titleColor,
    required this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AppBarTitle(title: title, color: titleColor),
        const SizedBox(height: 1),
        Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: subtitleColor),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

/// MD3 navigation bar (bottom) for compact/medium breakpoints.
///
/// Follows spec:
/// - `container.color`: `surface-container`
/// - Active indicator `secondary` / inactive `on-surface-variant`
/// - No elevation
class LeafzNavigationBar extends StatelessWidget {
  final List<NavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int>? onDestinationSelected;

  const LeafzNavigationBar({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: destinations,
    );
  }
}

/// MD3 bottom toolbar — placed in the bottom bar or trailing rail region.
///
/// Uses `surfaceContainerLow` background to match the on-scroll
/// app bar color, with `outlineVariant` border.
class PuzzleToolbar extends StatelessWidget {
  final Widget child;

  const PuzzleToolbar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final padding = MediaQuery.paddingOf(context);

    return ClipRRect(
      borderRadius: BorderRadius.zero,
      child: BackdropFilter(
        filter: AppGlass.filter,
        child: Container(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 8,
            bottom: 8 + padding.bottom,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer.withValues(alpha: 0.7),
          ),
          child: child,
        ),
      ),
    );
  }
}
