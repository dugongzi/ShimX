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
import 'package:shim/features/codex_session/presentation/providers/codex_session_query_provider.dart';

/// 左栏:按 cwd 分组的 codex 项目列表,带顶部搜索框。
class ProjectsPane extends HookConsumerWidget {
  const ProjectsPane({
    super.key,
    required this.selectedCwd,
    required this.onSelect,
  });

  final String? selectedCwd;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProjects = ref.watch(listCodexProjectsProvider);
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
                  onPressed: () => ref.invalidate(listCodexProjectsProvider),
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
                final q = query.value.trim().toLowerCase();
                final filtered = q.isEmpty
                    ? projects
                    : projects
                          .where((p) => p.cwd.toLowerCase().contains(q))
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
                    final g = filtered[i];
                    final isSelected = selectedCwd == g.cwd;
                    return SessionListTile(
                      title: _projectDisplayName(g.cwd),
                      subtitle:
                          '${l10n.claudeProjectSubtitle(g.sessionCount, formatRelativeTime(context, g.lastActiveMs))} · ${_projectParentHint(g.cwd)}',
                      selected: isSelected,
                      onTap: () => onSelect(g.cwd),
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
