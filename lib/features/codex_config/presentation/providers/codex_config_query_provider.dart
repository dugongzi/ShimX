import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:shimx/features/codex_config/data/datasources/codex_config_query_datasource.dart';
import 'package:shimx/features/codex_config/data/repositories/codex_config_query_repository_impl.dart';
import 'package:shimx/features/codex_config/domain/repositories/codex_config_query_repository.dart';

part 'codex_config_query_provider.g.dart';

@riverpod
CodexConfigQueryDatasource codexConfigQueryDatasource(Ref ref) {
  return const CodexConfigQueryDatasource();
}

@riverpod
CodexConfigQueryRepository codexConfigQueryRepository(Ref ref) {
  final ds = ref.watch(codexConfigQueryDatasourceProvider);
  return CodexConfigQueryRepositoryImpl(dataSource: ds);
}

/// 当前 codex config.toml 里的 `model_provider`,给首页顶部条使用。
/// autoDispose 让页面关掉后不再持有,重新进入会 refresh。
@riverpod
Future<String?> codexModelProvider(Ref ref) async {
  final repo = ref.watch(codexConfigQueryRepositoryProvider);
  return repo.readModelProvider();
}
