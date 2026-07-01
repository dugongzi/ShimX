import 'package:flutter/material.dart';
import 'package:shim/core/extensions/context_extensions.dart';

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
    final isDark = context.isDark;
    final fg = isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87;
    final selectedBg = isDark
        ? const Color(0xFF37373D)
        : const Color(0xFFE4E6F1);

    return Material(
      color: selected ? selectedBg : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        hoverColor: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.04),
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
