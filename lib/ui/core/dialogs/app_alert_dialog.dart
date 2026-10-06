import 'package:leafz/helpers/localizations_ext.dart';
import 'package:leafz/ui/core/layout/glass.dart';
import 'package:leafz/ui/core/layout/spacing.dart';
import 'package:leafz/ui/core/app_text_styles.dart';
import 'package:flutter/material.dart';

class AppAlertDialog extends StatelessWidget {
  final String? title;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final Widget? content;
  final EdgeInsets insetPadding;

  const AppAlertDialog({
    super.key,
    this.title,
    this.onConfirm,
    this.onCancel,
    this.content,
    this.insetPadding = const EdgeInsets.symmetric(
      horizontal: 40.0,
      vertical: 24.0,
    ),
  }) : assert(content == null ? title != null && onConfirm != null : true);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      backgroundColor: Colors.transparent,
      contentPadding: const EdgeInsets.all(0),
      scrollable: true,
      insetPadding: insetPadding,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.zero,
            child: BackdropFilter(
              filter: AppGlass.filter,
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.screenHPadding,
                  vertical: Spacing.md,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.zero,
                  color: colorScheme.surfaceContainer.withValues(alpha: 0.7),
                ),
                child: content ?? _buildBody(context, colorScheme),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, ColorScheme colorScheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (title != null)
          Text(
            title!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppTextStyles.primaryFontFamily,
              fontSize: 22,
              fontWeight: FontWeight.w400,
              height: 1.2,
              color: colorScheme.onSurface,
            ),
          ),
        const SizedBox(height: 40),
        _buildButtonRow(context, colorScheme),
      ],
    );
  }

  Widget _buildButtonRow(BuildContext context, ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              if (onConfirm != null) {
                onConfirm!();
              }
              Navigator.of(context).pop();
            },
            child: Text(context.l10n.yes),
          ),
        ),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: ElevatedButton(
            onPressed: onCancel ?? () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: colorScheme.onSurface,
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
                side: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.15),
                  width: 0.5,
                ),
              ),
            ),
            child: Text(context.l10n.cancel),
          ),
        ),
      ],
    );
  }
}
