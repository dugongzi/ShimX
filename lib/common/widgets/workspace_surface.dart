import 'package:codex_z/core/constants/app_sizes.dart';
import 'package:codex_z/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

class WorkspaceSurface extends StatelessWidget {
  const WorkspaceSurface({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(
          alpha: context.isDark ? 0.52 : 0.72,
        ),
        borderRadius: BorderRadius.circular(AppSizes.cardRadius + 8),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.28),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}
