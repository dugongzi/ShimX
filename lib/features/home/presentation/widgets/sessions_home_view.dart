import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:shimx/core/constants/app_sizes.dart';
import 'package:shimx/core/extensions/context_extensions.dart';
import 'package:shimx/features/codex_backup/presentation/providers/codex_backup_action_provider.dart';
import 'package:shimx/features/codex_backup/presentation/providers/codex_backup_query_provider.dart';
import 'package:shimx/features/codex_config/presentation/providers/codex_config_action_provider.dart';
import 'package:shimx/features/codex_config/presentation/providers/codex_config_query_provider.dart';
import 'package:shimx/features/codex_session/presentation/providers/codex_session_action_provider.dart';
import 'package:shimx/features/codex_session/presentation/providers/codex_session_query_provider.dart';
import 'package:shimx/features/providers/presentation/providers/provider_query_provider.dart';

const String _shimxBucket = 'shimx';
const int _bucketPageSize = 30;

/// 首页 tab:codex 会话按 model_provider 分桶展示 + 手动移动 + 备份触发。
/// 备份库单独在「备份」tab。
class SessionsHomeView extends HookConsumerWidget {
  const SessionsHomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final selected = useState<Set<String>>({});
    final targetBucket = useState<String>(_shimxBucket);

    final buckets = ref.watch(codexBucketsProvider);
    final currentBucket = ref.watch(codexModelProviderProvider);

    Future<void> refreshAll() async {
      ref.invalidate(codexBucketsProvider);
      ref.invalidate(codexModelProviderProvider);
      ref.invalidate(codexBackupIdsProvider);
    }

    Future<void> switchBucket(String targetBucketName) async {
      try {
        final proxy = await ref.read(proxyConfigProvider.future);
        await ref
            .read(codexConfigActionRepositoryProvider)
            .writeModelProviderWithSection(
              value: targetBucketName,
              baseUrl: proxy.localProxyUrl,
            );
        ref.invalidate(codexModelProviderProvider);
        SmartDialog.showToast(l10n.sessionSwitchBucketSuccess(targetBucketName));
      } catch (e) {
        SmartDialog.showToast(l10n.sessionSwitchBucketFailed(e.toString()));
      }
    }

    Future<void> moveSelected() async {
      if (selected.value.isEmpty) {
        SmartDialog.showToast(l10n.sessionNoSelection);
        return;
      }
      try {
        final n = await ref
            .read(codexSessionActionRepositoryProvider)
            .moveThreadsToBucket(
              threadIds: selected.value.toList(),
              targetBucket: targetBucket.value,
            );
        selected.value = {};
        SmartDialog.showToast(l10n.sessionMoveSuccess(n, targetBucket.value));
        await refreshAll();
      } catch (e) {
        SmartDialog.showToast(l10n.sessionMoveFailed(e.toString()));
      }
    }

    Future<void> backupSelected() async {
      if (selected.value.isEmpty) {
        SmartDialog.showToast(l10n.sessionNoSelection);
        return;
      }
      try {
        final n = selected.value.length;
        await ref
            .read(codexBackupActionRepositoryProvider)
            .createBackup(selected.value.toList());
        SmartDialog.showToast(l10n.sessionBackupSuccess(n));
        ref.invalidate(codexBackupIdsProvider);
      } catch (e) {
        SmartDialog.showToast(l10n.sessionBackupFailed(e.toString()));
      }
    }

