import 'package:flutter/material.dart';

/// 自动切换设置行标签:label 文字 + 右侧帮助 tooltip icon。
class AutoSwitchRowLabel extends StatelessWidget {
  const AutoSwitchRowLabel({
    super.key,
    required this.label,
    required this.help,
  });

  final String label;
  final String help;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(width: 6),
        Tooltip(
          message: help,
          waitDuration: const Duration(milliseconds: 300),
          preferBelow: false,
          child: MouseRegion(
            cursor: SystemMouseCursors.help,
            child: Icon(
              Icons.help_outline_rounded,
              size: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
