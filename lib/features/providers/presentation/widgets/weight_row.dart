import 'package:flutter/material.dart';

/// 供应商权重调节行(1-10),用于编辑对话框里的 providerWeight / modelWeight。
class WeightRow extends StatelessWidget {
  const WeightRow({
    super.key,
    required this.label,
    required this.help,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String help;
  final int value;
  final ValueChanged<int> onChanged;

  static const _min = 1;
  static const _max = 10;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Row(
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
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            iconSize: 18,
            visualDensity: VisualDensity.compact,
            onPressed: value > _min ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove_rounded),
          ),
          SizedBox(
            width: 40,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          IconButton(
            iconSize: 18,
            visualDensity: VisualDensity.compact,
            onPressed: value < _max ? () => onChanged(value + 1) : null,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }
}
