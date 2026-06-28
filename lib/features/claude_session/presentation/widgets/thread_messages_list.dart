import 'package:flutter/material.dart';
import 'package:shim/features/claude_session/domain/models/claude_thread_message.dart';
import 'package:shim/features/claude_session/presentation/widgets/thread_message_tile.dart';

/// 消息流。`reverse: true` 从下往上懒加载渲染,默认即在底部,大会话不卡。
class ThreadMessagesList extends StatelessWidget {
  const ThreadMessagesList({super.key, required this.messages});

  final List<ClaudeThreadMessage> messages;

  @override
  Widget build(BuildContext context) {
    final last = messages.length - 1;
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.all(14),
      itemCount: messages.length,
      // reverse 后 index 0 是最底部一条,所以倒着取
      itemBuilder: (context, i) => ThreadMessageTile(message: messages[last - i]),
    );
  }
}
