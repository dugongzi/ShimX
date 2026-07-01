import 'package:flutter/material.dart';

class ScriptEditorSidebarItem extends StatelessWidget {
  const ScriptEditorSidebarItem({
    super.key,
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.dirty,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final bool selected;
  final bool dirty;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fg = colorScheme.onSurface;
    // 选中态用 seedColor 低饱和染底,呼应主题
    final selectedBg = colorScheme.primary.withValues(alpha: 0.14);

    return Material(
      color: selected ? selectedBg : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        hoverColor: colorScheme.onSurface.withValues(alpha: 0.04),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              const Icon(
                Icons.javascript_rounded,
                size: 16,
                color: Color(0xFFF7DF1E),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: fg, fontSize: 13),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: fg.withValues(alpha: 0.45),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (dirty)
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: fg.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
