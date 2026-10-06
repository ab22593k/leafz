import 'package:leafz/ui/core/layout/panes.dart';
import 'package:leafz/ui/core/layout/screen_type_helper.dart';
import 'package:leafz/ui/core/layout/spacing.dart';
import 'package:flutter/material.dart';

/// Fundamental UI design structure that provides a standard
/// platform for assembling key components.
///
/// The scaffold structures every piece of an adaptive layout
/// into **bars**, **rails**, and **panes**:
///
/// ## Breakpoint adaptation (per MD3 Scaffold + Panes spec)
///
/// | Breakpoint | Width (dp) | Bars | Rails | Panes |
///
/// | **Compact** | <600 | AppBar + NavBar | top/bottom rail only | 1 |
/// | **Medium** | 600–839 | AppBar + NavBar | top/bottom rail, opt. leading | 1 (opt. 2) |
/// | **Expanded** | 840–1199 | AppBar | leading rail, opt. trailing | 2 (opt. 1) |
/// | **Large** | 1200–1599 | AppBar | leading + trailing rail | 2 (opt. 1) |
/// | **Extra-large** | 1600+ | AppBar | leading + trailing rail | 2–3 |
class LeafzScaffold extends StatefulWidget {
  /// Top app bar — sits below the safety region, frames the top of the screen.
  final PreferredSizeWidget? topBar;

  /// Bottom navigation bar — sits above the safety region on compact/medium.
  /// Hidden on expanded+ where the leading rail takes over navigation.
  final Widget? bottomBar;

  /// Leading rail — typically a [NavigationRail]. Shown on medium+ screens.
  /// On compact, navigation is handled by [bottomBar] + [drawer].
  final Widget? leadingRail;

  /// Trailing rail — a vertical toolbar or supporting controls.
  /// Shown on expanded+ screens.
  final Widget? trailingRail;

  /// Top rail region — floats above panes on compact (toolbars, FABs, inputs).
  final Widget? topRail;

  /// Bottom rail region — floats above the bottom bar (toolbars, FABs).
  final Widget? bottomRail;

  /// Primary pane — always visible, flexible.
  final Widget body;

  /// Secondary pane — shown alongside [body] on medium+ breakpoints.
  final Widget? secondaryPane;

  /// Tertiary pane — shown only on extra-large breakpoints as a third pane.
  final Widget? tertiaryPane;

  final PaneSizing secondarySizing;
  final PaneSizing tertiarySizing;
  final PaneDisplay secondaryDisplay;
  final PaneDisplay tertiaryDisplay;
  final double? secondaryFixedWidth;
  final double? tertiaryFixedWidth;
  final int primaryPaneFlex;
  final int secondaryPaneFlex;

  /// Drawer content — slides from the leading edge on compact/medium.
  final Widget? drawer;

  /// FAB — placed in the bottom-right rail region per MD3.
  final Widget? floatingActionButton;

  const LeafzScaffold({
    super.key,
    this.topBar,
    this.bottomBar,
    this.leadingRail,
    this.trailingRail,
    this.topRail,
    this.bottomRail,
    required this.body,
    this.secondaryPane,
    this.tertiaryPane,
    this.secondarySizing = PaneSizing.flexible,
    this.tertiarySizing = PaneSizing.flexible,
    this.secondaryDisplay = PaneDisplay.coPlanar,
    this.tertiaryDisplay = PaneDisplay.coPlanar,
    this.secondaryFixedWidth,
    this.tertiaryFixedWidth,
    this.primaryPaneFlex = 2,
    this.secondaryPaneFlex = 1,
    this.drawer,
    this.floatingActionButton,
  });

  @override
  State<LeafzScaffold> createState() => _LeafzScaffoldState();
}

class _LeafzScaffoldState extends State<LeafzScaffold> {
  bool _secondaryCollapsed = false;

  /// Persistent pane width memory — survives breakpoint changes per MD3 spec.
  /// Null means use default (split = 50/50, fixed = [PaneSnapPoints.fixedPane]).
  double? _secondaryWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wc = ScreenTypeHelper(
          constraints.maxWidth,
          constraints.maxHeight,
        ).windowClass;

