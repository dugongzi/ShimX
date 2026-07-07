import 'package:shimx/core/extensions/context_extensions.dart';
import 'package:shimx/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class CustomDialog extends StatelessWidget {
  final Widget title;

  final List<Widget>? action;

  final List<Widget>? actionButtons;

  final bool hasClose;

  final Widget? child;

  final double? height;

  final double? width;

  const CustomDialog({
    super.key,
    required this.title,
    this.child,
    this.hasClose = false,
    this.actionButtons,
    this.action,
    this.height,
    this.width,
  });

  static Future<T?> show<T>({
    required Widget title,
    Widget? child,
    List<Widget>? action,
    double? height,
    double? width,
    List<Widget>? actionButtons,
    bool hasClose = false,
  }) {
    return SmartDialog.show(
      builder: (context) => CustomDialog(
        title: title,
        action: action,
        width: width,
        height: height,
        actionButtons: actionButtons,
        hasClose: hasClose,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenW = context.screenWidth;
        final screenH = context.screenHeight;
        final upperWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : screenW;
        final upperHeight = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : screenH;
        final resolvedMaxWidth =
            (screenW * 0.9).clamp(280.0, 560.0).clamp(0.0, upperWidth);
        final resolvedMaxHeight =
            (screenH * 0.9).clamp(0.0, upperHeight).toDouble();
        final dialogWidth = width == null
            ? resolvedMaxWidth
            : width!.clamp(0.0, resolvedMaxWidth).toDouble();
        final dialogHeight = height?.clamp(0.0, resolvedMaxHeight).toDouble();
        final content = Padding(
          padding: EdgeInsets.symmetric(
            vertical: 8.ch(min: 6, max: 12),
            horizontal: 10.cw(min: 8, max: 14),
          ),
          child: Column(
            mainAxisSize: dialogHeight == null
                ? MainAxisSize.min
                : MainAxisSize.max,
            children: [
              if (child != null)
                if (dialogHeight != null) Expanded(child: child!) else child!,
              if (actionButtons != null) ...[
                if (child != null) SizedBox(height: 8.ch(min: 6, max: 12)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: 5.cw(min: 4, max: 8),
                  children: [...actionButtons!],
                ),
              ],
            ],
          ),
        );

        return Material(
          color: context.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: resolvedMaxWidth,
              maxHeight: resolvedMaxHeight,
            ),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 10.cw(min: 8, max: 14),
                vertical: 8.ch(min: 6, max: 12),
              ),
              width: dialogWidth,
              height: dialogHeight,
              child: Column(
                mainAxisSize: dialogHeight == null
                    ? MainAxisSize.min
                    : MainAxisSize.max,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 8.ch(min: 6, max: 12),
                      horizontal: 10.cw(min: 8, max: 14),
                    ),
                    child: DefaultTextStyle(
                      style: TextStyle(
                        fontSize: 18.csp(min: 15, max: 20),
                        fontFamily: AppFonts.primary,
                        color: context.textTheme.titleMedium!.color,
                      ),
                      child: Row(
                        children: [
                          Expanded(child: title),
                          if (action != null) ...action!,
                          if (hasClose)
                            IconButton(
                              onPressed: () => SmartDialog.dismiss(),
                              visualDensity: VisualDensity.compact,
                              tooltip: MaterialLocalizations.of(
                                context,
                              ).closeButtonTooltip,
                              icon: const Icon(Icons.close, color: Colors.grey),
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (child != null) const Divider(),
                  if (dialogHeight != null)
                    Expanded(child: content)
                  else
                    content,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
