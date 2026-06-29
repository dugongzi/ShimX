import 'package:flutter/material.dart';

/// MCP 列表/配置等空状态居中提示;比 common 的 SessionEmptyBox 内边距更大。
class McpEmptyBox extends StatelessWidget {
  const McpEmptyBox({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ),
    );
  }
}
