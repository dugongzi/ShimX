import 'package:flutter/material.dart';

/// MCP 列表/配置等错误状态居中提示。
class McpErrorBox extends StatelessWidget {
  const McpErrorBox({super.key, required this.message});

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
