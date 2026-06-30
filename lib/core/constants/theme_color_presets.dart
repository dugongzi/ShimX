import 'package:flutter/material.dart';

/// 主题色选项盘:第一项是 launch 主题色,后续为预设备选。
/// 多色渐变仅装饰 launch 主题色,其余 swatch 用纯色。
const Color launchThemeColor = Color(0xFF7C6BFF);

const List<Color> themeColorPresets = [
  launchThemeColor,
  Color(0xFFB07BFF),
  Color(0xFF6C8CFF),
  Color(0xFF98D2D5),
  Color(0xFF27AE60),
  Color(0xFFE86F51),
];

/// launch 主题色的特殊渐变(在 swatch 上做光晕效果)。
const LinearGradient launchThemeColorGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF6C7BFF),
    Color(0xFF7C6BFF),
    Color(0xFFB07BFF),
    Color(0xFFE43FE4),
  ],
);
