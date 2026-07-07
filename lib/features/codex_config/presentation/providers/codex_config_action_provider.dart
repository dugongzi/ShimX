import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:shimx/features/codex_config/data/datasources/codex_config_action_datasource.dart';
import 'package:shimx/features/codex_config/data/repositories/codex_config_action_repository_impl.dart';
import 'package:shimx/features/codex_config/domain/repositories/codex_config_action_repository.dart';

part 'codex_config_action_provider.g.dart';

@riverpod
CodexConfigActionDatasource codexConfigActionDatasource(Ref ref) {
  return const CodexConfigActionDatasource();
}

@riverpod
CodexConfigActionRepository codexConfigActionRepository(Ref ref) {
  final ds = ref.watch(codexConfigActionDatasourceProvider);
  return CodexConfigActionRepositoryImpl(dataSource: ds);
}
