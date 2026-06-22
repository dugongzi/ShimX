import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shim/common/widgets/surface_card.dart';
import 'package:shim/core/constants/app_sizes.dart';
import 'package:shim/core/extensions/context_extensions.dart';
import 'package:shim/features/claude_session/domain/models/claude_project.dart';
import 'package:shim/features/claude_session/domain/models/claude_thread.dart';
import 'package:shim/features/claude_session/domain/models/claude_thread_detail.dart';
import 'package:shim/features/claude_session/domain/models/claude_thread_message.dart';
import 'package:shim/features/claude_session/presentation/providers/claude_session_export_provider.dart';
import 'package:shim/features/claude_session/presentation/providers/claude_session_query_provider.dart';

class ClaudeSessionsView extends HookConsumerWidget {
  const ClaudeSessionsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedProject = useState<ClaudeProject?>(null);
    final selectedThread = useState<ClaudeThread?>(null);
    final l10n = context.l10n;

    return Padding(
      padding: EdgeInsets.all(AppSizes.itemGap),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 240,
            child: _ProjectsPane(
              selected: selectedProject.value,
              onSelect: (p) {
                selectedProject.value = p;
                selectedThread.value = null;
              },
            ),
          ),
          SizedBox(width: AppSizes.itemGap),
          SizedBox(
            width: 320,
            child: _ThreadsPane(
              project: selectedProject.value,
              selected: selectedThread.value,
              onSelect: (t) => selectedThread.value = t,
              emptyHint: l10n.claudeProjectsSelectHint,
            ),
          ),
          SizedBox(width: AppSizes.itemGap),
          Expanded(
            child: _ThreadDetailPane(thread: selectedThread.value),
          ),
        ],
      ),
    );
  }
}

class _ProjectsPane extends ConsumerWidget {
  const _ProjectsPane({required this.selected, required this.onSelect});

  final ClaudeProject? selected;
  final ValueChanged<ClaudeProject> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProjects = ref.watch(listClaudeProjectsProvider);
    final l10n = context.l10n;

