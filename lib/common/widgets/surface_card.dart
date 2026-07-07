import 'dart:ui';

import 'package:shimx/core/constants/app_sizes.dart';
import 'package:shimx/core/extensions/context_extensions.dart';
import 'package:shimx/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

/// 通用卡片:深色下走玻璃质感 + 蓝紫带色阴影。
class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = context.isDark;
    // 子卡圆角:比主面板(cardRadius+12)明显小一档,层级感
    final radius = BorderRadius.circular(AppSizes.cardRadius + 2);

    final fill = isDark
        ? AppColors.darkSurface.withValues(alpha: 0.78)
        : colorScheme.surface.withValues(alpha: 0.82);
    final borderColor = isDark
        ? AppColors.darkOutline.withValues(alpha: 0.24)
        : colorScheme.outlineVariant.withValues(alpha: 0.42);
    final shadowColor = isDark
        ? colorScheme.primary.withValues(alpha: 0.18)
        : Colors.black.withValues(alpha: 0.06);

    final card = Container(
      width: width,
      padding: padding ?? EdgeInsets.all(14.cw(min: 12, max: 16)),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: radius,
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: isDark ? 28 : 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );

    if (!isDark) {
      return Padding(padding: margin ?? EdgeInsets.zero, child: card);
    }

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: card,
        ),
      ),
    );
  }
}
