import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:shimx/core/extensions/context_extensions.dart';

/// skill 卡片里的一行 label + value(可选 copy 按钮)。
class SkillInfoRow extends StatelessWidget {
  const SkillInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.copyable = false,
    this.maxLines,
  });

  final String label;
  final String value;
  final bool copyable;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        Expanded(
          child: SelectableText(
            value,
            maxLines: maxLines,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontFamily: copyable ? 'monospace' : null,
                ),
          ),
        ),
        if (copyable)
          IconButton(
            tooltip: context.l10n.copy,
            iconSize: 14,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            onPressed: () async {
              final copiedToast = context.l10n.copied;
              await Clipboard.setData(ClipboardData(text: value));
              SmartDialog.showToast(copiedToast);
            },
            icon: const Icon(Icons.copy_rounded),
          ),
      ],
    );
  }
}
