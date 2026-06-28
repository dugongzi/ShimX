import 'package:flutter/material.dart';
import 'package:shim/core/extensions/context_extensions.dart';
import 'package:shim/features/claude_session/domain/models/claude_thread_message.dart';
import 'package:shim/features/claude_session/presentation/widgets/collapsible_text.dart';

/// 单条消息气泡:文本 / 工具调用 / 工具结果 三态。
class ThreadMessageTile extends StatelessWidget {
  const ThreadMessageTile({super.key, required this.message});

  final ClaudeThreadMessage message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final Color bg;
    final String label;
    switch (message.kind) {
      case 'tool_use':
        bg = colorScheme.tertiaryContainer.withValues(alpha: 0.30);
        label = message.toolName.isEmpty
            ? l10n.threadMessageToolCall
            : '${l10n.threadMessageToolCall} · ${message.toolName}';
        break;
      case 'tool_result':
        bg = colorScheme.surfaceContainerHighest.withValues(alpha: 0.55);
        label = l10n.threadMessageToolResult;
        break;
      default:
        if (message.role == 'user') {
          bg = colorScheme.primaryContainer.withValues(alpha: 0.32);
          label = l10n.threadMessageUser;
        } else {
          bg = colorScheme.secondaryContainer.withValues(alpha: 0.28);
          label = l10n.threadMessageAssistant;
        }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              const Spacer(),
              if (message.timestamp.isNotEmpty)
                Text(
                  message.timestamp,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.7),
                      ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          if (message.kind == 'tool_result')
            CollapsibleText(text: message.text)
          else if (message.kind == 'tool_use')
            SelectableText(
              message.text,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            )
          else
            SelectableText(message.text),
        ],
      ),
    );
  }
}
