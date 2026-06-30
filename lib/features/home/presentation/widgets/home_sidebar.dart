import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shim/core/constants/app_sizes.dart';
import 'package:shim/core/extensions/context_extensions.dart';
import 'package:shim/core/themes/app_colors.dart';
import 'package:shim/features/home/presentation/widgets/sidebar_brand.dart';
import 'package:shim/features/home/presentation/widgets/sidebar_system_panel.dart';

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
    // 主面板圆角:和 WorkspaceSurface 对齐(cardRadius+12),
    // 让侧栏 / 内容区作为同级主面板,共同对比内部子卡(cardRadius+4)的更小圆角
    final radius = BorderRadius.circular(AppSizes.cardRadius + 12);

    // dark:比 WorkspaceSurface 更暗,做出主面板/工作区层级
    // light:保留玻璃白(让背景渐变透过去),不强行"加暗"——
    //   light 主次区分应靠"内容区更亮"实现,而不是"侧栏更脏"
    final fill = isDark
        ? AppColors.darkBgTop.withValues(alpha: 0.78)
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

    // 内容层:能纵向滚 + 横向溢出可见(让选中 tab 的 transform 探出右边界)
    // 关键:CustomScrollView/Viewport/sliver 全链路 clipBehavior: Clip.none。
    final content = Padding(
      padding: EdgeInsets.all(AppSizes.itemGap),
      child: CustomScrollView(
        clipBehavior: Clip.none,
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SidebarBrand(title: title),
                SizedBox(height: AppSizes.sectionGap),
              ],
            ),
          ),
          SliverList.separated(
            itemCount: children.length,
            separatorBuilder: (context, _) =>
                SizedBox(height: AppSizes.itemGap),
            itemBuilder: (context, index) => children[index],
          ),
          // 底部状态区:窗口够高时占满剩余空间贴底;够矮时只占自身高度,
          // 整页纵向可滚,不再 RenderFlex overflow。
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(height: AppSizes.sectionGap),
                const SidebarSystemPanel(),
              ],
            ),
          ),
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
