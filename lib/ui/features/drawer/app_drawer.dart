import 'dart:io';

import 'package:leafz/helpers/localizations_ext.dart';
import 'package:leafz/ui/core/layout/glass.dart';
import 'package:leafz/ui/features/drawer/app_version_section.dart';
import 'package:leafz/ui/features/drawer/dark_mode_toggle.dart';
import 'package:leafz/ui/features/drawer/drawer_app_info.dart';
import 'package:leafz/ui/features/drawer/game_mode_settings.dart';
import 'package:leafz/ui/features/drawer/language_picker.dart';
import 'package:leafz/ui/features/drawer/latest_scores.dart';
import 'package:leafz/ui/features/drawer/puzzle_size_settings.dart';
import 'package:leafz/ui/core/layout/spacing.dart';
import 'package:leafz/ui/core/layout/screen_type_helper.dart';
import 'package:leafz/ui/core/app_text_styles.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  /// Fraction of the window width used on compact/medium breakpoints.
  static const double _drawerWidthFraction = 0.82;

  /// Fixed drawer width on expanded+ breakpoints.
  static const double _drawerMaxWidth = 500;

  Widget _drawerHeader(double drawerStartPadding) {
    return _DrawerHeader(drawerStartPadding: drawerStartPadding);
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    final windowSize = MediaQuery.sizeOf(context);
    final windowClass = context.windowClass;
    final isWideLayout = windowSize.width > windowSize.height;
    double drawerStartPadding = padding.left == 0 ? Spacing.md : padding.left;
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      left: false,
      child: ClipRRect(
        borderRadius: BorderRadius.zero,
        child: BackdropFilter(
          filter: AppGlass.filter,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Drawer width follows the window class, not the drawer's own
              // constraints (which reflect the drawer, not the window).
              final drawerWidth = switch (windowClass) {
                WindowClass.compact ||
                WindowClass.medium => windowSize.width * _drawerWidthFraction,
                _ => _drawerMaxWidth,
              };

              return Container(
                width: drawerWidth,
                margin:
                    kIsWeb ||
                        Platform.isAndroid ||
                        Platform.isMacOS ||
                        Platform.isLinux
                    ? const EdgeInsets.symmetric(vertical: 16)
                    : EdgeInsets.only(top: isWideLayout ? padding.bottom : 0),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.zero,
                ),
                child: Column(
                  children: [
                    _drawerHeader(drawerStartPadding),
                    const Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            PuzzleSizeSettings(),
                            GameModeSettings(),
                            LanguagePicker(),
                            DarkModeToggle(),
                            SizedBox(height: 8),
                            LatestScores(),
                          ],
                        ),
                      ),
                    ),
                    _DrawerFooter(drawerStartPadding: drawerStartPadding),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  final double drawerStartPadding;

  const _DrawerHeader({required this.drawerStartPadding});

  @override
  Widget build(BuildContext context) {
    final wc = context.windowClass;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.only(
        left: drawerStartPadding,
        right: Spacing.xl,
        top: Spacing.xl,
        bottom: Spacing.lg,
      ),
      child: Row(
        children: [
          _buildLogo(colorScheme),
          const SizedBox(width: 12),
          _buildTitleSection(context, wc, colorScheme),
          _buildCloseButton(context, colorScheme),
        ],
      ),
    );
  }

  Widget _buildLogo(ColorScheme colorScheme) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.zero,
      ),
      child: Center(
        child: Text(
          'D',
          style: AppTextStyles.headlineLarge.copyWith(
            color: colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildTitleSection(
    BuildContext context,
    WindowClass wc,
    ColorScheme colorScheme,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.appTitle,
            style:
                (wc == WindowClass.compact
                        ? AppTextStyles.titleMedium
                        : AppTextStyles.titleLarge)
                    .copyWith(
                      fontVariations: const [FontVariation('wght', 700)],
                    ),
          ),
          const SizedBox(height: 1),
          Text(
            context.l10n.appSubtitle,
            style: AppTextStyles.bodyAdaptive(
              wc,
            ).copyWith(fontVariations: const [FontVariation('wght', 400)]),
          ),
        ],
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context, ColorScheme colorScheme) {
    return IconButton(
      onPressed: () => Navigator.of(context).pop(),
      icon: const HugeIcon(icon: HugeIcons.strokeRoundedCancel01),
      style: IconButton.styleFrom(
        foregroundColor: colorScheme.onSurface.withValues(alpha: 0.7),
      ),
    );
  }
}

class _DrawerFooter extends StatelessWidget {
  final double drawerStartPadding;

  const _DrawerFooter({required this.drawerStartPadding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: drawerStartPadding,
        right: Spacing.md,
        top: Spacing.sm,
        bottom: Spacing.md + MediaQuery.paddingOf(context).bottom / 2,
      ),
      child: const Row(
        // Version pinned left, attribution right — the decorative rocket
        // was an icon-for-icons'-sake (DESIGN.md: no non-functional icons).
        children: [
          Expanded(child: AppVersionSection()),
          SizedBox(width: 8),
          DrawerAppInfo(),
        ],
      ),
    );
  }
}
