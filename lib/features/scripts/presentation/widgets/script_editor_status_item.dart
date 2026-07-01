import 'package:flutter/material.dart';

class ScriptEditorStatusItem extends StatelessWidget {
  const ScriptEditorStatusItem({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onPrimary,
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
