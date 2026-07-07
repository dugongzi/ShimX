import 'package:shimx/core/extensions/context_extensions.dart';
import 'package:shimx/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

/// 全局渐变背景:
/// dark 走中性深底 + 主题色光晕(主题色变化时光晕跟着变)
/// light 沿用浅色 + 主色低饱和渐变
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = context.isDark;

    final base = isDark ? AppColors.darkBgTop : const Color(0xFFF6FAFB);
    final mid = isDark ? AppColors.darkBgMid : base;
    final end = isDark
        ? AppColors.darkBgBottom
        : colorScheme.secondary.withValues(alpha: 0.08);

    // 主光晕(右上):用主题色,主题切换时跟着变
    final highlightTop = isDark
        ? colorScheme.primary.withValues(alpha: 0.18)
        : colorScheme.primary.withValues(alpha: 0.06);
    // 次光晕(左下):dark 保留紫粉尾色作为玻璃高光,
    // light 不画(避免和主题色冲突)
    final highlightBottom = isDark
        ? AppColors.darkSecondary.withValues(alpha: 0.12)
        : colorScheme.secondary.withValues(alpha: 0);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: base,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [base, mid, end],
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0.85, -0.85),
            radius: 1.1,
            colors: [highlightTop, Colors.transparent],
            stops: const [0, 1],
          ),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(-0.9, 0.95),
              radius: 1.2,
              colors: [highlightBottom, Colors.transparent],
              stops: const [0, 1],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
