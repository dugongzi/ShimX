import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shim/core/constants/app_sizes.dart';
import 'package:shim/core/extensions/context_extensions.dart';
import 'package:shim/features/claude_session/domain/models/claude_project.dart';
import 'package:shim/features/claude_session/domain/models/claude_thread.dart';
import 'package:shim/features/claude_session/presentation/widgets/projects_pane.dart';
import 'package:shim/features/claude_session/presentation/widgets/thread_detail_pane.dart';
import 'package:shim/features/claude_session/presentation/widgets/threads_pane.dart';

/// Claude Code 会话浏览三栏视图:项目 / 会话 / 详情。
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
            child: ProjectsPane(
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
            child: ThreadsPane(
              project: selectedProject.value,
              selected: selectedThread.value,
              onSelect: (t) => selectedThread.value = t,
              emptyHint: l10n.claudeProjectsSelectHint,
            ),
          ),
          SizedBox(width: AppSizes.itemGap),
          Expanded(
            child: ThreadDetailPane(thread: selectedThread.value),
          ),
        ],
      ),
    );
  }
}