    Future<void> mergeAllToShimX() async {
      final ok = await _confirm(
        context,
        title: l10n.sessionMergeConfirmTitle,
        body: l10n.sessionMergeConfirmBody,
        okText: l10n.sessionMergeConfirmOk,
        danger: false,
      );
      if (!ok) return;

      final bucketList = buckets.value ?? const [];
      final allIds = <String>[];
      for (final b in bucketList) {
        if (b.bucket == _shimxBucket) continue;
        final threads = await ref
            .read(codexSessionQueryRepositoryProvider)
            .listThreadsByBucket(bucket: b.bucket, limit: 1 << 30);
        allIds.addAll(threads.map((t) => t.id));
      }
      if (allIds.isEmpty) return;

      // 用 valueNotifier 驱动进度对话框, 每处理一批就更新一次数字。
      final done = ValueNotifier<int>(0);
      final total = allIds.length;
      SmartDialog.show(
        clickMaskDismiss: false,
        backType: SmartBackType.ignore,
        builder: (_) => _MergeProgressDialog(done: done, total: total),
      );

      try {
        const batchSize = 100;
        final repo = ref.read(codexSessionActionRepositoryProvider);
        var moved = 0;
        for (var i = 0; i < allIds.length; i += batchSize) {
          final batch = allIds.sublist(
            i,
            (i + batchSize).clamp(0, allIds.length),
          );
          moved += await repo.moveThreadsToBucket(
            threadIds: batch,
            targetBucket: _shimxBucket,
          );
          done.value = moved;
          await Future<void>.delayed(Duration.zero);
        }
        selected.value = {};
        // 合并完顺便切桶到 shimx(用户点这个按钮的目的就是"以后新会话也走 shimx")
        final proxy = await ref.read(proxyConfigProvider.future);
        await ref
            .read(codexConfigActionRepositoryProvider)
            .writeModelProviderWithSection(
              value: _shimxBucket,
              baseUrl: proxy.localProxyUrl,
            );
        ref.invalidate(codexModelProviderProvider);
        await SmartDialog.dismiss();
        SmartDialog.showToast(l10n.sessionMoveSuccess(moved, _shimxBucket));
        await refreshAll();
      } catch (e) {
        await SmartDialog.dismiss();
        SmartDialog.showToast(l10n.sessionMoveFailed(e.toString()));
      } finally {
        done.dispose();
      }
    }

    return buckets.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
      data: (bucketList) {
        final bucketNames = bucketList.map((b) => b.bucket).toList();
        final targetOptions = <String>{...bucketNames, _shimxBucket}.toList()
          ..sort();
        if (!targetOptions.contains(targetBucket.value)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!targetOptions.contains(targetBucket.value)) {
              targetBucket.value = _shimxBucket;
            }
          });
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CurrentBucketBar(
              current: currentBucket.value ?? '',
              options: targetOptions,
              onSwitchTo: switchBucket,
              onRefresh: refreshAll,
            ),
            _SessionActionToolbar(
              selectedCount: selected.value.length,
              targetBucket: targetBucket.value,
              targetOptions: targetOptions,
              onTargetChanged: (v) => targetBucket.value = v,
              onMove: moveSelected,
              onBackup: backupSelected,
              onMergeAll: mergeAllToShimX,
            ),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.pagePadding,
                  vertical: AppSizes.itemGap,
                ),
                itemCount: bucketList.length,
                separatorBuilder: (_, __) =>
                    SizedBox(height: AppSizes.itemGap),
                itemBuilder: (_, i) => _BucketGroup(
                  bucket: bucketList[i].bucket,
                  sessionCount: bucketList[i].sessionCount,
                  selected: selected,
                ),
              ),
            ),
          ],
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

class _CurrentBucketBar extends StatelessWidget {
  const _CurrentBucketBar({
    required this.current,
    required this.options,
    required this.onSwitchTo,
    required this.onRefresh,
  });

  final String current;
  final List<String> options;
  final Future<void> Function(String bucket) onSwitchTo;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.pagePadding,
        vertical: AppSizes.itemGap,
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Row(
        children: [
          Text(
            '${l10n.sessionCurrentBucket}: ',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            current.isEmpty ? '(未指定)' : current,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(color: scheme.primary),
          ),
          const Spacer(),
          MenuAnchor(
            builder: (context, controller, _) => Tooltip(
              message: l10n.sessionSwitchBucketTooltip,
              waitDuration: const Duration(milliseconds: 500),
              child: TextButton.icon(
                onPressed: () =>
                    controller.isOpen ? controller.close() : controller.open(),
                icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                label: Text(l10n.sessionSwitchBucket),
              ),
            ),
            menuChildren: [
              for (final b in options)
                MenuItemButton(
                  onPressed: b == current ? null : () => onSwitchTo(b),
                  leadingIcon: Icon(
                    b == current
                        ? Icons.check_rounded
                        : Icons.circle_outlined,
                    size: 14,
                    color: b == current ? scheme.primary : null,
                  ),
                  child: Text(b.isEmpty ? '(未指定)' : b),
                ),
            ],
          ),
          SizedBox(width: AppSizes.itemGap),
          IconButton(
            tooltip: l10n.sessionRefresh,
            visualDensity: VisualDensity.compact,
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded, size: 18),
          ),
        ],
      ),
    );
  }
}

