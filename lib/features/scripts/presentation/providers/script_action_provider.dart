import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shim/core/services/app_storage.dart';
import 'package:shim/features/scripts/data/datasources/script_action_datasource.dart';
import 'package:shim/features/scripts/data/repositories/script_action_repository_impl.dart';
import 'package:shim/features/scripts/domain/repositories/script_action_repository.dart';

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

/// 弹文件选择器导入 .js。用户取消返回 null。
///
/// 注:副作用(invalidate scriptsProvider)由调用方在 `await` 后自己触发。
/// 因为 `@riverpod Future<T>` action provider 在 `.future` 完成后会被立刻
/// dispose,在里头 `ref.invalidate` 会命中 "Ref after disposed" 断言。
@riverpod
Future<String?> importScript(Ref ref) async {
  return ref.read(scriptActionRepositoryProvider).importScript();
}

@riverpod
Future<void> deleteScripts(
  Ref ref, {
  required Iterable<String> ids,
}) async {
  final repo = ref.read(scriptActionRepositoryProvider);
  for (final id in ids) {
    await repo.deleteScript(id: id);
  }
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
}

/// 保存脚本代码。返回 false 表示文件不存在。
@riverpod
Future<bool> saveScript(
  Ref ref, {
  required String id,
  required String code,
}) async {
  return ref
      .read(scriptActionRepositoryProvider)
      .saveScript(id: id, code: code);
}

/// 创建新脚本。返回写入的文件名(id)。
@riverpod
Future<String> createScript(
  Ref ref, {
  required String name,
  required String code,
}) async {
  return ref
      .read(scriptActionRepositoryProvider)
      .createScript(name: name, code: code);
}

@riverpod
Future<void> setReloadOnRun(Ref ref, {required bool value}) async {
  await ref.read(scriptActionRepositoryProvider).setReloadOnRun(value: value);
}

@riverpod
Future<void> setHotRun(Ref ref, {required bool value}) async {
  await ref.read(scriptActionRepositoryProvider).setHotRun(value: value);
}
