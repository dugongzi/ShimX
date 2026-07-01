import 'package:flutter/material.dart';
import 'package:shim/core/extensions/context_extensions.dart';

class ScriptEditorEmptyView extends StatelessWidget {
  const ScriptEditorEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final fg = isDark
        ? Colors.white.withValues(alpha: 0.4)
        : Colors.black.withValues(alpha: 0.4);
    final l10n = context.l10n;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.description_outlined, size: 48, color: fg),
          const SizedBox(height: 12),
          Text(
            l10n.noScriptSelectedHint,
            style: TextStyle(color: fg, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
