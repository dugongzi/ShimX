import 'package:flutter/material.dart';
import 'package:shimx/features/codex_session/domain/models/codex_thread_message.dart';
import 'package:shimx/features/codex_session/presentation/widgets/thread_message_tile.dart';

/// 消息流。`reverse: true` 从下往上懒加载渲染,默认即在底部,大会话不卡。
class ThreadMessagesList extends StatelessWidget {
  const ThreadMessagesList({super.key, required this.messages});

  final List<CodexThreadMessage> messages;

  @override
  Widget build(BuildContext context) {
    final last = messages.length - 1;
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.all(14),
      itemCount: messages.length,
      itemBuilder: (context, i) => ThreadMessageTile(message: messages[last - i]),
    );
  }
}
