import 'package:flutter/material.dart';
import 'package:shim/common/widgets/workspace_surface.dart';
import 'package:shim/core/extensions/context_extensions.dart';
import 'package:shim/features/claude_session/presentation/widgets/claude_sessions_view.dart';
import 'package:shim/features/codex_session/presentation/widgets/codex_sessions_view.dart';
import 'package:shim/features/home/presentation/widgets/backup_library_view.dart';
import 'package:shim/features/home/presentation/widgets/sessions_home_view.dart';

class SessionsTab extends StatelessWidget {
  const SessionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DefaultTabController(
      length: 4,
      child: WorkspaceSurface(
        child: Column(
          children: [
            TabBar(
              tabs: [
                Tab(text: l10n.sessionTabHome),
                Tab(text: l10n.sessionTabBackup),
                Tab(text: l10n.sessionTabClaude),
                Tab(text: l10n.sessionTabCodex),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: const [
                  SessionsHomeView(),
                  BackupLibraryView(),
                  ClaudeSessionsView(),
                  CodexSessionsView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
