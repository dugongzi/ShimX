import 'package:shimx/features/codex_backup/data/datasources/codex_backup_query_datasource.dart';
import 'package:shimx/features/codex_backup/domain/models/codex_backup.dart';
import 'package:shimx/features/codex_backup/domain/models/codex_backup_detail.dart';
import 'package:shimx/features/codex_backup/domain/repositories/codex_backup_query_repository.dart';

class CodexBackupQueryRepositoryImpl implements CodexBackupQueryRepository {
  CodexBackupQueryRepositoryImpl({required this.dataSource});

  final CodexBackupQueryDatasource dataSource;

  @override
  Future<List<String>> listBackupIds({int limit = 30, int offset = 0}) =>
      dataSource.listBackupIds(limit: limit, offset: offset);

  @override
  Future<CodexBackup?> readSummary(String backupId) async {
    final dto = await dataSource.readSummary(backupId);
    return dto?.toEntity();
  }

  @override
  Future<CodexBackupDetail?> readDetail(String backupId) async {
    final dto = await dataSource.readDetail(backupId);
    return dto?.toEntity();
  }
}
