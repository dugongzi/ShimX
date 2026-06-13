import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shim/core/services/bridge_service.dart';
import 'package:shim/features/codex_session/data/datasources/codex_session_query_datasource.dart';
import 'package:shim/features/codex_session/data/repositories/codex_session_query_repository_impl.dart';
import 'package:shim/features/codex_session/domain/models/codex_thread.dart';
import 'package:shim/features/codex_session/domain/repositories/codex_session_query_repository.dart';

part 'codex_session_query_provider.g.dart';

@riverpod
CodexSessionQueryRepository codexSessionQueryRepository(Ref ref) {
  return CodexSessionQueryRepositoryImpl(
    dataSource: CodexSessionQueryDatasource(),
  );
}

@riverpod
Future<List<CodexThread>> listCodexThreads(Ref ref, {int limit = 100}) async {
  return ref
      .read(codexSessionQueryRepositoryProvider)
      .listThreads(limit: limit);
}

/// 把会话相关路由注册到 bridge。在 app 启动时 watch 一次让它生效。
@Riverpod(keepAlive: true)
bool codexSessionRouteRegistration(Ref ref) {
  final bridge = ref.read(bridgeServiceProvider);
  final repo = ref.read(codexSessionQueryRepositoryProvider);

  bridge.register('/session/list', (payload) async {
    final limit = (payload['limit'] as int?) ?? 100;
    final threads = await repo.listThreads(limit: limit);
    return {
      'threads': threads
          .map((t) => {
                'id': t.id,
                'title': t.title,
                'preview': t.preview,
                'firstUserMessage': t.firstUserMessage,
                'cwd': t.cwd,
                'archived': t.archived,
                'updatedAtMs': t.updatedAtMs,
                'createdAtMs': t.createdAtMs,
                'tokensUsed': t.tokensUsed,
              })
          .toList(),
    };
  });

  return true;
}
