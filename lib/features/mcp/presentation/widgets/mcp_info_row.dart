import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:shimx/core/extensions/context_extensions.dart';

/// MCP 卡片里的一行 label + value(可选 copy 按钮);
/// value 为 SelectableText,长内容可手动选中。
class McpInfoRow extends StatelessWidget {
  const McpInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.copyable = false,
    this.maxLines,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool copyable;
  final int? maxLines;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
                  color: valueColor ?? colorScheme.onSurface,
                  fontFamily: copyable ? 'monospace' : null,
                ),
          ),
        ),
        if (copyable)
          IconButton(
            tooltip: l10n.copy,
            iconSize: 14,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: value));
              SmartDialog.showToast(l10n.copied);
            },
            icon: const Icon(Icons.copy_rounded),
          ),
      ],
    );
  }
}
