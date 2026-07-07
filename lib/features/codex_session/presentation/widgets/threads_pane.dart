import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shimx/common/widgets/search_field.dart';
import 'package:shimx/common/widgets/session_empty_box.dart';
import 'package:shimx/common/widgets/session_error_box.dart';
import 'package:shimx/common/widgets/session_list_tile.dart';
import 'package:shimx/common/widgets/surface_card.dart';
import 'package:shimx/core/extensions/context_extensions.dart';
import 'package:shimx/core/utils/time_format.dart';
import 'package:shimx/features/codex_session/domain/models/codex_thread.dart';
import 'package:shimx/features/codex_session/presentation/providers/codex_session_query_provider.dart';

/// 中间栏:列出当前选中 cwd 下的所有会话,带顶部搜索框。
class ThreadsPane extends HookConsumerWidget {
  const ThreadsPane({
    super.key,
    required this.cwdFilter,
    required this.selected,
    required this.onSelect,
    required this.emptyHint,
  });

  final String? cwdFilter;
  final CodexThread? selected;
  final ValueChanged<CodexThread> onSelect;
  final String emptyHint;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final query = useState('');
    if (cwdFilter == null) {
      return SurfaceCard(
        child: Center(child: SessionEmptyBox(message: emptyHint)),
      );
    }
    final asyncThreads = ref.watch(listCodexThreadsProvider());

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
                  onPressed: () => ref.invalidate(listCodexThreadsProvider),
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
            child: SearchField(
              hint: l10n.searchHint,
              onChanged: (v) => query.value = v,
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
                final q = query.value.trim().toLowerCase();
                final inCwd = threads.where((t) {
                  final key = t.cwd.isEmpty ? '(unknown)' : t.cwd;
                  return key == cwdFilter;
                });
                final filtered = q.isEmpty
                    ? inCwd.toList()
                    : inCwd
                          .where(
                            (t) =>
                                t.title.toLowerCase().contains(q) ||
                                t.preview.toLowerCase().contains(q) ||
                                t.firstUserMessage.toLowerCase().contains(q) ||
                                t.id.toLowerCase().contains(q),
                          )
                          .toList();
                if (filtered.isEmpty) {
                  return SessionEmptyBox(
                    message: q.isEmpty
                        ? l10n.sessionsEmpty
                        : l10n.searchNoResults,
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 2),
                  itemBuilder: (context, i) {
                    final t = filtered[i];
                    final isSelected = selected?.id == t.id;
                    final title = t.title.isEmpty ? t.id : t.title;
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
