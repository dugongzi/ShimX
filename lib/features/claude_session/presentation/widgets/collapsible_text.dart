import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shim/core/extensions/context_extensions.dart';

/// 长文本(tool_result 等)默认截断 400 字,带"展开/收起"按钮。
class CollapsibleText extends HookWidget {
  const CollapsibleText({super.key, required this.text});

  final String text;

  static const _maxChars = 400;

  @override
  Widget build(BuildContext context) {
    final expanded = useState(false);
    final isLong = text.length > _maxChars;
    final shown = expanded.value || !isLong
        ? text
        : '${text.substring(0, _maxChars)}…';
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(
          shown,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
        ),
        if (isLong)
          TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 28),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () => expanded.value = !expanded.value,
            child: Text(expanded.value ? l10n.collapse : l10n.expand),
          ),
      ],
    );
  }
}
