import 'package:flutter/material.dart';

/// 对话框里 label + 控件的成对布局。
class McpDialogField extends StatelessWidget {
  const McpDialogField({super.key, required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 7),
        child,
      ],
    );
  }
}

/// 对话框里 TextField 的统一 InputDecoration。
InputDecoration mcpDialogInputDecoration(
  BuildContext context, {
  String? hintText,
  String? helperText,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  return InputDecoration(
    hintText: hintText,
    helperText: helperText,
    isDense: true,
    filled: true,
    fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.34),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    helperStyle: TextStyle(
      color: colorScheme.onSurfaceVariant,
      fontSize: 12,
      height: 1.2,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: colorScheme.outlineVariant),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: colorScheme.outlineVariant),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: colorScheme.primary, width: 1.2),
    ),
  );
}
