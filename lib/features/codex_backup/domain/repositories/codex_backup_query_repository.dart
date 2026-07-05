import 'package:shim/features/codex_backup/domain/models/codex_backup.dart';
import 'package:shim/features/codex_backup/domain/models/codex_backup_detail.dart';

abstract class CodexBackupQueryRepository {
  /// 只扫备份目录,拿到分页后的 backupId 列表(按时间倒序)。
  Future<List<String>> listBackupIds({int limit = 30, int offset = 0});

  /// 单条备份的摘要(不包含 entries 详情)。列表 tile 用。
  Future<CodexBackup?> readSummary(String backupId);

  /// 指定备份的详情(带 entries 列表)。展开 tile 才用。
  Future<CodexBackupDetail?> readDetail(String backupId);
}
