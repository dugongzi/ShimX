import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shim/core/services/app_storage.dart';
import 'package:shim/features/scripts/data/datasources/script_query_datasource.dart';
import 'package:shim/features/scripts/data/repositories/script_query_repository_impl.dart';
import 'package:shim/features/scripts/domain/models/inject_script.dart';
import 'package:shim/features/scripts/domain/repositories/script_query_repository.dart';

part 'script_query_provider.g.dart';

@riverpod
ScriptQueryDatasource scriptQueryDatasource(Ref ref) {
  final appStorage = ref.watch(appStorageProvider);
  return ScriptQueryDatasource(appStorage: appStorage);
}

@riverpod
ScriptQueryRepository scriptQueryRepository(Ref ref) {
  final dataSource = ref.watch(scriptQueryDatasourceProvider);
  return ScriptQueryRepositoryImpl(dataSource: dataSource);
}

@riverpod
Future<List<InjectScript>> scripts(Ref ref) async {
  return ref.read(scriptQueryRepositoryProvider).listScripts();
}

@riverpod
Future<bool> scriptEnabled(Ref ref, {required String id}) async {
  return ref.read(scriptQueryRepositoryProvider).isScriptEnabled(id: id);
}

/// 编辑器 Run 时是否同时刷新 Codex(默认 true)。
@riverpod
Future<bool> reloadOnRun(Ref ref) async {
  return ref.read(scriptQueryRepositoryProvider).isReloadOnRun();
}

/// 手动保存(Ctrl+S)后是否自动 Run(默认 false)。
@riverpod
Future<bool> hotRun(Ref ref) async {
  return ref.read(scriptQueryRepositoryProvider).isHotRun();
}
