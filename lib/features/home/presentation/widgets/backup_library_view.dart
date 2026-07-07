import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:shimx/core/constants/app_sizes.dart';
import 'package:shimx/core/extensions/context_extensions.dart';
import 'package:shimx/features/codex_backup/presentation/providers/codex_backup_action_provider.dart';
import 'package:shimx/features/codex_backup/presentation/providers/codex_backup_query_provider.dart';
import 'package:shimx/features/codex_session/presentation/providers/codex_session_query_provider.dart';

const int _backupPageSize = 30;

/// 备份库 tab:分页拉取备份 id 列表 → 每个 tile 各自异步拉自己的 summary,
/// 展开 tile 才拉 entries 详情。避免一次性打开几百个 manifest。
class BackupLibraryView extends HookConsumerWidget {
  const BackupLibraryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final loaded = useState<List<String>>(const []);
    final loading = useState<bool>(false);
    final error = useState<String?>(null);
    final loadedAll = useState<bool>(false);

    Future<void> loadPage() async {
      if (loading.value || loadedAll.value) return;
      loading.value = true;
      error.value = null;
      try {
        final page = await ref
            .read(codexBackupQueryRepositoryProvider)
            .listBackupIds(
              limit: _backupPageSize,
              offset: loaded.value.length,
            );
        if (page.isEmpty) {
          loadedAll.value = true;
        } else {
          loaded.value = [...loaded.value, ...page];
          if (page.length < _backupPageSize) loadedAll.value = true;
        }
      } catch (e) {
        error.value = e.toString();
      } finally {
        loading.value = false;
      }
    }

    // 首屏拉第一页
    useEffect(() {
      loadPage();
      return null;
    }, const []);

    Future<void> hardRefresh() async {
      loaded.value = const [];
      loadedAll.value = false;
      error.value = null;
      await loadPage();
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.pagePadding,
        vertical: AppSizes.itemGap,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Spacer(),
              IconButton(
                tooltip: l10n.sessionRefresh,
                onPressed: hardRefresh,
                icon: const Icon(Icons.refresh_rounded, size: 18),
              ),
            ],
          ),
          Expanded(
            child: Builder(builder: (context) {
              if (loaded.value.isEmpty && loading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (loaded.value.isEmpty && error.value != null) {
                return Center(child: Text(error.value!));
              }
              if (loaded.value.isEmpty && loadedAll.value) {
                return Center(
                  child: Text(
                    l10n.sessionBackupEmpty,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                );
              }
              return ListView.separated(
                itemCount: loaded.value.length + 1,
                separatorBuilder: (_, __) =>
                    SizedBox(height: AppSizes.itemGap),
                itemBuilder: (_, i) {
                  if (i == loaded.value.length) {
                    if (loadedAll.value) return const SizedBox.shrink();
                    if (loading.value) {
                      return const Padding(
                        padding: EdgeInsets.all(12),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (error.value != null) {
                      return Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          error.value!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      );
                    }
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: AppSizes.itemGap / 2,
                      ),
                      child: Center(
                        child: TextButton.icon(
                          onPressed: loadPage,
                          icon: const Icon(Icons.expand_more_rounded, size: 18),
                          label: Text(l10n.sessionLoadMore),
                        ),
                      ),
                    );
                  }
                  return _BackupTile(
                    backupId: loaded.value[i],
                    onDeleted: hardRefresh,
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _BackupTile extends HookConsumerWidget {
  const _BackupTile({required this.backupId, required this.onDeleted});

  final String backupId;
  final Future<void> Function() onDeleted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final expanded = useState<bool>(false);
    final summaryAsync =
        ref.watch(codexBackupSummaryProvider(backupId: backupId));

    Future<void> restoreAll() async {
      final ok = await _confirm(
        context,
        title: l10n.sessionRestoreConfirmTitle,
        body: l10n.sessionRestoreConfirmBody,
        okText: l10n.sessionRestoreConfirmOk,
        danger: false,
      );
      if (!ok) return;
      try {
        final n = await ref
            .read(codexBackupActionRepositoryProvider)
            .restoreBackup(backupId: backupId);
        SmartDialog.showToast(l10n.sessionRestoreSuccess(n));
        ref.invalidate(codexBucketsProvider);
      } catch (e) {
        SmartDialog.showToast(l10n.sessionRestoreFailed(e.toString()));
      }
    }

    Future<void> restoreOne(String threadId) async {
      final ok = await _confirm(
        context,
        title: l10n.sessionRestoreConfirmTitle,
        body: l10n.sessionRestoreConfirmBody,
        okText: l10n.sessionRestoreConfirmOk,
        danger: false,
      );
      if (!ok) return;
      try {
        final n = await ref
            .read(codexBackupActionRepositoryProvider)
            .restoreBackup(backupId: backupId, entryIds: [threadId]);
        SmartDialog.showToast(l10n.sessionRestoreSuccess(n));
        ref.invalidate(codexBucketsProvider);
      } catch (e) {
        SmartDialog.showToast(l10n.sessionRestoreFailed(e.toString()));
      }
    }

    Future<void> deleteBackup() async {
      final ok = await _confirm(
        context,
        title: l10n.sessionDeleteBackupConfirmTitle,
        body: l10n.sessionDeleteBackupConfirmBody,
        okText: l10n.sessionDeleteBackupConfirmOk,
        danger: true,
      );
      if (!ok) return;
      try {
        await ref
            .read(codexBackupActionRepositoryProvider)
            .deleteBackup(backupId);
        SmartDialog.showToast(l10n.sessionDeleteBackupSuccess);
        await onDeleted();
      } catch (e) {
        SmartDialog.showToast(e.toString());
      }
    }

    return summaryAsync.when(
      loading: () => const ListTile(
        title: SizedBox(height: 20, child: LinearProgressIndicator()),
      ),
      error: (e, _) => ListTile(title: Text(e.toString())),
      data: (summary) {
        if (summary == null) return const SizedBox.shrink();
        return Card(
          margin: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                leading: Icon(
                  expanded.value
                      ? Icons.keyboard_arrow_down_rounded
                      : Icons.keyboard_arrow_right_rounded,
                ),
                title: Text(_formatMs(summary.createdAtMs)),
                subtitle: Text([
                  l10n.sessionBackupThreadCount(summary.threadCount),
                  if (summary.originalProviders.isNotEmpty)
                    l10n.sessionBackupFromBucket(
                      summary.originalProviders.join(', '),
                    ),
                ].join(' · ')),
                onTap: () => expanded.value = !expanded.value,
                trailing: PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'restoreAll') restoreAll();
                    if (v == 'delete') deleteBackup();
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'restoreAll',
                      child: Text(l10n.sessionRestoreAll),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(l10n.sessionDeleteBackup),
                    ),
                  ],
                ),
              ),
              if (expanded.value)
                _BackupEntriesPane(
                  backupId: backupId,
                  onRestoreOne: restoreOne,
                ),
            ],
          ),
        );
      },
    );
  }
}

