import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shimx/common/widgets/session_empty_box.dart';
import 'package:shimx/common/widgets/session_error_box.dart';
import 'package:shimx/common/widgets/surface_card.dart';
import 'package:shimx/core/extensions/context_extensions.dart';
import 'package:shimx/features/codex_session/domain/models/codex_thread.dart';
import 'package:shimx/features/codex_session/presentation/providers/codex_session_query_provider.dart';
import 'package:shimx/features/codex_session/presentation/widgets/thread_detail_header.dart';
import 'package:shimx/features/codex_session/presentation/widgets/thread_messages_list.dart';

/// 右栏:某个 thread 的完整详情(header + 消息流)。thread 为 null 时显示空提示。
class ThreadDetailPane extends ConsumerWidget {
  const ThreadDetailPane({super.key, required this.thread});

  final CodexThread? thread;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    if (thread == null) {
      return SurfaceCard(
        child: Center(child: SessionEmptyBox(message: l10n.threadSelectHint)),
      );
    }
    final asyncDetail = ref.watch(codexThreadDetailProvider(id: thread!.id));

    return SurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 8),
            child: asyncDetail.when(
              loading: () => Text(
                thread!.title.isEmpty ? thread!.id : thread!.title,
              ),
              error: (_, __) => Text(thread!.id),
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
