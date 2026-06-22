import 'dart:io';

import 'package:shim/features/codex_session/data/datasources/codex_session_export_datasource.dart';
import 'package:shim/core/utils/codex_session_export_formatter.dart';
import 'package:shim/features/codex_session/domain/models/codex_thread_detail.dart';
import 'package:shim/features/codex_session/domain/repositories/codex_session_export_repository.dart';

class CodexSessionExportRepositoryImpl implements CodexSessionExportRepository {
  final CodexSessionExportDatasource dataSource;
  final CodexSessionExportFormatter formatter;

  CodexSessionExportRepositoryImpl({
    required this.dataSource,
    required this.formatter,
  });

  @override
  Future<CodexThreadDetail> loadThreadDetail({required String id}) async {
    final dto = await dataSource.loadDetail(id: id);
    return dto.toEntity();
  }

  @override
  Future<void> exportToFile({
    required CodexThreadDetail detail,
    required String format,
    required String outputPath,
  }) async {
    switch (format) {
      case 'raws':
        // 直接拷贝原始 rollout JSONL,不重新拼
        if (detail.rolloutPath.isEmpty) {
          throw StateError('rollout path is empty');
        }
        final src = File(detail.rolloutPath);
        if (!await src.exists()) {
          throw StateError('rollout file not found: ${detail.rolloutPath}');
        }
        await src.copy(outputPath);
        return;
      case 'markdown':
        final md = formatter.renderMarkdown(detail);
        await File(outputPath).writeAsString(md);
        return;
      default:
        throw ArgumentError('unsupported format: $format');
    }
  }
}
