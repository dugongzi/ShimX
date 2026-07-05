import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:shim/features/codex_backup/data/datasources/codex_backup_query_datasource.dart';
import 'package:shim/features/codex_backup/data/repositories/codex_backup_query_repository_impl.dart';
import 'package:shim/features/codex_backup/domain/models/codex_backup.dart';
import 'package:shim/features/codex_backup/domain/models/codex_backup_detail.dart';
import 'package:shim/features/codex_backup/domain/repositories/codex_backup_query_repository.dart';

part 'codex_backup_query_provider.g.dart';

@riverpod
CodexBackupQueryDatasource codexBackupQueryDatasource(Ref ref) {
  return const CodexBackupQueryDatasource();
}

@riverpod
CodexBackupQueryRepository codexBackupQueryRepository(Ref ref) {
  final ds = ref.watch(codexBackupQueryDatasourceProvider);
  return CodexBackupQueryRepositoryImpl(dataSource: ds);
}

/// 首屏拿分页后的 backupId,不打开 manifest。列表 tile 各自异步拉自己的 summary。
@riverpod
Future<List<String>> codexBackupIds(
  Ref ref, {
  int limit = 30,
  int offset = 0,
}) {
  return ref
      .watch(codexBackupQueryRepositoryProvider)
      .listBackupIds(limit: limit, offset: offset);
}

/// 单条备份的摘要(不含 entries),用于列表 tile 头部显示。
@riverpod
Future<CodexBackup?> codexBackupSummary(
  Ref ref, {
  required String backupId,
}) {
  return ref
      .watch(codexBackupQueryRepositoryProvider)
      .readSummary(backupId);
}

/// 单条备份的详情(含 entries),只在展开 tile 时才用。
@riverpod
Future<CodexBackupDetail?> codexBackupDetail(
  Ref ref, {
  required String backupId,
}) {
  return ref
      .watch(codexBackupQueryRepositoryProvider)
      .readDetail(backupId);
}
