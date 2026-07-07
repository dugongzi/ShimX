import 'package:shimx/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

class IconBadge extends StatelessWidget {
  const IconBadge({super.key, required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 38.cr(min: 34, max: 42),
      height: 38.cr(min: 34, max: 42),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(
          alpha: context.isDark ? 0.24 : 0.16,
        ),
        borderRadius: BorderRadius.circular(12.cr(min: 10, max: 14)),
      ),
      child: Icon(
        icon,
        color: colorScheme.primary,
        size: 20.cr(min: 18, max: 22),
      ),
    );
  }
}
