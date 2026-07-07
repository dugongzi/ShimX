import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shimx/features/home/data/datasources/inject_query_datasource.dart';
import 'package:shimx/features/home/data/repositories/inject_query_repository_impl.dart';
import 'package:shimx/features/home/domain/repositories/inject_query_repository.dart';
import 'package:url_launcher/url_launcher.dart';

part 'inject_query_provider.g.dart';

/// 找不到 codex page target 时由 openInspector 抛出,widget 层捕获后用 l10n 翻译。
class CodexNotRunningException implements Exception {
  const CodexNotRunningException();

  @override
  String toString() => 'CodexNotRunningException';
}

@riverpod
InjectQueryDatasource injectQueryDatasource(Ref ref) {
  return InjectQueryDatasource();
}

@riverpod
InjectQueryRepository injectQueryRepository(Ref ref) {
  final dataSource = ref.watch(injectQueryDatasourceProvider);
  return InjectQueryRepositoryImpl(dataSource: dataSource);
}

@riverpod
Future<bool> isDebugPortAlive(Ref ref, {required int debugPort}) async {
  return ref
      .read(injectQueryRepositoryProvider)
      .isDebugPortAlive(debugPort: debugPort);
}

/// 找到 devtools URL → 用系统浏览器打开。
/// 未找到时抛 [CodexNotRunningException],widget 层翻译为 l10n.codexNotRunningError。
@riverpod
Future<void> openInspector(Ref ref, {required int debugPort}) async {
  final repo = ref.read(injectQueryRepositoryProvider);
  final url = await repo.findDevtoolsUrl(debugPort: debugPort);
  if (url == null) {
    throw const CodexNotRunningException();
  }
  await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
}

@riverpod
Future<void> waitForDebugPort(Ref ref, {required int debugPort}) async {
  await ref
      .read(injectQueryRepositoryProvider)
      .waitForDebugPort(debugPort: debugPort);
}

@riverpod
Future<String> loadInjectScript(Ref ref) async {
  return ref.read(injectQueryRepositoryProvider).loadInjectScript();
}
