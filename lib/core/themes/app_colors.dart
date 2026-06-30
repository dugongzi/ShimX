import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const primary = Color(0xFF7C6BFF);
  static const secondary = Color(0xFFB07BFF);

  static const textPrimary = Color(0xFF333333);
  static const textSecondary = Color(0xFF666666);
  static const textHint = Color(0xFF999999);
  static const textWhite = Colors.white;

  static const background = Color(0xFFF5F5F5);
  static const surface = Colors.white;
  static const surfaceVariant = Color(0x89C8C7C7);
  static const darkBackground = Color(0xFF1E1E1E);

  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFF9800);
  static const error = Color(0xFFF44336);
  static const info = Color(0xFF2196F3);

  static const divider = Color(0xFFE0E0E0);
  static const overlay = Color(0x80000000);

  // ---- Dark theme palette ----
  // 底色用中性深色(冷暖中性 near-black),色相由主题色光晕决定,
  // 不再绑定紫调——用户切主题色时整个背景自然跟随
  static const darkBgTop = Color(0xFF14161B);
  static const darkBgMid = Color(0xFF101216);
  static const darkBgBottom = Color(0xFF0B0D11);

  // 玻璃卡基色:在中性深底上偏冷一档(略带蓝紫只是为了在主色叠加时不发黄)
  // 实际显示色由 alpha + BackdropFilter 决定,这两个常量本身视觉极暗
  static const darkSurface = Color(0xFF1B1E26);
  static const darkSurfaceHigh = Color(0xFF242833);

  // 描边:中性灰紫,只在玻璃边缘隐约可见
  static const darkOutline = Color(0xFF4A4E5C);

  // dark 模式下用作激活态紫粉尾色(参考图设计语言的固定尾色,
  // 主题色变化时仍保留这个"主→紫粉"渐变收尾)
  static const darkSecondary = Color(0xFFB07BFF);
}
