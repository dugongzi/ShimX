import 'package:codex_z/core/constants/app_sizes.dart';
import 'package:codex_z/core/extensions/context_extensions.dart';
import 'package:codex_z/features/home/presentation/widgets/home_tab_item.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class HomeSidebar extends StatelessWidget {
  const HomeSidebar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<HomeTabItem> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSizes.sidebarWidth,
      child: GlassPanel(
        padding: EdgeInsets.all(AppSizes.itemGap),
        shape: LiquidRoundedSuperellipse(borderRadius: AppSizes.cardRadius + 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SidebarBrand(title: context.l10n.homeTitle),
            SizedBox(height: AppSizes.sectionGap),
            for (var index = 0; index < tabs.length; index++) ...[
              HomeNavigationTab(
                item: tabs[index],
                selected: selectedIndex == index,
                onTap: () => onChanged(index),
              ),
              if (index != tabs.length - 1) SizedBox(height: AppSizes.itemGap),
            ],
            const Spacer(),
            const SidebarStatus(),
          ],
        ),
      ),
    );
  }
}

class SidebarBrand extends StatelessWidget {
  const SidebarBrand({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.itemGap,
        vertical: AppSizes.itemGap,
      ),
      child: Row(
        children: [
          Container(
            width: 34.cr(min: 30, max: 38),
            height: 34.cr(min: 30, max: 38),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(10.cr(min: 8, max: 12)),
            ),
            child: Icon(
              Icons.terminal_rounded,
              color: colorScheme.onPrimary,
              size: 18.cr(min: 16, max: 20),
            ),
          ),
          SizedBox(width: 10.cw(min: 8, max: 12)),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class SidebarStatus extends StatelessWidget {
  const SidebarStatus({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(10.cw(min: 8, max: 12)),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(
          alpha: context.isDark ? 0.10 : 0.42,
        ),
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: AppSizes.itemGap),
          Expanded(
            child: Text(
              'Ready',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeNavigationTab extends StatelessWidget {
  const HomeNavigationTab({
    super.key,
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final HomeTabItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foreground = selected
        ? colorScheme.onPrimary
        : colorScheme.onSurface.withValues(alpha: 0.78);
    final background = selected
        ? colorScheme.primary
        : colorScheme.surface.withValues(alpha: context.isDark ? 0.04 : 0.26);

    return Tooltip(
      message: item.label,
      waitDuration: const Duration(milliseconds: 500),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: AppSizes.tabHeight,
          padding: EdgeInsets.symmetric(horizontal: AppSizes.itemGap + 2),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            border: Border.all(
              color: selected
                  ? colorScheme.primary.withValues(alpha: 0.18)
                  : colorScheme.outlineVariant.withValues(alpha: 0.20),
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.24),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Icon(
                selected ? item.selectedIcon : item.icon,
                size: AppSizes.tabIconSize,
                color: foreground,
              ),
              SizedBox(width: AppSizes.itemGap),
              Expanded(
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: foreground,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
