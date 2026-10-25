import 'dart:math' as math;

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
import 'package:leafz/ui/core/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class AppDrawer extends StatelessWidget {
  /// Explicit width for hosts that already constrain the drawer (the floating
  /// pane used on expanded layouts). When null, the drawer sizes itself from
  /// the window.
  final double? width;

  const AppDrawer({super.key, this.width});

  /// Fraction of the window width the drawer takes on a phone.
  static const double _drawerWidthFraction = 0.86;

  /// Hard ceiling. A drawer is a control surface, not a co-planar pane: at
  /// tablet widths a fraction alone produced a 684dp drawer that buried the
  /// board it was opening over.
  static const double _drawerMaxWidth = 400;

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.paddingOf(context);
    final scaffold = Scaffold.maybeOf(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final startInset = isRtl ? insets.right : insets.left;
    final endInset = isRtl ? insets.left : insets.right;
    final drawerStartPadding = startInset == 0 ? Spacing.md : startInset;
    final colorScheme = Theme.of(context).colorScheme;
    final drawerWidth =
        width ??
        math.min(
          MediaQuery.sizeOf(context).width * _drawerWidthFraction,
          _drawerMaxWidth,
        );

    // The app bar paints above the drawer, so the masthead has to clear it.
    // `appBarMaxHeight` already includes the status-bar inset; when the
    // drawer is hosted elsewhere (the floating pane) there is no app bar and
    // the system inset is the only thing to avoid.
    final contentTop = scaffold?.appBarMaxHeight ?? insets.top;

    // Scaffold lays the drawer slot out with *tight* full-window constraints,
    // so a width set on a descendant Container is silently discarded. The
    // Align is what lets the sheet be narrower than the slot and expose the
    // scrim strip that marks it as dismissible.
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: SizedBox(
        width: drawerWidth,
        child: ClipRRect(
          borderRadius: BorderRadius.zero,
          child: BackdropFilter(
            filter: AppGlass.filter,
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer.withValues(alpha: 0.7),
                borderRadius: BorderRadius.zero,
              ),
              child: Column(
                children: [
                  _DrawerHeader(
                    startPadding: drawerStartPadding,
                    endPadding: Spacing.md + endInset,
                    topPadding: contentTop + Spacing.xl,
                  ),
                  const Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          PuzzleSizeSettings(),
                          GameModeSettings(),
                          LanguagePicker(),
                          DarkModeToggle(),
                          // A full blank line before the record: the scores
                          // are the drawer's coda, not a sixth setting.
                          SizedBox(height: Spacing.section),
                          LatestScores(),
                        ],
                      ),
                    ),
                  ),
                  _DrawerFooter(
                    startPadding: drawerStartPadding,
                    endPadding: Spacing.md + endInset,
                    bottomPadding: Spacing.md + insets.bottom,
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

class _DrawerHeader extends StatelessWidget {
  final double startPadding;
  final double endPadding;
  final double topPadding;

  const _DrawerHeader({
    required this.startPadding,
    required this.endPadding,
    required this.topPadding,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsetsDirectional.only(
        start: startPadding,
        end: endPadding,
        top: topPadding,
        bottom: Spacing.lg,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildMasthead(context, colorScheme)),
          _buildCloseButton(context, colorScheme),
        ],
      ),
    );
  }

  /// Masthead: rubric over wordmark. The old square "logo" tile was a
  /// placeholder glyph; the product name set in the display face does the
  /// same job with actual brand voice.
  Widget _buildMasthead(BuildContext context, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.appSubtitle.toUpperCase(),
          style: AppTextStyles.kicker.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.45),
          ),
        ),
        const SizedBox(height: Spacing.xxs),
        Text(
          context.l10n.appTitle,
          style: AppTextStyles.headlineMedium.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
      ],
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
  final double startPadding;
  final double endPadding;
  final double bottomPadding;

  const _DrawerFooter({
    required this.startPadding,
    required this.endPadding,
    required this.bottomPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.only(
        start: startPadding,
        end: endPadding,
        top: Spacing.sm,
        bottom: bottomPadding,
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
