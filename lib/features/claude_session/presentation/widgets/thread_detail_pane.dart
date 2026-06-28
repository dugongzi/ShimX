import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shim/common/widgets/surface_card.dart';
import 'package:shim/core/extensions/context_extensions.dart';
import 'package:shim/features/claude_session/domain/models/claude_thread.dart';
import 'package:shim/features/claude_session/presentation/providers/claude_session_query_provider.dart';
import 'package:shim/features/claude_session/presentation/widgets/session_empty_box.dart';
import 'package:shim/features/claude_session/presentation/widgets/session_error_box.dart';
import 'package:shim/features/claude_session/presentation/widgets/thread_detail_header.dart';
import 'package:shim/features/claude_session/presentation/widgets/thread_messages_list.dart';

/// 右栏:某个 thread 的完整详情(header + 消息流)。thread 为 null 时显示空提示。
class ThreadDetailPane extends ConsumerWidget {
  const ThreadDetailPane({super.key, required this.thread});

  final ClaudeThread? thread;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    if (thread == null) {
      return SurfaceCard(
        child: Center(child: SessionEmptyBox(message: l10n.threadSelectHint)),
      );
    }
    final asyncDetail = ref.watch(
      claudeThreadDetailProvider(jsonlPath: thread!.jsonlPath),
    );

    return SurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 8),
            child: asyncDetail.when(
              loading: () => Text(
                thread!.title.isEmpty ? thread!.sessionId : thread!.title,
              ),
              error: (_, __) => Text(thread!.sessionId),
              data: (d) => ThreadDetailHeader(detail: d),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: asyncDetail.when(
              loading: () => const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              error: (e, _) => SessionErrorBox(message: e.toString()),
              data: (d) {
                if (d.messages.isEmpty) {
                  return SessionEmptyBox(message: l10n.threadEmpty);
                }
                return ThreadMessagesList(messages: d.messages);
              },
            ),
          ),
        ],
      ),
    );
  }
}
