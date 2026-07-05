abstract class CodexBackupActionRepository {
  /// 备份给定 threadIds,返回 backupId(空串表示没备份到任何东西)。
  Future<String> createBackup(List<String> threadIds);

  /// 恢复 backupId 下部分或全部 entry。entryIds=null 表示全部。返回处理条数。
  Future<int> restoreBackup({
    required String backupId,
    List<String>? entryIds,
  });

  Future<void> deleteBackup(String backupId);
}
