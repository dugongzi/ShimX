import 'package:flutter/material.dart';
import 'package:shim/core/constants/app_sizes.dart';
import 'package:shim/core/extensions/context_extensions.dart';
import 'package:shim/features/home/presentation/widgets/proxy_status.dart';
import 'package:shim/features/home/presentation/widgets/sidebar_action_icons_row.dart';
import 'package:shim/features/home/presentation/widgets/sidebar_brand.dart';
import 'package:shim/features/home/presentation/widgets/sidebar_status.dart';

/// 主页面左侧侧栏外壳:品牌 + tab 列表 + 底部动作 / 状态。
class HomeSidebar extends StatelessWidget {
  const HomeSidebar({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: AppSizes.sidebarWidth,
      child: Container(
        padding: EdgeInsets.all(AppSizes.itemGap),
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(
            alpha: context.isDark ? 0.68 : 0.76,
          ),
          borderRadius: BorderRadius.circular(AppSizes.cardRadius + 4),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(
              alpha: context.isDark ? 0.18 : 0.42,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: context.isDark ? 0.18 : 0.06,
              ),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: CustomScrollView(
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
            // 导航 tab 列表
            SliverList.separated(
              itemCount: children.length,
              separatorBuilder: (context, index) =>
                  SizedBox(height: AppSizes.itemGap),
              itemBuilder: (context, index) => children[index],
            ),
            // 底部按钮组:窗口够高时贴底,矮时整体可滚不溢出
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(height: AppSizes.sectionGap),
                  const SidebarActionIconsRow(debugPort: 9229),
                  SizedBox(height: AppSizes.itemGap),
                  const SidebarStatus(),
                  SizedBox(height: AppSizes.itemGap),
                  const ProxyStatus(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
