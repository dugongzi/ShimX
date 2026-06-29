import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shim/core/services/app_storage.dart';
import 'package:shim/features/scripts/data/datasources/script_action_datasource.dart';
import 'package:shim/features/scripts/data/repositories/script_action_repository_impl.dart';
import 'package:shim/features/scripts/domain/repositories/script_action_repository.dart';
import 'package:shim/features/scripts/presentation/providers/script_query_provider.dart';

part 'script_action_provider.g.dart';

@riverpod
ScriptActionDatasource scriptActionDatasource(Ref ref) {
  return ScriptActionDatasource(appStorage: ref.watch(appStorageProvider));
}

@riverpod
ScriptActionRepository scriptActionRepository(Ref ref) {
  return ScriptActionRepositoryImpl(
    dataSource: ref.watch(scriptActionDatasourceProvider),
  );
}

/// 弹文件选择器导入 .js;成功后 invalidate 列表。用户取消返回 null。
@riverpod
Future<String?> importScript(Ref ref) async {
  final id = await ref.read(scriptActionRepositoryProvider).importScript();
  if (id != null) {
    ref.invalidate(scriptsProvider);
  }
  return id;
}

@riverpod
Future<void> deleteScripts(
  Ref ref, {
  required Iterable<String> ids,
}) async {
  final repo = ref.read(scriptActionRepositoryProvider);
  for (final id in ids) {
    await repo.deleteScript(id: id);
    ref.invalidate(scriptEnabledProvider(id: id));
  }
  ref.invalidate(scriptsProvider);
}

@riverpod
Future<void> setScriptsEnabled(
  Ref ref, {
  required Iterable<String> ids,
  required bool enabled,
}) async {
  await ref
      .read(scriptActionRepositoryProvider)
      .setEnabled(ids: ids, enabled: enabled);
  for (final id in ids) {
    ref.invalidate(scriptEnabledProvider(id: id));
  }
}
