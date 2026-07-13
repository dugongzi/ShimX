import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shimx/common/widgets/search_field.dart';
import 'package:shimx/common/widgets/session_empty_box.dart';
import 'package:shimx/common/widgets/session_error_box.dart';
import 'package:shimx/common/widgets/session_list_tile.dart';
import 'package:shimx/common/widgets/surface_card.dart';
import 'package:shimx/core/extensions/context_extensions.dart';
import 'package:shimx/core/utils/time_format.dart';
import 'package:shimx/features/codex_session/domain/models/codex_thread.dart';
import 'package:shimx/features/codex_session/presentation/providers/codex_session_action_provider.dart';
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
                      onSecondaryTapDown: (details) => _showContextMenu(
                        context,
                        ref,
                        thread: t,
                        title: title,
                        position: details.globalPosition,
                      ),
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

  /// 右键会话行:仅一项"删除"。桌面端 showMenu 在鼠标位置弹出。
  Future<void> _showContextMenu(
    BuildContext context,
    WidgetRef ref, {
    required CodexThread thread,
    required String title,
    required Offset position,
  }) async {
    final l10n = context.l10n;
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (overlay == null) return;
    final chosen = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(position.dx, position.dy, 0, 0),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(
                Icons.delete_outline_rounded,
                size: 18,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: 10),
              Text(
                l10n.threadContextMenuDelete,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ),
        ),
      ],
    );
    if (chosen != 'delete') return;
    if (!context.mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l10n.threadDeleteConfirmTitle),
        content: Text(l10n.threadDeleteConfirmBody(title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: Text(l10n.threadContextMenuDelete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(deleteCodexThreadProvider(id: thread.id).future);
      ref.invalidate(listCodexThreadsProvider);
      SmartDialog.showToast(l10n.threadDeleteSuccess);
    } catch (e) {
      SmartDialog.showToast(l10n.threadDeleteFailed(e.toString()));
    }
  }
}
