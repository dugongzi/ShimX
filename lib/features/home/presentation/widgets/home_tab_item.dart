import 'package:shimx/core/constants/app_sizes.dart';
import 'package:shimx/core/extensions/context_extensions.dart';
import 'package:shimx/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

/// 侧栏 tab 项:选中态走 Wally 设计语言——
/// 选中项向右平移 18px(Transform),右侧切平、左侧圆角,无右描边,
/// 形成"被推到内容区"的位移感。
class HomeTabItem extends StatelessWidget {
  const HomeTabItem({
    super.key,
    required this.leading,
    required this.selectedLeading,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final IconData leading;
  final IconData selectedLeading;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = context.isDark;
    final accent = colorScheme.primary;

    final shape = BorderRadius.circular(14);

    // 选中态填色:
    //   dark:深紫凹陷感(比侧栏底更深),保留 Wally 那种"压下去"的体积
    //   light:主色低饱和染底(避免一整条饱和色撑场)
    final selectedBaseColor = isDark
        ? AppColors.darkBgBottom.withValues(alpha: 0.92)
        : accent.withValues(alpha: 0.12);

    final borderColor = selected
        ? accent.withValues(alpha: isDark ? 0.55 : 0.32)
        : Colors.transparent;

    // 文字色:选中态 light 用主题色 / dark 用白色;未选中保持默认前景色
    final foreground = selected
        ? (isDark ? Colors.white : accent)
        : (isDark
              ? Colors.white.withValues(alpha: 0.72)
              : colorScheme.onSurface.withValues(alpha: 0.78));

    // 左侧光柱:light 用纯主色;dark 保留主色→紫粉渐变(参考图设计语言)
    final pillarGradient = isDark
        ? LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colorScheme.primary, AppColors.darkSecondary],
          )
        : LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colorScheme.primary, colorScheme.primary],
          );

    return Tooltip(
      message: title,
      waitDuration: const Duration(milliseconds: 500),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        height: 52,
        // 选中:整条向右平移 18px 探入内容区
        transform: Matrix4.translationValues(selected ? 18 : 0, 0, 0),
        decoration: BoxDecoration(
          color: selected ? selectedBaseColor : Colors.transparent,
          borderRadius: shape,
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
          boxShadow: selected && isDark
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.32),
                    blurRadius: 22,
                    spreadRadius: -2,
                    offset: const Offset(2, 4),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: shape,
          child: InkWell(
            borderRadius: shape,
            onTap: onTap,
            hoverColor: selected
                ? Colors.transparent
                : Colors.white.withValues(alpha: 0.04),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  width: selected ? 4 : 0,
                  height: 28,
                  margin: EdgeInsets.only(left: selected ? 6 : 0),
                  decoration: BoxDecoration(
                    gradient: selected ? pillarGradient : null,
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: accent.withValues(alpha: 0.8),
                              blurRadius: 12,
                              spreadRadius: 0.5,
                            ),
                          ]
                        : null,
                  ),
                ),
                SizedBox(width: selected ? 10 : 16),
                Icon(
                  selected ? selectedLeading : leading,
                  size: 20,
                  color: foreground,
                ),
                SizedBox(width: AppSizes.itemGap + 4),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: foreground,
                      fontWeight: selected
                          ? FontWeight.w800
                          : FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                AnimatedSlide(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  offset: selected ? Offset.zero : const Offset(0.4, 0),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 220),
                    opacity: selected ? 1 : 0,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 22),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: foreground,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
