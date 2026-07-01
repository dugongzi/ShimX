import 'package:flutter/material.dart';
import 'package:shim/core/extensions/context_extensions.dart';
import 'package:shim/features/scripts/presentation/widgets/script_editor_status_item.dart';

class ScriptEditorStatusBar extends StatelessWidget {
  const ScriptEditorStatusBar({
    super.key,
    required this.line,
    required this.column,
    required this.language,
    required this.encoding,
    required this.dirty,
    required this.saving,
    required this.hasScript,
  });

  /// 光标行(1-based 展示前 +1);null 表示无光标信息
  final int? line;
  final int? column;
  final String language;
  final String encoding;
  final bool dirty;
  final bool saving;
  final bool hasScript;

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF007ACC);
    final l10n = context.l10n;

    String? saveLabel;
    if (hasScript) {
      if (saving) {
        saveLabel = l10n.editorSavingLabel;
      } else if (dirty) {
        saveLabel = l10n.editorUnsavedLabel;
      } else {
        saveLabel = l10n.editorSavedLabel;
      }
    }

    return Container(
      height: 22,
      color: bg,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          if (saveLabel != null) ScriptEditorStatusItem(text: saveLabel),
          const Spacer(),
          if (line != null && column != null)
            ScriptEditorStatusItem(
              text: '${l10n.editorLine} ${line! + 1}, ${l10n.editorColumn} ${column! + 1}',
            ),
          const SizedBox(width: 16),
          ScriptEditorStatusItem(text: language),
          const SizedBox(width: 16),
          ScriptEditorStatusItem(text: encoding),
        ],
      ),
    );
  }
}
