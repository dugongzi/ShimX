import 'package:flutter/material.dart';

class ScriptEditorStatusItem extends StatelessWidget {
  const ScriptEditorStatusItem({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
