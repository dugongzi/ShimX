import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shimx/core/constants/app_sizes.dart';
import 'package:shimx/core/extensions/context_extensions.dart';
import 'package:shimx/features/claude_session/domain/models/claude_project.dart';
import 'package:shimx/features/claude_session/domain/models/claude_thread.dart';
import 'package:shimx/features/claude_session/presentation/widgets/projects_pane.dart';
import 'package:shimx/features/claude_session/presentation/widgets/thread_detail_pane.dart';
import 'package:shimx/features/claude_session/presentation/widgets/threads_pane.dart';

/// Claude Code 会话浏览:栈式导航(项目 → 会话 → 详情),
/// 同时只展示一栏,顶部面包屑可返回上一级。
class ClaudeSessionsView extends HookConsumerWidget {
  const ClaudeSessionsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedProject = useState<ClaudeProject?>(null);
    final selectedThread = useState<ClaudeThread?>(null);
    final l10n = context.l10n;

    // 栈深度由"选了什么"自动决定;返回操作清空对应状态
    final Widget body;
    if (selectedThread.value != null) {
      body = _PaneWithCrumbs(
        key: const ValueKey('thread-detail'),
        crumbs: [
          _Crumb(label: l10n.sessionTabClaude, onTap: () {
            selectedProject.value = null;
            selectedThread.value = null;
          }),
          _Crumb(
            label: _shortPath(selectedProject.value?.cwd ?? ''),
            onTap: () => selectedThread.value = null,
          ),
        ],
        onBack: () => selectedThread.value = null,
        child: ThreadDetailPane(thread: selectedThread.value),
      );
    } else if (selectedProject.value != null) {
      body = _PaneWithCrumbs(
        key: const ValueKey('threads'),
        crumbs: [
          _Crumb(label: l10n.sessionTabClaude, onTap: () {
            selectedProject.value = null;
          }),
        ],
        onBack: () => selectedProject.value = null,
        child: ThreadsPane(
          project: selectedProject.value,
          selected: selectedThread.value,
          onSelect: (t) => selectedThread.value = t,
          emptyHint: l10n.claudeProjectsSelectHint,
        ),
      );
    } else {
      body = _PaneWithCrumbs(
        key: const ValueKey('projects'),
        crumbs: const [],
        onBack: null,
        child: ProjectsPane(
          selected: selectedProject.value,
          onSelect: (p) {
            selectedProject.value = p;
            selectedThread.value = null;
          },
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.all(AppSizes.itemGap),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final slide = Tween<Offset>(
            begin: const Offset(0.04, 0),
            end: Offset.zero,
          ).animate(animation);
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: slide, child: child),
          );
        },
        child: body,
      ),
    );
  }
}

class _Crumb {
  const _Crumb({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
}

/// 面包屑展示用:取路径最后一段,避免完整 cwd 撑爆。
String _shortPath(String path) {
  if (path.isEmpty) return '';
  final normalized = path.replaceAll('\\', '/');
  final segments = normalized.split('/').where((s) => s.isNotEmpty).toList();
  if (segments.isEmpty) return path;
  return segments.last;
}

/// 顶部:返回按钮 + 面包屑;下方:面板内容。
class _PaneWithCrumbs extends StatelessWidget {
  const _PaneWithCrumbs({
    super.key,
    required this.crumbs,
    required this.onBack,
    required this.child,
  });

  final List<_Crumb> crumbs;
  final VoidCallback? onBack;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (crumbs.isEmpty && onBack == null) {
      return child;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 36,
          child: Row(
            children: [
              if (onBack != null)
                IconButton(
                  onPressed: onBack,
                  visualDensity: VisualDensity.compact,
                  iconSize: 18,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
              const SizedBox(width: 6),
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    for (var i = 0; i < crumbs.length; i++) ...[
                      InkWell(
                        onTap: crumbs[i].onTap,
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 4,
                          ),
                          child: Text(
                            crumbs[i].label,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Icon(
                          Icons.chevron_right_rounded,
                          size: 16,
                          color: colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Expanded(child: child),
      ],
    );
  }
}
