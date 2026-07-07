import 'package:shimx/features/codex_session/data/datasources/codex_session_action_datasource.dart';
import 'package:shimx/features/codex_session/domain/models/codex_import_result.dart';
import 'package:shimx/features/codex_session/domain/models/codex_thread_detail.dart';
import 'package:shimx/features/codex_session/domain/repositories/codex_session_action_repository.dart';

class CodexSessionActionRepositoryImpl implements CodexSessionActionRepository {
  final CodexSessionActionDatasource dataSource;

  CodexSessionActionRepositoryImpl({required this.dataSource});

  @override
  Future<String> deleteThread({required String id}) {
    return dataSource.deleteThread(id: id);
  }

  @override
  Future<String?> pickAndExport({
    required CodexThreadDetail detail,
    required String format,
    String? dialogTitle,
  }) {
    return dataSource.pickAndExport(
      detail: detail,
      format: format,
      dialogTitle: dialogTitle,
    );
  }

  @override
  Future<({String? path, int ok, int failed})> pickAndExportBundle({
    required Iterable<CodexThreadDetail> details,
    required String format,
    required String defaultBundleFileName,
    String? dialogTitle,
  }) {
    return dataSource.pickAndExportBundle(
      details: details,
      format: format,
      defaultBundleFileName: defaultBundleFileName,
      dialogTitle: dialogTitle,
    );
  }

  @override
  Future<void> exportToFile({
    required CodexThreadDetail detail,
    required String format,
    required String outputPath,
  }) {
    return dataSource.exportToFile(
      detail: detail,
      format: format,
      outputPath: outputPath,
    );
  }

  @override
  Future<({int ok, int failed})> exportBundleToZip({
    required Iterable<CodexThreadDetail> details,
    required String format,
    required String outputPath,
  }) {
    return dataSource.exportBundleToZip(
      details: details,
      format: format,
      outputPath: outputPath,
    );
  }

  @override
  Future<CodexImportResult?> importSingle({String? targetCwd}) {
    return dataSource.pickAndImportSingle(targetCwd: targetCwd);
  }

  @override
  Future<CodexImportBundleResult?> importBundle({String? targetCwd}) {
    return dataSource.pickAndImportBundle(targetCwd: targetCwd);
  }

  @override
  Future<int> moveThreadsToBucket({
    required List<String> threadIds,
    required String targetBucket,
  }) {
    return dataSource.moveThreadsToBucket(
      threadIds: threadIds,
      targetBucket: targetBucket,
    );
  }
}
