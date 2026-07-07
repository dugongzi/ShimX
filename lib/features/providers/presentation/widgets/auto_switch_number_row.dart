import 'package:flutter/material.dart';
import 'package:shimx/core/extensions/context_extensions.dart';
import 'package:shimx/features/providers/presentation/widgets/auto_switch_row_label.dart';

/// 自动切换数字调节行:label + 减号 + 当前值 + 加号。带边界 clamp。
class AutoSwitchNumberRow extends StatelessWidget {
  const AutoSwitchNumberRow({
    super.key,
    required this.label,
    required this.suffix,
    required this.value,
    required this.min,
    required this.max,
    required this.help,
    required this.onChanged,
    this.step = 1,
  });

  final String label;
  final String suffix;
  final int value;
  final int min;
  final int max;
  final int step;
  final String help;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.ch(min: 2, max: 6)),
      child: Row(
        children: [
          Expanded(child: AutoSwitchRowLabel(label: label, help: help)),
          IconButton(
            tooltip: '-',
            iconSize: 18,
            visualDensity: VisualDensity.compact,
            onPressed:
                value > min ? () => onChanged((value - step).clamp(min, max)) : null,
            icon: const Icon(Icons.remove_rounded),
          ),
          SizedBox(
            width: 64,
            child: Text(
              '$value $suffix',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
            ),
          ),
          IconButton(
            tooltip: '+',
            iconSize: 18,
            visualDensity: VisualDensity.compact,
            onPressed:
                value < max ? () => onChanged((value + step).clamp(min, max)) : null,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }
}
