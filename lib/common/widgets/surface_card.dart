import 'package:codex_z/core/constants/app_sizes.dart';
import 'package:codex_z/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

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

    return Container(
      width: width,
      margin: margin,
      padding: padding ?? EdgeInsets.all(14.cw(min: 12, max: 16)),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(
          alpha: context.isDark ? 0.88 : 0.82,
        ),
        borderRadius: BorderRadius.circular(AppSizes.cardRadius + 2),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(
            alpha: context.isDark ? 0.18 : 0.42,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDark ? 0.18 : 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
