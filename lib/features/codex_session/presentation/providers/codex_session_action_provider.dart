import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shim/core/services/bridge_service.dart';
import 'package:shim/features/codex_session/data/datasources/codex_session_action_datasource.dart';
import 'package:shim/features/codex_session/data/repositories/codex_session_action_repository_impl.dart';
import 'package:shim/features/codex_session/domain/repositories/codex_session_action_repository.dart';

part 'codex_session_action_provider.g.dart';

@riverpod
CodexSessionActionRepository codexSessionActionRepository(Ref ref) {
  return CodexSessionActionRepositoryImpl(
    dataSource: CodexSessionActionDatasource(),
  );
}

@riverpod
Future<String> deleteCodexThread(Ref ref, {required String id}) async {
  return ref.read(codexSessionActionRepositoryProvider).deleteThread(id: id);
}

/// 把 action 路由注册到 bridge
@Riverpod(keepAlive: true)
bool codexSessionActionRouteRegistration(Ref ref) {
  final bridge = ref.read(bridgeServiceProvider);
  final repo = ref.read(codexSessionActionRepositoryProvider);

  bridge.register('/session/delete', (payload) async {
    final id = (payload['id'] as String?)?.trim();
    if (id == null || id.isEmpty) {
      throw ArgumentError('missing id');
    }
    final backupPath = await repo.deleteThread(id: id);
    return {'backupPath': backupPath};
  });

  return true;
}
