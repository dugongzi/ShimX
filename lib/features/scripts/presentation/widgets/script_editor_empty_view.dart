import 'package:flutter/material.dart';
import 'package:shim/core/extensions/context_extensions.dart';

class ScriptEditorEmptyView extends StatelessWidget {
  const ScriptEditorEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).colorScheme.onSurfaceVariant;
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
