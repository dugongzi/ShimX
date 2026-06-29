import 'package:flutter/material.dart';

/// skills tab 加载失败时的错误提示框。
class SkillsErrorBox extends StatelessWidget {
  const SkillsErrorBox({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
        ),
      ),
    );
  }
}
