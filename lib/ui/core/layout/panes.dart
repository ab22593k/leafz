import 'package:flutter/material.dart';
import 'package:leafz/ui/core/layout/glass.dart';

/// Whether a pane has a fixed width or flexes with available space.
///
/// All layouts need at least one [flexible] pane.
enum PaneSizing {
  /// Width doesn't change based on available space.
  fixed,

  /// Width changes based on available space.
  flexible,
}

/// How multiple panes are displayed relative to each other.
enum PaneDisplay {
  /// Side-by-side panes. Preferred for persistent utilities.
  coPlanar,

  /// A pane displayed above other panes, like a dialog.
  floating,

  /// A pane pinned to the edge of the window, like a bottom sheet.
  docked,
}

/// How a pane adapts when the breakpoint changes.
enum PaneAdaptation {
  /// Pane enters/exits the screen as breakpoint changes.
  showAndHide,

  /// Pane elevates above other content as floating or docked.
  levitate,

  /// Pane reorganizes position (e.g. side-by-side → stacked).
  reflow,
}

/// The type of multi-pane layout.
enum PaneLayout {
  /// One flexible pane extending to fit available width.
  /// Recommended for compact and medium breakpoints.
  single,

  /// Two flexible panes with the spacer visually centered (50/50).
  /// Best for foldable devices and dynamic layouts.
  split,

  /// One fixed + one flexible pane. Common for expanded, large,
  /// and extra-large breakpoints. The fixed pane is often temporary.
  fixedAndFlexible,

  /// Two panes + a side sheet as third pane. Extra-large only.
  /// Fixed panes recommended at 412dp; side sheets max 400dp.
  threePane,
}

/// Recommended snap widths for pane resizing.
class PaneSnapPoints {
  /// Recommended fixed pane width at extra-large breakpoint.
  static const double fixedPane = 412;

  /// Default maximum width for a side sheet used as a third pane.
  static const double sideSheetMax = 400;

  /// Recommended custom snap width.
  static const double narrow = 460;

  /// Recommended custom snap width.
  static const double standard = 412;

  /// Returns the nearest snap point to [width], or null if not within
  /// [tolerance] of any snap point.
  static double? nearest(double width, {double tolerance = 24}) {
    const points = [narrow, standard];
    for (final p in points) {
      if ((width - p).abs() <= tolerance) return p;
    }
    return null;
  }
}

/// Configuration for a single pane in the layout.
class PaneConfig {
  final Widget child;
  final PaneSizing sizing;
  final PaneDisplay display;
  final PaneAdaptation adaptation;
  final double? fixedWidth;
  final int flex;

  const PaneConfig({
    required this.child,
    this.sizing = PaneSizing.flexible,
    this.display = PaneDisplay.coPlanar,
    this.adaptation = PaneAdaptation.showAndHide,
    this.fixedWidth,
    this.flex = 1,
  });
}

/// Determines the recommended [PaneLayout] for a given breakpoint.
PaneLayout recommendedPaneLayout({
  required int paneCount,
  required bool isExtraLarge,
  required bool isExpandedOrLarger,
}) {
  if (paneCount <= 1) return PaneLayout.single;
  if (isExtraLarge && paneCount >= 3) return PaneLayout.threePane;
  if (isExpandedOrLarger) return PaneLayout.fixedAndFlexible;
  return PaneLayout.split;
}

/// A draggable handle for resizing panes.
class PaneDragHandle extends StatefulWidget {
  final VoidCallback? onTap;
  final ValueChanged<double>? onDrag;
  final ValueChanged<double>? onDragEnd;
  final bool isCollapsed;
  final double currentWidth;
  final double minWidth;
  final double maxWidth;

  const PaneDragHandle({
    super.key,
    this.onTap,
    this.onDrag,
    this.onDragEnd,
    this.isCollapsed = false,
    this.currentWidth = 0,
    this.minWidth = 320,
    this.maxWidth = double.infinity,
  });

  @override
  State<PaneDragHandle> createState() => _PaneDragHandleState();
}

class _PaneDragHandleState extends State<PaneDragHandle> {
  double _dragStart = 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        onTap: widget.onTap,
        onDoubleTap: widget.onTap,
        onHorizontalDragStart: (details) {
          _dragStart = details.globalPosition.dx;
        },
        onHorizontalDragUpdate: (details) {
          final delta = details.globalPosition.dx - _dragStart;
          _dragStart = details.globalPosition.dx;
          widget.onDrag?.call(delta);
        },
        onHorizontalDragEnd: (_) {
          widget.onDragEnd?.call(widget.currentWidth);
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 24,
          alignment: Alignment.center,
          child: Container(
            width: 4,
            height: 32,
            decoration: BoxDecoration(
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.zero,
            ),
            child: widget.isCollapsed
                ? Icon(
                    Icons.chevron_left,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

/// An pane divider used between co-planar panes.
Widget paneDivider(BuildContext context) {
  return const SizedBox(width: 24);
}

/// A floating pane displayed above other panes, like a dialog or popover.
///
/// Per MD3 spec:
/// - Temporary tasks should remain floating regardless of breakpoint.
/// - On large screens, floating panes are the default and the scrim is optional.
/// - Can be customized to be dragged or resized.
class FloatingPane extends StatelessWidget {
  final Widget child;
  final bool showScrim;
  final bool modal;
  final VoidCallback? onDismiss;
  final double? width;
  final double? height;

  const FloatingPane({
    super.key,
    required this.child,
    this.showScrim = true,
    this.modal = true,
    this.onDismiss,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        if (showScrim)
          ModalBarrier(
            dismissible: !modal,
            color: colorScheme.scrim.withValues(alpha: 0.4),
          ),
        Center(
          child: Container(
            width: width,
            height: height,
            constraints: BoxConstraints(
              maxWidth: width ?? 560,
              maxHeight: height ?? MediaQuery.sizeOf(context).height * 0.8,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer.withValues(alpha: 0.7),
              borderRadius: BorderRadius.zero,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.onSurface.withValues(alpha: 0.04),
                  blurRadius: 40,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.zero,
              child: BackdropFilter(
                filter: AppGlass.filter,
                child: Material(color: Colors.transparent, child: child),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A docked pane pinned to the edge of the window, like a bottom sheet.
///
/// Per MD3 spec:
/// - Docked panes are usually at the bottom of the window.
/// - At medium and expanded breakpoints, docked panes can adapt into
///   floating or co-planar panes.
class DockedPane extends StatelessWidget {
  final Widget child;
  final bool isExpanded;

  const DockedPane({super.key, required this.child, this.isExpanded = false});

  @override
  Widget build(BuildContext context) {
    if (isExpanded) {
      return FloatingPane(showScrim: false, modal: false, child: child);
    }

    final colorScheme = Theme.of(context).colorScheme;
    final padding = MediaQuery.paddingOf(context);

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 640),
        margin: EdgeInsets.only(bottom: padding.bottom),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer.withValues(alpha: 0.7),
          borderRadius: BorderRadius.zero,
          boxShadow: [
            BoxShadow(
              color: colorScheme.onSurface.withValues(alpha: 0.04),
              blurRadius: 40,
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.zero,
          child: BackdropFilter(
            filter: AppGlass.filter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 32,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                Flexible(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
