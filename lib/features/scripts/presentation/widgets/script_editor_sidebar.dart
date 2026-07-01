import 'package:flutter/material.dart';
import 'package:shim/core/extensions/context_extensions.dart';
import 'package:shim/features/scripts/domain/models/inject_script.dart';
import 'package:shim/features/scripts/presentation/widgets/script_editor_sidebar_item.dart';

class ScriptEditorSidebar extends StatelessWidget {
  const ScriptEditorSidebar({
    super.key,
    required this.scripts,
    required this.selectedId,
    required this.dirty,
    required this.onSelect,
    required this.onNew,
  });

  final List<InjectScript> scripts;
  final String? selectedId;
  final bool dirty;
  final ValueChanged<InjectScript> onSelect;
  final VoidCallback onNew;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bg = isDark ? const Color(0xFF252526) : const Color(0xFFF3F3F3);
    final headerFg = isDark
        ? Colors.white.withValues(alpha: 0.7)
        : Colors.black.withValues(alpha: 0.6);
    final divider = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFDDDDDD);
    final l10n = context.l10n;

    return Container(
      width: 260,
      color: bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 32,
            child: Row(
              children: [
                const SizedBox(width: 12),
                Text(
                  l10n.scripts.toUpperCase(),
                  style: TextStyle(
                    color: headerFg,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: l10n.newScript,
                  iconSize: 16,
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(
                    minWidth: 28,
                    minHeight: 28,
                  ),
                  onPressed: onNew,
                  icon: Icon(Icons.add_rounded, color: headerFg),
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),
          Container(height: 1, color: divider),
          Expanded(
            child: scripts.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        l10n.noScripts,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: headerFg,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: scripts.length,
                    itemBuilder: (context, i) {
                      final s = scripts[i];
                      final isSelected = s.id == selectedId;
                      return ScriptEditorSidebarItem(
                        label: s.metadata.name.isEmpty
                            ? s.id
                            : s.metadata.name,
                        subtitle: s.id,
                        selected: isSelected,
                        dirty: isSelected && dirty,
                        onTap: () => onSelect(s),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