/// 操作栏,横向排列 TextButton,学 [ScriptListToolbar] 的风格。
class _SessionActionToolbar extends StatelessWidget {
  const _SessionActionToolbar({
    required this.selectedCount,
    required this.targetBucket,
    required this.targetOptions,
    required this.onTargetChanged,
    required this.onMove,
    required this.onBackup,
    required this.onMergeAll,
  });

  final int selectedCount;
  final String targetBucket;
  final List<String> targetOptions;
  final ValueChanged<String> onTargetChanged;
  final Future<void> Function() onMove;
  final Future<void> Function() onBackup;
  final Future<void> Function() onMergeAll;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasSelection = selectedCount > 0;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.pagePadding,
        vertical: AppSizes.itemGap,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.sessionSelectedCount(selectedCount),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(width: AppSizes.itemGap),
            _TargetBucketDropdown(
              value: targetBucket,
              options: targetOptions,
              onChanged: onTargetChanged,
            ),
            SizedBox(width: AppSizes.itemGap),
            TextButton.icon(
              onPressed: hasSelection ? onMove : null,
              icon: const Icon(Icons.drive_file_move_rounded, size: 18),
              label: Text(l10n.sessionExecute),
            ),
            SizedBox(width: AppSizes.itemGap),
            Tooltip(
              message: l10n.sessionBackupSelectedTooltip,
              waitDuration: const Duration(milliseconds: 500),
              child: TextButton.icon(
                onPressed: hasSelection ? onBackup : null,
                icon: const Icon(Icons.backup_rounded, size: 18),
                label: Text(l10n.sessionBackupSelected),
              ),
            ),
            SizedBox(width: AppSizes.itemGap),
            Tooltip(
              message: l10n.sessionMergeAllToShimXTooltip,
              waitDuration: const Duration(milliseconds: 500),
              child: TextButton.icon(
                onPressed: onMergeAll,
                icon: const Icon(Icons.merge_type_rounded, size: 18),
                label: Text(l10n.sessionMergeAllToShimX),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TargetBucketDropdown extends StatelessWidget {
  const _TargetBucketDropdown({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final effective =
        options.contains(value) ? value : (options.isNotEmpty ? options.first : _shimxBucket);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(l10n.sessionMoveTo),
        const SizedBox(width: 6),
        DropdownButton<String>(
          value: effective,
          isDense: true,
          items: [
            for (final b in options)
              DropdownMenuItem(
                value: b,
                child: Text(b.isEmpty ? '(未指定)' : b),
              ),
          ],
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ],
    );
  }
}

/// 单个桶折叠面板。
///
/// 懒加载:
/// - 默认折叠(不拉数据),点击 header 才展开
/// - 展开后先加载第一页(30 条),底部有「加载更多」按钮
/// - 已加载条目累积在本地 state,不重复请求
class _BucketGroup extends HookConsumerWidget {
  const _BucketGroup({
    required this.bucket,
    required this.sessionCount,
    required this.selected,
  });

  final String bucket;
  final int sessionCount;
  final ValueNotifier<Set<String>> selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    // 折叠状态默认关(避免一进页就拉每个桶)
    final expanded = useState<bool>(false);
    // 已经加载完的 threads(entity 直接存)
    final loaded = useState<List<_ThreadRow>>(const []);
    final loading = useState<bool>(false);
    final error = useState<String?>(null);
    final loadedAll = useState<bool>(false);

    Future<void> loadPage() async {
      if (loading.value || loadedAll.value) return;
      loading.value = true;
      error.value = null;
      try {
        final page = await ref
            .read(codexSessionQueryRepositoryProvider)
            .listThreadsByBucket(
              bucket: bucket,
              limit: _bucketPageSize,
              offset: loaded.value.length,
            );
        if (page.isEmpty) {
          loadedAll.value = true;
        } else {
          loaded.value = [
            ...loaded.value,
            for (final t in page) _ThreadRow(id: t.id, title: t.title, cwd: t.cwd),
          ];
          if (page.length < _bucketPageSize) {
            loadedAll.value = true;
          }
        }
      } catch (e) {
        error.value = e.toString();
      } finally {
        loading.value = false;
      }
    }

    // 展开时首次触发加载(useEffect 依赖 expanded)
    useEffect(() {
      if (expanded.value && loaded.value.isEmpty && !loadedAll.value) {
        loadPage();
      }
      return null;
    }, [expanded.value]);

    final ids = loaded.value.map((t) => t.id).toSet();
    final allSelected =
        ids.isNotEmpty && ids.every((id) => selected.value.contains(id));

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
            title: Row(
              children: [
                Text(
                  '${l10n.sessionBucketLabel}: ',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  bucket.isEmpty ? '(未指定)' : bucket,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(width: 8),
                Text(
                  '($sessionCount)',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Theme.of(context).hintColor),
                ),
              ],
            ),
            trailing: expanded.value && loaded.value.isNotEmpty
                ? TextButton(
                    onPressed: () {
                      final next = {...selected.value};
                      if (allSelected) {
                        next.removeAll(ids);
                      } else {
                        next.addAll(ids);
                      }
                      selected.value = next;
                    },
                    child: Text(l10n.sessionSelectAll),
                  )
                : null,
            onTap: () => expanded.value = !expanded.value,
          ),
          if (expanded.value) ...[
            for (final t in loaded.value)
              CheckboxListTile(
                value: selected.value.contains(t.id),
                onChanged: (v) {
                  final next = {...selected.value};
                  if (v == true) {
                    next.add(t.id);
                  } else {
                    next.remove(t.id);
                  }
                  selected.value = next;
                },
                title: Text(
                  t.title.isEmpty ? t.id : t.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  t.cwd.isEmpty ? '(未知路径)' : t.cwd,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
              ),
            if (loading.value)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (error.value != null)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  error.value!,
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            if (!loading.value && loaded.value.isEmpty && loadedAll.value)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(l10n.sessionEmptyBucket),
              ),
            if (!loading.value && !loadedAll.value)
              Padding(
                padding: EdgeInsets.symmetric(vertical: AppSizes.itemGap / 2),
                child: TextButton.icon(
                  onPressed: loadPage,
                  icon: const Icon(Icons.expand_more_rounded, size: 18),
                  label: Text(l10n.sessionLoadMore),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

/// 精简版 thread 显示项,只保留 UI 需要的字段,避免持有大 entity。
class _ThreadRow {
  const _ThreadRow({required this.id, required this.title, required this.cwd});
  final String id;
  final String title;
  final String cwd;
}

/// 合并进度对话框:显示"正在合并 N / total"和一根线性进度条。
/// 由外部 valueNotifier 驱动,不做手动关闭。
class _MergeProgressDialog extends StatelessWidget {
  const _MergeProgressDialog({required this.done, required this.total});

  final ValueNotifier<int> done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Dialog(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.pagePadding,
          vertical: AppSizes.sectionGap,
        ),
        child: SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.sessionMergeProgressTitle,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              SizedBox(height: AppSizes.itemGap),
              ValueListenableBuilder<int>(
                valueListenable: done,
                builder: (_, value, __) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(
                      value: total == 0 ? 0 : value / total,
                    ),
                    SizedBox(height: AppSizes.itemGap / 2),
                    Text(
                      l10n.sessionMergeProgressBody(value, total),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
