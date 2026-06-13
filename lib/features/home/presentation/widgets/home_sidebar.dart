import 'package:codex_z/core/constants/app_sizes.dart';
import 'package:codex_z/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SidebarBrand(title: title),
            SizedBox(height: AppSizes.sectionGap),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: children.length,
                separatorBuilder: (context, index) =>
                    SizedBox(height: AppSizes.itemGap),
                itemBuilder: (context, index) => children[index],
              ),
            ),
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
              context.l10n.readyStatus,
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
