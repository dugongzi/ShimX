import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shim/core/constants/app_sizes.dart';
import 'package:shim/core/extensions/context_extensions.dart';
import 'package:shim/core/themes/app_colors.dart';
import 'package:shim/features/home/presentation/widgets/proxy_status.dart';
import 'package:shim/features/home/presentation/widgets/sidebar_action_icons_row.dart';
import 'package:shim/features/home/presentation/widgets/sidebar_brand.dart';
import 'package:shim/features/home/presentation/widgets/sidebar_status.dart';

/// 主页面左侧侧栏外壳:品牌 + tab 列表 + 底部动作 / 状态。
/// 关键:不用任何 Scroll widget(viewport 永远裁剪),纯 Column,
/// 让选中 tab 的 transform-x 可以可见地溢出右边界。
class HomeSidebar extends StatelessWidget {
  const HomeSidebar({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = context.isDark;
    final radius = BorderRadius.circular(AppSizes.cardRadius + 8);

    final fill = isDark
        ? AppColors.darkSurface.withValues(alpha: 0.5)
        : colorScheme.surface.withValues(alpha: 0.76);
    final borderColor = isDark
        ? AppColors.darkOutline.withValues(alpha: 0.24)
        : colorScheme.outlineVariant.withValues(alpha: 0.42);
    final shadowColor = isDark
        ? colorScheme.primary.withValues(alpha: 0.2)
        : Colors.black.withValues(alpha: 0.06);

    // 背景层:玻璃模糊 + 半透明底色 + 描边,被 ClipRRect 裁掉超出部分
    final glassBackground = ClipRRect(
      borderRadius: radius,
      child: Stack(
        children: [
          if (isDark)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: const SizedBox.expand(),
              ),
            ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: fill,
                borderRadius: radius,
                border: Border.all(color: borderColor),
              ),
            ),
          ),
        ],
      ),
    );

    // 内容层:纯 Column,无 Scroll 容器(viewport 会裁切 transform 溢出)
    final content = Padding(
      padding: EdgeInsets.all(AppSizes.itemGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SidebarBrand(title: title),
          SizedBox(height: AppSizes.sectionGap),
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) SizedBox(height: AppSizes.itemGap),
            children[i],
          ],
          const Spacer(),
          SizedBox(height: AppSizes.sectionGap),
          const SidebarActionIconsRow(debugPort: 9229),
          SizedBox(height: AppSizes.itemGap),
          const SidebarStatus(),
          SizedBox(height: AppSizes.itemGap),
          const ProxyStatus(),
        ],
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: isDark ? 32 : 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      // Stack + Clip.none,让 tab 探出右边界
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(child: glassBackground),
          Positioned.fill(child: content),
        ],
      ),
    );
  }
}