        return _buildScaffold(context, wc);
      },
    );
  }

  Widget _buildScaffold(BuildContext context, WindowClass wc) {
    final showBottomBar = _shouldShowBottomBar(wc);
    final showDrawer = _shouldShowDrawer(wc);

    final scaffold = Scaffold(
      backgroundColor: Colors.transparent,
      appBar: widget.topBar,
      bottomNavigationBar: showBottomBar ? widget.bottomBar : null,
      drawer: showDrawer ? widget.drawer : null,
      floatingActionButton: widget.floatingActionButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _buildBody(context, wc),
    );

    return _withRails(wc, scaffold);
  }

  Widget _buildBody(BuildContext context, WindowClass wc) {
    final panes = _buildPanes(context, wc);

    final children = <Widget>[];

    if (widget.topRail != null) {
      children.add(_railRegion(widget.topRail!, isTop: true));
    }

    children.add(Expanded(child: panes));

    if (widget.bottomRail != null) {
      children.add(_railRegion(widget.bottomRail!, isTop: false));
    }

    if (children.length == 1) return panes;

    return Column(children: children);
  }

  Widget _buildPanes(BuildContext context, WindowClass wc) {
    final showSecondary = _shouldShowSecondary(wc) && !_secondaryCollapsed;
    final showTertiary = _shouldShowTertiary(wc);

    if (!showSecondary && !showTertiary) {
      return _paneArea(wc, widget.body);
    }

    final layout = _resolvePaneLayout(wc, showTertiary);

    return switch (layout) {
      PaneLayout.single => _paneArea(wc, widget.body),
      PaneLayout.split => _buildSplitPane(wc),
      PaneLayout.fixedAndFlexible => _buildFixedAndFlexiblePane(
        wc,
        showTertiary,
      ),
      PaneLayout.threePane => _buildThreePane(wc),
    };
  }

  PaneLayout _resolvePaneLayout(WindowClass wc, bool showTertiary) {
    final paneCount = 1 + (showTertiary ? 2 : 1);
    return recommendedPaneLayout(
      paneCount: paneCount,
      isExtraLarge: wc == WindowClass.extraLarge,
      isExpandedOrLarger: switch (wc) {
        WindowClass.expanded ||
        WindowClass.large ||
        WindowClass.extraLarge => true,
        _ => false,
      },
    );
  }

  // "A split-pane layout keeps the spacer visually centered.
  // It's best for foldable devices and dynamic layouts."
  // Both panes are flexible and default to 50% width.

  Widget _buildSplitPane(WindowClass wc) {
    return Row(
      children: [
        Expanded(
          flex: widget.primaryPaneFlex,
          child: _paneArea(wc, widget.body),
        ),
        paneDivider(context),
        Expanded(
          flex: widget.secondaryPaneFlex,
          child: _paneArea(wc, widget.secondaryPane!),
        ),
      ],
    );
  }

  // "This layout is common for expanded, large, and extra-large
  // breakpoints. The fixed pane is often temporary, used for side sheets
  // or lists with light information density."
  // The drag handle can fully collapse and expand the fixed pane.

  Widget _buildFixedAndFlexiblePane(WindowClass wc, bool showTertiary) {
    final fixedWidth =
        _secondaryWidth ??
        widget.secondaryFixedWidth ??
        PaneSnapPoints.fixedPane;

    final panes = <Widget>[Expanded(child: _paneArea(wc, widget.body))];

    panes.addAll(
      _buildPaneResizer(
        isCollapsed: _secondaryCollapsed,
        fixedWidth: fixedWidth,
        wc: wc,
      ),
    );

    if (showTertiary) {
      panes.add(paneDivider(context));
      panes.add(
        SizedBox(
          width: widget.tertiaryFixedWidth ?? PaneSnapPoints.sideSheetMax,
          child: _paneArea(wc, widget.tertiaryPane!),
        ),
      );
    }

    return Row(children: panes);
  }

  List<Widget> _buildPaneResizer({
    required bool isCollapsed,
    required double fixedWidth,
    required WindowClass wc,
  }) {
    if (!isCollapsed) {
      return [
        PaneDragHandle(
          currentWidth: fixedWidth,
          onTap: () => setState(() => _secondaryCollapsed = true),
          onDrag: (delta) {
            setState(() {
              _secondaryWidth = (fixedWidth - delta).clamp(
                PaneSnapPoints.narrow,
                PaneSnapPoints.standard + 100,
              );
            });
          },
          onDragEnd: (width) {
            final snap = PaneSnapPoints.nearest(width);
            if (snap != null) {
              setState(() => _secondaryWidth = snap);
            }
          },
        ),
        SizedBox(
          width: _secondaryWidth ?? fixedWidth,
          child: _paneArea(wc, widget.secondaryPane!),
        ),
      ];
    }
    return [
      PaneDragHandle(
        isCollapsed: true,
        onTap: () => setState(() => _secondaryCollapsed = false),
      ),
    ];
  }

  // "The extra-large breakpoint supports using a standard side sheet
  // as a third pane. Fixed panes recommended at 412dp; side sheets max 400dp."

  Widget _buildThreePane(WindowClass wc) {
    return Row(
      children: [
        Expanded(
          flex: widget.primaryPaneFlex,
          child: _paneArea(wc, widget.body),
        ),
        paneDivider(context),
        SizedBox(
          width: widget.secondaryFixedWidth ?? PaneSnapPoints.fixedPane,
          child: _paneArea(wc, widget.secondaryPane!),
        ),
        paneDivider(context),
        SizedBox(
          width: widget.tertiaryFixedWidth ?? PaneSnapPoints.sideSheetMax,
          child: _paneArea(wc, widget.tertiaryPane!),
        ),
      ],
    );
  }

  Widget _withRails(WindowClass wc, Widget scaffold) {
    final showLeading = _shouldShowLeadingRail(wc);
    final showTrailing = _shouldShowTrailingRail(wc);

    if (!showLeading && !showTrailing) return scaffold;

    return Row(
      children: [
        if (showLeading) widget.leadingRail!,
        Expanded(child: scaffold),
        if (showTrailing) widget.trailingRail!,
      ],
    );
  }

  Widget _railRegion(Widget child, {required bool isTop}) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.screenHPadding,
          vertical: Spacing.xs,
        ),
        child: child,
      ),
    );
  }

  bool _shouldShowBottomBar(WindowClass wc) {
    if (widget.bottomBar == null) return false;
    return switch (wc) {
      WindowClass.compact || WindowClass.medium => true,
      _ => false,
    };
  }

  bool _shouldShowDrawer(WindowClass wc) {
    if (widget.drawer == null) return false;
    return switch (wc) {
      WindowClass.compact || WindowClass.medium => true,
      _ => false,
    };
  }

  bool _shouldShowLeadingRail(WindowClass wc) {
    if (widget.leadingRail == null) return false;
    return switch (wc) {
      WindowClass.compact => false,
      WindowClass.medium ||
      WindowClass.expanded ||
      WindowClass.large ||
      WindowClass.extraLarge => true,
    };
  }

  bool _shouldShowTrailingRail(WindowClass wc) {
    if (widget.trailingRail == null) return false;
    return switch (wc) {
      WindowClass.compact || WindowClass.medium => false,
      WindowClass.expanded ||
      WindowClass.large ||
      WindowClass.extraLarge => true,
    };
  }

  bool _shouldShowSecondary(WindowClass wc) {
    if (widget.secondaryPane == null) return false;
    return switch (wc) {
      WindowClass.compact || WindowClass.medium => false,
      WindowClass.expanded ||
      WindowClass.large ||
      WindowClass.extraLarge => true,
    };
  }

  bool _shouldShowTertiary(WindowClass wc) {
    if (widget.tertiaryPane == null) return false;
    return wc == WindowClass.extraLarge;
  }

  Widget _paneArea(WindowClass wc, Widget child) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Spacing.screenHPaddingFor(wc)),
      child: child,
    );
  }
}

/// Creates a [NavigationRail] that adapts its extended state to the
/// breakpoint: collapsed on medium, extended on expanded+.
class AdaptiveNavigationRail extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int>? onDestinationSelected;
  final List<NavigationRailDestination> destinations;
  final Widget? leading;
  final Widget? trailing;

  const AdaptiveNavigationRail({
    super.key,
    required this.selectedIndex,
    this.onDestinationSelected,
    required this.destinations,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final wc = context.windowClass;
    final extended = switch (wc) {
      WindowClass.compact || WindowClass.medium => false,
      WindowClass.expanded ||
      WindowClass.large ||
      WindowClass.extraLarge => true,
    };

    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: destinations,
      extended: extended,
      leading: leading,
      trailing: trailing,
      minExtendedWidth: 200,
    );
  }
}
