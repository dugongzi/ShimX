import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shim/common/widgets/search_field.dart';
import 'package:shim/common/widgets/session_empty_box.dart';
import 'package:shim/common/widgets/session_error_box.dart';
import 'package:shim/common/widgets/session_list_tile.dart';
import 'package:shim/common/widgets/surface_card.dart';
import 'package:shim/core/extensions/context_extensions.dart';
import 'package:shim/core/utils/time_format.dart';
import 'package:shim/features/claude_session/domain/models/claude_project.dart';
import 'package:shim/features/claude_session/presentation/providers/claude_session_query_provider.dart';

/// 左栏:列出 ~/.claude/projects/ 下所有项目目录,带顶部搜索框。
class ProjectsPane extends HookConsumerWidget {
  const ProjectsPane({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  final ClaudeProject? selected;
  final ValueChanged<ClaudeProject> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProjects = ref.watch(listClaudeProjectsProvider);
    final query = useState('');
    final l10n = context.l10n;

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
                  onPressed: () => ref.invalidate(listClaudeProjectsProvider),
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
            child: asyncProjects.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (e, _) => SessionErrorBox(message: e.toString()),
              data: (projects) {
                final filtered = _filterProjects(projects, query.value);
                if (filtered.isEmpty) {
                  return SessionEmptyBox(
                    message: query.value.isEmpty
                        ? l10n.claudeProjectsEmpty
                        : l10n.searchNoResults,
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 2),
                  itemBuilder: (context, i) {
                    final p = filtered[i];
                    final isSelected = selected?.encodedDir == p.encodedDir;
                    return SessionListTile(
                      title: _projectDisplayName(p.cwd),
                      subtitle:
                          '${l10n.claudeProjectSubtitle(p.sessionCount, formatRelativeTime(context, p.lastActiveMs))} · ${_projectParentHint(p.cwd)}',
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

List<ClaudeProject> _filterProjects(List<ClaudeProject> projects, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return projects;
  return projects.where((p) => p.cwd.toLowerCase().contains(q)).toList();
}

String _projectDisplayName(String path) {
  if (path.isEmpty) return '(unknown)';
  final normalized = path.replaceAll('\\', '/');
  final segments = normalized.split('/').where((s) => s.isNotEmpty).toList();
  if (segments.isEmpty) return path;
  return segments.last;
}

String _projectParentHint(String path) {
  if (path.isEmpty) return '';
  final normalized = path.replaceAll('\\', '/');
  final segments = normalized.split('/').where((s) => s.isNotEmpty).toList();
  if (segments.length < 2) return path;
  return segments[segments.length - 2];
}
