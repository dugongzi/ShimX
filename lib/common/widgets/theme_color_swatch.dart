import 'package:flutter/material.dart';

/// 一个圆形主题色选项;支持选中态光晕 + 可选渐变填充。
/// 注意:类名故意避开 Flutter 内置 `ColorSwatch`(那是 Material 的色阶类)。
class ThemeColorSwatch extends StatelessWidget {
  const ThemeColorSwatch({
    super.key,
    required this.color,
    required this.selected,
    required this.onTap,
    this.gradient,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message:
          '#${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}',
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color,
            gradient: gradient,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: selected ? 0.96 : 0.74),
              width: selected ? 3 : 2,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.36),
                      blurRadius: 14,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: selected
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
              : null,
        ),
      ),
    );
  }
}