/// 单 tile 展开后才 watch detail provider,拿完整 entries。
class _BackupEntriesPane extends HookConsumerWidget {
  const _BackupEntriesPane({
    required this.backupId,
    required this.onRestoreOne,
  });

  final String backupId;
  final Future<void> Function(String threadId) onRestoreOne;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final revealed = useState<int>(_backupPageSize);
    final detailAsync =
        ref.watch(codexBackupDetailProvider(backupId: backupId));
    return detailAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text(e.toString()),
      ),
      data: (detail) {
        if (detail == null || detail.entries.isEmpty) {
          return const SizedBox.shrink();
        }
        final total = detail.entries.length;
        final visibleCount = revealed.value.clamp(0, total);
        final visible = detail.entries.take(visibleCount);
        return Padding(
          padding: EdgeInsets.only(bottom: AppSizes.itemGap),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final e in visible)
                ListTile(
                  dense: true,
                  title: Text(
                    e.title.isEmpty ? e.threadId : e.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${e.originalProvider} · ${e.cwd}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: TextButton(
                    onPressed: () => onRestoreOne(e.threadId),
                    child: Text(l10n.sessionRestoreOne),
                  ),
                ),
              if (visibleCount < total)
                Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: AppSizes.itemGap / 2),
                  child: Center(
                    child: TextButton.icon(
                      onPressed: () => revealed.value =
                          (revealed.value + _backupPageSize).clamp(0, total),
                      icon: const Icon(Icons.expand_more_rounded, size: 18),
                      label: Text(l10n.sessionLoadMore),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

Future<bool> _confirm(
  BuildContext context, {
  required String title,
  required String body,
  required String okText,
  required bool danger,
}) async {
  final result = await SmartDialog.show<bool>(
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => SmartDialog.dismiss(result: false),
          child: Text(ctx.l10n.cancel),
        ),
        FilledButton(
          style: danger
              ? FilledButton.styleFrom(backgroundColor: Colors.red)
              : null,
          onPressed: () => SmartDialog.dismiss(result: true),
          child: Text(okText),
        ),
      ],
    ),
  );
  return result == true;
}

String _formatMs(int ms) {
  final dt = DateTime.fromMillisecondsSinceEpoch(ms).toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${dt.year}-${two(dt.month)}-${two(dt.day)} '
      '${two(dt.hour)}:${two(dt.minute)}';
}
