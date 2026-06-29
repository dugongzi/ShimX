import 'package:flutter/material.dart';

/// skills tab 内分组(已管理 / 外部)的标题行。
class SkillGroupHeader extends StatelessWidget {
  const SkillGroupHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
    );
  }
}
