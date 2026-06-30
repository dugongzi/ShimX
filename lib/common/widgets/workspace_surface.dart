import 'dart:ui';

import 'package:shim/core/extensions/context_extensions.dart';
import 'package:shim/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

/// 右侧工作区大面板:深色下走玻璃质感(BackdropFilter + 半透明蓝紫底)。
class WorkspaceSurface extends StatelessWidget {
  const WorkspaceSurface({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = context.isDark;
    final radius = BorderRadius.zero;

    final fill = isDark
        ? AppColors.darkSurface.withValues(alpha: 0.55)
        : colorScheme.surface.withValues(alpha: 0.72);
    final borderColor = isDark
        ? AppColors.darkOutline.withValues(alpha: 0.22)
        : colorScheme.outlineVariant.withValues(alpha: 0.28);

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: radius,
            border: Border.all(color: borderColor),
          ),
          child: child,
        ),
      ),
    );
  }
}