    return SurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(14, 12, 6, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.claudeProjects,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                IconButton(
                  tooltip: l10n.refresh,
                  iconSize: 18,
                  visualDensity: VisualDensity.compact,
                  onPressed: () =>
                      ref.invalidate(listClaudeProjectsProvider),
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: asyncProjects.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (e, _) => _ErrorBox(message: e.toString()),
              data: (projects) {
                if (projects.isEmpty) {
                  return _EmptyBox(message: l10n.claudeProjectsEmpty);
                }
                return ListView.separated(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  itemCount: projects.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 2),
                  itemBuilder: (context, i) {
                    final p = projects[i];
                    final isSelected = selected?.encodedDir == p.encodedDir;
                    return _ListTile(
                      title: _projectDisplayName(p.cwd),
                      subtitle:
                          '${l10n.claudeProjectSubtitle(p.sessionCount, _formatRelativeTime(context, p.lastActiveMs))} · ${_projectParentHint(p.cwd)}',
                      selected: isSelected,
                      onTap: () => onSelect(p),
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

class _ThreadsPane extends ConsumerWidget {
  const _ThreadsPane({
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
        child: Center(
          child: _EmptyBox(message: emptyHint),
        ),
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
            padding: EdgeInsets.fromLTRB(14, 12, 6, 8),
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
              error: (e, _) => _ErrorBox(message: e.toString()),
              data: (threads) {
                if (threads.isEmpty) {
                  return _EmptyBox(message: l10n.sessionsEmpty);
                }
                return ListView.separated(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  itemCount: threads.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 2),
                  itemBuilder: (context, i) {
                    final t = threads[i];
                    final isSelected = selected?.sessionId == t.sessionId;
                    final title = t.title.isEmpty
                        ? t.sessionId
                        : t.title;
                    return _ListTile(
                      title: title,
                      subtitle: _formatRelativeTime(context, t.updatedAtMs),
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

class _ThreadDetailPane extends ConsumerWidget {
  const _ThreadDetailPane({required this.thread});

  final ClaudeThread? thread;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    if (thread == null) {
      return SurfaceCard(
        child: Center(child: _EmptyBox(message: l10n.threadSelectHint)),
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
            padding: EdgeInsets.fromLTRB(14, 12, 8, 8),
            child: asyncDetail.when(
              loading: () => Text(thread!.title.isEmpty
                  ? thread!.sessionId
                  : thread!.title),
              error: (_, __) => Text(thread!.sessionId),
              data: (d) => _DetailHeader(detail: d),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: asyncDetail.when(
              loading: () => const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              error: (e, _) => _ErrorBox(message: e.toString()),
              data: (d) {
                if (d.messages.isEmpty) {
                  return _EmptyBox(message: l10n.threadEmpty);
                }
                return ListView.builder(
                  padding: EdgeInsets.all(14),
                  itemCount: d.messages.length,
                  itemBuilder: (context, i) =>
                      _MessageTile(message: d.messages[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailHeader extends ConsumerWidget {
  const _DetailHeader({required this.detail});

  final ClaudeThreadDetail detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final title = detail.title.isEmpty ? detail.sessionId : detail.title;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                detail.cwd,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
        PopupMenuButton<String>(
          tooltip: l10n.sessionExport,
          icon: const Icon(Icons.more_horiz_rounded),
          onSelected: (value) => _export(context, ref, detail, value),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'markdown',
              child: Text(l10n.sessionExportMarkdown),
            ),
            PopupMenuItem(
              value: 'raws',
              child: Text(l10n.sessionExportRaw),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _export(
    BuildContext context,
    WidgetRef ref,
    ClaudeThreadDetail detail,
    String format,
  ) async {
    final l10n = context.l10n;
    try {
      final repo = ref.read(claudeSessionExportRepositoryProvider);
      final path = await exportClaudeThread(
        repo: repo,
        detail: detail,
        format: format,
      );
      if (path == null) return;
      SmartDialog.showToast(l10n.sessionExportSuccess);
    } catch (e) {
      SmartDialog.showToast(l10n.sessionExportFailed(e.toString()));
    }
  }
}

class _MessageTile extends StatelessWidget {
  const _MessageTile({required this.message});

  final ClaudeThreadMessage message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    Color bg;
    String label;
    switch (message.kind) {
      case 'tool_use':
        bg = colorScheme.tertiaryContainer.withValues(alpha: 0.30);
        label = message.toolName.isEmpty
            ? 'Tool call'
            : 'Tool call · ${message.toolName}';
        break;
      case 'tool_result':
        bg = colorScheme.surfaceContainerHighest.withValues(alpha: 0.55);
        label = 'Tool result';
        break;
      default:
        if (message.role == 'user') {
          bg = colorScheme.primaryContainer.withValues(alpha: 0.32);
          label = 'User';
        } else {
          bg = colorScheme.secondaryContainer.withValues(alpha: 0.28);
          label = 'Assistant';
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
            _CollapsibleText(text: message.text)
          else if (message.kind == 'tool_use')
            SelectableText(
              message.text,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            )
          else
            SelectableText(message.text),
        ],
      ),
    );
  }
}

class _CollapsibleText extends HookWidget {
  const _CollapsibleText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final expanded = useState(false);
    final isLong = text.length > 400;
    final shown =
        expanded.value || !isLong ? text : '${text.substring(0, 400)}…';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(
          shown,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
        ),
        if (isLong)
          TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 28),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () => expanded.value = !expanded.value,
            child: Text(expanded.value ? '收起' : '展开'),
          ),
      ],
    );
  }
}

class _ListTile extends StatelessWidget {
  const _ListTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        child: Container(
          color: selected
              ? colorScheme.primary.withValues(alpha: 0.10)
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                      color: selected
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyBox extends StatelessWidget {
  const _EmptyBox({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
        ),
      ),
    );
  }
}

/// 取路径最后一段(项目名本身),例如:
///   f:\Programming_projects\FlutterProject\shim → shim
///   /Users/mkbk/Documents/foo → foo
String _projectDisplayName(String path) {
  if (path.isEmpty) return '(unknown)';
  final normalized = path.replaceAll('\\', '/');
  final segments = normalized.split('/').where((s) => s.isNotEmpty).toList();
  if (segments.isEmpty) return path;
  return segments.last;
}

/// 取倒数第二段父目录,用作 subtitle 里的辨识提示(同名项目时能区分)。
/// 例如:f:\Programming_projects\FlutterProject\shim → FlutterProject
String _projectParentHint(String path) {
  if (path.isEmpty) return '';
  final normalized = path.replaceAll('\\', '/');
  final segments = normalized.split('/').where((s) => s.isNotEmpty).toList();
  if (segments.length < 2) return path;
  return segments[segments.length - 2];
}

String _formatRelativeTime(BuildContext context, int ms) {
  if (ms == 0) return '';
  final dt = DateTime.fromMillisecondsSinceEpoch(ms);
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inMinutes < 1) return context.l10n.justNow;
  if (diff.inHours < 1) return context.l10n.minutesAgo(diff.inMinutes);
  if (diff.inDays < 1) return context.l10n.hoursAgo(diff.inHours);
  if (diff.inDays < 30) return context.l10n.daysAgo(diff.inDays);
  return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
