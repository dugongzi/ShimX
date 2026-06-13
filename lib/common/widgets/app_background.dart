import 'package:codex_z/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final base = context.isDark
        ? const Color(0xFF151719)
        : const Color(0xFFF6FAFB);
    final mid = context.isDark ? const Color(0xFF1B1E21) : base;
    final end = context.isDark
        ? const Color(0xFF111315)
        : colorScheme.secondary.withValues(alpha: 0.08);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: base,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.isDark
                ? colorScheme.primary.withValues(alpha: 0.08)
                : colorScheme.primary.withValues(alpha: 0.10),
            mid,
            end,
          ],
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0.82, -0.78),
            radius: 1.1,
            colors: [
              colorScheme.primary.withValues(alpha: context.isDark ? 0.08 : 0),
              Colors.transparent,
            ],
            stops: const [0, 1],
          ),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(-0.88, 0.92),
              radius: 1.2,
              colors: [
                colorScheme.secondary.withValues(
                  alpha: context.isDark ? 0.05 : 0,
                ),
                Colors.transparent,
              ],
              stops: const [0, 1],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
