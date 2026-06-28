import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shim/common/widgets/surface_card.dart';
import 'package:shim/core/extensions/context_extensions.dart';
import 'package:shim/core/utils/time_format.dart';
import 'package:shim/features/claude_session/domain/models/claude_project.dart';
import 'package:shim/features/claude_session/domain/models/claude_thread.dart';
import 'package:shim/features/claude_session/presentation/providers/claude_session_query_provider.dart';
import 'package:shim/features/claude_session/presentation/widgets/session_empty_box.dart';
import 'package:shim/features/claude_session/presentation/widgets/session_error_box.dart';
import 'package:shim/features/claude_session/presentation/widgets/session_list_tile.dart';

/// 中间栏:列出当前选中项目下的所有会话。project 为 null 时显示空提示。
class ThreadsPane extends ConsumerWidget {
  const ThreadsPane({
    super.key,
    required this.project,
    required this.selected,
    required this.onSelect,
    required this.emptyHint,
  });

  final ClaudeProject? project;
  final ClaudeThread? selected;
  final ValueChanged<ClaudeThread> onSelect;
  final String emptyHint;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    if (project == null) {
      return SurfaceCard(
        child: Center(child: SessionEmptyBox(message: emptyHint)),
      );
    }
    final asyncThreads = ref.watch(
      listClaudeThreadsProvider(encodedDir: project!.encodedDir),
    );

    return SurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 6, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.sessionsTitle,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                IconButton(
                  tooltip: l10n.refresh,
                  iconSize: 18,
                  visualDensity: VisualDensity.compact,
                  onPressed: () => ref.invalidate(
                    listClaudeThreadsProvider(encodedDir: project!.encodedDir),
                  ),
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: asyncThreads.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (e, _) => SessionErrorBox(message: e.toString()),
              data: (threads) {
                if (threads.isEmpty) {
                  return SessionEmptyBox(message: l10n.sessionsEmpty);
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: threads.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 2),
                  itemBuilder: (context, i) {
                    final t = threads[i];
                    final isSelected = selected?.sessionId == t.sessionId;
                    final title = t.title.isEmpty ? t.sessionId : t.title;
                    return SessionListTile(
                      title: title,
                      subtitle: formatRelativeTime(context, t.updatedAtMs),
                      selected: isSelected,
                      onTap: () => onSelect(t),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
