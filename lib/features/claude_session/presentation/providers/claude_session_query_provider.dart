import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shim/core/services/bridge_service.dart';
import 'package:shim/features/claude_session/data/datasources/claude_session_query_datasource.dart';
import 'package:shim/features/claude_session/data/repositories/claude_session_query_repository_impl.dart';
import 'package:shim/features/claude_session/domain/models/claude_project.dart';
import 'package:shim/features/claude_session/domain/models/claude_thread.dart';
import 'package:shim/features/claude_session/domain/repositories/claude_session_query_repository.dart';

part 'claude_session_query_provider.g.dart';

@riverpod
ClaudeSessionQueryRepository claudeSessionQueryRepository(Ref ref) {
  return ClaudeSessionQueryRepositoryImpl(
    dataSource: ClaudeSessionQueryDatasource(),
  );
}

@riverpod
Future<List<ClaudeProject>> listClaudeProjects(Ref ref) async {
  return ref.read(claudeSessionQueryRepositoryProvider).listProjects();
}

@riverpod
Future<List<ClaudeThread>> listClaudeThreads(
  Ref ref, {
  required String encodedDir,
  int limit = 200,
}) async {
  return ref
      .read(claudeSessionQueryRepositoryProvider)
      .listThreads(encodedDir: encodedDir, limit: limit);
}

/// 把 Claude 会话查询路由注册到 bridge,供 codex_enhance.js 的侧栏折叠列表调用。
///
/// /claude-session/projects        → 列出全部 Claude Code 项目分组
/// /claude-session/threads         → payload.encodedDir 必填,列该项目下会话
@Riverpod(keepAlive: true)
bool claudeSessionRouteRegistration(Ref ref) {
  final bridge = ref.read(bridgeServiceProvider);
  final repo = ref.read(claudeSessionQueryRepositoryProvider);

  bridge.register('/claude-session/projects', (payload) async {
    final projects = await repo.listProjects();
    return {
      'projects': projects
          .map((p) => {
                'encodedDir': p.encodedDir,
                'cwd': p.cwd,
                'sessionCount': p.sessionCount,
                'lastActiveMs': p.lastActiveMs,
              })
          .toList(),
    };
  });

  bridge.register('/claude-session/threads', (payload) async {
    final encodedDir = (payload['encodedDir'] as String?)?.trim();
    if (encodedDir == null || encodedDir.isEmpty) {
      throw ArgumentError('missing encodedDir');
    }
    final limit = (payload['limit'] as int?) ?? 200;
    final threads =
        await repo.listThreads(encodedDir: encodedDir, limit: limit);
    return {
      'threads': threads
          .map((t) => {
                'sessionId': t.sessionId,
                'jsonlPath': t.jsonlPath,
                'title': t.title,
                'cwd': t.cwd,
                'gitBranch': t.gitBranch,
                'updatedAtMs': t.updatedAtMs,
              })
          .toList(),
    };
  });

  return true;
}
