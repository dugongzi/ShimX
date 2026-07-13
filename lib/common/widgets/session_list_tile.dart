import 'package:flutter/material.dart';

/// 左侧两栏(项目 / 会话)共用的列表项。
///
/// [onSecondaryTapDown] 用来接右键(桌面端)。回调把点击位置传上去,
/// 调用方可以直接用 `showMenu` 在鼠标位置弹菜单。项目栏不需要就不传。
class SessionListTile extends StatelessWidget {
  const SessionListTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.onSecondaryTapDown,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final ValueChanged<TapDownDetails>? onSecondaryTapDown;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        onSecondaryTapDown: onSecondaryTapDown,
        child: Container(
          color: selected
              ? colorScheme.primary.withValues(alpha: 0.10)
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                      color: selected
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
