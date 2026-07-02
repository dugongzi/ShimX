import 'dart:async';
import 'dart:io';

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

/// watch 脚本目录的文件系统事件。用于让 UI 感知外部编辑器改动。
/// 磁盘无该目录时静默不发,一旦目录出现或被删又建都会自动重订阅。
/// 事件不带具体路径含义(平台差异大),订阅方拿到就 invalidate + 对比 mtime/内容。
@riverpod
Stream<FileSystemEvent> scriptsDirWatch(Ref ref) async* {
  final datasource = ref.watch(scriptQueryDatasourceProvider);
  final dir = await datasource.scriptsDir();
  if (!await dir.exists()) return;
  // recursive:false 就够了,脚本都是平铺 .js。
  final sub = dir.watch();
  yield* sub;
}
