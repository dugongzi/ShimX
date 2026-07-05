import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:shim/features/codex_backup/data/datasources/codex_backup_action_datasource.dart';
import 'package:shim/features/codex_backup/data/repositories/codex_backup_action_repository_impl.dart';
import 'package:shim/features/codex_backup/domain/repositories/codex_backup_action_repository.dart';

part 'codex_backup_action_provider.g.dart';

@riverpod
CodexBackupActionDatasource codexBackupActionDatasource(Ref ref) {
  return const CodexBackupActionDatasource();
}

@riverpod
CodexBackupActionRepository codexBackupActionRepository(Ref ref) {
  final ds = ref.watch(codexBackupActionDatasourceProvider);
  return CodexBackupActionRepositoryImpl(dataSource: ds);
}
