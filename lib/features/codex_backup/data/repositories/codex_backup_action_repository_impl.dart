import 'package:shimx/features/codex_backup/data/datasources/codex_backup_action_datasource.dart';
import 'package:shimx/features/codex_backup/domain/repositories/codex_backup_action_repository.dart';

class CodexBackupActionRepositoryImpl implements CodexBackupActionRepository {
  CodexBackupActionRepositoryImpl({required this.dataSource});

  final CodexBackupActionDatasource dataSource;

  @override
  Future<String> createBackup(List<String> threadIds) =>
      dataSource.createBackup(threadIds);

  @override
  Future<int> restoreBackup({
    required String backupId,
    List<String>? entryIds,
  }) =>
      dataSource.restoreBackup(backupId: backupId, entryIds: entryIds);

  @override
  Future<void> deleteBackup(String backupId) => dataSource.deleteBackup(backupId);
}
